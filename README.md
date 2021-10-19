
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental-1)
![GitHub](https://img.shields.io/github/license/inbo/checklist) [![R
build
status](https://github.com/inbo/checklist/workflows/check%20package%20on%20main/badge.svg)](https://github.com/inbo/checklist/actions)
![r-universe
name](https://inbo.r-universe.dev/badges/:name?color=c04384)
![r-universe
package](https://inbo.r-universe.dev/badges/checklist?color=c04384)
[![Codecov test
coverage](https://codecov.io/gh/inbo/checklist/branch/main/graph/badge.svg)](https://app.codecov.io/gh/inbo/checklist?branch=main)
![GitHub code size in
bytes](https://img.shields.io/github/languages/code-size/inbo/checklist.svg)
![GitHub repo
size](https://img.shields.io/github/repo-size/inbo/checklist.svg)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4028303.svg)](https://doi.org/10.5281/zenodo.4028303)
<!-- badges: end -->

# The Checklist Package <img src="man/figures/logo.svg" align="right" alt="A hexagon with the word checklist" width="120" />

The goal of `checklist` is to provide an elaborate and strict set of
checks for R packages and R code.

## Installation

You can install the package from the [INBO
universe](https://inbo.r-universe.dev/ui#builds) via

``` r
# Enable the INBO universe
options(
  repos = c(
    inbo = "https://inbo.r-universe.dev", CRAN = "https://cloud.r-project.org"
  )
)
# Install the packages
install.packages("checklist")
```

If that doesn’t work, you can install the version from
[GitHub](https://github.com/inbo/checklist/) with:

``` r
# install.packages("remotes")
remotes::install_github("inbo/checklist")
```

## Examples

You can run the full list of checks

``` r
library(checklist)
check_package() # for packages
check_source() # for a project with R and Rmd files
```

Or run the individual checks

``` r
check_cran()
check_description()
check_documentation()
check_lintr()
check_filename()
```

Create a `checklist.yml` to allow some of warnings or notes.

``` r
write_checklist()
```

Start a package from scratch with everything set-up

``` r
create_package()
```
