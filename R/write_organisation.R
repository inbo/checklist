#' Write organisation settings
#'
#' Store the organisation rules into `organisation.yml` file.
#' First run `org <- organisation$new()` with the appropriate argument.
#' Next you can store the configuration with `write_organisation(org)`.
#'
#' @param org An `organisation` object.
#' Create it with `organisation$new()`.
#' @inheritParams read_checklist
#' @importFrom assertthat assert_that
#' @importFrom fs path
#' @importFrom yaml write_yaml
#' @export
#' @family both
write_organisation <- function(org, x = ".") {
  .Deprecated(new = "org_list$new()$write", package = "checklist")
  assert_that(inherits(org, "organisation"))
  checklist <- try(read_checklist(x = x), silent = TRUE)
  if (inherits(checklist, "checklist")) {
    x <- checklist$get_path
  }
  path(x, "organisation.yml") |>
    write_yaml(x = org$template)
  return(invisible(NULL))
}
