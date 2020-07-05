#' Run the package checks required by CRAN
#' @inheritParams read_checklist
#' @return A `Checklist` object.
#' @importFrom rcmdcheck rcmdcheck
#' @export
check_cran <- function(x = ".") {
  if (!inherits(x, "Checklist") || !"checklist" %in% x$get_checked) {
    x <- read_checklist(x = x)
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
