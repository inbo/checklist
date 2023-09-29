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
  x <- read_checklist(x = x)
  organisation_file <- path(x$get_path, "organisation.yml")
  if (!is_file(organisation_file)) {
    return(organisation$new())
  }
  read_yaml(organisation_file) |>
    do.call(what = organisation$new)
}
