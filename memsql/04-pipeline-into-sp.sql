USE demo;
-- Pipelines into Stored Procedures example --

CREATE PIPELINE storedproc_pipeline AS
LOAD DATA KAFKA 'kafka:29092/locs'
WITH TRANSFORM ('memsql://json', '', '-r "[.icao24, .callsign, .origin_country, .time_position, .last_contact, .lon, .lat, .geo_altitude, .on_ground, .velocity] | @tsv"')
SKIP PARSER ERRORS
INTO PROCEDURE micro_batch_sp 
(_icao, _callsign, _origin_country, @var1, @var2, @lon, @lat, _altitude, _on_ground, _velocity)
SET _time_position = FROM_UNIXTIME(@var1),
_last_contact = FROM_UNIXTIME(@var2),
_location = CONCAT('POINT(',@lon,' ',@lat,')');
