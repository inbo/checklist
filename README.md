
<!-- README.md is generated from README.Rmd. Please edit that file -->

# checklist

<!-- badges: start -->

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
check_package()
```

Or run the individual checks

``` r
check_cran()
check_lintr()
check_description()
check_documentation()
```

Create a `checklist.yml` to allow some of warnings or notes.

``` r
write_checklist()
```
