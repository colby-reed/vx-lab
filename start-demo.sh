#!/bin/bash

check_state(){
if [ "$?" != "0" ]; then
    echo "ERROR at last command. Aborting this launch script"
    echo "Please check the Production Ready Automation user guide at https://docs.cumulusnetworks.com for system dependencies and prerequisites and to try to start the simulation manually"
    echo "Ask for help on the Cumulus Community public Slack: https://slack.cumulusnetworks.com"
    exit 1
fi
}


if [ ! "$(ls -A cldemo2)" ]
then
    echo "Cumulus Reference topology submodule not present"
    echo "attempting to fix that for us"
    cd cldemo2
    check_state
    git submodule init
    check_state
    git submodule update
    check_state
    cd ..
    check_state
else
    echo "Submodule folder not empty. Assuming it is ok"
fi

cd cldemo2/simulation
check_state

echo "Starting OOB management devices"
if [ "$1" == "--no-netq" ]; then
  vagrant up oob-mgmt-server oob-mgmt-switch
  check_state
else
  vagrant up oob-mgmt-switch oob-mgmt-server netq-ts
  check_state
fi

echo "Starting the Network nodes"
vagrant up leaf01 leaf02 leaf03 leaf04 spine01 spine02 spine03 spine04 
check_state
vagrant up server01 server02 server03 server04 
check_state
vagrant up server05 server06 server07 server08 
check_state
vagrant up border01 border02 fw1 fw2
check_state

echo "Copy Topology Automation to oob-mgmt-server"
vagrant scp ../../automation oob-mgmt-server:/home/vagrant
check_state
echo "Finsihed automation copy into the simulation"
echo ""
 
echo ""
echo "Displaying status of all devices under this Vagrant simulation"
echo "netq-ts may not be running if you used the --no-netq option"
echo ""
vagrant status

echo ""
echo "###########################"
echo "# Demo launch complete!   #"
echo "###########################"
echo ""
echo "Change to cldemo2/simluation directory to vagrant ssh into the simulation:"
echo ""
echo "cd cldemo2/simluation"
echo "vagrant ssh oob-mgmt-server"
echo ""
