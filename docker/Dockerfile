FROM alpine:latest AS builder
RUN apk add --no-cache git wget
    # geoip-db
ADD https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb  /clash/Country.mmdb
    # yacd-ui
RUN wget -O yacd.zip 'https://github.com/haishanh/yacd/archive/gh-pages.zip' \
    && mkdir /clash/ui \
    && unzip yacd.zip -d /clash/ui \
    && mv /clash/ui/yacd-gh-pages/* /clash/ui \
    && rm -rf /clash/ui/yacd-gh-pages


FROM alpine:3.14
LABEL container.maintainer="xtoys <echoless@yeah.net>" \
      container.sourceCode="https://github.com/Dreamacro/clash"

ENV SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    TZ=Asia/Shanghai \
    WORKSPACE=/root/.config/clash

COPY --from=dreamacro/clash-premium:latest /clash /usr/bin/clash
COPY --from=builder /clash /root/.config/clash
COPY s6-overlay /

RUN apk update -f \
    && apk --no-cache add -f \
       bash \
       tzdata \
       iptables \
       s6-overlay \
       ca-certificates \
    && rm -rf /var/cache/apk/* \
    && chmod -R +x /etc/cont-init.d \
    && chmod -R +x /etc/services.d

WORKDIR $WORKSPACE
ENTRYPOINT ["/init"]