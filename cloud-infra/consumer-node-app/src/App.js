// load regenerator-runtime (async enabler) and env variables before anything else
import "regenerator-runtime";
import dotenv from "dotenv";
let result = dotenv.config();
if (result.error) {
  throw result.error;
}

import solace from "solclientjs";
import QueueConsumer from "./QueueConsumer";

async function run() {
  // Solace initialization
  let factoryProps = new solace.SolclientFactoryProperties();
  factoryProps.profile = solace.SolclientFactoryProfiles.version10;
  solace.SolclientFactory.init(factoryProps);
  solace.SolclientFactory.setLogLevel(solace.LogLevel.WARN);

  // initialize a queue consumer that consumes images from the queue we just provisioned
  var queueConsumer = QueueConsumer(solace, process.env.QUEUE_NAME);
  // and open a connect with the Solace PubSub+ Broker
  queueConsumer.run();

  // program will run until it is told to exit
  queueConsumer.log("Press Ctrl-C to exit");
  process.stdin.resume();

  process.on("SIGINT", function() {
    "use strict";
    queueConsumer.exit();
  });
}

run();
