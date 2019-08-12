#!/bin/bash
#
# run-test.sh
#
# Runs the Node.js program that provisions the Solace infrastructure, 
# runs terraform apply to build the AWS infrastructure, 
# and runs the Ansible commands to start the tests.
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

cd `dirname $0`

if [ "$#" -ne 2 ]; then
	echo "  USAGE: $0 <QUEUE_COUNT> <STORE_COUNT>"
	echo ""
	exit 0
fi
QUEUE_COUNT=$1
STORE_COUNT=$2

# validate that .env files exist
SOLACE_INFRA_ENV_FILE=.solace-infra.env
CONSUMER_NODE_APP_ENV_FILE=.consumer-node-app.env
if [ ! -f "$SOLACE_INFRA_ENV_FILE" ] || [ ! -f "$CONSUMER_NODE_APP_ENV_FILE" ]; then
  msg "ERROR!"
  echo "Could not find one of the following files:"
  echo "  - .solace-infra.env"
  echo "  - .consumer-node-app.env"
  echo ""
  echo "Read the EDIT-ME.env files for further instructions."
  exit 0
fi

# override queue and store counts to reflect command line arguments
sed -i.bak \
  -e "s/.*QUEUE_COUNT=.*/QUEUE_COUNT=$QUEUE_COUNT/g" \
  -e "s/.*STORE_COUNT=.*/STORE_COUNT=$STORE_COUNT/g" \
  .solace-infra.env

# clean up .bak file
rm .solace-infra.env.bak

# copy .env files to their respective directories
cp $SOLACE_INFRA_ENV_FILE solace-infra/.env
cp $CONSUMER_NODE_APP_ENV_FILE cloud-infra/consumer-node-app/.env

# build solace infrastructure
solace-infra/build-and-run.sh

# build cloud infrastructure
cloud-infra/build-and-run.sh $QUEUE_COUNT