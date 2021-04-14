#' Write a check list with allowed issues in the source code
#'
#' First run `x <- checklist::check_package()` or
#' `x <- checklist::check_source()`.
#' These commands run the checks and store the CheckList object in the variable
#' `x`.
#' Next you can store the configuration with `checklist::write_checklist(x)`.
#' This will first list any existing allowed warnings or notes.
#' For every one of them, you choose whether you want to keep it or not.
#' Next, the function presents every new warning or note which you may allow or not.
#' If you choose to allow a warning or note, you must provide a motivation.
#' Please provide a sensible motivation.
#' Keep in mind that `checklist.yml` stores these motivations in plain text.
#' So they are visible for other users.
#' We use the `yesno()` function to make sure you carefully read the questions.
#' @inheritParams read_checklist
#' @param package Logical indication if `checklist.yml` refers to an R package.
#' Defaults to `TRUE`.
#' @importFrom assertthat assert_that is.flag noNA
#' @importFrom yaml write_yaml
#' @export
#' @family both
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
