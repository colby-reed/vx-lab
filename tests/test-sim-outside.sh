#!/bin/bash

cd cldemo2/vx-simulation

function error() {
  echo -e "\e[0;33mERROR: Testing of the simulation failed while running the command $BASH_COMMAND at line $BASH_LINENO.\e[0m" >&2
  if [ "$debug" != "true" ]; then
    echo " >>>Destroying Simulation<<<"
    vagrant destroy -f
  fi
  exit 1
}

trap error ERR

source ../../tests/pipeline_failure_behavior
echo "Starting to run tests...."

set -e
set -x

# Force Colored output for Vagrant when being run in CI Pipeline
export VAGRANT_FORCE_COLOR=true

# NOTE:
# the -- -l cumulus at the end is the way you pass additional ssh args to vagrant ssh
# because we do the trick with .bash_profile with user vagrant to switch to user cumulus when someone does a 'vagrant ssh oob-mgmt-server'
# it breaks this method of passing commands to oob-mgmt-server, but if we login as user cumulus, it works fine.
# just need to make sure key from /home/vagrant/.ssh/authorized_keys, gets into same path for user cumulus (that is done in cldemo2 base)
vagrant ssh oob-mgmt-server -c "bash /home/vagrant/tests/tests-oob-server-inside.sh" -- -l cumulus
### Other tests that we want to run from oob-mgmt-server go in this script above

# Tests/checks that we want to perform from the netq-ts should go in this script
vagrant ssh netq-ts -c "bash tests/tests-netq-ts-inside.sh"
