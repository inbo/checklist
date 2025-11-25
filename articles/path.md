# File paths in code

## Do not use absolute file paths

An absolute file path defines the location of a file or folder starting
from the root of a disk. For example `C:\tmp\test.txt` on a Windows
machine or `/tmp/test.txt` on a Unix machine. Using an absolute path in
your code will likely break the code as soon as you run it on a
different machine. Because that file or folder is probably located
somewhere else on the other machine.

[`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md)
looks for absolute paths in your code and turns them into an error. This
check is optional (but strongly recommended) with
[`check_project()`](https://inbo.github.io/checklist/reference/check_project.md)
and mandatory with
[`check_package()`](https://inbo.github.io/checklist/reference/check_package.md).

## Easiest solution: use relative paths within the project

In
[`vignette("folder", package = "checklist")`](https://inbo.github.io/checklist/articles/folder.md)
we recommend what folder structure to use in an R project.

We expect users to run the scripts with the base RStudio project as
working directory. The base RStudio project is the one containing the
`checklist.yml` file. Make every path relative to the location of this
file.

In case of **Rmarkdown** files, use paths relative to the location of
the main Rmarkdown file. And make sure to work in an RStudio project at
the location of that file. Note that you can have “nested” RStudio
projects.

Let’s illustrate this with an example. We assume a base RStudio project
with a `checklist.yml` file at its root. Suppose the main Rmarkdown file
is `source/bookdown/index.Rmd`. We have an RStudio project at
`source/bookdown`, so that the working directory is by default at this
location. In one of the code chunks you want to read
`data/observations.txt`. Then point the read function to
`../../data/observations.txt`. `..` moves one step towards the root of
the disk. The working directory within the Rmarkdown files will be
`source/bookdown`. A single `..` points in this case at `source`.
`../..` points from `source/bookdown` to the root of the project. Then
we need to move up into the `data` folder by using `../../data`.

Another option is to use the `get_path` method on the `checklist` object
to get this location. Then use that information to define the absolute
location of the files within the project.

``` r

library(checklist)
x <- read_checklist()
file.path(x$get_path, "data", "observations.txt")
```

## Alternative solution: use relative paths between projects

Sometimes you need to store the data outside of the project. For example
because several projects share the same data. In such case you can place
the projects and the data in a shared folder structure. Then you can
still rely on relative paths to point to the common data outside of the
project. Note that this requires that every user complies to use the
same structure. The maintainer should document this structure and give
the user instructions on how to set up a project. A good example can be
found in the [data storage
vignette](https://inbo.github.io/n2khab/articles/v020_datastorage.html)
of the [`n2khab`](https://inbo.github.io/n2khab/index.html) package.

    superproject
    |-- shared_data
    |-- project_a
      |-- source
    |-- project_b
      |-- source

## Fallback solution: ask the user to specify the path

This solution relies on setting a system variable on the computer of the
user. Simply create a `.Renviron` text file at the root of the RStudio
project. This file contains a list of key-value pairs as shown in the
example below. Please choose a more suitable name than `MYPROJECT_DATA`.
Using a project specific name minimises the potential of multiple
projects using the same system variables.

Content of `.Renviron`

    MYPROJECT_DATA="C:\temp"

Starting the RStudio project will load the system variables set in
`.Renviron`. Keep in mind that you need might a `.Renviron` in every
RStudio project where you use this trick.

Location of `.Renviron`

    project_a
    |-- .Renviron
    |-- project_a.Rproj
    |-- data
    |-- source
      |-- bookdown
        |-- .Renviron
        |-- bookdown.Rproj
        |-- index.Rmd
      |-- script.R

The following R code chunk illustrates how to read and use the system
variable. Besides writing good documentation, you should check the
content of the system variable. Your code should provide helpful errors
when the user fails to set the correct system variable. In the example
below we use [`stopifnot()`](https://rdrr.io/r/base/stopifnot.html).
This function uses named expressions. Every expression must yield a
single `TRUE` or `FALSE`. When the expression yields `FALSE`, the
function returns an error using the name of the expression. When the
expression yields `TRUE`, the code continues without a message.

``` r

data_path <- Sys.getenv("MYPROJECT_DATA", NA)
stopifnot(
  "System variable `MYPROJECT_DATA` not set" = !is.na(data_path),
  "`MYPROJECT_DATA` is not an existing directory" = file_test("-d", data_path)
)
file.path(data_path, "data", "observations.txt")
```
