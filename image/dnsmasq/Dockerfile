FROM alpine
ADD ./gfwlist2dnsmasq.sh /usr/local/bin/gfwlist2dnsmasq
ENV PROXY_PORT=45353
RUN apk --no-cache add dnsmasq && \
  mkdir -p /etc/default/ && \
  echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq && \
  gfwlist2dnsmasq -p $PROXY_PORT -o /etc/dnsmasq.d/gfwlist.conf
COPY dnsmasq.conf /etc/dnsmasq.conf
CMD dnsmasq -d -C /etc/dnsmasq.conf
