# Create an R package according to INBO requirements

Creates a package template in a new folder. Use this function when you
want to start a new package. Please DO READ
[`vignette("getting_started")`](https://inbo.github.io/checklist/articles/getting_started.md)
before running this function.

## Usage

``` r
create_package(package, path = ".")
```

## Arguments

- package:

  Name of the new package.

- path:

  Where to create the package directory.

## Details

What you get with a checklist setup:

- minimal folder structure and files required for an R package using
  INBO guidelines with GPL-3 or MIT license.

- an RStudio project file

- a local git repository

- an initial `NEWS.md` file

- a template for an `README.Rmd`

- set-up for automated checks and releases of the package using GitHub
  Actions.

- a code of conduct and contributing guidelines.

- the set-up for a `pkgdown` website using the INBO corporate identity.

## See also

Other setup:
[`create_project()`](https://inbo.github.io/checklist/reference/create_project.md),
[`new_org_list()`](https://inbo.github.io/checklist/reference/new_org_list.md),
[`prepare_ghpages()`](https://inbo.github.io/checklist/reference/prepare_ghpages.md),
[`set_license()`](https://inbo.github.io/checklist/reference/set_license.md),
[`setup_package()`](https://inbo.github.io/checklist/reference/setup_package.md),
[`setup_project()`](https://inbo.github.io/checklist/reference/setup_project.md),
[`setup_source()`](https://inbo.github.io/checklist/reference/setup_source.md)
