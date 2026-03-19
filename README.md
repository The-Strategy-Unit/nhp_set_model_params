# {modparams} ![R](https://www.r-project.org/favicon-32x32.png)🛵📦📝

<!-- badges: start -->
[![MIT licence](https://img.shields.io/badge/License-MIT-yellow.svg)][mitlic]
[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable release][repostatus_svg]][repostatus_info]
[![Lifecycle: experimental][lifecycle_svg]][lifecycle]
![GitHub R package version][gh_ver]

[mitlic]: https://opensource.org/licenses/MIT
[repostatus_info]: https://www.repostatus.org/#wip
[repostatus_svg]: https://www.repostatus.org/badges/latest/wip.svg
[lifecycle]: https://lifecycle.r-lib.org/articles/stages.html#experimental
[lifecycle_svg]: https://img.shields.io/badge/lifecycle-experimental-orange.svg
[gh_ver]: https://img.shields.io/github/r-package/v/The-Strategy-Unit/nhp_set_model_params
<!-- badges: end -->

Set up and modify NHP model parameter lists, and export them as JSON files.

While the repository is `nhp_set_model_params`, the R package is just
`modparams`.


## Installation

You should be able to run the following R command to install {modparams}:

```r
# install.packages("pak") # if not already installed
pak::pak("The-Strategy-Unit/nhp_set_model_params")
```

## Usage

### Requirements

You will need a dataframe of intervals data to create the custom params file.

This might be generated via the [composite scheme and nee][compsch] intervals
project, by rendering the qmd file there.
This method by default will save an `rds` file into your current working
directory.

Use `readRDS()` to read the file into R, creating a list object that will
contain multiple tables of interval data.

(Alternatively, extend the code within your own copy of the qmd file, processing
the `intervals_list` object that is created, rather than using the rds file
outside the qmd.)


[compsch]: https://github.com/The-Strategy-Unit/composite_scheme_and_nee_intervals_for_tpmas


### Create custom params!

There are a couple of ways to approach this.
The first option is probably preferable.

1. You might do something like this:


```r
intervals_list <- readRDS("intervals_data_from_qmd.rds")

# config skeleton for NHP model version 4.4
config_file <- system.file("config_v4.4.yaml", package = "modparams")
model_version <- "v4.4"

# `write_params_json()` writes a file to disk, and returns the path to the file
file_out <- modparams::write_params_json(
  config_file,
  intervals_list[[1]], # it is probably safer to use the list element name
  dataset = "ZZZ",
  scenario = "my-custom-scenario", # check this matches the intervals data
  seed = 87654L, # can be any random integer
  user = "nhp.user", # you should use your own name/username
  end_year = 2039L # supply years as integers (with the `L` suffix) or strings
)
```

2. Or you could edit a YAML config file directly, in which case you can do:

```r
config_file <- "custom_config.yaml"
file.copy(system.file("config_v4.4.yaml", package = "modparams"), config_file)

# manually edit custom_config.yaml to add dataset, scenario, user etc.

file_out <- modparams::write_params_json(config_file, intervals_list[[1]])
```

You can validate the file you have just created:

```r
modparams::validate_files(file_out, model_version)
```
This should return `TRUE` if your file validates according to the NHP model
JSON Schema, or return `FALSE`.
You can use `error = TRUE` to get the function to error if the file is invalid:

```r
modparams::validate_files(file_out, model_version, error = TRUE)
```


### Things to note

Certain params must be supplied by the user:

* `config_file`
* `intervals_data`
* `dataset`*
* `scenario`*
* `seed`*
* `user`*

\* *supplied within `...` or by editing the config file*

Other arguments can be used to overwrite the default values in the config file.
This is probably easier than editing the config file directly, but whatever
suits you.

In the above example, although `end_year` has a default value in the config
file, this is overridden by the value passed into the function via `...`.


## Limitations / future development

Please make suggestions for future development via the Issues area of the repo.
And of course report any problems or bugs found, noting what you expected to
happen and what you actually observed.

Currently (March 2026) we are at v4.4 of the NHP model:

* The package currently only handles NDG3 values.
* Only "linear" time profiles are catered for, which matches the current design
  of the NHP model.
* The v4.4 YAML config file included in the package is likely to be suitable for
  use with any later v4.x versions.
  But future versions (eg from v5) may require updated YAML skeleton configs.
