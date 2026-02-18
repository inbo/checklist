# Set the proper license

Set the proper license

## Usage

``` r
set_license(x = ".", license, org)
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

- license:

  the license to set. If missing, the user will be prompted to choose a
  license.

- org:

  An `organisation` object. If missing, the organisation will be read
  from the project.

## Value

Invisible `NULL`.

## See also

Other setup:
[`create_package()`](https://inbo.github.io/checklist/reference/create_package.md),
[`create_project()`](https://inbo.github.io/checklist/reference/create_project.md),
[`new_org_list()`](https://inbo.github.io/checklist/reference/new_org_list.md),
[`prepare_ghpages()`](https://inbo.github.io/checklist/reference/prepare_ghpages.md),
[`setup_package()`](https://inbo.github.io/checklist/reference/setup_package.md),
[`setup_project()`](https://inbo.github.io/checklist/reference/setup_project.md),
[`setup_source()`](https://inbo.github.io/checklist/reference/setup_source.md)
