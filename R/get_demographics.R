#' Get provider demographics from the OpenPlan API
#'
#' @param provider string. The provider identifier.
#' @param start_year integer. The start year for the demographic data.
#' @param end_year integer. The end year for the demographic data.
#' @param variant string. The demographic variant to use. Default is "migration_category".
#'
#' @returns A list containing the demographic data, with the variant included.
#' @export
get_provider_demographics <- function(
  provider,
  start_year,
  end_year,
  variant = "migration_category"
) {
  app_id <- Sys.getenv("AZ_APP_ID")
  tenant_id <- Sys.getenv("AZ_TENANT_ID")
  api_endpoint <- Sys.getenv("OPENPLAN_API_ENDPOINT")

  if (!nzchar(app_id) || !nzchar(tenant_id)) {
    cli::cli_abort("AZ_APP_ID and AZ_TENANT_ID envvars must be set.")
  }

  if (!nzchar(api_endpoint)) {
    cli::cli_abort("OPENPLAN_API_ENDPOINT envvar must be set.")
  }

  token <- azkit::get_auth_token(app_id, tenant_id) |>
    AzureAuth::extract_jwt()

  req <- httr2::request(api_endpoint) |>
    httr2::req_auth_bearer_token(token) |>
    httr2::req_url_path_append(
      "v1",
      "demographics",
      "provider",
      provider,
      start_year,
      end_year,
      variant
    )

  resp <- req |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  c(list(variant = variant), resp)
}
