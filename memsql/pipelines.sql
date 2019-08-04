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




-- Pipelines into Stored Procedures example --

CREATE PIPELINE p AS
LOAD DATA KAFKA '172.31.46.241:9092/locs'
WITH TRANSFORM ('memsql://json', '', '-r "[.icao24, .callsign, .origin_country, .time_position, .last_contact, .lon, .lat, .geo_altitude, .on_ground, .velocity] | @tsv"')
SKIP ALL ERRORS
INTO PROCEDURE test
(_icao, _callsign, _origin_country, @var1, @var2, @lon, @lat, _altitude, _on_ground, _velocity)
SET _time_position = FROM_UNIXTIME(@var1),
_last_contact = FROM_UNIXTIME(@var2),
_location = CONCAT('POINT(',@lon,' ',@lat,')');

















LOAD DATA INFILE '/home/ubuntu/airports.csv'
SKIP ALL ERRORS
INTO TABLE airportlocs
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY '';


LOAD DATA INFILE '/home/ubuntu/airlines.csv'
SKIP ALL ERRORS
INTO TABLE airlines
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY '';
