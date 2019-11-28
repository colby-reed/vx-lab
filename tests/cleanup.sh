#!/bin/bash

set -x

cd ./cldemo2/vx-simulation

#echo "NetQ decomm servers"
vagrant ssh netq-ts -c "bash /home/vagrant/tests/netq-decommission-inside.sh"


date
time vagrant destroy -f

echo "Finished."
