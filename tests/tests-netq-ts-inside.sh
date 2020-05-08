#!/bin/bash

check_state(){
if [ "$?" != "0" ]; then
    echo "ERROR Previous test failure - Exit with error"
    exit 1
fi
}
set -x

echo "60 seconds of NetQ agent + server processing time"
sleep 60

echo "netq show agents"
netq show agents
check_state

echo "netq check bgp"
#netq check bgp
#check_state
netq check bgp include 0
check_state
netq check bgp include 1
check_state
netq check bgp include 2
check_state

echo "netq check vxlan"
#netq check vxlan
#check_state
netq check vxlan include 0
check_state
netq check vxlan include 1
check_state

echo "netq check evpn"
#netq check evpn
#check_state
netq check evpn include 0
check_state
netq check evpn include 1
check_state
netq check evpn include 2
check_state
netq check evpn include 3
check_state
netq check evpn include 4
check_state
netq check evpn include 5
check_state
netq check evpn include 6
check_state
netq check evpn include 7 
check_state

echo "netq check clag"
netq check clag include 0
check_state
netq check clag include 1
check_state
netq check clag include 2
check_state
netq check clag include 3
check_state
netq check clag include 4
check_state
netq check clag include 5
check_state
netq check clag include 6
check_state
netq check clag include 7
check_state
netq check clag include 8
check_state
netq check clag include 9
check_state
netq check clag include 10
check_state

echo "netq check cl-version"
netq check cl-version include 0
check_state

echo "netq check mtu"
#netq check mtu 0
#check_state
netq check mtu 1
check_state
netq check mtu 2
check_state

echo "netq check ntp"
netq check ntp 0
check_state

echo "netq check vlan"
netq check vlan include 0
check_state
netq check vlan include 1
check_state

