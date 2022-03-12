FROM hwdsl2/ipsec-vpn-server:latest

RUN set -xe && \
    apk add --no-cache supervisor tinyproxy tor i2pd bind-tools ca-certificates openssl dumb-init &&\
    update-ca-certificates

# coredns

ARG COREDNS_VERSION=1.9.0

RUN apk add --no-cache curl && \
    curl --silent --show-error --fail --location \
    --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
    "https://github.com/coredns/coredns/releases/download/v${COREDNS_VERSION}/coredns_${COREDNS_VERSION}_linux_amd64.tgz" \
    | tar --no-same-owner -C /usr/bin/ -xz coredns &&\
    apk del curl &&\
    chmod 0755 /usr/bin/coredns  &&\
    /usr/bin/coredns -version

# tinyproxy tor i2pd

COPY ./tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY ./supervisord.conf /etc/supervisord.conf
COPY ./Corefile /etc/coredns/Corefile

RUN cp /etc/tor/torrc.sample /etc/tor/torrc

ENTRYPOINT ["dumb-init"]

#CMD ["/usr/bin/coredns", "-conf", "/etc/coredns/Corefile"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
