view: pipelines_batches {
  sql_table_name: information_schema.PIPELINES_BATCHES ;;

  dimension: batch_earliest_offset {
    type: number
    sql: ${TABLE}.BATCH_EARLIEST_OFFSET ;;
  }

  dimension: batch_id {
    type: number
    sql: ${TABLE}.BATCH_ID ;;
  }

  dimension: batch_latest_offset {
    type: number
    sql: ${TABLE}.BATCH_LATEST_OFFSET ;;
  }

  dimension: batch_partition_extracted_bytes {
    type: number
    sql: ${TABLE}.BATCH_PARTITION_EXTRACTED_BYTES ;;
  }

  dimension: batch_partition_parsed_rows {
    type: number
    sql: ${TABLE}.BATCH_PARTITION_PARSED_ROWS ;;
  }

  dimension: batch_partition_state {
    type: string
    sql: ${TABLE}.BATCH_PARTITION_STATE ;;
  }

  dimension: batch_partition_time {
    type: number
    sql: ${TABLE}.BATCH_PARTITION_TIME ;;
  }

  dimension: batch_partition_transformed_bytes {
    type: number
    sql: ${TABLE}.BATCH_PARTITION_TRANSFORMED_BYTES ;;
  }

  dimension: batch_rows_written {
    type: number
    sql: ${TABLE}.BATCH_ROWS_WRITTEN ;;
  }

  dimension: batch_source_partition_id {
    type: string
    sql: ${TABLE}.BATCH_SOURCE_PARTITION_ID ;;
  }

  dimension: batch_start_unix_timestamp {
    type: number
    sql: ${TABLE}.BATCH_START_UNIX_TIMESTAMP ;;
  }

  dimension: batch_state {
    type: string
    sql: ${TABLE}.BATCH_STATE ;;
  }

  dimension: batch_time {
    type: number
    sql: ${TABLE}.BATCH_TIME ;;
  }

  dimension: database_name {
    type: string
    sql: ${TABLE}.DATABASE_NAME ;;
  }

  dimension: host {
    type: string
    sql: ${TABLE}.HOST ;;
  }

  dimension: partition {
    type: number
    sql: ${TABLE}.PARTITION ;;
  }

  dimension: pipeline_name {
    type: string
    sql: ${TABLE}.PIPELINE_NAME ;;
  }

  dimension: port {
    type: number
    sql: ${TABLE}.PORT ;;
  }

  dimension: rowspersec {
    type: number
    sql:  ${batch_partition_parsed_rows}/${batch_partition_time} ;;
  }

  measure: count {
    type: count
    drill_fields: [database_name, pipeline_name]
  }
}
