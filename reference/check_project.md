# Run the required quality checks on a project

Set or update the required checks via
[`setup_project()`](https://inbo.github.io/checklist/reference/setup_project.md).

## Usage

``` r
check_project(x = ".", fail = !interactive(), quiet = FALSE)
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

- fail:

  Should the function return an error in case of a problem? Defaults to
  `TRUE` on a non-interactive session and `FALSE` on an interactive
  session.

- quiet:

  Whether to print check output during checking.

## See also

Other project:
[`check_folder()`](https://inbo.github.io/checklist/reference/check_folder.md),
[`check_source()`](https://inbo.github.io/checklist/reference/check_source.md)
