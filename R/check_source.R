#' Standardised test for an R source repository
#'
#' @inheritParams read_checklist
#' @param fail Should the function return an error in case of a problem?
#' Defaults to `TRUE` on non-interactive session and `FALSE` on an interactive
#' session.
#' @importFrom assertthat assert_that is.flag is.string noNA
#' @importFrom utils file_test
#' @export
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
