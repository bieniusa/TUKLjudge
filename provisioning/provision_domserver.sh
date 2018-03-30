#!/bin/bash

# Variables for customizations
export MYSQL_ROOT_PASSWORD="securepassword"
export DOMJUDGE_DB_NAME="domjudge"
export DOMJUDGE_DB_USER="domjudge"
export DOMJUDGE_DB_PASSWORD="domjudge"
export DOMSERVER_PASSWORD="judgehostpw" # this is the password for the judgehosts

# Installation procedure
export DEBIAN_FRONTEND=noninteractive
export BUILDDEPS="\
    git gcc g++ make bsdmainutils patch \
    linuxdoc-tools linuxdoc-tools-text \
    groff texlive-latex-recommended texlive-latex-extra \
    texlive-fonts-recommended curl autoconf automake"
export RUNDEPS="apache2 php7.0 php7.0-cli libapache2-mod-php7.0 \
    php7.0-gd php7.0-curl php7.0-mysql php7.0-json php7.0-mbstring \
    mysql-client ca-certificates unzip zip"
export MYSQLDEPS="default-mysql-server"
apt-get update
apt-get install -y --no-install-recommends $BUILDDEPS $RUNDEPS $MYSQLDEPS

cat <<EOF > /etc/mysql/conf.d/domjudge.cnf
[mysqld]
max_connections=300
max_allowed_packet=100M
EOF

mysql -u root << EOF
FLUSH PRIVILEGES;
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PASSWORD');
EOF

cat <<EOF > /root/.my.cnf
[client]
user=root
password=$MYSQL_ROOT_PASSWORD
EOF
chmod 0600 /root/.my.cnf

mkdir -p /src && cd /src
git clone https://github.com/bieniusa/TUKLjudge.git
cd TUKLjudge
make configure && ./configure --disable-submitclient && make domserver && make install-domserver
cd /opt/domjudge/domserver
chgrp -R www-data /opt/domjudge && chmod -R g+w /opt/domjudge
cp /opt/domjudge/domserver/etc/apache.conf /etc/apache2/sites-available/domjudge.conf && a2dissite 000-default && a2ensite domjudge
cp /src/TUKLjudge/domserver/php.ini /etc/php/7.0/apache2/php.ini
printf "dummy:%s:%s:%s:%s\n" localhost $DOMJUDGE_DB_NAME $DOMJUDGE_DB_USER $DOMJUDGE_DB_PASSWORD > /opt/domjudge/domserver/etc/dbpasswords.secret
/opt/domjudge/domserver/bin/dj-setup-database -u root -p"$MYSQL_ROOT_PASSWORD" bare-install

HASHED_PASS=$(printf '%s' "judgehost#$DOMSERVER_PASSWORD" | md5sum | cut -d ' ' -f 1)

mysql $DOMJUDGE_DB_NAME <<EOF
UPDATE user SET password='$HASHED_PASS' WHERE username='judgehost'
EOF

systemctl reload apache2
