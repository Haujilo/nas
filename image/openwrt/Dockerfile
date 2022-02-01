FROM haujilo/openwrt:rootfs

ADD ./iproute /etc/hotplug.d/iface/10-iproute
ADD ./network-default.uci /etc/uci-defaults/99_network_default

RUN mkdir /var/lock && \
    /etc/init.d/odhcpd disable && \
    /etc/init.d/dnsmasq disable && \
    /etc/init.d/dropbear disable && \
    /etc/init.d/sysntpd disable && \
    opkg update && \
    opkg install ip-full iptables-mod-tproxy uhttpd-mod-lua && \
    uci set uhttpd.main.interpreter='.lua=/usr/bin/lua' && \
    uci commit uhttpd

CMD ["/sbin/init"]
