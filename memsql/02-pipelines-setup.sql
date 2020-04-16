USE demo;

CREATE PIPELINE locations
AS LOAD DATA KAFKA '172.31.46.241:9092/locs'
WITH TRANSFORM ('memsql://json', '', '-r "[.icao24, .callsign, .origin_country, .time_position, .last_contact, .lon, .lat, .geo_altitude, .on_ground, .velocity] | @tsv"')
SKIP ALL ERRORS
INTO TABLE flightlocs
FIELDS TERMINATED BY '\t'
(icao, callsign, origin_country, @var1, @var2, @lon, @lat, altitude, on_ground, velocity)
SET time_position = FROM_UNIXTIME(@var1),
last_contact = FROM_UNIXTIME(@var2),
location = CONCAT('POINT(',@lon,' ',@lat,')')
ON DUPLICATE KEY UPDATE time_position = VALUES(flightlocs.time_position),
last_contact = VALUES(flightlocs.last_contact),
location = VALUES(flightlocs.location),
altitude = VALUES(flightlocs.altitude),
on_ground = VALUES(flightlocs.on_ground),
velocity = VALUES(flightlocs.velocity);


CREATE PIPELINE counts_pipeline
AS LOAD DATA KAFKA '172.31.46.241:9092/locs'
WITH TRANSFORM ('memsql://json', '', '-r "[.icao24, .callsign] | @tsv"')
SKIP ALL ERRORS
INTO TABLE flightupdates
FIELDS TERMINATED BY '\t'
(icao, callsign)
ON DUPLICATE KEY UPDATE count = count + 1;
