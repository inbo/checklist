#' Read the check list file from a package
#' @return a named list with check list information
#' @inheritParams check_package
#' @export
#' @importFrom assertthat assert_that has_name is.string
#' @importFrom yaml read_yaml
read_checklist <- function(path = ".") {
  assert_that(is.string(path))
  assert_that(
    file_test("-d", path),
    msg = "`path` is not a directory."
  )
  if (!file_test("-f", file.path(path, "checklist.yml"))) {
    return(
      list(
        description = "Configuration file for checklist::check_pkg()",
        allowed = list(warnings = list(), notes = list())
      )
    )
  }
  checklist <- read_yaml(file.path(path, "checklist.yml"))
  assert_that(has_name(checklist, "description"))
  assert_that(has_name(checklist, "allowed"))
  assert_that(has_name(checklist$allowed, "warnings"))
  assert_that(has_name(checklist$allowed, "notes"))
  return(checklist)
}
