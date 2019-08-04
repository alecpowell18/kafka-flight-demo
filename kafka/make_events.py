#!/usr/bin/env python
import unirest
import json
import threading, logging, time
import multiprocessing
from kafka import KafkaProducer

class Producer(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
        self.stop_event = threading.Event()
        
    def stop(self):
        self.stop_event.set()

    def run(self):
        #producer = KafkaProducer(bootstrap_servers='localhost:9092')
        producer = KafkaProducer(bootstrap_servers='localhost:9092', value_serializer=lambda v: json.dumps(v).encode('utf-8'))

        while not self.stop_event.is_set():
            messages = callapi()
            for m in messages:
                producer.send('locs', m)
            time.sleep(1)
            producer.flush()

        producer.close()

def callapi():
    print("Starting API call..")
    response = unirest.get("https://opensky-network.p.mashape.com/states/all",
        headers={
            "X-Mashape-Key": "kaC3rLIygZmshpyVjlYqowx7XQFpp1DNMP2jsn9AIhPmMmZ1bS",
            "Accept": "application/json"
        }
    )
    # Serialize json messages
    messages = []
    for s in response.body['states']:
        #format into JSON
        data = {}
        data['icao24'] = s[0]
        data['callsign'] = s[1].strip(' ')
        data['origin_country'] = s[2]
        data['time_position'] = s[3] 
        data['last_contact'] = s[4]
	data['lon'] = s[5]
	data['lat'] = s[6]
        data['geo_altitude'] = s[7]
        data['on_ground'] = s[8]
        data['velocity'] = s[9]
        data['heading'] = s[10]
        print data 
	if data['lon'] != None and data['lat'] != None:
        	messages.append(data)
    return messages


def main():
    tasks = [
        Producer()
    ]

    for t in tasks:
        t.start()

    time.sleep(10)

    for task in tasks:
        task.stop()

    for task in tasks:
        task.join()


if __name__ == "__main__":
    logging.basicConfig(
        format='%(asctime)s.%(msecs)s:%(name)s:%(thread)d:%(levelname)s:%(process)d:%(message)s',
        level=logging.INFO
        )
    main()
