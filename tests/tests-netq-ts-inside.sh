#!/bin/bash

check_state(){
if [ "$?" != "0" ]; then
    echo "ERROR Previous test failure - Exit with error"
    exit 1
fi
}

set -e
set -x

echo "netq show agents"
netq show agents
check_state

echo "netq check bgp"
netq check bgp
#netq check bgp | grep -q "Failed Nodes: 0"
check_state
#netq check bgp | grep -q "Failed Sessions: 0"
check_state

echo "netq check vxlan"
netq check vxlan
#netq check vxlan | grep -q "Failed Nodes: 0"
check_state

echo "netq check evpn"
netq check evpn
#netq check evpn | grep -q "Failed Nodes: 0"
check_state


#Netq traces between some points in the topology?
