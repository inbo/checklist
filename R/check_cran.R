#' Run the package checks required by CRAN
#' @inheritParams read_checklist
#' @return A `Checklist` object.
#' @importFrom assertthat assert_that
#' @importFrom rcmdcheck rcmdcheck
#' @export
#' @family package
check_cran <- function(x = ".") {
  if (!inherits(x, "Checklist") || !"checklist" %in% x$get_checked) {
    x <- read_checklist(x = x)
  }
  assert_that(
    x$package,
    msg = "`check_cran()` is only relevant for packages.
`checklist.yml` indicates this is not a package."
  )

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
