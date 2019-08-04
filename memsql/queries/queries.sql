-- #Flights from United

-- select * from flightlocs where left(callsign,3) = 'UAL';


-- #Top airports by distance for a given flight

-- select a.icao, a.callsign, a.origin_country,
-- b.name as Airport, b.iso_country as Country, b.iata_code as IATA_Code, b.ident as Identifier,
-- round(GEOGRAPHY_DISTANCE(a.location, b.location), 0) as distance
-- from flightlocs a, airportlocs b
-- where a.callsign = 'UAL989'
-- and b.type = 'large_airport'
-- order by distance
-- limit 10;


-- #look at callsigns
-- select distinct(left(callsign,3)) as code from flightlocs where callsign like 'V%' order by 1;


-- select * from airlines where operatorCode like 'V%';


-- #get active airlines
-- #get all airlines first
-- select a.operatorName as Airline, a.operatorCode as Operator_Code, count(*) as Count
-- from flightlocs f join airlines a
-- on left(f.callsign,3) = a.operatorCode
-- where timestampdiff(HOUR, f.last_contact, now()) < 1
-- group by 1;



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

