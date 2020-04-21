SELECT
	active_airlines.Airline  AS `active_airlines.airline`,
	COALESCE(SUM(active_airlines.Count ), 0) AS `active_airlines.active_num_flights`
FROM (select
      a.operatorName as Airline,
      a.operatorCode as Operator_Code,
      count(*) as Count
        from flightlocs f join airlines a
        on left(f.callsign,3) = a.operatorCode
        where timestampdiff(HOUR, f.last_contact, now()) < 1
        group by 1
      ) AS active_airlines

GROUP BY 1
ORDER BY COALESCE(SUM(active_airlines.Count ), 0) DESC
LIMIT 15;
