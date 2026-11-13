# {modparams} ![R](https://www.r-project.org/favicon-32x32.png)🛵📦📝

<!-- badges: start -->
[![License: MIT][mit_svg]][mitlic]
[![Project Status: Active -- The project has reached a stable, usable state and
is being actively developed][repostatus_svg]][repostatus_info]
![GitHub R package version][gh_ver]

[mit_svg]: https://img.shields.io/badge/License-MIT-yellow.svg?label=licence
[mitlic]: https://opensource.org/licenses/MIT
[repostatus_svg]: https://www.repostatus.org/badges/latest/active.svg
[repostatus_info]: https://www.repostatus.org/#active
[gh_ver]: https://img.shields.io/github/r-package/v/The-Strategy-Unit/nhp_set_model_params
<!-- badges: end -->

Set up and modify OpenPlan model parameter lists, and export them as JSON files.

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
outside the qmd. The `generate_params` branch of the composite scheme and nee
repo contains some additional code in the qmd to support this approach.)


[compsch]: https://github.com/The-Strategy-Unit/composite_scheme_and_nee_intervals_for_tpmas


### Create custom params!

There are a couple of ways to approach this.
The first option is probably preferable.

1. You might do something like this:


```r
# rds previously saved, or exported from the quarto process in the composite
# schemes / NEE intervals repository
intervals_list <- readRDS("intervals_data_from_qmd.rds")

# Note that this is the OpenPlan model version, unrelated to the version of this
# package
model_version <- "v6.2"

# config skeleton for the selected OpenPlan model version
config_file <- modparams::get_config_filepath(model_version)

# `write_params_json()` writes a file to disk, and returns the path to the file
file_out <- modparams::write_params_json(
  config_file,
  intervals_list[[1]], # it is probably safer to use the list element name
  dataset = "ZZZ",
  scenario = "my-custom-scenario", # check this matches the intervals data
  seed = 87654L, # can be any random integer
  user = "nhp.user", # you should use your own name/username
  end_year = 2043L # supply years as integers (with the `L` suffix) or strings
)
```

2. Or you could edit a YAML config file directly, in which case you can do:

```r
config_file <- "custom_config.yaml"
file.copy(modparams::get_config_filepath(model_version), config_file)

# ! Now manually edit custom_config.yaml to add dataset, scenario, user etc.

file_out <- modparams::write_params_json(config_file, intervals_list[[1]])
```

### Validate your generated params file

You can validate the file you have just created:

```r
modparams::validate_files(file_out, model_version)
```
(note that `write_params_json()` returns the file path to the file it created.)

This should return `TRUE` if your file validates according to the OpenPlan model
JSON Schema, or return `FALSE`.

You can use `error = TRUE` to get the function to error if the file is invalid:

```r
modparams::validate_files(file_out, model_version, error = TRUE)
```


### Things to note

There are certain params you as the user must supply:

* `config`
* `intervals_data`
* `dataset`*
* `scenario`*
* `seed`*
* `user`*

\* _supplied within `...`, or by editing the config file_

Other arguments can be used to overwrite the default values in the config file.
This is probably easier than editing the config file directly; but whatever
suits you.

In the above example, although `end_year` has a default value in the config
file, this is overridden by the value passed into the function via `...`.


## Working with different model versions

The package is set up to work with the latest version of the OpenPlan model.
New versions are released with git tags matching the OpenPlan model number.

If you need to create params that match the schema for a previous model version,
you can do this by switching to a tag as appropriate.
This will "time travel" the package to the way it was when that tag was applied.
You can then switch back to the latest tag.


The list of tagged releases is available [here][tags_page].

[tags_page]: https://github.com/The-Strategy-Unit/nhp_set_model_params/tags


### How to switch to a different version tag, option 1: via `{pak}`

This is simpler in a way but a bit more clunky and less flexible.

At the top of this README you were instructed to use `{pak}` to install the
package.
`pak::pkg_install` is able to install a package from a particular tag, using
the `@` format.

So if you wanted to switch to the version of this package that matches model
version v5.1, you could do:

```r
pak::pak("The-Strategy-Unit/nhp_set_model_params@nhp_v5.1")
```

This would install the package and then you'd be ready to go.

In order to get back to the latest version, either use the latest tag as above,
or just repeat the initial `{pak}` command which will install from the latest
version of the package on the `main` branch.


### How to switch to a different version tag, option 2: with `git`

You will need to have used `git clone` to download the repo and moved into the
source directory.

```bash
git clone https://github.com/The-Strategy-Unit/nhp_set_model_params.git
```

or alternatively using the GitHub CLI (`gh`)

```bash
gh repo clone The-Strategy-Unit/nhp_set_model_params
```

then move into the directory you have just cloned

```bash
cd nhp_set_model_params
```


Then at the terminal, use `git checkout` or `git switch`

```bash
git checkout nhp_v6.1 # leaves you in a detached HEAD state but that's OK
```

```bash
git switch -c <branch_name> nhp_v6.1 # moves you into a new branch
```

Use `git switch main` to get back to the main branch.


## Limitations / future development

Please make suggestions for future development via the Issues area of the repo.
And of course report any problems or bugs found, noting what you expected to
happen and what you actually observed.
