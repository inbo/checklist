#' A standardised test for R packages
#'
#' @param path The path of the package.
#' Defaults to `"."`
#' @importFrom assertthat assert_that is.string
#' @importFrom rcmdcheck rcmdcheck
#' @export
check_package <- function(path = ".") {
  assert_that(is.string(path))
  check_output <- rcmdcheck(
    path = path,
    args = c("--timings", "--as-cran"),
    error_on = "never"
  )
  if (length(check_output$errors) > 1) {
    stop("Checking the package reveals some problems.")
  }
  return(check_output)
}
