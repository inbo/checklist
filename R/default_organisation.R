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
  .Deprecated(
    new = "org_list$new()",
    package = "checklist",
    msg = paste(
      "The `default_organisation()` function is deprecated.",
      "Please use the `org_list` class instead."
    )
  )
  assert_that(inherits(org, "organisation"))
  target <- R_user_dir("checklist", which = "config")
  dir_create(target)
  target |>
    path("organisation.yml") |>
    write_yaml(x = org$template)
  return(invisible(NULL))
}
