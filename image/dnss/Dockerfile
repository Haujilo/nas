FROM golang as builder
ARG DEBIAN_FRONTEND=noninteractive
ARG GO111MODULE=on
ARG GOPROXY=https://goproxy.cn,direct
RUN apt-get update -q && apt-get install -y -q knot-dnsutils systemd
RUN go env -w GO111MODULE=${GO111MODULE} && go env -w GOPROXY=${GOPROXY}
RUN GOBIN=/ go get -v -ldflags '-extldflags "-static"' blitiri.com.ar/go/dnss && chmod a+x /dnss

FROM busybox:stable-glibc
COPY --from=builder /dnss /usr/local/bin/
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
ENV CACHE=false
ENV PORT=:53
ENV DNS_UPSTREAM=119.29.29.29
ENV HTTPS_UPSTREAM=https://doh.pub/dns-query
CMD /usr/local/bin/dnss --enable_dns_to_https --enable_cache=${CACHE} --dns_listen_addr=${PORT} --dns_upstream=${DNS_UPSTREAM} --https_upstream=${HTTPS_UPSTREAM}
