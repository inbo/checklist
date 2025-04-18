#' Check the folder structure
#'
#' For the time being, this function only checks projects.
#' Keep in mind that R packages have requirements for the folder structure.
#' That is one of things that `check_cran()` checks.
#'
#' # Recommended folder structure
#'
#' - `source`: contains all `R` scripts and `Rmd` files.
#' - `data`: contains all data files.
#'
#' # `source`
#'
#' A simple project with only `R` scripts or only `Rmd` files can place all the
#' files directly in the `source` folder.
#'
#' More elaborate projects should place in the files in several folders under
#' `source`.
#' Place every `bookdown` document in a dedicated folder.
#' And create an RStudio project for that folder.
#'
#' # `data`
#'
#' Simple projects in which `source` has no subfolders, place `data` at the
#' root of the project.
#' For more elaborate project you must choose between either `data` at the root
#' of the project or `data` as subfolder of the subfolders of `source`.
#' E.g. `source/report/data`.
#'
#' Place the data in an open file format.
#' E.g. `csv`, `txt` or `tsv` for tabular data.
#' We strongly recommend to use `git2rdata::write_vc()` to store such data.
#' Use the [`geopackage`](https://www.geopackage.org/) format for spatial data.
#' Optionally add description of the data as markdown files.
#'
#' @inheritParams read_checklist
#' @family project
#' @export
#' @importFrom fs dir_ls path path_rel
check_folder <- function(x = ".") {
  x <- read_checklist(x = x)
  if (x$package) {
    x$add_warnings(character(0), item = "folder conventions")
    return(x)
  }

  relevant <- list_project_files(x$get_path)
  files <- relevant$files
  dirs <- relevant$dirs

  root_dir <- dirs[dirs != "." & dirname(dirs) == "."]

  # find bookdown and quarto projects
  dirname(files[grepl("^source(\\/.*?)+_(bookdown|quarto)\\.yml$", files)]) |>
    unique() -> projects

  # check data file locations
  paste(open_data_ext, collapse = "|") |>
    sprintf(fmt = "\\.(%s)$") -> data_regexp
  data_files <- files[grepl(data_regexp, files)]
  # data files in /data are OK
  global_data <- data_files[grepl("^data\\/", data_files)]
  data_files <- data_files[!grepl("^data\\/", data_files)]
  # data files in /output are OK
  data_files <- data_files[!grepl("^output\\/", data_files)]
  # generated data files in  are OK
  data_files <- data_files[
    !grepl("(^|\\/)(_book|_files|libs|renv)\\/", data_files)
  ]
  # data files in data sub folder of projects are OK
  paste(projects, collapse = "|") |>
    sprintf(fmt = "^(%s)\\/data\\/") -> local_data_regexp
  local_data <- data_files[grepl(local_data_regexp, data_files)]
  data_files <- data_files[!grepl(local_data_regexp, data_files)]

  # check graphics file locations
  paste(graphics_ext, collapse = "|") |>
    sprintf(fmt = "\\.(%s)$") -> graphics_regexp
  graphics_files <- files[grepl(graphics_regexp, files)]
  # graphics files in /media are OK
  global_graphics <- graphics_files[grepl("^media\\/", graphics_files)]
  graphics_files <- graphics_files[!grepl("^media\\/", graphics_files)]
  # graphics files in /output are OK
  graphics_files <- graphics_files[!grepl("^output\\/", graphics_files)]
  # generated graphics files are OK
  graphics_files <- graphics_files[
    !grepl("(^|\\/)(_book|_extensions|_files|libs|renv)\\/", graphics_files)
  ]
  # graphics files in media sub folder of projects are OK
  paste(projects, collapse = "|") |>
    sprintf(fmt = "^(%s)\\/media\\/") -> local_graphics_regexp
  local_graphics <- graphics_files[grepl(local_graphics_regexp, graphics_files)]
  graphics_files <- graphics_files[
    !grepl(local_graphics_regexp, graphics_files)
  ]

  c(
    paste(
      "A project should only have `data`, `inst`, `media`, `output`, `renv`",
      "and `source` as main folder."
    )[
      !all(
        root_dir %in%
          c(".github", "data", "inst", "media", "output", "renv", "source")
      )
    ],
    sprintf(
      "Data files found outside of a `data` folder:\n  %s",
      paste(data_files, collapse = "\n  ")
    )[length(data_files) > 1],
    sprintf(
      "Media files found outside of a `media` folder:\n  %s",
      paste(graphics_files, collapse = "\n  ")
    )[length(graphics_files) > 1]
  ) -> warn

  c(
    "No `source` main folder found"[!"source" %in% root_dir],
    "`src` main folder is not allowed"["src" %in% root_dir],
    paste(
      "Use either a common `data` folder at the root or a `data` folder within",
      "the subfolders of `source`."
    )[length(global_data) && length(local_data)],
    paste(
      "Use either a common `media` folder at the root or a `media` folder",
      "within the subfolders of `source`."
    )[length(global_graphics) && length(local_graphics)]
  ) -> problems

  x$add_error(problems, item = "folder conventions")
  x$add_warnings(warn, item = "folder conventions")
  return(x)
}
