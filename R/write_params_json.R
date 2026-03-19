#' Create custom NHP model parameters and write them to a JSON file
#'
#' @inheritParams create_custom_params
#' @param save_to file path. The location to which the .json file will be
#'  written. The default value is `"."` (the user's current working directory).
#'
#' @returns The location to which the params.json file will be written
#' @export
write_params_json <- function(config_file, intervals_data, save_to = ".", ...) {
  custom_data <- create_custom_params(config_file, intervals_data, ...)
  file_basename <- custom_data[["file_basename"]]
  write_params_to_file(custom_data[["custom_params"]], file_basename, save_to)
}


#' Create custom NHP model parameters
#'
#' Use a YAML config file to set up a base params list. Intervals data is
#'  then required. Specific values in the params list may be supplied using
#'  named values in `...`. These will replace existing values or NULLs from the
#'  base config.
#'
#' @param config_file string. File path to a YAML config file that specifies
#'  essential elements of the params list to be created.
#' @param intervals_data data frame containing p10 and p90 intervals for TPMAs.
#'  Must contain columns `type`, `change_factor`, `strategy` and `interval`.
#'  These intervals will be used to create the params and time profile mappings
#'  for all included TPMAs ("strategies").
#' @param ... Named arguments that you can use to supply values to fill in blank
#'  values from the config, or overwrite values from the config.
#'  Using `...` is an alternative to editing the config file directly, and may
#'  facilitate the programmatic generation of params files.
#'  In particular, the "dataset", "scenario" and "seed" elements of the params
#'  list do not generally have default values and so may be blank (NULL,
#'  unspecified) in the base config. These must not remain blank, so you must
#'  supply values here if they are not already supplied in the config file.
#'
#' @returns A list containing a derived output filename and the custom params
#' @export
create_custom_params <- function(config_file, intervals_data, ...) {
  supplementary_params <- rlang::list2(...)
  create_dttm <- substr(sub(" ", "_", gsub("[:-]", "", Sys.time())), 1L, 15L)
  intervals_lst <- get_intervals_list(intervals_data)
  time_profiles_lst <- get_linear_time_profiles(intervals_data)
  ndg3_values_lst <- yaml::read_yaml(get_local_sysfile("ndg3_values.yaml"))

  params_lst <- yaml12::read_yaml(config_file) |>
    purrr::assign_in("create_datetime", create_dttm) |>
    purrr::assign_in("time_profile_mappings", time_profiles_lst) |>
    purrr::modify_at("user", \(x) x %||% Sys.getenv("NHP_API_USER", NULL))

  if (base_params[["non-demographic_adjustment"]] == "ndg3") {
    base_params <- base_params |>
      purrr::assign_in("non-demographic_adjustment", ndg3_values_lst)
  }
  to_check <- c("dataset", "scenario", "seed", "user")
  chkd <- rlang::set_names(purrr::map(to_check, check_specified), to_check)
  file_basename <- stringr::str_to_snake(paste(chkd[["scenario"]], create_dttm))
  custom_params <- base_params |>
    purrr::list_modify(!!!intervals_lst) |>
    purrr::list_merge(!!!supplementary_params)
  list(file_basename = file_basename, custom_params = custom_params)
}


#' Function to check that a params element is not NULL
#'
#' @param x The name of the list element to check
#' @keywords internal
check_specified <- function(x, bp = base_params, sp = supplementary_params) {
  msg <- "{.fn create_custom_params}: variable {.var {x}} was not specified"
  out <- bp[[x]] %||% sp[[x]]
  if (is.null(out)) {
    cli::cli_abort(msg, class = "params_check")
  } else {
    out
  }
}


get_local_sysfile <- function(...) {
  purrr::partial(system.file, package = "modparams", mustWork = TRUE)(...)
}


write_params_to_file <- function(lst, file_basename, save_dir) {
  file_out <- file.path(save_dir, paste0(file_basename, ".json"))
  yyj_write_opts <- yyjsonr::opts_write_json(pretty = TRUE, auto_unbox = TRUE)
  yyjsonr::write_json_file(lst, file_out, yyj_write_opts)
  file_out
}
