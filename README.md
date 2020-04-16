# memsql-flight-demo
# updated 04-15-20 for confluent platform 5.4

#### set up Kafka ####
docker-compose up -d
pip3 install -r requirements.txt

//create topic
kafka-topics --bootstrap-server localhost:9092 --create --topic locs --partitions 1 --replication-factor 1

//produce records
./make_events.py

//You can use
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic locs --from-beginning
//to make sure the records are being produced

#### set up MemSQL: https://docs.memsql.com/guides/latest/install-memsql/ ####
//docker quickstart, or could merge into the docker-compose.yml

//Create the schemas
memsql -uroot -h0 < 01-tables-setup.sql
//create pipeline(s)
memsql -uroot -h0 < 02-pipelines-setup.sql 

memsql -uroot -h0 < 03-udfs-sps.sql

memsql -uroot -h0 < 04-pipeline-into-sp.sql

ALTER PIPELINE SET OFFSETS LATEST?
//start pipeline!


NOTE:
//Per main() in the make_events script, the script only runs for 10 seconds and stops the kafka producing, so you may have to loop it or just restart it
