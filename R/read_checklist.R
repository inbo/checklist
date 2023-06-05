#' Read the check list file from a package
#'
#' The checklist package stores configuration information in the `checklist.yml`
#' file in the root of a project.
#' This function reads this configuration.
#' It is mainly used by the other functions inside the package.
#' If no `checklist.yml` file is found at the path,
#' the function walks the directory structure upwards until it finds such file.
#' The function returns an error when it reaches the root of the disk without
#' finding a `checklist.yml` file.
#' @param x Either a `checklist` object or a path to the source code.
#' Defaults to `.`.
#' @return A `checklist` object.
#' @export
#' @importFrom assertthat assert_that has_name is.string
#' @importFrom fs is_dir is_file path path_real path_split
#' @importFrom yaml read_yaml
#' @family both
read_checklist <- function(x = ".") {
  if (inherits(x, "checklist")) {
    return(x)
  }

  assert_that(is.string(x), is_dir(x))
  current <- path_real(x)
  checklist_file <- path(current, "checklist.yml")
  while (!is_file(checklist_file) && length(path_split(current)[[1]]) > 1) {
    path(current, "..") |>
      path_real() -> current
    checklist_file <- path(current, "checklist.yml")
  }
  assert_that(
    is_file(checklist_file),
    msg = sprintf("no checklist.yml found `%s` or its parents", x)
  )

  # read existing check list file
  allowed <- read_yaml(checklist_file)
  assert_that(has_name(allowed, "package"))
  if (!has_name(allowed, "spelling")) {
    allowed$spelling <- list(default = "en-GB")
  }
  if (allowed$package) {
    x <- checklist$new(
      x = x, package = TRUE,
      language = ifelse(
        has_name(allowed$spelling, "default"), allowed$spelling$default, "en-GB"
      )
    )
  } else {
    x <- checklist$new(
      x = x, package = FALSE,
      language = ifelse(
        has_name(allowed$spelling, "default"), allowed$spelling$default, "en-GB"
      )
    )
    if (has_name(allowed, "required")) {
      x$set_required(allowed$required)
    }
  }
  if (has_name(allowed$spelling, "ignore")) {
    x$set_ignore(allowed$spelling$ignore)
  }
  if (has_name(allowed$spelling, "other")) {
    x$set_other(allowed$spelling$other)
  }
  x$package <- allowed$package

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
