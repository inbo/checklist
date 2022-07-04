#' Run the complete set of standardised tests on a package
#'
#' A convenience function that runs all packages related tests in sequence.
#' The details section lists the relevant functions.
#' After fixing a problem, you can quickly check if it is solved by running only
#' the related check.
#' But we still recommend to run `check_package()` before you push to GitHub.
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
#' Defaults to `TRUE` on a non-interactive session and `FALSE` on an interactive
#' session.
#' @param pkgdown Test pkgdown website.
#' Defaults to `TRUE` on an interactive session and `FALSE` on a non-interactive
#' session.
#' @param quiet Whether to print check output during checking.
#' @importFrom assertthat assert_that is.flag is.string noNA
#' @importFrom pkgdown build_site
#' @importFrom utils file_test
#' @export
#' @family package
check_package <- function(
    x = ".", fail = !interactive(), pkgdown = interactive(), quiet = FALSE
) {
  assert_that(is.flag(fail), noNA(fail))
  assert_that(is.flag(pkgdown), noNA(pkgdown))
  assert_that(is.flag(quiet), noNA(quiet))

  x <- check_cran(x = x, quiet = quiet)

  quiet_cat("Checking code style\n", quiet = quiet)
  x <- check_lintr(x, quiet = quiet)

  quiet_cat("Checking filename conventions\n", quiet = quiet)
  x <- check_filename(x)

  quiet_cat("Checking description\n", quiet = quiet)
  x <- check_description(x)

  quiet_cat("Updating citation\n", quiet = quiet)
  x <- update_citation(x)

  quiet_cat("Checking documentation\n", quiet = quiet)
  x <- check_documentation(x, quiet = quiet)

  quiet_cat("Checking code metadata\n", quiet = quiet)
  x <- check_codemeta(x)

  x <- check_environment(x)

  quiet_cat("Checking spelling\n", quiet = quiet)
  x <- check_spelling(x = x, quiet = quiet)

  if (pkgdown) {
    old_ci <- Sys.getenv("CI")
    on.exit({
      Sys.unsetenv("CI")
      if (old_ci != "") {
        Sys.setenv(CI = old_ci)
      }
    }, add = TRUE
    )
    Sys.setenv(CI = TRUE)
    if (quiet) {
      junk <- tempfile(fileext = ".txt")
      on.exit(file.remove(junk), add = TRUE, after = TRUE)
      sink(junk)
      build_site(x$get_path, preview = FALSE)
      sink()
    } else {
      build_site(x$get_path)
    }
  }

  print(x, quiet = quiet)
  if (!x$fail) {
    quiet_cat("\nNo problems found. Good job!\n\n", quiet = quiet)
    return(invisible(x))
  }
  assert_that(!fail, msg = "Checking the package revealed some problems.")

  quiet_cat("\nChecking the package revealed some problems.\n\n", quiet = quiet)

  return(invisible(x))
}
