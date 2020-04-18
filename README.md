# kafka-flight-demo

![Dashboard screenshot](./looker/dash-screenshot.png?raw=true "Kafka-flight-demo Looker Dashboard")

### Author: Alec Powell (apowell@confluent.io)
#### This repo uses a Python producer to call the OpenSky REST API (https://opensky-network.org/apidoc/rest.html) to fetch live flight locations for thousands of planes around the globe and feed them into Apache Kafka. 
#### Last updated: 04-15-20 for Confluent Platform 5.4
#### TODO: join on airline codes to add airlines to data set.
#### TODO2: add argument for wait time in python producer script.
#### TODO3: add some message produce logging in producer

STEPS (Ubuntu Bionic-18.04):
1. Install pre-reqs
```bash
sudo apt update
sudo apt install git -y
#install mysql-client
sudo apt install mysql-client -y
#install docker
sudo apt install python3-pip libffi-dev -y
curl -fsSL https://get.docker.com/ | sh
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
./create_topic.py
#produce records
nohup ./make_events.py > producer-out.log &
```

4. Prepare the db and pipelines
```bash
#Check connectivity to MemSQL cluster
mysql -uroot -h 127.0.0.1 -P 3306
exit
#Create the schemas, enable load data local to load from source file
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
