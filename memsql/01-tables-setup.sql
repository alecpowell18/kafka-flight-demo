CREATE DATABASE IF NOT EXISTS demo;
USE demo;

CREATE TABLE IF NOT EXISTS flightlocs (
	icao varchar(10),
	callsign varchar(10),
	origin_country varchar(50),
	time_position timestamp,
	last_contact timestamp,
	location GEOGRAPHYPOINT,
	-- longitude_deg float,
	-- latitude_deg float,
	altitude int,
	on_ground boolean,
	velocity int,
	PRIMARY KEY id (`icao`,`callsign`)
);

CREATE TABLE IF NOT EXISTS flightupdates (
	icao varchar(10),
	callsign varchar(10),
	count int default 0,
	PRIMARY KEY id (`icao`,`callsign`)
);

CREATE TABLE IF NOT EXISTS airportlocs (
	id int PRIMARY KEY,
	ident text,
	type text,
	name text,
	latitude_deg float,
	longitude_deg float,
	elevation int,
	continent text,
	iso_country text,
	iso_region text,
	municipality text,
	scheduled_service boolean,
	gps_code text,
	iata_code text,
	local_code text,
	home_link text,
	wikipedia_link text,
	keywords text,
	location as concat("POINT(",cast(longitude_deg as binary)," ",cast(latitude_deg as binary),")") PERSISTED GEOGRAPHYPOINT
);

CREATE TABLE IF NOT EXISTS airlines (
	operatorCode text PRIMARY KEY,
	operatorName text,
	countryName text,
	countryCode text,
	lastUpdate timestamp
);

CREATE TABLE IF NOT EXISTS nearest_airports (
	icao varchar(10),
	callsign varchar(10),
	airport_iata varchar(10),
	airport_name varchar(10),
	distance float,
	PRIMARY KEY (`icao`, `callsign`)
);

LOAD DATA LOCAL INFILE './data/airports.csv'
SKIP ALL ERRORS
INTO TABLE airportlocs
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY ''
IGNORE 1 LINES;


LOAD DATA LOCAL INFILE './data/airlines.csv'
SKIP ALL ERRORS
INTO TABLE airlines
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY ''
IGNORE 1 LINES;
