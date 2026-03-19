test_that("the usual", {
  custom_params <- list(dataset = "national")
  config_file <- get_local_sysfile("config_v4.4.yaml")
  expect_true(file.exists(config_file))
  base_params <- expect_no_error(yaml::read_yaml(config_file))
  expect_null(base_params[["dataset"]])
  new_params <- purrr::list_merge(base_params, !!!custom_params)
  expect_identical(new_params[["dataset"]], "national")
})


test_that("`get_local_sysfile()` works", {
  expect_true(rlang::is_installed("modparams"))
  expect_true(file.exists(get_local_sysfile("ndg3_values.yaml")))
  expect_no_error(yaml::read_yaml(get_local_sysfile("ndg3_values.yaml")))
})
