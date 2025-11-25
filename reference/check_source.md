# Standardised test for an R source repository

Defunct function. Please use
[`check_project()`](https://inbo.github.io/checklist/reference/check_project.md)
instead.

## Usage

``` r
check_source(x = ".", fail = !interactive())
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

- fail:

  Should the function return an error in case of a problem? Defaults to
  `TRUE` on non-interactive session and `FALSE` on an interactive
  session.

## See also

Other project:
[`check_folder()`](https://inbo.github.io/checklist/reference/check_folder.md),
[`check_project()`](https://inbo.github.io/checklist/reference/check_project.md)
