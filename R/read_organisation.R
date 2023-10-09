#' Read the organisation file
#'
#' The checklist package stores organisation information in the
#' `organisation.yml` file in the root of a project.
#' @inheritParams read_checklist
#' @return An `organisation` object.
#' @export
#' @importFrom assertthat assert_that has_name is.string
#' @importFrom fs is_dir is_file path path_real path_split
#' @importFrom yaml read_yaml
#' @family both
read_organisation <- function(x = ".") {
  checklist <- try(read_checklist(x = x), silent = TRUE)
  if (inherits(checklist, "checklist")) {
    organisation_file <- path(checklist$get_path, "organisation.yml")
    if (is_file(organisation_file)) {
      read_yaml(organisation_file) |>
        do.call(what = organisation$new) -> org
      return(org)
    }
  }
  organisation_file <- path(x, "organisation.yml")
  if (is_file(organisation_file)) {
    read_yaml(organisation_file) |>
      do.call(what = organisation$new) -> org
    return(org)
  }
  return(organisation$new())
}
