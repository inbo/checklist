#' Write a check list with allowed issues in the source code
#'
#' Checklist stores it configuration as a `checklist.yml` file.
#' `create_package()`, `setup_package()` and `setup_source()` generate a default
#' file.
#' If you need to allow some warnings or notes, you need to update the
#' configuration.
#'
#' @details
#' First run `x <- checklist::check_package()` or
#' `x <- checklist::check_source()`.
#' These commands run the checks and store the CheckList object in the variable
#' `x`.
#' Next you can store the configuration with `checklist::write_checklist(x)`.
#' This will first list any existing allowed warnings or notes.
#' For every one of them, choose whether you want to keep it or not.
#' Next, the function presents every new warning or note which you may allow or
#' not.
#' If you choose to allow a warning or note, you must provide a motivation.
#' Please provide a sensible motivation.
#' Keep in mind that `checklist.yml` stores these motivations in plain text,
#' so they are visible for other users.
#' We use the `yesno()` function to make sure you carefully read the questions.
#'
#' @details # Caveat
#' When you allow a warning or note, this warning or note must appear.
#' Otherwise you get a "missing warning" or "missing note" error.
#' So if you fix an allowed warning or note, you need to rerun
#' `checklist::write_checklist(x)` and remove the old version.
#'
#' If you can solve a warning or note, then solve it rather than to allow it.
#' Only allow a warning or note in case of a generic "problem" that you can't
#' solve.
#' The best example is the `checking CRAN incoming feasibility ... NOTE New
#' submission` which appears when checking a package not on
#' [CRAN](https://cran.r-project.org/).
#' That is should an allowed note as long as the package is not on CRAN.
#' Or permantly when your package is not intended for CRAN.
#'
#' Do not allow a warning or note to fix an issue specific to your machine.
#' That will result in an error when checking the package on an other machine
#' (e.g. GitHub actions).
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
