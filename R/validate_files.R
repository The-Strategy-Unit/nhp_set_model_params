#' Validate JSON files against the relevant NHP params schema
#'
#' @param files List of paths to the JSON files to validate, or of JSON strings
#' @param version string. The NHP schema version to validate against eg "v4.4"
#' @param ... Options that may be passed through to the `validate` method of
#'  [jsonvalidate::json_schema], which specify the behaviour on validation
#'  failure, for example whether to return a logical `FALSE` or throw an error.
#'
#' @returns A list the same length as `files` containing `TRUE` where a file
#'  is valid and `FALSE`, by default, otherwise. For further configuration of
#'  how validation errors are handled, see [jsonvalidate::json_schema]$validate.
#' @export
validate_files <- function(files, version, ...) {
  schema_obj <- get_schema(version)
  purrr::map(files, \(x) rlang::inject(schema_obj$validate(x, ...)))
}


get_schema <- function(version) {
  stopifnot(grepl("^(v[1-5]\\.[0-9]+|dev)$", version))
  schema_url <- build_schema_url(version)
  sch <- withr::local_tempfile()
  x <- utils::download.file(schema_url, sch, mode = "wb", quiet = TRUE)
  stopifnot(`Failed to download schema file` = x == 0L)
  cat("\n", file = sch, append = TRUE)
  jsonvalidate::json_schema$new(sch)
}


build_schema_url <- function(version) {
  base_url <- "https://the-strategy-unit.github.io"
  file.path(base_url, "nhp_model", version, "params-schema.json")
}
