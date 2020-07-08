#' Read the check list file from a package
#' @param x Either a `Checklist` object or a path to the package.
#' Defaults to `.`.
#' @return A `Checklist` object.
#' @export
#' @importFrom assertthat assert_that has_name is.string
#' @importFrom utils file_test
#' @importFrom yaml read_yaml
read_checklist <- function(x = ".") {
  if (!inherits(x, "Checklist")) {
    assert_that(is.string(x))
    x <- checklist$new(x = x)
  }

  checklist_file <- file.path(x$get_path, "checklist.yml")
  if (!file_test("-f", checklist_file)) {
    # no check list file found
    x <- x$allowed(warnings = character(0), notes = character(0))
    return(x)
  }

  # read existing check list file
  allowed <- read_yaml(checklist_file)
  assert_that(has_name(allowed, "description"))
  assert_that(has_name(allowed, "allowed"))
  allowed <- allowed$allowed
  assert_that(has_name(allowed, "warnings"))
  assert_that(has_name(allowed, "notes"))
  assert_that(is.list(allowed$warnings))
  assert_that(is.list(allowed$notes))
  motivation <- vapply(
    allowed$warnings, `[[`, character(1), "motivation"
  )
  assert_that(
    length(allowed$warnings) == length(motivation),
    msg = "Each warning in the checklist requires a motivation"
  )
  assert_that(
    all(nchar(motivation) > 0),
    msg = "Please add a motivation for each warning the checklist"
  )
  motivation <- vapply(
    allowed$notes, `[[`, character(1), "motivation"
  )
  assert_that(
    length(allowed$notes) == length(motivation),
    msg = "Each note in the checklist requires a motivation"
  )
  assert_that(
    all(nchar(motivation) > 0),
    msg = "Please add a motivation for each note the checklist"
  )
  value <- vapply(
    allowed$warnings, `[[`, character(1), "value"
  )
  assert_that(
    length(allowed$warnings) == length(value),
    msg = "Each warning in the checklist requires a value"
  )
  value <- vapply(
    allowed$notes, `[[`, character(1), "value"
  )
  assert_that(
    length(allowed$notes) == length(value),
    msg = "Each note in the checklist requires a value"
  )
  x <- x$allowed(warnings = allowed$warnings, notes = allowed$notes)
  return(x)
}
