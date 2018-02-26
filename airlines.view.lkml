view: airlines {
  sql_table_name: demo.airlines ;;

  dimension: country_code {
    type: string
    sql: ${TABLE}.countryCode ;;
  }

  dimension: country_name {
    type: string
    sql: ${TABLE}.countryName ;;
  }

  dimension_group: last_update {
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
    sql: ${TABLE}.lastUpdate ;;
  }

  dimension: operator_code {
    type: string
    sql: ${TABLE}.operatorCode ;;
  }

  dimension: operator_name {
    type: string
    sql: ${TABLE}.operatorName ;;
  }

  measure: count {
    type: count
    drill_fields: [operator_name, country_name]
  }
}
