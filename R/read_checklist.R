#' Read the check list file from a package
#'
#' The checklist package stores configuration information in the `checklist.yml`
#' file in the root of a project.
#' This function reads this configuration.
#' It is mainly used by the other functions inside the package.
#' @param x Either a `Checklist` object or a path to the source code.
#' Defaults to `.`.
#' @return A `Checklist` object.
#' @export
#' @importFrom assertthat assert_that has_name is.string
#' @importFrom fs is_file path
#' @importFrom yaml read_yaml
#' @family both
read_checklist <- function(x = ".") {
  if (inherits(x, "Checklist")) {
    return(x)
  }

  assert_that(is.string(x))
  checklist_file <- path(x, "checklist.yml")
  if (!is_file(checklist_file)) {
    # no check list file found
    message("No `checklist.yml` found. Assuming this is a package.
See `?write_checklist` to generate a `checklist.yml`.")
    x <- checklist$new(x = x, language = "en-GB")
    x <- x$allowed()
    return(x)
  }

  # read existing check list file
  allowed <- read_yaml(checklist_file)
  assert_that(has_name(allowed, "package"))
  if (has_name(allowed, "spelling")) {
    if (allowed$package) {
      x <- checklist$new(x = x)
    } else if (has_name(allowed$spelling, "default")) {
      x <- checklist$new(x = x, language = allowed$spelling)
    } else {
      x <- checklist$new(x = x, language = "en-GB")
    }
    if (has_name(allowed$spelling, "ignore")) {
      x$set_ignore(allowed$spelling$ignore)
    }
    if (has_name(allowed$spelling, "other")) {
      x$set_other(allowed$spelling$other)
    }
  }
  x$package <- allowed$package
  if (has_name(allowed, "citation_roles")) {
    x$set_roles(allowed$citation_roles)
  }
  if (has_name(allowed, "keywords")) {
    x$update_keywords(allowed$keywords)
  }

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
