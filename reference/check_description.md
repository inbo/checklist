# Check the `DESCRIPTION` file

The `DESCRIPTION` file contains the most important meta-data of the
package. A good `DESCRIPTION` is tidy, has a meaningful version number,
full author details and a clear license.

## Usage

``` r
check_description(x = ".")
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

## Details

This function ensures the `DESCRIPTION` is tidy, using
[`tidy_desc()`](https://inbo.github.io/checklist/reference/tidy_desc.md).

The version number of the package must have either a `0.0` or a `0.0.0`
format (see [this
discussion](https://github.com/inbo/checklist/issues/1) why we allow
only these formats). The version number in every branch must be larger
than the current version number in the main or master branch. New
commits in the main or master must have a larger version number than the
previous commit. We recommend to protect the main or master branch and
to not commit into the main or master.

Furthermore we check the author information.

- Is INBO listed as copyright holder and funder?

- Has every author an ORCID?

We check the license through
[`check_license()`](https://inbo.github.io/checklist/reference/check_license.md).

## See also

Other package:
[`check_codemeta()`](https://inbo.github.io/checklist/reference/check_codemeta.md),
[`check_cran()`](https://inbo.github.io/checklist/reference/check_cran.md),
[`check_documentation()`](https://inbo.github.io/checklist/reference/check_documentation.md),
[`check_environment()`](https://inbo.github.io/checklist/reference/check_environment.md),
[`check_license()`](https://inbo.github.io/checklist/reference/check_license.md),
[`check_package()`](https://inbo.github.io/checklist/reference/check_package.md),
[`tidy_desc()`](https://inbo.github.io/checklist/reference/tidy_desc.md)
