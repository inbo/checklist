#' Write organisation settings
#'
#' Store the organisation rules into `organisation.yml` file.
#' First run `org <- checklist::organisation$new()` with the appropriate argument.
#' Next you can store the configuration with
#' `checklist::write_organisation(org)`.
#'
#' @inheritParams read_checklist
#' @importFrom assertthat assert_that
#' @importFrom fs path
#' @importFrom yaml write_yaml
#' @export
#' @family both
write_organisation <- function(org, x = ".") {
  assert_that(inherits(org, "organisation"))
  x <- suppressMessages(read_checklist(x = x))

  path(x$get_path, "organisation.yml") |>
    write_yaml(x = org$template)
  return(invisible(NULL))
}
