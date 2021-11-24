-- instantiate ksqlDB stream based on raw Kafka topic data from 'flights' topic
CREATE STREAM flights_raw WITH(kafka_topic='flights', value_format='AVRO');

-- sample filter query to create new ksqlDB stream 'flights_usa'
CREATE STREAM flights_usa AS
SELECT callsign,
   lon,
   lat,
   velocity,
   heading FROM flights_raw
WHERE origin_country = 'United States'
AND on_ground = False
EMIT CHANGES;