# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
ARG SRCARCH
ARG VERSION
#
ENV \
    SSHWIFTY_CONFIG=/config/sshwifty.conf.json
#
RUN set -ex \
    && apk add -Uu --no-cache \
        ca-certificates \
        curl \
        # gcompat \
        tzdata \
    && echo "Using version: $SRCARCH / $VERSION" \
    && curl \
        -o /tmp/sshwifty_${VERSION}_${SRCARCH}.tar.gz \
        -jSLN https://github.com/nirui/sshwifty/releases/download/${VERSION}/sshwifty_${VERSION%%-prebuild}_${SRCARCH}.tar.gz \
    && tar -xzf /tmp/sshwifty_${VERSION}_${SRCARCH}.tar.gz -C /usr/local/bin \
    && mv /usr/local/bin/sshwifty_${SRCARCH} /usr/local/bin/sshwifty \
    # && mkdir -p ${SSHWIFTY_ROOT} /defaults \
    # && mv /usr/local/bin/sshwifty.conf.example.json /defaults/ \
    # && curl -o ${SSHWIFTY_CONFIG} -SL \
    #     https://raw.githubusercontent.com/nirui/sshwifty/master/sshwifty.conf.example.json \
    # && chown -R ${S6_USER:-alpine}:${S6_USER:-alpine} ${SSHWIFTY_ROOT} \
    && apk del --purge curl \
    && rm -rf /var/cache/apk/* /tmp/*
#
COPY root/ /
#
VOLUME /config
# WORKDIR /config
#
EXPOSE 8182
#
HEALTHCHECK \
    --interval=2m \
    --retries=5 \
    --start-period=5m \
    --timeout=10s \
    CMD \
    wget -q -T '2' -O /dev/null ${HEALTHCHECK_URL:-"http://localhost:8182/"} || exit 1
#
ENTRYPOINT ["/init"]
