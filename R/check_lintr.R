#' Check the packages for linters
#'
#' @inheritParams read_checklist
#' @export
#' @importFrom lintr lint_dir lint_package
check_lintr <- function(x = ".") {
  old_lint_option <- getOption("lintr.rstudio_source_markers", TRUE)
  options(lintr.rstudio_source_markers = FALSE)
  on.exit(options(lintr.rstudio_source_markers = old_lint_option))

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
