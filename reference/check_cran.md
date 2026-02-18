# Run all the package checks required by CRAN

CRAN imposes an impressive list of tests on every package before
publication. This suite of test is available in every R installation.
Hence we use this full suite of tests too. Notice that
[`check_package()`](https://inbo.github.io/checklist/reference/check_package.md)
runs several additional tests.

## Usage

``` r
check_cran(x = ".", quiet = FALSE)
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

- quiet:

  Whether to print check output during checking.

## Value

A `checklist` object.

## See also

Other package:
[`check_codemeta()`](https://inbo.github.io/checklist/reference/check_codemeta.md),
[`check_description()`](https://inbo.github.io/checklist/reference/check_description.md),
[`check_documentation()`](https://inbo.github.io/checklist/reference/check_documentation.md),
[`check_environment()`](https://inbo.github.io/checklist/reference/check_environment.md),
[`check_license()`](https://inbo.github.io/checklist/reference/check_license.md),
[`check_package()`](https://inbo.github.io/checklist/reference/check_package.md),
[`tidy_desc()`](https://inbo.github.io/checklist/reference/tidy_desc.md)
