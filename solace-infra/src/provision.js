// load regenerator-runtime (async enabler) and env variables before anything else
import "regenerator-runtime";
import dotenv from "dotenv";
let result = dotenv.config();
if (result.error) {
  throw result.error;
}

import solace from "solclientjs";
import SEMPClient from "./SEMPClient";
import hash from "./hash";

async function run() {
  // Solace initialization
  let factoryProps = new solace.SolclientFactoryProperties();
  factoryProps.profile = solace.SolclientFactoryProfiles.version10;
  solace.SolclientFactory.init(factoryProps);
  solace.SolclientFactory.setLogLevel(solace.LogLevel.WARN);

  // provision the queues and set up distribution counter
  let client = SEMPClient(process.env.SEMP_MSG_VPN);
  let queueDistributionCounts = {};
  for (let i = 0; i < Number(process.env.QUEUE_COUNT); i++) {
    try {
      await client.provisionQueue(`Q/node-${i}`);
      queueDistributionCounts[i] = 0;
    } catch (err) {
      console.log(err);
      process.exit();
    }
  }

  // distribute store topic subscriptions across queues based on hash
  for (let i = 0; i < process.env.STORE_COUNT; i++) {
    let storeTopicName = `T/store-${i}`;
    let storeTopicHash = hash(storeTopicName);
    let queueMapping = storeTopicHash % Number(process.env.QUEUE_COUNT);
    let queueName = `Q/node-${queueMapping}`;
    try {
      queueDistributionCounts[queueMapping] = queueDistributionCounts[queueMapping] + 1;
      await client.provisionQueueSubscription(queueName, storeTopicName);
    } catch (err) {
      console.log(err);
      process.exit();
    }
  }

  console.log();
  console.log("Topic distribution");
  console.table(queueDistributionCounts);
}

run();
