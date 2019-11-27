#!/bin/bash

check_state(){
if [ "$?" != "0" ]; then
    echo "ERROR Previous test failure - Exit with error"
    exit 1
fi
}
set -x

echo "netq show agents"
netq show agents
check_state

echo "netq check bgp"
netq check bgp
check_state
netq check bgp include 0
check_state
netq check bgp include 1
check_state
netq check bgp include 2
check_state

echo "netq check vxlan"
netq check vxlan
check_state
netq check vxlan include 0
check_state
netq check vxlan include 1
check_state

echo "netq check evpn"
netq check evpn
check_state
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

#Netq traces between some points in the topology

