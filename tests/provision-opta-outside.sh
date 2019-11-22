#!/bin/bash

set -e
set -x


check_state(){
if [ "$?" != "0" ]; then
    echo "ERROR on previous command - Exit with failure"
    exit 1
fi
}

cd cldemo2/vx-simulation

echo "Getting OPTA Install Filename"
vagrant ssh netq-ts -c "ls /mnt/installables"
INSTALL_FILENAME=`vagrant ssh netq-ts -c "ls /mnt/installables | grep opta.tgz | tr -d '[:space:]'"`
echo "Detected Filename: $INSTALL_FILENAME"

echo "OPTA Install...takes several minutes"
vagrant ssh netq-ts -c "netq install opta interface eth0 tarball $INSTALL_FILENAME key $NETQ_CONFIG_KEY"

echo "Adding NetQ CLI Server"
vagrant ssh netq-ts -c "netq config add cli server api.netq.cumulusnetworks.com access-key $NETQ_ACCESS_KEY secret-key $NETQ_SECRET_KEY"

echo "Restarting NetQ agent and cli"
vagrant ssh netq-ts -c "netq config restart cli"
vagrant ssh netq-ts -c "netq config restart agent"

#cleanup step prior to testing in case a previous pipline failure occurred
echo "Performing NetQ agent decommission"
vagrant ssh netq-ts -c "bash /home/vagrant/tests/netq-decommission-inside.sh"

