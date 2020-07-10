#' Write a check list with allowed issues in the source code
#'
#' @inheritParams read_checklist
#' @param package Logical indication if `checklist.yml` refers to an R package.
#' Defaults to `TRUE`.
#' @importFrom assertthat assert_that is.flag noNA
#' @importFrom yaml write_yaml
#' @export
write_checklist <- function(x = ".", package = TRUE) {
  if (!inherits(x, "Checklist") || !"checklist" %in% x$get_checked) {
    x <- suppressMessages(read_checklist(x = x))
  }

  assert_that(is.flag(package))
  assert_that(noNA(package))
  x$package <- package

  if (package && !"R CMD check" %in% x$get_checked) {
    x <- check_cran(x)
  }

  x$confirm_motivation("warnings")
  x$confirm_motivation("notes")
  x$add_motivation("warnings")
  x$add_motivation("notes")

  write_yaml(x$template, file.path(x$get_path, "checklist.yml"))
  return(invisible(NULL))
}
