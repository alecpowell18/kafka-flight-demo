connection: "alec_flight_demo"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

datagroup: flight_demo_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: flight_demo_default_datagroup

explore: flightlocs {}

explore: airlines {}

explore: airportlocs {}

explore: flightupdates {}

explore: nearest_airports {}

explore: active_airlines {}

explore: pipelines_batches {}

map_layer: usa {
  file: "map.topojson"
}
