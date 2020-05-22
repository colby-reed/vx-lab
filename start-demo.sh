#!/bin/bash

# If we error, include some ways to find help
check_state(){
if [ "$?" != "0" ]; then
    echo "ERROR at last command. Aborting this launch script"
    echo "Please check the Production Ready Automation user guide at https://docs.cumulusnetworks.com for system dependencies and prerequisites and to try to start the simulation manually"
    echo "Ask for help on the Cumulus Community public Slack: https://slack.cumulusnetworks.com"
    exit 1
fi
}

# Function to check for vagrant scp plugin
check_scp_plugin(){
  VAGRANT_SCP_INSTALLED="false"
  for plugin in `vagrant plugin list`
  do
    if [ $plugin = 'vagrant-scp' ]
    then
      VAGRANT_SCP_INSTALLED="true"
    fi
  done
}

# Check if the Cumulus Reference Topology submodule is present
# Remediate if not
echo "Checking for cldemo2 submodule..."
if [ ! "$(ls -A cldemo2)" ]
then
    echo "..Cumulus Reference topology submodule not present"
    echo "..attempting to fix that for us"
    cd cldemo2
    check_state
    git submodule init
    check_state
    git submodule update
    check_state
    cd ..
    check_state
else
    echo "..The submodule appears to be present and populated."
fi

# Check if the Vagrant SCP plugin is present
# Remediate if not
check_scp_plugin
echo "Checking for vagrant-scp plugin"
if [ "$VAGRANT_SCP_INSTALLED" = "true" ]
then
  echo "..vagrant-scp plugin detected."
else
  echo "..vagrant-scp plugin not detected. This is used for convenience to copy the automation into the simulation."
  while true; do
    read -p "..Do you wish to install it quickly? [y/n] " yn
    case $yn in
        [Yy]* ) vagrant plugin install vagrant-scp; break;;
        [Nn]* ) echo "..Skipping. You will need to clone this project again once on the oob-mgmt-server to get the automation files into the simulation for deployment"; SCP_SKIPPED="true"; break;;
        * ) echo "..Please answer yes or no.";;
    esac
  done
fi

# Change to directory with the Vagrantfile present where vagrant up is valid
cd cldemo2/simulation
check_state

# Start up oob-mgmt devices first so DHCP and ZTP work.
echo "Starting OOB management devices"
if [ "$1" == "--no-netq" ]; then
  vagrant up oob-mgmt-server oob-mgmt-switch
  check_state
else
  vagrant up oob-mgmt-switch oob-mgmt-server netq-ts
  check_state
fi

# Start up the rest of the network nodes
# Take advantage of vagrant/libvirt parallelism
echo "Starting the Network nodes"
vagrant up leaf01 leaf02 leaf03 leaf04 spine01 spine02 spine03 spine04 
check_state
vagrant up server01 server02 server03 server04 
check_state
vagrant up server05 server06 server07 server08 
check_state
vagrant up border01 border02 fw1 fw2
check_state

echo "Finsihed starting simulation nodes"
echo ""

# Copy the automation directory onto the oob-mgmt-server for deployment in the simulation
# Else, you must clone the project again once inside the simulation
if [ "$VAGRANT_SCP_INSTALLED" = "true" ]
then
  echo "Copy Topology Automation to oob-mgmt-server"
  vagrant scp ../../automation oob-mgmt-server:/home/cumulus
  check_state
  echo "Finsihed automation copy into the simulation"
  echo ""
fi

## All Done. Print some helpful information
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
echo "cd cldemo2/simulation"
echo "vagrant ssh oob-mgmt-server"
echo ""

if [ "$SCP_SKIPPED" = "true" ]
then
  echo "###WARNING###"
  echo "The vagrant-scp plugin was not detected on this machine and was not installed."
  echo "As a result, The automation included for this demo was not copied into the simulation"
  echo "After entering the simulation on the oob-mgmt-server, you must git clone this project again"
  echo ""
  echo "git clone https://gitlab.com/cumulus-consulting/goldenturtle/dc_configs_vxlan_evpnsym.git"
  echo ""
fi
