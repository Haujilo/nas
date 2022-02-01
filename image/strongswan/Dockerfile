FROM alpine:edge

RUN apk --no-cache add --update \
    strongswan \
    ca-certificates \
    && rm -rf /var/cache/apk/*

EXPOSE 500/udp 4500/udp

CMD ipsec start --nofork
