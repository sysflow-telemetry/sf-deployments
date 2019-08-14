FROM ubuntu:18.04

RUN apt-get update -yqq && \
    apt-get upgrade -yqq && \
    apt-get install -yqq \
    nodejs \
    npm \
    apache2-utils \
    python3-pip && \
    apt-get clean -yqq && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/apt/archive/*

COPY modules/attack /build/
COPY modules/loadtest /build/
COPY modules/loadconfig.cfg /build/
RUN  cd /build && npm install
WORKDIR /build/

CMD ["/build/test-harness.py", "--config", "/build/loadconfig.cfg"]
