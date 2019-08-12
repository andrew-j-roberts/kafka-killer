#!/bin/bash
#
# build.sh
#
# Forms a template file for each consumer node,
# then runs terraform apply to build them all.
# 
# Note:  
# This test uses one consumer node per queue.  
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

cd `dirname $0`

function msg() {
  line="- + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + "
  echo ""; echo "$line"; echo "$*"; echo "$line"; echo ""
}

if [ "$#" -ne 1 ]; then
	echo "  USAGE: $0 <QUEUE_COUNT>"
	echo ""
	exit 0
fi
QUEUE_COUNT=$1

msg "Creating a terraform and cloud config file for each consumer node"
cd terraform
for (( i = 0; i < $QUEUE_COUNT; i++ )) 
do 
  cat templates/consumer-node.template.tf \
  | sed -e "s/__NODE_NAME__/node-$i/g" \
  > consumer-node-$i.tf
  echo "Created consumer-node-$i.tf"

  # cat templates/consumer-cloud-config.template.yml \
  # | sed -e "s/__NODE_NUMBER__/$i/g" \
  # > cloud-config-consumer-node-$i.yml
  # echo "Created cloud-config-node-$i.yml"
done

# build cloud resources from generated terraform files
terraform init
terraform apply
cd ..
