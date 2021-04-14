#' Check the packages for linters
#'
#' This functions does [static code analysis](
#' https://en.wikipedia.org/wiki/Static_program_analysis).
#' It relies on [lintr::lint_package()].
#' We recommend that you activate all code diagnostics in RStudio to help meeting the requirements.
#' You can find this in the menu _Tools_ > _Global options_ > _Code_ >
#' _Diagnostics_.
#'
#' @details
#'
#' Your code must follow the default coding style defined by the lintr package.
#' - Use underscore (`_`) to separate long names.
#' - No names longer than 30 characters.
#' - No lines longer than 80 characters.
#' - Use `TRUE` and `FALSE`,
#'   Don't use `T` or `F`.
#' - Add sufficient whitespace characters.
#'   But don't use whitespace when it is not relevant (end of line or file).
#' - ...
#'
#' @inheritParams read_checklist
#' @export
#' @importFrom lintr lint_dir lint_package
#' @family both
check_lintr <- function(x = ".") {
  old_lint_option <- getOption("lintr.rstudio_source_markers", TRUE)
  options(lintr.rstudio_source_markers = FALSE)
  on.exit(options(lintr.rstudio_source_markers = old_lint_option), add = TRUE)
  if (!inherits(x, "Checklist") || !"checklist" %in% x$get_checked) {
    x <- read_checklist(x = x)
  }

  if (x$package) {
    linter <- lint_package(path = x$get_path)
  } else {
    linter <- lint_dir(x$get_path, pattern = "\\.R(md|nw)?")
  }
  if (length(linter) > 0) {
    print(linter)
  }
  x$add_linter(linter = linter)
  return(x)
}
