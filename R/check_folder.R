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
#' of the project or `data` as sub folder of the sub folders of `source`.
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

  dir_ls(x$get_path, type = "directory") |>
    path_rel(x$get_path) -> root_dir
  suppressWarnings(
    path(x$get_path, "source") |>
      dir_ls(type = "directory", fail = FALSE) -> source_1
  )

  paste(open_data_ext, collapse = "|") |>
    sprintf(fmt = "\\.(%s)$") -> data_regexp
  dir_ls(x$get_path, type = "file", recurse = TRUE, regexp = data_regexp) |>
    path_rel(x$get_path) -> data_files
  suppressWarnings(
    path(x$get_path, "output") |>
      dir_ls(
        type = "file", recurse = TRUE, regexp = data_regexp, fail = FALSE
      ) |>
      path_rel(x$get_path) -> ignore_data_files
  )
  data_files <- data_files[!data_files %in% ignore_data_files]
  suppressWarnings(
    path(x$get_path, "data") |>
      dir_ls(
        type = "file", recurse = TRUE, regexp = data_regexp, fail = FALSE
      ) |>
      path_rel(x$get_path) -> ignore_data_files
  )
  data_files <- data_files[!data_files %in% ignore_data_files]
  suppressWarnings(
    path(x$get_path, "renv") |>
      dir_ls(
        type = "file", recurse = TRUE, regexp = data_regexp, fail = FALSE
      ) |>
      path_rel(x$get_path) -> ignore_data_files
  )
  data_files <- data_files[!data_files %in% ignore_data_files]
  suppressWarnings(
    path(source_1, "data") |>
      dir_ls(
        type = "file", recurse = TRUE, regexp = data_regexp, fail = FALSE
      ) |>
      path_rel(x$get_path) -> ignore_data_files
  )
  data_files <- data_files[!data_files %in% ignore_data_files]

  paste(graphics_ext, collapse = "|") |>
    sprintf(fmt = "\\.(%s)$") -> graphics_regexp
  dir_ls(x$get_path, type = "file", recurse = TRUE, regexp = graphics_regexp) |>
    path_rel(x$get_path) -> graphics_files
  dir_ls(
    x$get_path, type = "file", recurse = TRUE,
    regexp = paste0("_files.*", graphics_regexp)
  ) |>
    path_rel(x$get_path) -> ignore_graphics_files
  graphics_files <- graphics_files[!graphics_files %in% ignore_graphics_files]
  suppressWarnings(
    path(x$get_path, "output") |>
      dir_ls(
        type = "file", recurse = TRUE, regexp = graphics_regexp, fail = FALSE
      ) |>
      path_rel(x$get_path) -> ignore_graphics_files
  )
  graphics_files <- graphics_files[!graphics_files %in% ignore_graphics_files]
  suppressWarnings(
    path(x$get_path, "media") |>
      dir_ls(
        type = "file", recurse = TRUE, regexp = graphics_regexp, fail = FALSE
      ) |>
      path_rel(x$get_path) -> ignore_graphics_files
  )
  graphics_files <- graphics_files[!graphics_files %in% ignore_graphics_files]
  suppressWarnings(
    path(source_1, "media") |>
      dir_ls(
        type = "file", recurse = TRUE, regexp = graphics_regexp, fail = FALSE
      ) |>
      path_rel(x$get_path) -> ignore_graphics_files
  )
  graphics_files <- graphics_files[!graphics_files %in% ignore_graphics_files]
  suppressWarnings(
    path(x$get_path, "renv") |>
      dir_ls(
        type = "file", recurse = TRUE, regexp = graphics_regexp, fail = FALSE
      ) |>
      path_rel(x$get_path) -> ignore_graphics_files
  )
  graphics_files <- graphics_files[!graphics_files %in% ignore_graphics_files]

  dir_ls(x$get_path, recurse = TRUE, regexp = "_(bookdown|quarto)\\.yml$") |>
    dirname() |>
    c(source_1) |>
    vapply(check_data_media, vector(mode = "list", length = 1)) -> data_media_ok
  if (length(data_media_ok) == 0) {
    ignore_data_files <- character(0)
    ignore_graphics_files <- character(0)
  } else {
    vapply(data_media_ok, "[[", vector(mode = "list", length = 1), "data") |>
      unlist() |>
      path_rel(x$get_path) -> ignore_data_files
    data_files <- data_files[!data_files %in% ignore_data_files]
    vapply(data_media_ok, "[[", vector(mode = "list", length = 1), "cover") |>
      unlist() |>
      path_rel(x$get_path) -> ignore_cover_files
    data_files <- data_files[!data_files %in% ignore_cover_files]
    vapply(
      data_media_ok, "[[", vector(mode = "list", length = 1), "extra_media"
    ) |>
      unlist() |>
      path_rel(x$get_path) -> ignore_graphics_files
    graphics_files <- graphics_files[!graphics_files %in% ignore_graphics_files]
    vapply(data_media_ok, "[[", vector(mode = "list", length = 1), "media") |>
      unlist() |>
      path_rel(x$get_path) -> ignore_graphics_files
    graphics_files <- graphics_files[!graphics_files %in% ignore_graphics_files]
  }

  dir_ls(x$get_path, recurse = TRUE, regexp = "_bookdown\\.yml$") |>
    dirname() |>
    vapply(check_bookdown, vector(mode = "list", length = 1)) |>
    unlist() |>
    unname() |>
    c(
      paste(
        "A project should only have `data`, `inst`, `media`, `output`, `renv`",
        "and `source` as main folder."
      )[
        !all(
          root_dir %in% c("data", "inst", "media", "output", "renv", "source")
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
    "`source` cannot have `data` as a subfolder"[
      "data" %in% basename(source_1)
    ],
    paste(
      "Use either a common `data` folder at the root or a `data` folder within",
      "the subfolders of `source`."
    )["data" %in% root_dir && length(ignore_data_files) > 0],
    paste(
      "Use either a common `media` folder at the root or a `media` folder",
      "within the subfolders of `source`."
    )["media" %in% root_dir && length(ignore_graphics_files) > 0]
  ) -> problems

  x$add_error(problems, item = "folder conventions")
  x$add_warnings(warn, item = "folder conventions")
  return(x)
}

#' @importFrom fs dir_ls
check_bookdown <- function(path) {
  rstudio <- dir_ls(path, regexp = "\\.Rproj$")
  c(
    paste("No Rstudio project found for bookdown", path)[length(rstudio) == 0],
    paste(
      "Multiple Rstudio projects found for bookdown", path
    )[length(rstudio) > 1]
  ) -> warn
  list(warn)
}

#' @importFrom fs dir_ls is_dir path
check_data_media <- function(path) {
  cover_ok <- dir_ls(path, type = "file")
  cover_ok <- cover_ok[basename(cover_ok) == "cover.txt"]

  paste(open_data_ext, collapse = "|") |>
    sprintf(fmt = "\\.(%s)$") -> rg
  suppressWarnings(
    dir_ls(
      path = path(path, "data"), type = "file", recurse = TRUE, fail = FALSE,
      regexp = rg
    ) -> data_ok
  )

  paste(graphics_ext, collapse = "|") |>
    sprintf(fmt = "\\.(%s)$") -> rg
  suppressWarnings(
    dir_ls(
      path = path(path, "media"), type = "file", recurse = TRUE, fail = FALSE,
      regexp = rg
    ) -> media_ok
  )

  paste(graphics_ext, collapse = "|") |>
    sprintf(fmt = "\\.(%s)$") -> rg
  suppressWarnings(
    dir_ls(
      path = path(path, c("_book", "_extensions", "_freeze", "libs")),
      type = "file", recurse = TRUE, regexp = rg, fail = FALSE
    ) -> extra_media_ok
  )

  list(
    cover = list(cover_ok), data = list(data_ok),
    extra_media = list(extra_media_ok), media = list(media_ok)
  ) |>
    list()
}
