#' Read the check list file from a package
#' @return a named list with check list information
#' @inheritParams check_package
#' @export
#' @importFrom assertthat assert_that has_name is.string
#' @importFrom utils file_test
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
  assert_that(is.list(checklist$allowed$warnings))
  assert_that(is.list(checklist$allowed$notes))
  motivation <- vapply(
    checklist$allowed$warnings, `[[`, character(1), "motivation"
  )
  assert_that(
    length(checklist$allowed$warnings) == length(motivation),
    msg = "Each warning in the checklist requires a motivation"
  )
  assert_that(
    all(nchar(motivation) > 0),
    msg = "Please add a motivation for each warning the checklist"
  )
  motivation <- vapply(
    checklist$allowed$notes, `[[`, character(1), "motivation"
  )
  assert_that(
    length(checklist$allowed$notes) == length(motivation),
    msg = "Each note in the checklist requires a motivation"
  )
  assert_that(
    all(nchar(motivation) > 0),
    msg = "Please add a motivation for each note the checklist"
  )
  value <- vapply(
    checklist$allowed$warnings, `[[`, character(1), "value"
  )
  assert_that(
    length(checklist$allowed$warnings) == length(value),
    msg = "Each warning in the checklist requires a value"
  )
  value <- vapply(
    checklist$allowed$notes, `[[`, character(1), "value"
  )
  assert_that(
    length(checklist$allowed$notes) == length(value),
    msg = "Each note in the checklist requires a value"
  )
  return(checklist)
}
