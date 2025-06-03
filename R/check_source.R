#' Standardised test for an R source repository
#'
#' Defunct function.
#' Please use `check_project()` instead.
#' @inheritParams read_checklist
#' @param fail Should the function return an error in case of a problem?
#' Defaults to `TRUE` on non-interactive session and `FALSE` on an interactive
#' session.
#' @export
#' @family project
check_source <- function(x = ".", fail = !interactive()) {
  # nocov start
  .Defunct("check_project", package = "checklist")
  # nocov end
}
