#!/bin/bash

check_state(){
if [ "$?" != "0" ]; then
    echo "ERROR on previous command - Exit with failure"
    exit 1
fi
}

set -e
set -x

echo "Currently in directory: $(pwd)"

# Force Colored output for Vagrant when being run in CI Pipeline
export VAGRANT_FORCE_COLOR=true

#only going to start pod1

#echo "#####################################"
#echo "#   Clone cldemo2 repo...     #"
#echo "#####################################"

cd cldemo2/vx-simulation

echo "#####################################"
echo "#   Starting the MGMT Server...     #"
echo "#####################################"
vagrant up oob-mgmt-server oob-mgmt-switch netq-ts #--no-parallel
check_state

echo "#####################################"
echo "#   Starting all Spines...      #"
echo "#####################################"
vagrant up spine01 spine02 spine03 spine04
check_state

echo "#####################################"
echo "#   Starting all Leafs...      #"
echo "#####################################"
vagrant up leaf01 leaf02 leaf03 leaf04
check_state

echo "#####################################"
echo "#   Starting Service/Border Leafs...      #"
echo "#####################################"
vagrant up border01 border02 fw1 fw2
check_state

echo "#####################################"
echo "#   Starting all Servers...      #"
echo "#####################################"
vagrant up server01 server02 server03 server04 server05 server06 server07 server08 server09 server10
check_state

ip_address=$(vagrant ssh-config oob-mgmt-server | grep HostName | cut -d " " -f4)

echo "Detected $ip_address for the OOB-MGMT-SERVER"

echo "Creating netq decomm script from cldemo2.dot"
echo "#!/bin/bash" > ../../tests/netq-decommission-inside.sh
grep function cldemo2.dot | cut -d'"' -f 2 | sed 's/^/netq decommission /' >>../../tests/netq-decommission-inside.sh

echo "Copy automation to oob-mgmt-server for provisioning"
vagrant scp ../../automation oob-mgmt-server:/home/vagrant
check_state

echo "Copy test scripts directory to oob-mgmt-server for testing"
vagrant scp ../../tests oob-mgmt-server:/home/vagrant
check_state

echo "Copy test scripts directory to netq-ts for testing"
vagrant scp ../../tests netq-ts:/home/vagrant
check_state

echo "List directory /home/vagrant on oob-mgmt-server"
vagrant ssh oob-mgmt-server -c "ls -lha /home/vagrant" -- -l cumulus

echo "List directory /home/vagrant on netq-ts"
vagrant ssh netq-ts -c "ls -lha /home/vagrant"

