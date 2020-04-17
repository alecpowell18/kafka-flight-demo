# memsql-flight-demo
# updated 04-15-20 for confluent platform 5.4
# TODO: join on airline codes to add airlines to data set.
# TODO2: add argument for wait time in python producer script.

#### set up Zookeeper, Kafka & MemSQL ####
//install python3
//install mysql-client
//install docker
pip3 install -r requirements.txt
docker-compose up -d

//create topic
kafka-topics --bootstrap-server localhost:9092 --create --topic locs --partitions 1 --replication-factor 1

//produce records
./make_events.py

//You can use
kafka-console-consumer --bootstrap-server localhost:9092 --topic locs --from-beginning --max-messages 10
//to make sure the records are being produced

//Create the schemas, enable load data local to load from source file
mysql -uroot -h0 --local-infile < 01-tables-setup.sql

//create pipeline(s)
mysql -uroot -h0 < 02-pipelines-setup.sql 

//create UDFs and SP
mysql -uroot -h0 < 03-udfs-sps.sql

//create pipeline which will use SP
mysql -uroot -h0 < 04-pipeline-into-sp.sql

//start pipelines!
//use localhost:8080 to use MemSQL Studio , or command line to do so:
mysql -uroot -h0 demo -e 'START ALL PIPELINES;'
