view: flightlocs {
  sql_table_name: demo.flightlocs ;;


  dimension: callsign {
    type: string
    sql: ${TABLE}.callsign ;;
  }

  dimension: icao {
    type: string
    sql: ${TABLE}.icao ;;
  }

  dimension_group: last_contact {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.last_contact ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}.location ;;
  }

  dimension: location_looker {
    label: "Flight Location"
    type: location
    map_layer_name: usa
    sql_latitude: round(geography_latitude(${location}),3) ;;
    sql_longitude: round(geography_longitude(${location}),3) ;;
  }

  dimension: on_ground {
    type: yesno
    sql: ${TABLE}.on_ground ;;
  }

  dimension: origin_country {
    type: string
    sql: ${TABLE}.origin_country ;;
  }

  dimension_group: time_position {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.time_position ;;
  }

  dimension: velocity {
    type: number
    sql: ${TABLE}.velocity ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: altitude {
    type: number
    sql: ${TABLE}.altitude ;;
  }

}
