# The Checklist Package

The goal of `checklist` is to provide an elaborate and strict set of
checks for R packages and R code.

## Installation

You can install the package from the [INBO
universe](https://inbo.r-universe.dev/builds) via

``` r

# Enable the INBO universe
options(
  repos = c(
    inbo = "https://inbo.r-universe.dev", CRAN = "https://cloud.r-project.org"
  )
)
# Install the packages
install.packages("checklist", dependencies = TRUE)
```

If that doesn’t work, you can install the version from
[GitHub](https://github.com/inbo/checklist/) with:

``` r

# install.packages("remotes")
remotes::install_github("inbo/checklist", dependencies = TRUE)
```

## Setting a default organisation

Originally, we created `checklist` with the Research Institute for
Nature and Forest (INBO) in mind. We recommend that you set a default
organisation list. More details in
[`vignette("organisation", package = "checklist")`](https://inbo.github.io/checklist/articles/organisation.md).

## Using `checklist` on a package.

Before you can run the checks, you must initialise `checklist` on the
package. Either use
[`create_package()`](https://inbo.github.io/checklist/reference/create_package.md)
to create a new package from scratch. Or use
[`setup_package()`](https://inbo.github.io/checklist/reference/setup_package.md)
on an existing package. More details in
[`vignette("getting_started", package = "checklist")`](https://inbo.github.io/checklist/articles/getting_started.md).

``` r

create_package()
```

Once initialised, you can run all the checks with
[`check_package()`](https://inbo.github.io/checklist/reference/check_package.md).
Or run the individual checks.

``` r

check_cran()
check_description()
check_documentation()
check_lintr()
check_filename()
check_folder()
update_citation()
```

To allow some of the warnings or notes, first run the checks and store
them in an object. Update `checklist.yml` by writing that object.

``` r

x <- check_package()
write_checklist(x)
```

## Using `checklist` on a project.

Before you can run the checks, you must initialise `checklist` on the
project. Either use
[`create_project()`](https://inbo.github.io/checklist/reference/create_project.md)
to create a new package from scratch. Or use
[`setup_project()`](https://inbo.github.io/checklist/reference/setup_project.md)
on an existing package. More details in
[`vignette("getting_started_project", package = "checklist")`](https://inbo.github.io/checklist/articles/getting_started_project.md).

``` r

library(checklist)
create_project()
```

Once initialised, you can run all the checks with
[`check_project()`](https://inbo.github.io/checklist/reference/check_project.md).
Or run the individual checks.

``` r

check_lintr()
check_filename()
check_folder()
update_citation()
```

To allow some of the warnings or notes, first run the checks and store
them in an object. Update `checklist.yml` by writing that object.

``` r

x <- check_project()
write_checklist(x)
```
