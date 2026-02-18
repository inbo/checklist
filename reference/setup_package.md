# Add or update the checklist infrastructure to an existing package

Use this function when you have an existing package and you want to use
the checklist functionality. Please keep in mind that the checklist is
an opinionated list of checks. It might require some breaking changes in
your package. Please DO READ
[`vignette("getting_started")`](https://inbo.github.io/checklist/articles/getting_started.md)
before running this function.

## Usage

``` r
setup_package(path = ".")
```

## Arguments

- path:

  The path to the package. Defaults to `"."`.

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
[`create_package()`](https://inbo.github.io/checklist/reference/create_package.md),
[`create_project()`](https://inbo.github.io/checklist/reference/create_project.md),
[`new_org_list()`](https://inbo.github.io/checklist/reference/new_org_list.md),
[`prepare_ghpages()`](https://inbo.github.io/checklist/reference/prepare_ghpages.md),
[`set_license()`](https://inbo.github.io/checklist/reference/set_license.md),
[`setup_project()`](https://inbo.github.io/checklist/reference/setup_project.md),
[`setup_source()`](https://inbo.github.io/checklist/reference/setup_source.md)
