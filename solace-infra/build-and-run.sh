#!/bin/bash
#
# build.sh
#
# Provisions the provided number of queues and
# distributes the provided number of store topics across them.
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

cd `dirname $0`

function msg() {
  line="- + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + "
  echo ""; echo "$line"; echo "$*"; echo "$line"; echo ""
}

# verify that .env file exists
SOLACE_INFRA_ENV_FILE=.env
if [ ! -f "$SOLACE_INFRA_ENV_FILE" ]; then
  echo "ERROR!"
  echo "Could not find one of the following files:"
  echo "  - .env"
  echo ""
  echo "Read the EDIT-ME.env files for further instructions."
fi

# build and run docker container
msg "Provisioning queues and distributing store topic subscriptions across them"
docker-compose build
docker-compose up
docker-compose down