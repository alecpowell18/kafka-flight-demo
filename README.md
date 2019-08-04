# memsql-flight-demo

NOTE: all kafka commands taken from quickstart (https://kafka.apache.org/quickstart)

#set up Kafka
sudo apt-get update
sudo apt-get install default-jre
sudo apt-get install python-pip
pip install unirest
pip install kafka-python
wget http://mirror.cc.columbia.edu/pub/software/apache/kafka/1.0.0/kafka_2.11-1.0.0.tgz

tar -xvf kafka/
cd kafka

nohup bin/zookeeper-server-start.sh config/zookeeper.properties > zoo.out &
nohup bin/kafka-server-start.sh config/server.properties > kafka.out &

//create topic
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic locs

//Run [python make_events.py] from localhost with kafka installed and topic created, it will send to kafka using Python's KafkaProducer library
//YOu can use [bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic locs] to make sure the records are being produced

#set up MemSQL: https://docs.memsql.com/guides/latest/install-memsql/
//Create the schemas
//create pipeline
//ALTER PIPELINE SET OFFSETS LATEST
//start pipeline!

NOTE:
//Per main() in the make_events script, the script only runs for 10 seconds and stops the kafka producing, so you may have to loop it or just restart it
