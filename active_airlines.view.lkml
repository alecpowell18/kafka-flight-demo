view: active_airlines {
  # Or, you could make this view a derived table, like this:
  derived_table: {
#     persist_for: "1 minute"
    sql: select
      a.operatorName as Airline,
      a.operatorCode as Operator_Code,
      count(*) as Count
        from flightlocs f join airlines a
        on left(f.callsign,3) = a.operatorCode
        where timestampdiff(HOUR, f.last_contact, now()) < 1
        group by 1
      ;;
  }

  # Define your dimensions and measures here, like this:
  dimension: airline {
    description: "Unique ID for each user that has ordered"
    type: string
    sql: ${TABLE}.Airline ;;
  }

  dimension: operator_code {
    description: "The total number of orders for each user"
    type: string
    sql: ${TABLE}.Operator_Code ;;
  }

  measure: active_num_flights {
    description: "Use this for counting flights per airline"
    type: sum
    sql: ${TABLE}.Count ;;
  }
}
