#' Standardised test for an R source repository
#'
#' A convenience function that runs all source related tests in sequence.
#' The details lists the relevant functions.
#' When you fixed a problem, you can speed things up by running only the related
#' check.
#' We still recommend to run `check_source()` before you push to GitHub.
#' And only push when the functions indicates that there are no problems.
#' This caches most problems before sending the code to GitHub.
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
#' @importFrom utils file_test
#' @export
#' @family source
check_source <- function(x = ".", fail = !interactive()) {
  assert_that(is.flag(fail))
  assert_that(noNA(fail))

  cat("Checking code style\n")
  x <- check_lintr(x)

  cat("Checking filename conventions\n")
  x <- check_filename(x)

  print(x)
  if (!x$fail) {
    cat("\nNo problems found. Good job!\n\n")
    return(invisible(x))
  }
  if (fail) {
    stop("Checking the source code revealed some problems.")
  }
  cat("\nChecking the source code revealed some problems.\n\n")
  return(invisible(x))
}
