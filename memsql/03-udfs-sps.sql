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
limit 1;
//

-- Function to receive inputs from Kafka pipeline

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
