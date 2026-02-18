# Check the documentation

The function make sure that the documentation is up to date. Rules:

- You must use [`roxygen2`](https://roxygen2.r-lib.org) to document the
  functions.

- If you use a `README.Rmd`, it should be rendered. You need at least a
  `README.md`.

- Don't use a `NEWS.Rmd` but a `NEWS.md`.

- `NEWS.md` must contain an entry for the current package version.

## Usage

``` r
check_documentation(x = ".", quiet = FALSE)
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

- quiet:

  Whether to print check output during checking.

## Details

The function generates the help files from the `roxygen2` tag in the R
code. Then it checks whether any of the help files changed. We use the
same principle with the `README.Rmd`. If any file changed, the
documentation does not match the code. Hence `check_documentation()`
returns an error.

A side effect of running `check_documentation()` locally, is that it
generates all the documentation. So the only thing left for you to do,
is to commit these changes. Pro tip: make sure RStudio renders the
`roxygen2` tags whenever you install and restart the package. We
describe this in
[`vignette("getting_started")`](https://inbo.github.io/checklist/articles/getting_started.md)
under "Prepare local setup".

## Required format for `NEWS.md`

    # package_name version

    * Description of something that changed.
    * Lines should not exceed 80 characters.
      Start a new line with two space to continue an item.
    * Add a single blank line before and after each header.

    ## Second level heading

    * You can use second level headings when you want to add more structure.

     # `package_name` version

     * Adding back ticks around the package name is allowed.

## See also

Other package:
[`check_codemeta()`](https://inbo.github.io/checklist/reference/check_codemeta.md),
[`check_cran()`](https://inbo.github.io/checklist/reference/check_cran.md),
[`check_description()`](https://inbo.github.io/checklist/reference/check_description.md),
[`check_environment()`](https://inbo.github.io/checklist/reference/check_environment.md),
[`check_license()`](https://inbo.github.io/checklist/reference/check_license.md),
[`check_package()`](https://inbo.github.io/checklist/reference/check_package.md),
[`tidy_desc()`](https://inbo.github.io/checklist/reference/tidy_desc.md)
