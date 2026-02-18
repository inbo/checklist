# Check the folder structure

For the time being, this function only checks projects. Keep in mind
that R packages have requirements for the folder structure. That is one
of things that
[`check_cran()`](https://inbo.github.io/checklist/reference/check_cran.md)
checks.

## Usage

``` r
check_folder(x = ".")
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

## Recommended folder structure

- `source`: contains all `R` scripts and `Rmd` files.

- `data`: contains all data files.

## `source`

A simple project with only `R` scripts or only `Rmd` files can place all
the files directly in the `source` folder.

More elaborate projects should place in the files in several folders
under `source`. Place every `bookdown` document in a dedicated folder.
And create an RStudio project for that folder.

## `data`

Simple projects in which `source` has no subfolders, place `data` at the
root of the project. For more elaborate project you must choose between
either `data` at the root of the project or `data` as subfolder of the
subfolders of `source`. E.g. `source/report/data`.

Place the data in an open file format. E.g. `csv`, `txt` or `tsv` for
tabular data. We strongly recommend to use `git2rdata::write_vc()` to
store such data. Use the [`geopackage`](https://www.geopackage.org/)
format for spatial data. Optionally add description of the data as
markdown files.

## See also

Other project:
[`check_project()`](https://inbo.github.io/checklist/reference/check_project.md),
[`check_source()`](https://inbo.github.io/checklist/reference/check_source.md)
