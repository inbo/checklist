#' Write default organisation settings
#'
#' Store the default organisation rules.
#' First run `org <- organisation$new()` with the appropriate argument.
#' Next you can store the configuration with `default_organisation(org)`.
#'
#' @param org An `organisation` object.
#' Create it with `organisation$new()`.
#' @importFrom assertthat assert_that
#' @importFrom fs path
#' @importFrom yaml write_yaml
#' @export
#' @family both
default_organisation <- function(org = organisation$new()) {
  assert_that(inherits(org, "organisation"))
  R_user_dir("checklist", which = "config") |>
    path("organisation.yml") |>
    write_yaml(x = org$template)
  return(invisible(NULL))
}
