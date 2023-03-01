#' Standardised test for an R source repository
#'
#' A convenience function that runs test on a project with only `.R` and `.Rmd`
#' files.
#' The details section lists the relevant functions.
#' When you fixed a problem, you can speed things up by running only the related
#' check.
#' We still recommend to run `check_source()` before you push to GitHub.
#' And only push when the functions indicate that there are no problems.
#' This catches most problems before sending the code to GitHub.
#'
#' @details
#' List of checks in order:
#'
#' 1. `check_lintr()`
#' 1. `check_filename()`

#' @inheritParams read_checklist
#' @param fail Should the function return an error in case of a problem?
#' Defaults to `TRUE` on non-interactive session and `FALSE` on an interactive
#' session.
#' @importFrom assertthat assert_that is.flag is.string noNA
#' @importFrom fs dir_exists file_exists path
#' @importFrom utils file_test
#' @export
#' @family project
check_source <- function(x = ".", fail = !interactive()) {
  # nocov start
  .Deprecated("check_project", package = "checklist")
  check_project(x = x, fail = fail)
  # nocov end
}
