# Check the license of a package

Every package needs a clear license. Without a license, the end-users
have no clue under what conditions they can use the package. You must
specify the license in the `DESCRIPTION` and provide a `LICENSE.md`
file.

## Usage

``` r
check_license(x = ".", org)
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

- org:

  An `organisation` object. If missing, the organisation will be read
  from the project.

## Details

This functions checks if the `DESCRIPTION` mentions one of the standard
licenses. The `LICENSE.md` must match this license. Use
[`setup_package()`](https://inbo.github.io/checklist/reference/setup_package.md)
to add the correct `LICENSE.md` to the package.

Currently, following licenses are allowed:

- GPL-3

- MIT

We will consider pull requests adding support for other open source
licenses.

## See also

Other package:
[`check_codemeta()`](https://inbo.github.io/checklist/reference/check_codemeta.md),
[`check_cran()`](https://inbo.github.io/checklist/reference/check_cran.md),
[`check_description()`](https://inbo.github.io/checklist/reference/check_description.md),
[`check_documentation()`](https://inbo.github.io/checklist/reference/check_documentation.md),
[`check_environment()`](https://inbo.github.io/checklist/reference/check_environment.md),
[`check_package()`](https://inbo.github.io/checklist/reference/check_package.md),
[`tidy_desc()`](https://inbo.github.io/checklist/reference/tidy_desc.md)
