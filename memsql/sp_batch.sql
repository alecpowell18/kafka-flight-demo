delimiter //
CREATE OR REPLACE PROCEDURE test(batch QUERY(
	_icao VARCHAR(10),
	_callsign VARCHAR(10),
	_origin_country VARCHAR(50),
	_time_position TIMESTAMP,
	_last_contact TIMESTAMP,
	_location GEOGRAPHYPOINT,
	_altitude INT,
	_on_ground BOOLEAN,
	_velocity INT)) AS
DECLARE
	callsignQ QUERY(callsign varchar(10)) = select _callsign from batch;
	callsigns ARRAY(RECORD(callsign varchar(10))) = collect(callsignQ);
	callsign_value varchar(10);
BEGIN
	REPLACE INTO flightlocs SELECT * from batch;

	INSERT INTO flightupdates (icao, callsign)
		SELECT _icao, _callsign from batch
		ON DUPLICATE KEY UPDATE count = count + 1;
END
//
delimiter ;

CREATE PIPELINE p AS
LOAD DATA KAFKA '172.31.46.241:9092/locs'
WITH TRANSFORM ('memsql://json', '', '-r "[.icao24, .callsign, .origin_country, .time_position, .last_contact, .lon, .lat, .geo_altitude, .on_ground, .velocity] | @tsv"')
SKIP ALL ERRORS
INTO PROCEDURE test
(_icao, _callsign, _origin_country, @var1, @var2, @lon, @lat, _altitude, _on_ground, _velocity)
SET _time_position = FROM_UNIXTIME(@var1),
_last_contact = FROM_UNIXTIME(@var2),
_location = CONCAT('POINT(',@lon,' ',@lat,')');





optimize pipeline p;


#update nearest airport
	-- FOR i in callsigns LOOP
	-- 	callsign_value = i.callsign;
	-- 	replace into nearest_airports select * from find_nearest_airport(callsign_value);
	-- END LOOP;

	#insert overwrite into original table

	#update count of updates for this specific flight


	nearest_airport RECORD(icao varchar(10),callsign varchar(10),airport_iata varchar(10),airport_name varchar(10),distance float);
		nearest_airport = COLLECT(select * from find_nearest_airport(callsign_value))
