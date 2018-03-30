#!/bin/bash

# Variables for customizations
export DOMSERVER_HOST="http://192.168.50.2/domjudge/api"
export DOMSERVER_USER="judgehost"
export DOMSERVER_PASSWORD="judgehostpw"

# Installation procedure
export DEBIAN_FRONTEND=noninteractive
export BUILDDEPS="\
make curl autoconf automake patch git"
export RUNDEPS="debootstrap unzip php7.0-cli php7.0-curl php7.0-json procps sudo \
gcc g++ openjdk-8-jre-headless openjdk-8-jdk-headless \
fp-compiler ghc ca-certificates libcgroup-dev python python3"
apt-get update
apt-get install -y --no-install-recommends $BUILDDEPS $RUNDEPS
useradd -d / -s /bin/false domjudge
mkdir -p /src && cd /src
git clone https://github.com/bieniusa/TUKLjudge.git
cd TUKLjudge
sed -i 's/openjdk-7-jre-headless/openjdk-8-jre-headless/g' misc-tools/dj_make_chroot.in
make configure && ./configure --with-domjudge-user=domjudge --disable-submitclient && make judgehost && make install-judgehost
cd /opt/domjudge/judgehost
useradd -d / -g nogroup -s /bin/false domjudge-run
cp /opt/domjudge/judgehost/etc/sudoers-domjudge /etc/sudoers.d/
mkdir /cgroup

printf "default\t%s\t%s\t%s\n" $DOMSERVER_HOST $DOMSERVER_USER $DOMSERVER_PASSWORD > /opt/domjudge/judgehost/etc/restapi.secret

./bin/dj_make_chroot

cat <<EOF > /opt/domjudge/judgehost/bin/init.sh
#!/bin/bash

/opt/domjudge/judgehost/bin/create_cgroups
sudo -u domjudge /opt/domjudge/judgehost/bin/judgedaemon
EOF
chmod a+x /opt/domjudge/judgehost/bin/init.sh

cat <<EOF > /etc/systemd/system/judgehost.service
[Unit]
Description=TUKLjudge judgehost

After=network.target

[Service]
ExecStart=/opt/domjudge/judgehost/bin/init.sh
Type=simple

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl enable judgehost
systemctl start judgehost
