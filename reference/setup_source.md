# Add or update the checklist infrastructure to a repository with source files.

This adds the required GitHub workflows to run
[`check_source()`](https://inbo.github.io/checklist/reference/check_source.md)
automatically whenever you push commits to GitHub. It also adds a [CC-BY
4.0](https://creativecommons.org/licenses/by/4.0/) license file, a
[`CODE_OF_CONDUCT.md`](https://inbo.github.io/checklist/CODE_OF_CONDUCT.html)
and the checklist configuration file (`checklist.yml`).

## Usage

``` r
setup_source(path = ".")
```

## Arguments

- path:

  The path to the project. Defaults to `"."`.

## See also

Other setup:
[`create_package()`](https://inbo.github.io/checklist/reference/create_package.md),
[`create_project()`](https://inbo.github.io/checklist/reference/create_project.md),
[`new_org_list()`](https://inbo.github.io/checklist/reference/new_org_list.md),
[`prepare_ghpages()`](https://inbo.github.io/checklist/reference/prepare_ghpages.md),
[`set_license()`](https://inbo.github.io/checklist/reference/set_license.md),
[`setup_package()`](https://inbo.github.io/checklist/reference/setup_package.md),
[`setup_project()`](https://inbo.github.io/checklist/reference/setup_project.md)
