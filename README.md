The Checklist Package
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
![GitHub](https://img.shields.io/github/license/inbo/checklist) [![R
build
status](https://github.com/inbo/checklist/workflows/R-CMD-check/badge.svg)](https://github.com/inbo/checklist/actions)
[![Codecov test
coverage](https://codecov.io/gh/inbo/checklist/branch/master/graph/badge.svg)](https://codecov.io/gh/inbo/checklist?branch=master)
![GitHub code size in
bytes](https://img.shields.io/github/languages/code-size/inbo/checklist.svg)
![GitHub repo
size](https://img.shields.io/github/repo-size/inbo/checklist.svg)
<!-- badges: end -->

The goal of `checklist` is to provide an elaborate and strict set of
checks for R packages and R code.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

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
