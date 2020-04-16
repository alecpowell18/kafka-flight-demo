#!/usr/bin/python3
import requests
import json
import threading, logging, time
import multiprocessing
# from kafka import KafkaProducer
from confluent_kafka import Producer
# from opensky_api import OpenSkyApi


class Producer(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
        self.stop_event = threading.Event()
        
    def stop(self):
        self.stop_event.set()

    def run(self):
        #producer = KafkaProducer(bootstrap_servers='localhost:9092')
        # producer = KafkaProducer(bootstrap_servers='localhost:9092', value_serializer=lambda v: json.dumps(v).encode('utf-8'))
        p = Producer({'bootstrap.servers': 'localhost:9092'})

        while not self.stop_event.is_set():
            messages = callapi()
            for m in messages:
                p.produce('locs', m.encode('utf-8'))
            time.sleep(1)
            print("producing" + len(messages) + " messages...")
            p.flush()

def callapi():
    #new version?
    # api = OpenSkyApi()
    # s = api.get_states()
    # print(s)

    # using REST    
    print("Starting API call..")
    r = requests.get("https://opensky-network.org/api/states/all",
        headers={
            "X-Mashape-Key": "kaC3rLIygZmshpyVjlYqowx7XQFpp1DNMP2jsn9AIhPmMmZ1bS",
            "Accept": "application/json"
        }
    )
    if r.status_code != 200:
        print("wat. " + r.status_code)
    # print(r.text)
    # Serialize json messages
    messages = []
    data = json.loads(r.text)
    for s in data['states']:
        rec = {}
        rec['icao24'] = s[0]
        rec['callsign'] = s[1].strip(' ')
        rec['origin_country'] = s[2]
        rec['time_position'] = s[3] 
        rec['last_contact'] = s[4]
        rec['lon'] = s[5]
        rec['lat'] = s[6]
        rec['geo_altitude'] = s[7]
        rec['on_ground'] = s[8]
        rec['velocity'] = s[9]
        rec['heading'] = s[10]
        # print(rec) 
        if rec['lon'] != None and rec['lat'] != None:
            messages.append(rec)
    return messages


def main():
    tasks = [
        Producer()
    ]

    for t in tasks:
        t.start()

    time.sleep(30)

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
    # callapi()