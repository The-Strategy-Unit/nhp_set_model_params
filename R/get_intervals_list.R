get_intervals_list <- function(intervals_data) {
  intervals_data |>
    tidyr::nest(.by = "change_factor") |>
    tibble::deframe() |>
    purrr::map(\(x) tidyr::nest(x, .by = "type")) |>
    purrr::map(tibble::deframe) |>
    purrr::map_depth(2, tibble::deframe) |>
    # efficiencies must have a type as well as an interval
    purrr::modify_at("efficiencies", \(x) {
      x |>
        # most have type = "all"...
        purrr::map_depth(2, \(x) purrr::list_merge(x, type = "all")) |>
        # but some are different
        purrr::modify_at("ip", adjust_ip_efficiencies)
    })
}


adjust_ip_efficiencies <- function(efficiencies_ip_list) {
  efficiencies_ip_list |>
    purrr::modify_at(\(x) grepl("^same_day_emergency_care", x), \(x) {
      purrr::list_modify(x, type = "sdec")
    }) |>
    purrr::modify_at(\(x) grepl("^day_procedures.*dc$", x), \(x) {
      purrr::list_modify(x, type = "day_procedures_daycase")
    }) |>
    purrr::modify_at(\(x) grepl("^day_procedures.*op$", x), \(x) {
      purrr::list_modify(x, type = "day_procedures_outpatients")
    }) |>
    purrr::modify_at(\(x) grepl("^pre-op_los", x), \(x) {
      purrr::list_modify(x, type = "pre-op")
    }) |>
    purrr::modify_at("pre-op_los_1-day", \(x) {
      purrr::list_merge(x, `pre-op_days` = 1L)
    }) |>
    purrr::modify_at("pre-op_los_2-day", \(x) {
      purrr::list_merge(x, `pre-op_days` = 2L)
    })
}
