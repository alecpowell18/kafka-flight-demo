view: airportlocs {
  sql_table_name: demo.airportlocs ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: continent {
    type: string
    sql: ${TABLE}.continent ;;
  }

  dimension: elevation {
    type: number
    sql: ${TABLE}.elevation ;;
  }

  dimension: gps_code {
    type: string
    sql: ${TABLE}.gps_code ;;
  }

  dimension: home_link {
    type: string
    sql: ${TABLE}.home_link ;;
  }

  dimension: iata_code {
    type: string
    sql: ${TABLE}.iata_code ;;
  }

  dimension: ident {
    type: string
    sql: ${TABLE}.ident ;;
  }

  dimension: iso_country {
    type: string
    sql: ${TABLE}.iso_country ;;
  }

  dimension: iso_region {
    type: string
    sql: ${TABLE}.iso_region ;;
  }

  dimension: keywords {
    type: string
    sql: ${TABLE}.keywords ;;
  }

  dimension: latitude_deg {
    type: number
    sql: ${TABLE}.latitude_deg ;;
  }

  dimension: local_code {
    type: string
    sql: ${TABLE}.local_code ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}.location ;;
  }

  dimension: longitude_deg {
    type: number
    sql: ${TABLE}.longitude_deg ;;
  }

  dimension: municipality {
    type: string
    sql: ${TABLE}.municipality ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: scheduled_service {
    type: yesno
    sql: ${TABLE}.scheduled_service ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: wikipedia_link {
    type: string
    sql: ${TABLE}.wikipedia_link ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name]
  }
}
