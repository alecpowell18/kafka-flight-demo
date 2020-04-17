USE demo;

delimiter //
CREATE OR REPLACE FUNCTION find_nearest_airport(arg_callsign VARCHAR(10)) RETURNS TABLE AS
RETURN
select a.icao, a.callsign,
b.iata_code as IATA_Code,b.name as Airport,
round(GEOGRAPHY_DISTANCE(a.location, b.location), 0) as distance
from flightlocs a, airportlocs b
where a.callsign = arg_callsign
and b.type = 'large_airport'
order by distance
limit 1;//
delimiter ;


-- Function to update nearest airports table
delimiter //
CREATE OR REPLACE PROCEDURE update_nearest_airports() AS
DECLARE
        my_query QUERY(callsign VARCHAR(10), altitude INT) = SELECT callsign, altitude from flightlocs limit 100;
        my_array ARRAY(RECORD(callsign VARCHAR(10), altitude INT));
        _callsign VARCHAR(10);
        _altitude INT;
BEGIN
        my_array = COLLECT(my_query);
        FOR i in my_array LOOP
                _callsign = i.callsign;
                _altitude = i.altitude;
                IF _altitude > 500 THEN
                        replace into nearest_airports select * from find_nearest_airport(concat('',_callsign));
                END IF;
        END LOOP;
END //
delimiter ;


-- Function to receive inputs from Kafka pipeline
delimiter //
CREATE OR REPLACE PROCEDURE micro_batch_sp(batch QUERY(
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
	CALL update_nearest_airports();
END //
delimiter ;
