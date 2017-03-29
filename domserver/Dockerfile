FROM debian:jessie

MAINTAINER Mathias Weber <m_weber@cs.uni-kl.de>

RUN export DEBIAN_FRONTEND=noninteractive && export BUILDDEPS="\
        gcc g++ make bsdmainutils patch \
        linuxdoc-tools linuxdoc-tools-text \
        groff texlive-latex-recommended texlive-latex-extra \
        texlive-fonts-recommended texlive-lang-dutch curl autoconf automake" && \
    export RUNDEPS="apache2 php5 php5-cli libapache2-mod-php5 \
        php5-gd php5-curl php5-mysql php5-json \
        ntp mysql-client ca-certificates unzip zip" && \
    apt-get update && apt-get install -y --no-install-recommends $BUILDDEPS $RUNDEPS

ADD . /src/TUKLjudge-master/

WORKDIR /src/TUKLjudge-master/

RUN make configure && /src/TUKLjudge-master/configure --disable-submitclient && make domserver && make install-domserver && \
    cd /opt/domjudge/domserver && \
    rm -rf /src && \
    apt-get purge -y $BUILDDEPS && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    chgrp -R www-data /opt/domjudge && chmod -R g+w /opt/domjudge && \
    cp /opt/domjudge/domserver/etc/apache.conf /etc/apache2/sites-available/domjudge.conf && a2dissite 000-default && a2ensite domjudge

EXPOSE 80

COPY domserver/start.sh /usr/local/bin/start.sh
COPY domserver/apache2-foreground.sh /usr/local/bin/apache2-foreground.sh

ENTRYPOINT ["start.sh"]
CMD ["apache2-foreground.sh"]
