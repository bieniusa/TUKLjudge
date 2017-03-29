FROM debian:stretch

MAINTAINER Mathias Weber <m_weber@cs.uni-kl.de>

RUN export DEBIAN_FRONTEND=noninteractive && export BUILDDEPS="\
        make curl autoconf automake patch" && \
    export RUNDEPS="unzip php7.0-cli php7.0-curl php7.0-json procps sudo \
        gcc g++ openjdk-8-jre-headless openjdk-8-jdk-headless \
        fp-compiler ghc ca-certificates libcgroup-dev python python3" && \
    apt-get update && apt-get install -y --no-install-recommends $BUILDDEPS $RUNDEPS && \
    useradd -d / -s /bin/false domjudge

ADD . /src/TUKLjudge-master/

RUN cd /src/TUKLjudge-master && \
    make configure && /src/TUKLjudge-master/configure --with-domjudge-user=domjudge --disable-submitclient && make judgehost && make install-judgehost && \
    cd /opt/domjudge/judgehost && \
    rm -rf /src && \
    apt-get purge -y $BUILDDEPS && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    useradd -d / -g nogroup -s /bin/false domjudge-run && \
    cp /opt/domjudge/judgehost/etc/sudoers-domjudge /etc/sudoers.d/ && \
    sed -i 's/true/false/g' /opt/domjudge/judgehost/etc/judgehost-config.php && \
    mkdir /cgroup

COPY judgehost/start.sh /usr/local/bin/start.sh

ENTRYPOINT ["start.sh"]
CMD ["/opt/domjudge/judgehost/bin/judgedaemon"]
