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
#' @importFrom withr defer
#' @family both
check_lintr <- function(x = ".", quiet = FALSE) {
  assert_that(is.flag(quiet), noNA(quiet))
  options(lintr.linter_file = system.file("lintr", package = "checklist"))
  old_lint_option <- getOption("lintr.rstudio_source_markers", TRUE)
  options(lintr.rstudio_source_markers = interactive())
  defer(options(lintr.rstudio_source_markers = old_lint_option))
  x <- read_checklist(x = x)

  if (x$package) {
    linter <- lint_package(path = x$get_path)
  } else {
    linter <- lint_dir(x$get_path, pattern = "\\.R(md|nw)?$")
  }
  if (!quiet && length(linter) > 0) {
    print(linter)
  }
  x$add_linter(linter = linter)
  return(x)
}
