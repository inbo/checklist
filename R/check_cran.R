#' Run all the package checks required by CRAN
#'
#' CRAN imposes an impressive list of tests on every package before publication.
#' This suite of test is available in every R installation.
#' Hence we use this full suite of tests too.
#' Notice that `check_package()` runs several additional tests.
#' @inheritParams read_checklist
#' @return A `Checklist` object.
#' @importFrom assertthat assert_that
#' @importFrom httr HEAD
#' @importFrom rcmdcheck rcmdcheck
#' @export
#' @family package
check_cran <- function(x = ".") {
  x <- read_checklist(x = x)
  assert_that(
    x$package,
    msg = "`check_cran()` is only relevant for packages.
`checklist.yml` indicates this is not a package."
  )

  clock_status <- HEAD("http://worldclockapi.com/api/json/utc/now")$status_code
  if (clock_status != 200) {
    Sys.setenv("_R_CHECK_SYSTEM_CLOCK_" = 0)
  }

  check_output <- rcmdcheck(
    path = x$get_path,
    args = c("--timings", "--as-cran", "--no-manual"),
    error_on = "never"
  )
  x$add_rcmdcheck(
    errors = check_output$errors,
    warnings = check_output$warnings,
    notes = check_output$notes
  )
  return(x)
}
