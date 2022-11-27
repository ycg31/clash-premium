#!/bin/bash

set -e

function addIptables(){
  if ! [ -x "$(command -v iptables)" ]; then
    echo "[init] package: installing iptables..."
    apk add --update --no-cache -q iptables
    echo "[init] package: done."
  else
    echo '[init] package: iptables has been installed.'
  fi
}

function enableIpv4Forward(){
  echo "[init] setting: enable ipv4 ip forwarding..."
  sysctl -w net.ipv4.ip_forward=1
  echo "[init] setting: done."
}

function setIptables(){
  echo "[init] iptables: adding iptables rules..."
  # ROUTE RULES
  ip rule add fwmark 1 table 100
  ip route add local 0.0.0.0/0 dev lo table 100
  # CREATE TABLE
  iptables -t mangle -N clash
  # RETURN LOCAL AND LANS
  iptables -t mangle -A clash -d 0.0.0.0/8 -j RETURN
  iptables -t mangle -A clash -d 10.0.0.0/8 -j RETURN
  iptables -t mangle -A clash -d 127.0.0.0/8 -j RETURN
  iptables -t mangle -A clash -d 169.254.0.0/16 -j RETURN
  iptables -t mangle -A clash -d 172.16.0.0/12 -j RETURN
  iptables -t mangle -A clash -d 192.168.0.0/16 -j RETURN
  iptables -t mangle -A clash -d 224.0.0.0/4 -j RETURN
  iptables -t mangle -A clash -d 240.0.0.0/4 -j RETURN
  # FORWARD ALL
  iptables -t mangle -A clash -p udp -j TPROXY --on-port 7893 --tproxy-mark 1
  iptables -t mangle -A clash -p tcp -j TPROXY --on-port 7893 --tproxy-mark 1
  # REDIRECT
  iptables -t mangle -A PREROUTING -j clash
  echo "[init] iptables: done."
}

function initApp() {
  echo "====================== clash.service ========================"
  echo "[init] executing container initialization scripts..."
  if [ $ENHANCED_MODE ]; then
      echo "[init] mode: enable transparent proxies mode."
      enableIpv4Forward
      addIptables
      setIptables
  else
      echo "[init] mode: enable http proxies mode."
  fi
  echo "[init] container initialization scripts completed."
  echo "[service] clash: service started, have fun"
}

initApp

exec clash -d /clash -ext-ui /clash/ui "$@"
