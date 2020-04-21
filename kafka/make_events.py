#!/usr/bin/python3
import requests
import json
import threading, logging, time
import multiprocessing
import argparse
from confluent_kafka import Producer
# from opensky_api import OpenSkyApi


class MyProducer(threading.Thread):
    def __init__(self, topic, delay):
        threading.Thread.__init__(self)
        self.stop_event = threading.Event()
        self.topic_name = topic
        self.delay_time = delay
        
    def stop(self):
        self.stop_event.set()

    def run(self):
        p = Producer({'bootstrap.servers': 'localhost:9092'})

        while not self.stop_event.is_set():
            messages = call_api()
            print(messages[0])
            for m in messages:
                # print(m)
                p.produce(self.topic_name, json.dumps(m).encode('utf-8'))
            print(f"produced {len(messages)} messages... to {self.topic_name}")
            p.flush()
            #Sleep for x sec between API calls
            print(f"sleeping for {self.delay_time} seconds")
            time.sleep(self.delay_time)

def call_api():
    #new version?
    # api = OpenSkyApi()
    # s = api.get_states()
    # print(s)

    # Using REST    
    print("Starting API call..")
    r = requests.get("https://opensky-network.org/api/states/all",
        headers={
            "Accept": "application/json"
        }
    )
    if r.status_code != 200:
        print(f"Error. Return code={r.status_code}")
    # Serialize json messages
    messages = []
    data = json.loads(r.text)
    for s in data['states']:
        rec = {
            "icao24": s[0],
            "callsign": s[1].strip(' '),
            "origin_country": s[2],
            "time_position": s[3] ,
            "last_contact": s[4],
            "lon": s[5],
            "lat": s[6],
            "geo_altitude": s[7],
            "on_ground": s[8],
            "velocity": s[9],
            "heading": s[10]
        }
        if rec['lon'] != None and rec['lat'] != None:
            messages.append(rec)
    return messages


def run_tasks(args):
    tasks = []
    for i in range(0,args.num_threads):
        tasks.append(MyProducer(args.topic_name, args.delay_time))

    # tasks = [
    #     MyProducer(),
    #     MyProducer()
    # ]
    for t in tasks:
        t.start()

    #Total Runtime
    time.sleep(args.runtime)
    print(f"producer shutdown after {args.runtime} seconds")

    for task in tasks:
        print(f"stopping task {task}")
        task.stop()

    for task in tasks:
        task.join()


def main():
    parser = argparse.ArgumentParser(description='Produce data to kafka topic.')
    parser.add_argument('--time', type=int, dest='runtime', required=True, help='total runtime in seconds')
    parser.add_argument('--topic-name', type=str, dest='topic_name', required=True, help='name of Kafka topic to produce to')
    parser.add_argument('--delay', type=int, dest='delay_time', default=10, help='time (s) in between API calls')
    parser.add_argument('--num-threads', dest='num_threads', default=1, help='number of threads')

    args = parser.parse_args()

    run_tasks(args)
    

if __name__ == "__main__":
    logging.basicConfig(
        format='%(asctime)s.%(msecs)s:%(name)s:%(thread)d:%(levelname)s:%(process)d:%(message)s',
        level=logging.INFO
        )
    main()