# kafka-flight-demo

![Dashboard screenshot](./looker/dash-screenshot.png?raw=true "Kafka-flight-demo Looker Dashboard")

### Author: Alec Powell (apowell@confluent.io)
#### This repo uses a Python producer script to call the OpenSky REST API (https://opensky-network.org/apidoc/rest.html) to fetch live flight locations for thousands of planes around the globe and feed them into an Apache Kafka cluster. 
#### Last updated: 01-07-2022 for Confluent Cloud & BigQuery ("SaaS-ified" version)


## "SaaS-ified" version (Confluent Cloud + Google BigQuery)
STEPS (as of 01-07-2022)
1. Install pre-reqs (note new v2 of Confluent CLI was released Nov 2021)

Make [Confluent Cloud](https://confluent.cloud/signup) and GCP accounts

Install the [Confluent CLI](https://docs.confluent.io/confluent-cli/current/install.html)

```bash
curl -sL --http1.1 https://cnfl.io/cli | sh -s -- latest
export PATH=$(pwd)/bin:$PATH
pip3 install -r requirements.txt
```

2. Spin up Kafka cluster, topic(s)
```bash
confluent login
confluent kafka cluster create ...
confluent kafka cluster use <cluster-id>
confluent kafka topic create flights
confluent kakfa topic list
```

3. Set up configs

Create your API keys for Kafka & Schema Registry first:
```bash
confluent api-key create --resource <cluster-id>
confluent api-key create --resource <schema-registry-id>
```

Now, create your librdkafka.config file and paste in the API keys/Secrets. It should look like this:
```
# Kafka
bootstrap.servers=<cluster-id>.<cloud>.confluent.cloud:9092
security.protocol=SASL_SSL
sasl.mechanisms=PLAIN
sasl.username=<API-key>
sasl.password=<API-secret>

# Confluent Cloud Schema Registry
schema.registry.url=https://<schema-registry-id>.<region>.<cloud>.confluent.cloud
basic.auth.credentials.source=USER_INFO
basic.auth.user.info=<API-key>:<API-secret>
```

4. Produce data! 

Our producer is based on Confluent's example [script](https://docs.confluent.io/platform/current/tutorials/examples/clients/docs/python.html) using confluent-kafka Python client.
Call the event producer script from the `kafka` directory. `-f` is path to your librdkafka.config file, `-t` is topic name, `-n` is number of consecutive API calls you want to make (there is a 10second sleep between API calls, so `-n 3` will take ~ 30seconds to run) 
```bash
./event_producer.py -f librdkafka.config -t flights -n 20
```

5. ksqlDB for fun & profit

Create a ksqlDB app using `confluent` CLI or in the Confluent Cloud UI.
Browse [ksqldb-streams.sql](kafka/ksqldb-streams.sql) for query ideas.

6. Spin up BigQuery Sink connector

Download a json file for your BigQuery ServiceAccount,
Use the UI -> "Connectors" page to create a BigQuery Sink connector, with 1 task, which will sink data from your Kafka topic to your BigQuery project.

7. Query your data in BigQuery!

Browse [bigquery.sql](bigquery/bigquery.sql) for query ideas.


## Dockerized/local version (Confluent Platform + MemSQL/SingleStore)
STEPS (Last tested on Ubuntu Bionic-18.04 in 04-2020):
1. Install pre-reqs
```bash
sudo apt update
sudo apt install git -y
#install mysql-client
sudo apt install mysql-client -y
#install docker
sudo apt install python3-pip libffi-dev -y
curl -fsSL https://get.docker.com/ | sh
#you may have to logout and log back in for this usermod to register
sudo usermod -aG docker $(whoami) 
sudo systemctl start docker
sudo systemctl enable docker
sudo apt install docker-compose -y
```

[1b]. Get MemSQL license key (https://portal.memsql.com/), set as env variable `$MEMSQL_LICENSE_KEY`

2. _Clone this repo_ and spin up the containers using Docker Compose
```bash
git clone https://github.com/alecpowell18/kafka-flight-demo.git 
cd kafka-memsql-demo/
docker-compose up -d
```

3. Produce data
```bash
#install dependencies for producer script
sudo apt install librdkafka-dev -y
pip3 install -r requirements.txt
#create topic
./kafka/create_topic.py
#produce records - default Kafka topic = 'locs', default time between API calls = 10s
#run ./kafka/make_events.py --help for script options
nohup ./kafka/make_events.py --time 500 > producer.log &
```

4. Prepare the db and pipelines
```bash
#Check connectivity to MemSQL cluster
mysql -uroot -h 127.0.0.1 -P 3306
exit
#Create the schemas, enable load data local to load from source file
cd memsql/
mysql -uroot -h0 --local-infile < 01-tables-setup.sql
#create pipeline(s)
mysql -uroot -h0 < 02-pipelines-setup.sql 
#create UDFs and SP
mysql -uroot -h0 < 03-udfs-sps.sql
#create pipeline which will use SP
mysql -uroot -h0 < 04-pipeline-into-sp.sql
```

5. Start pipelines!
Browse to `<your-instance-ip-addr>:8080` for MemSQL Studio, or use the command line to do so:
```bash
mysql -uroot -h0 demo -e 'START ALL PIPELINES;'
```
