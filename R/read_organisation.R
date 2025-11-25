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
  .Deprecated(new = "org_list$new()$read", package = "checklist")
  checklist <- try(read_checklist(x = x), silent = TRUE)
  if (inherits(checklist, "checklist")) {
    x <- checklist$get_path
  }
  organisation_file <- path(x, "organisation.yml")
  if (is_file(organisation_file)) {
    yaml <- read_yaml(organisation_file)
    if (!has_name(yaml, "checklist version")) {
      org <- do.call(yaml, what = organisation$new)
      return(org)
    }
  }
  org_list$new()$read(x)
}
