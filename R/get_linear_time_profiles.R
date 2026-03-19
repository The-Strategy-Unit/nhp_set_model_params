get_linear_time_profiles <- function(intervals_data) {
  intervals_data |>
    dplyr::select(!"interval") |>
    dplyr::mutate(l = "linear") |>
    tidyr::nest(.by = "change_factor") |>
    tibble::deframe() |>
    purrr::map(\(x) tidyr::nest(x, .by = "type")) |>
    purrr::map(tibble::deframe) |>
    purrr::map_depth(2, \(x) dplyr::mutate(x, dplyr::across("l", as.list))) |>
    purrr::map_depth(2, tibble::deframe)
}
