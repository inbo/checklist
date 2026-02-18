# Make sure that the required environment variables are set on GitHub

Some actions will fail when these environment variables are not set.
This function does only work on GitHub.

## Usage

``` r
check_environment(x = ".")
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

## Value

An invisible `checklist` object.

## See also

Other package:
[`check_codemeta()`](https://inbo.github.io/checklist/reference/check_codemeta.md),
[`check_cran()`](https://inbo.github.io/checklist/reference/check_cran.md),
[`check_description()`](https://inbo.github.io/checklist/reference/check_description.md),
[`check_documentation()`](https://inbo.github.io/checklist/reference/check_documentation.md),
[`check_license()`](https://inbo.github.io/checklist/reference/check_license.md),
[`check_package()`](https://inbo.github.io/checklist/reference/check_package.md),
[`tidy_desc()`](https://inbo.github.io/checklist/reference/tidy_desc.md)
