# Run the complete set of standardised tests on a package

A convenience function that runs all packages related tests in sequence.
The details section lists the relevant functions. After fixing a
problem, you can quickly check if it is solved by running only the
related check. But we still recommend to run `check_package()` before
you push to GitHub. And only push when the functions indicate that there
are no problems. This catches most problems before sending the code to
GitHub.

## Usage

``` r
check_package(
  x = ".",
  fail = !interactive(),
  pkgdown = interactive(),
  quiet = FALSE
)
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

- fail:

  Should the function return an error in case of a problem? Defaults to
  `TRUE` on a non-interactive session and `FALSE` on an interactive
  session.

- pkgdown:

  Test pkgdown website. Defaults to `TRUE` on an interactive session and
  `FALSE` on a non-interactive session.

- quiet:

  Whether to print check output during checking.

## Details

List of checks in order:

1.  [`check_cran()`](https://inbo.github.io/checklist/reference/check_cran.md)

2.  [`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md)

3.  [`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md)

4.  [`check_description()`](https://inbo.github.io/checklist/reference/check_description.md)

5.  [`check_documentation()`](https://inbo.github.io/checklist/reference/check_documentation.md)

6.  [`check_codemeta()`](https://inbo.github.io/checklist/reference/check_codemeta.md)

## See also

Other package:
[`check_codemeta()`](https://inbo.github.io/checklist/reference/check_codemeta.md),
[`check_cran()`](https://inbo.github.io/checklist/reference/check_cran.md),
[`check_description()`](https://inbo.github.io/checklist/reference/check_description.md),
[`check_documentation()`](https://inbo.github.io/checklist/reference/check_documentation.md),
[`check_environment()`](https://inbo.github.io/checklist/reference/check_environment.md),
[`check_license()`](https://inbo.github.io/checklist/reference/check_license.md),
[`tidy_desc()`](https://inbo.github.io/checklist/reference/tidy_desc.md)
