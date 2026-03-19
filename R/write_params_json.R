#' Create custom NHP model parameters and write them to a JSON file
#'
#' @inheritParams create_custom_params
#' @param save_to path. The directory to which the .json file will be written.
#'  The default value is `"."` (the user's current working directory).
#'
#' @returns The full file path to which the .json file has been written
#' @export
write_params_json <- function(config_file, intervals_data, save_to = ".", ...) {
  params_lst <- create_custom_params(config_file, intervals_data, ...)
  filenm_stub <- glue::glue_data(params_lst, "{scenario}_{create_datetime}")
  write_params_to_file(params_lst, filenm_stub, save_to)
}


#' Create a list of custom NHP model parameters
#'
#' Use a YAML config file to set up a base params list. Intervals data must also
#'  be supplied. Specific values may be supplied using named values in `...`.#'  These will replace existing values or NULLs from the base config.
#'
#' @param config_file string. File path to a YAML config file that specifies
#'  essential elements of the params list to be created.
#' @param intervals_data data frame containing p10 and p90 intervals for TPMAs.
#'  Must contain columns `type`, `change_factor`, `strategy` and `interval`.
#'  These intervals will be used to create the params and time profile mappings
#'  for all included TPMAs (aka "strategies").
#' @param ... Named arguments that you can use to provide values that are empty
#'  in the config file, and to potentially overwrite default values.
#'  Using `...` is an alternative to editing the config file directly, and may
#'  facilitate the programmatic generation of params lists.
#'  In particular, the "dataset", "scenario", "user" and "seed" elements of the
#'  params list do not generally have default values and so are empty (NULL,
#'  unspecified) in the default config. These must not remain empty, so you must
#'  supply values here if you have not already edited them in the config file.
#'
#' @returns A list of custom params
#' @export
create_custom_params <- function(config_file, intervals_data, ...) {
  create_dttm <- substr(sub(" ", "_", gsub("[:-]", "", Sys.time())), 1L, 15L)
  intervals <- get_intervals_list(intervals_data)
  time_profiles <- get_linear_time_profiles(intervals_data)

  params_lst <- yaml12::read_yaml(config_file) |>
    purrr::assign_in("create_datetime", create_dttm) |>
    purrr::modify_at("time_profile_mappings", \(x) {
      purrr::list_modify(x, !!!time_profiles)
    }) |>
    purrr::list_modify(!!!intervals) |>
    purrr::list_modify(...)

  # Currently, assigning ndg3 values is the only valid option here. But this
  # step is set up so as to be ready to work with other options in future.
  if (params_lst[["non-demographic_adjustment"]] == "ndg3") {
    ndg3_values <- yaml12::read_yaml(get_local_sysfile("ndg3_values.yaml"))
    purrr::assign_in(params_lst, "non-demographic_adjustment", ndg3_values)
  } else {
    params_lst
  }
}


get_local_sysfile <- function(...) {
  purrr::partial(system.file, package = "modparams", mustWork = TRUE)(...)
}


#' Write a list of params to a .json file
#'
#' @param params_lst R list of custom params (created by [create_custom_params])
#' @param filenm_stub A file name stub (.json extension will be added)
#' @inheritParams write_params_json
#' @returns The full file path to which the .json file has been written
#' @export
write_params_to_file <- function(params_lst, filenm_stub, save_to) {
  file_out <- file.path(save_to, paste0(filenm_stub, ".json"))
  yyj_write_opts <- yyjsonr::opts_write_json(pretty = TRUE, auto_unbox = TRUE)
  yyjsonr::write_json_file(params_lst, file_out, yyj_write_opts)
  file_out
}
