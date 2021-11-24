#!/usr/bin/env python
#
# Copyright 2020 Confluent Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# =============================================================================
#
# Helper module
#
# =============================================================================

import argparse, sys
from confluent_kafka import avro, KafkaError
from confluent_kafka.admin import AdminClient, NewTopic
from uuid import uuid4

#import certifi

name_schema = """
    {
        "namespace": "io.confluent.examples.clients.cloud",
        "name": "Name",
        "type": "record",
        "fields": [
            {"name": "name", "type": "string"}
        ]
    }
"""

class Name(object):
    """
        Name stores the deserialized Avro record for the Kafka key.
    """

    # Use __slots__ to explicitly declare all data members.
    __slots__ = ["name", "id"]

    def __init__(self, name=None):
        self.name = name
        # Unique id used to track produce request success/failures.
        # Do *not* include in the serialized object.
        self.id = uuid4()

    @staticmethod
    def dict_to_name(obj, ctx):
        return Name(obj['name'])

    @staticmethod
    def name_to_dict(name, ctx):
        return Name.to_dict(name)

    def to_dict(self):
        """
            The Avro Python library does not support code generation.
            For this reason we must provide a dict representation of our class for serialization.
        """
        return dict(name=self.name)


# Schema used for serializing Count class, passed in as the Kafka value
count_schema = """
    {
        "namespace": "io.confluent.examples.clients.cloud",
        "name": "Count",
        "type": "record",
        "fields": [
            {"name": "count", "type": "int"}
        ]
    }
"""


class Count(object):
    """
        Count stores the deserialized Avro record for the Kafka value.
    """

    # Use __slots__ to explicitly declare all data members.
    __slots__ = ["count", "id"]

    def __init__(self, count=None):
        self.count = count
        # Unique id used to track produce request success/failures.
        # Do *not* include in the serialized object.
        self.id = uuid4()

    @staticmethod
    def dict_to_count(obj, ctx):
        return Count(obj['count'])

    @staticmethod
    def count_to_dict(count, ctx):
        return Count.to_dict(count)

    def to_dict(self):
        """
            The Avro Python library does not support code generation.
            For this reason we must provide a dict representation of our class for serialization.
        """
        return dict(count=self.count)



flight_schema = """
    {
        "namespace": "io.confluent.alecdemo",
        "name": "FlightLocation",
        "type": "record",
        "fields": [
            {"name": "icao24", "type": "string"},
            {"name": "callsign", "type": "string"},
            {"name": "origin_country", "type": "string"},
            {"name": "time_position", "type": "long"},
            {"name": "last_contact", "type": "long"},
            {"name": "lon", "type": "float"},
            {"name": "lat", "type": "float"},
            {"name": "geo_altitude", "type": ["null", "float"]},
            {"name": "on_ground", "type": "boolean"},
            {"name": "velocity", "type": ["null", "float"]},
            {"name": "heading", "type": "float"}
        ]
    }
"""

class Flight(object):
    """
        Flight stores the deserialized Avro record for the Kafka key.
    """

    # Use __slots__ to explicitly declare all data members.
    __slots__ = ["icao24", "callsign", "origin_country", "time_position", "last_contact", "lon", "lat", "geo_altitude", "on_ground", "velocity", "heading", "id"]

    def __init__(self, icao24, callsign, origin_country, time_position, last_contact, lon, lat, geo_altitude, on_ground, velocity, heading):
        self.icao24 = icao24
        self.callsign = callsign
        self.origin_country = origin_country
        self.time_position = time_position
        self.last_contact = last_contact
        self.lon = lon
        self.lat = lat
        self.geo_altitude = geo_altitude
        self.on_ground = on_ground
        self.velocity = velocity
        self.heading = heading

        # Unique id used to track produce request success/failures.
        # Do *not* include in the serialized object.
        self.id = uuid4()

    @staticmethod
    def dict_to_flight(obj, ctx):
        return Flight(obj['icao24'], obj['callsign'], obj['origin_country'], obj['time_position'], obj['last_contact'], obj['lon'], obj['lat'], obj['geo_altitude'], obj['on_ground'], obj['velocity'], obj['heading'])

    @staticmethod
    def flight_to_dict(flight, ctx):
        return Flight.to_dict(flight)

    def to_dict(self):
        """
            The Avro Python library does not support code generation.
            For this reason we must provide a dict representation of our class for serialization.
        """
        return dict(icao24=self.icao24,
                    callsign=self.callsign,
                    origin_country=self.origin_country,
                    time_position=self.time_position,
                    last_contact=self.last_contact,
                    lon=self.lon,
                    lat=self.lat,
                    geo_altitude=self.geo_altitude,
                    on_ground=self.on_ground,
                    velocity=self.velocity,
                    heading=self.heading)



def parse_args():
    """Parse command line arguments"""

    parser = argparse.ArgumentParser(
             description="Confluent Python Client example to produce messages \
                  to Confluent Cloud")
    parser._action_groups.pop()
    required = parser.add_argument_group('required arguments')
    required.add_argument('-f',
                          dest="config_file",
                          help="path to Confluent Cloud configuration file",
                          required=True)
    required.add_argument('-t',
                          dest="topic",
                          help="topic name",
                          required=True)
    required.add_argument('-n',
                          dest="loops",
                          help="number of API calls",
                          default=1,
                          required=False)
    args = parser.parse_args()

    return args


def read_ccloud_config(config_file):
    """Read Confluent Cloud configuration for librdkafka clients"""

    conf = {}
    with open(config_file) as fh:
        for line in fh:
            line = line.strip()
            if len(line) != 0 and line[0] != "#":
                parameter, value = line.strip().split('=', 1)
                conf[parameter] = value.strip()

    #conf['ssl.ca.location'] = certifi.where()

    return conf


def pop_schema_registry_params_from_config(conf):
    """Remove potential Schema Registry related configurations from dictionary"""

    conf.pop('schema.registry.url', None)
    conf.pop('basic.auth.user.info', None)
    conf.pop('basic.auth.credentials.source', None)

    return conf


def create_topic(conf, topic):
    """
        Create a topic if needed
        Examples of additional admin API functionality:
        https://github.com/confluentinc/confluent-kafka-python/blob/master/examples/adminapi.py
    """

    admin_client_conf = pop_schema_registry_params_from_config(conf.copy())
    a = AdminClient(admin_client_conf)

    fs = a.create_topics([NewTopic(
         topic,
         num_partitions=1,
         replication_factor=3
    )])
    for topic, f in fs.items():
        try:
            f.result()  # The result itself is None
            print("Topic {} created".format(topic))
        except Exception as e:
            # Continue if error code TOPIC_ALREADY_EXISTS, which may be true
            # Otherwise fail fast
            if e.args[0].code() != KafkaError.TOPIC_ALREADY_EXISTS:
                print("Failed to create topic {}: {}".format(topic, e))
                sys.exit(1)
