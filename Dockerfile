FROM alpine:3.18.5@sha256:d695c3de6fcd8cfe3a6222b0358425d40adfd129a8a47c3416faff1a8aece389

LABEL repository="https://github.com/dan-is-not-the-man/dnscontrol-action"
LABEL maintainer="dan <github-action.h9wkl@slmail.me>"

LABEL "com.github.actions.name"="DNSControl"
LABEL "com.github.actions.description"="Deploy your DNS configuration to multiple providers."
LABEL "com.github.actions.icon"="globe"
LABEL "com.github.actions.color"="blue"

ENV DNSCONTROL_VERSION="4.8.2"
ENV DNSCONTROL_CHECKSUM="883a056fdccb30cbcd280120e36739b8f749fba6eaacb9ca03cdc87c3942a583"
ENV USER=dnscontrol-user

RUN apk -U --no-cache upgrade && \
    apk add --no-cache bash ca-certificates curl libc6-compat tar

RUN  addgroup -S dnscontrol-user && adduser -S dnscontrol-user -G dnscontrol-user --disabled-password

RUN curl -sL "https://github.com/StackExchange/dnscontrol/releases/download/v${DNSCONTROL_VERSION}/dnscontrol_${DNSCONTROL_VERSION}_linux_amd64.tar.gz" \
    -o dnscontrol && \
    echo "$DNSCONTROL_CHECKSUM  dnscontrol" | sha256sum -c - && \
    tar xvf dnscontrol

RUN chown dnscontrol-user:dnscontrol-user  dnscontrol

RUN chmod +x dnscontrol && \
    chmod 755 dnscontrol && \
    cp dnscontrol /usr/local/bin/dnscontrol
    
RUN ["dnscontrol", "version"]

COPY README.md entrypoint.sh bin/filter-preview-output.sh /
ENTRYPOINT ["/entrypoint.sh"]
