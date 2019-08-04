view: flightupdates {
  sql_table_name: demo.flightupdates ;;

  dimension: callsign {
    type: string
    sql: ${TABLE}.callsign ;;
  }

  dimension: this_count {
    type: number
    sql: ${TABLE}.count ;;
  }

  dimension: icao {
    type: string
    sql: ${TABLE}.icao ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

}
