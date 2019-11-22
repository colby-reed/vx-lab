#!/bin/bash
cd cldemo2/vx-simulation

vagrant up oob-mgmt-server oob-mgmt-switch

echo "Copy Topology Automation to oob-mgmt-server"
vagrant scp ../../automation oob-mgmt-server:/home/vagrant

vagrant ssh oob-mgmt-server -c "sudo mv /home/vagrant/automation /home/cumulus/" -- -l cumulus
vagrant ssh oob-mgmt-server -c "sudo chown -R cumulus:cumulus /home/cumulus/automation" -- -l cumulus

if [ "$1" == "netq" ]; then
  vagrant up netq-ts
fi

vagrant up leaf01 leaf02 leaf03 leaf04 spine01 spine02 server01 server02 server03 server05 server06 server07 border01 border02 fw1 fw2


