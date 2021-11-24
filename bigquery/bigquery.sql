-- find relevant US airports
select *
from `bigquery-public-data.faa.us_airports`
where airport_use = 'Public'
and state_abbreviation = 'CA'
and name like '% Intl'

-- make sure data from your US_FLIGHTS streams ends up in BigQuery
select *
from `sales-engineering-206314.alecdemo.pksqlc_wz0kgUS_FLIGHTS`
limit 10;

-- sample query joining across US_FLIGHTS and FAA US airports public data set
SELECT bq.icao_id as FAACode, 
    bq.name AS ClosestAirport,
    ROUND(ST_DISTANCE(ST_GEOGPOINT(a.lon, a.lat), bq.airport_geom), 0) AS distance,
    count(*) as NumFlights
FROM `cgc-testing.alecdemo.pksqlc_wz0kgUS_FLIGHTS` a,
    `bigquery-public-data.faa.us_airports` bq
WHERE bq.airport_use = 'Public'
    AND bq.name like '% Intl'
GROUP BY FAACode, ClosestAirport, distance
ORDER BY NumFlights desc
LIMIT 500;