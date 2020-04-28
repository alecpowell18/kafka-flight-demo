#!/usr/bin/python3
from confluent_kafka import Producer, Consumer, KafkaError
import requests
import time


def main():
    """
    TODO: This is sample code which we can use to integrate ksqlDB in the future.
    """
    print(">>> Starting Python Kafka Client...")
    produce_quotes()
    call_ksql()
    consume_lowercase_quotes()
    print("<<< Ending Python Kafka Client...")

# Initialization
quotes = [
    "Kafka enables the Confluent Streaming Platform",
    "Confluent offers a Streaming Platform powered by Kafka",
    "Kafka Streams are cool",
    "Streaming allows for real-time processing of information",
    "I love Kafka"
]
output_topic = "quotes"
input_topic = "QUOTES_LOWER"
bootstrap_servers = "localhost:9092"

# Function Definitions

def produce_quotes():
    print("------ Writing quotes to topic '" + output_topic + "' ------")
    producer = Producer({"bootstrap.servers": bootstrap_servers})
    for quote in quotes:
        print("*** writing: " + quote)
        producer.produce(output_topic, value=quote)
    producer.flush()
    print("------ done writing quotes ------")


def call_ksql():
    print("--------- Posting to KSQL Server ---------")
    ksql = "CREATE STREAM quotes_orig (line STRING) WITH(KAFKA_TOPIC='quotes', VALUE_FORMAT='DELIMITED');"
    post_expression(ksql)

    # wait until KSQL server has created the stream
    time.sleep(2)

    ksql = "CREATE STREAM quotes_lower AS SELECT LCASE(line) FROM quotes_orig;"
    post_expression(ksql)
    print("--------- done posting to KSQL Server -----------")

def post_expression(ksql):
    headers = {
        "accept": "application/vnd.ksql.v1+json",
        "content-type": "application/vnd.ksql.v1+json"
        }
    data = {
        "ksql": ksql,
        "streamsProperties": {"ksql.streams.auto.offset.reset": "earliest"}
    }
    try:
        r = requests.post("http://ksql-server:8088/ksql", json = data, headers=headers)
    except:
        print("ERROR: " + str(r.status_code) + ", " + r.text)
        raise
    print(str(r.status_code) + ", " + r.text)

def consume_lowercase_quotes():
    print("------ Reading from topic '" + input_topic + "' ------")
    consumer = Consumer({
        "bootstrap.servers": bootstrap_servers,
        "group.id": "sample-group",
        "default.topic.config": {
            "auto.offset.reset": "smallest"
        }
    })
    consumer.subscribe([input_topic])

    while True:
        msg = consumer.poll(1.0)

        if msg is None:
            continue
        if msg.error():
            if msg.error().code() == KafkaError._PARTITION_EOF:
                continue
            else:
                print(msg.error())
                break

        print('Received message: {}'.format(msg.value().decode('utf-8')))

    consumer.close()


# Call main function if program is run from command line
if __name__ == "__main__":
    main()
