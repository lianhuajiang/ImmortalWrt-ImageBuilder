#!/bin/sh
# === USB WAN 预配置：首次开机执行一次 ===
uci -q get network.usbwan >/dev/null || {
  uci set network.usbwan=interface
  uci set network.usbwan.proto='dhcp'
  uci set network.usbwan.device='usb0'
  uci set network.usbwan.auto='0'
  uci set network.usbwan.metric='20'
}
uci -q get network.usbwan6 >/dev/null || {
  uci set network.usbwan6=interface
  uci set network.usbwan6.proto='dhcpv6'
  uci set network.usbwan6.device='usb0'
  uci set network.usbwan6.auto='0'
  uci set network.usbwan6.reqaddress='try'
  uci set network.usbwan6.reqprefix='auto'
}
for z in $(uci show firewall | sed -n "s/^firewall\.@zone\[\([0-9]*\)\]\.name='wan'$/\1/p"); do
  uci -q get firewall.@zone[$z].network | grep -q usbwan || uci add_list firewall.@zone[$z].network='usbwan'
  uci -q get firewall.@zone[$z].network | grep -q usbwan6 || uci add_list firewall.@zone[$z].network='usbwan6'
done
uci commit network
uci commit firewall
chmod +x /etc/hotplug.d/net/99-usbwan 2>/dev/null || true
