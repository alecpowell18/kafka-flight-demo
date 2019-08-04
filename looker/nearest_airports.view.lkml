view: nearest_airports {
  sql_table_name: demo.nearest_airports ;;

  dimension: airport_iata {
    type: string
    sql: ${TABLE}.airport_iata ;;
  }

  dimension: airport_name {
    type: string
    sql: ${TABLE}.airport_name ;;
  }

  dimension: callsign {
    type: string
    sql: ${TABLE}.callsign ;;
  }

  dimension: distance {
    type: number
    sql: ${TABLE}.distance ;;
  }

  dimension: icao {
    type: string
    sql: ${TABLE}.icao ;;
  }

  measure: count {
    type: count
    drill_fields: [airport_name]
  }
}
