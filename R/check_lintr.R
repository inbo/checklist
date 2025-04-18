#' Check the packages for linters
#'
#' This functions does [static code analysis](
#' https://en.wikipedia.org/wiki/Static_program_analysis).
#' It relies on [lintr::lint_package()].
#' We recommend that you activate all code diagnostics in RStudio to help
#' meeting the requirements.
#' You can find this in the menu _Tools_ > _Global options_ > _Code_ >
#' _Diagnostics_.
#' Please have a look at `vignette("philosophy")` for more details on the rules.
#'
#' @inheritParams read_checklist
#' @inheritParams rcmdcheck::rcmdcheck
#' @export
#' @importFrom assertthat assert_that is.flag noNA
#' @importFrom lintr lint_dir lint_package
#' @importFrom fs dir_ls
#' @importFrom withr defer
#' @family both
check_lintr <- function(x = ".", quiet = FALSE) {
  assert_that(is.flag(quiet), noNA(quiet))
  stopifnot(
    "Please install the `cyclocomp` package" = requireNamespace("cyclocomp")
  )
  options(lintr.linter_file = system.file("lintr", package = "checklist"))
  old_lint_option <- getOption("lintr.rstudio_source_markers", TRUE)
  options(lintr.rstudio_source_markers = interactive())
  defer(options(lintr.rstudio_source_markers = old_lint_option))
  x <- read_checklist(x = x)
  missing_packages <- list_missing_packages(x$get_path)
  paste(missing_packages, collapse = ", ") |>
    sprintf(
      fmt = "The code depends on the following uninstalled packages: %s"
    ) -> missing_packages_msg
  x$add_error(
    missing_packages_msg[length(missing_packages) > 0], item = "lintr"
  )

  if (x$package) {
    linter <- lint_package(path = x$get_path)
  } else {
    dir_ls(
      path = x$get_path, recurse = TRUE, regexp = "/renv$", type = "directory"
    ) |>
      as.list() |>
      unname() -> exclude_renv
    linter <- lint_dir(
      x$get_path, pattern = "\\.(R|q)(md|nw)?$", exclusions = exclude_renv
    )
  }
  if (!quiet && length(linter) > 0) {
    print(linter)
  }
  x$add_linter(linter = linter)
  return(x)
}

#' @importFrom assertthat assert_that is.string noNA
#' @importFrom fs is_dir
#' @importFrom utils installed.packages
list_missing_packages <- function(x = ".") {
  if (!requireNamespace("renv", quietly = TRUE)) {
    warning("`renv` is not installed. Please install it.")
    return(character(0))
  }
  assert_that(is.string(x), noNA(x), is_dir(x))
  renv::dependencies(x, progress = FALSE)$Package |>
    unique() |>
    sort() -> required_packages
  installed.packages() |>
    rownames() -> installed_packages
  required_packages[!required_packages %in% installed_packages]
}
