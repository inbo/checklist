#' Run the complete set of standardised tests on a package
#'
#' A convenience function that runs all packages related tests in sequence.
#' The details section lists the relevant functions.
#' When you fixed a problem, you can speed things up by running only the related
#' check.
#' We still recommend to run `check_package()` before you push to GitHub.
#' And only push when the functions indicate that there are no problems.
#' This catches most problems before sending the code to GitHub.
#'
#' @details
#' List of checks in order:
#'
#' 1. `check_cran()`
#' 1. `check_lintr()`
#' 1. `check_filename()`
#' 1. `check_description()`
#' 1. `check_documentation()`
#' 1. `check_codemeta()`
#'
#' @inheritParams read_checklist
#' @param fail Should the function return an error in case of a problem?
#' Defaults to `TRUE` on non-interactive session and `FALSE` on an interactive
#' session.
#' @importFrom assertthat assert_that is.flag is.string noNA
#' @importFrom utils file_test
#' @export
#' @family package
check_package <- function(x = ".", fail = !interactive()) {
  assert_that(is.flag(fail))
  assert_that(noNA(fail))

  x <- check_cran(x = x)

  cat("Checking code style\n")
  x <- check_lintr(x)

  cat("Checking filename conventions\n")
  x <- check_filename(x)

  cat("Checking description\n")
  x <- check_description(x)

  cat("Checking documentation\n")
  x <- check_documentation(x)

  cat("Checking code metadata\n")
  x <- check_codemeta(x)

  print(x)
  if (!x$fail) {
    cat("\nNo problems found. Good job!\n\n")
    return(invisible(x))
  }
  if (fail) {
    stop("Checking the package revealed some problems.")
  }
  cat("\nChecking the package revealed some problems.\n\n")
  return(invisible(x))
}
