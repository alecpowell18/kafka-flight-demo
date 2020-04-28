USE demo;


-- Table-valued function to find the nearest airport to the given callsign
DELIMITER //
CREATE OR REPLACE FUNCTION find_nearest_airport(arg_callsign VARCHAR(10)) RETURNS TABLE AS
RETURN
	SELECT a.icao, a.callsign,
	b.iata_code AS IATA_Code, b.name AS Airport,
	ROUND(GEOGRAPHY_DISTANCE(a.location, b.location), 0) AS distance
	FROM flightlocs a, airportlocs b
	WHERE a.callsign = arg_callsign
    AND TIME_TO_SEC(TIMEDIFF(NOW(), a.last_contact)) < 3600
	AND b.type = 'large_airport'
	ORDER BY distance
	LIMIT 1;//
DELIMITER ;


-- Procedure to update nearest airports table
DELIMITER //
CREATE OR REPLACE PROCEDURE update_nearest_airports() AS
DECLARE
        my_query QUERY(callsign VARCHAR(10), altitude INT) = SELECT callsign, altitude FROM flightlocs ORDER BY RAND() LIMIT 100;
        my_array ARRAY(RECORD(callsign VARCHAR(10), altitude INT));
        _callsign VARCHAR(10);
        _altitude INT;
BEGIN
        my_array = COLLECT(my_query);
        FOR i in my_array LOOP
                _callsign = i.callsign;
                _altitude = i.altitude;
                IF _altitude > 500 THEN
                        REPLACE INTO nearest_airports SELECT * FROM find_nearest_airport(concat('',_callsign));
                END IF;
        END LOOP;
END //
DELIMITER ;


-- Procedure which will process inputs from Kafka pipeline
DELIMITER //
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
	callsignQ QUERY(callsign varchar(10)) = SELECT _callsign FROM batch;
	callsigns ARRAY(RECORD(callsign varchar(10))) = collect(callsignQ);
	callsign_value varchar(10);
BEGIN
	REPLACE INTO flightlocs SELECT * FROM batch;

	INSERT INTO flightupdates (icao, callsign)
		SELECT _icao, _callsign FROM batch
		ON DUPLICATE KEY UPDATE count = count + 1;
	CALL update_nearest_airports();
END //
DELIMITER ;