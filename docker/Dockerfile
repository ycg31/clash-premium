FROM alpine:latest AS builder
ARG CLASH_PREMIUM_VERSION
WORKDIR /out
COPY docker-entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
RUN apk add --update --no-cache curl gzip \
    && baseArch=$(cat /etc/apk/arch | sed "{s/x86_64/amd64/; s/aarch64/armv8/}") \
    && curl -sSL https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-${baseArch}-${CLASH_PREMIUM_VERSION}.gz -o clash.gz \
    && curl -sSL https://github.com/haishanh/yacd/releases/latest/download/yacd.tar.xz -o yacd.tar.xz \
    && curl -sSL https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb -o Country.mmdb
RUN gzip -d clash.gz && chmod 777 clash
RUN tar -xvJf yacd.tar.xz


FROM alpine:latest
LABEL container.maintainer="xtoys <echoless@yeah.net>"
ENV SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    TZ=Asia/Shanghai

COPY --from=builder /out/clash /usr/bin/clash
COPY --from=builder /out/public /clash/ui
COPY --from=builder /out/Country.mmdb /clash/Country.mmdb
COPY --from=builder /out/entrypoint.sh /usr/bin/

RUN apk add --update --no-cache \
       bash \
       tini \
       tzdata \
       ca-certificates

WORKDIR /clash
ENTRYPOINT ["tini","--","entrypoint.sh"]