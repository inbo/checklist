#' Read the check list file from a package
#'
#' The checklist package stores configuration information in the `checklist.yml`
#' file in the root of a project.
#' This function reads this configuration.
#' It is mainly used by the other functions inside the package.
#' If no `checklist.yml` file is found at the path,
#' the function walks upwards through the directory structure until it finds
#' such file.
#' The function returns an error when it reaches the root of the disk without
#' finding a `checklist.yml` file.
#' @param x Either a `checklist` object or a path to the source code.
#' Defaults to `.`.
#' @return A `checklist` object.
#' @export
#' @importFrom assertthat assert_that has_name is.string
#' @importFrom yaml read_yaml
#' @family both
read_checklist <- function(x = ".") {
  if (inherits(x, "checklist")) {
    return(x)
  }

  assert_that(is.string(x), file_test("-d", x))
  current <- normalizePath(x)
  checklist_file <- path_(current, "checklist.yml")
  while (
    !file_test("-f", checklist_file) && length(strsplit(current, "/")[[1]]) > 1
  ) {
    path_(current, "..") |> normalizePath() -> current
    checklist_file <- path_(current, "checklist.yml")
  }
  assert_that(
    file_test("-f", checklist_file),
    msg = paste(
      "No checklist.yml found at `%1$s` or its parents.",
      "\nRun `checklist::setup_package(\"%1$s\")` or",
      "`checklist::setup_project(\"%1$s\")`."
    ) |>
      sprintf(normalizePath(x))
  )

  # read existing check list file
  allowed <- read_yaml(checklist_file)
  assert_that(has_name(allowed, "package"))
  allowed$spelling <- coalesce(allowed$spelling, list(default = "en-GB"))
  if (allowed$package) {
    x <- checklist$new(
      x = current,
      package = TRUE,
      language = coalesce(allowed$spelling$default, "en-GB")
    )
  } else {
    x <- checklist$new(
      x = current,
      package = FALSE,
      language = ifelse(
        has_name(allowed$spelling, "default"),
        allowed$spelling$default,
        "en-GB"
      )
    )
    x$set_required(coalesce(allowed$required, character(0)))
  }
  x$set_ignore(coalesce(allowed$spelling$ignore, character(0)))
  x$set_other(coalesce(allowed$spelling$other, list()))
  x$package <- allowed$package
  x$set_pak(coalesce(as.character(allowed$pak), character(0)))
  x$set_gha_install(coalesce(as.character(allowed$gha_install), character(0)))

  assert_that(has_name(allowed, "description"))
  assert_that(has_name(allowed, "allowed"))
  allowed <- allowed$allowed
  assert_that(has_name(allowed, "warnings"))
  assert_that(has_name(allowed, "notes"))
  assert_that(is.list(allowed$warnings))
  assert_that(is.list(allowed$notes))
  motivation <- vapply(allowed$warnings, `[[`, character(1), "motivation")
  assert_that(
    length(allowed$warnings) == length(motivation),
    msg = "Each warning in the checklist requires a motivation"
  )
  assert_that(
    all(nchar(motivation) > 0),
    msg = "Please add a motivation for each warning the checklist"
  )
  motivation <- vapply(allowed$notes, `[[`, character(1), "motivation")
  assert_that(
    length(allowed$notes) == length(motivation),
    msg = "Each note in the checklist requires a motivation"
  )
  assert_that(
    all(nchar(motivation) > 0),
    msg = "Please add a motivation for each note the checklist"
  )
  value <- vapply(allowed$warnings, `[[`, character(1), "value")
  assert_that(
    length(allowed$warnings) == length(value),
    msg = "Each warning in the checklist requires a value"
  )
  value <- vapply(allowed$notes, `[[`, character(1), "value")
  assert_that(
    length(allowed$notes) == length(value),
    msg = "Each note in the checklist requires a value"
  )
  x <- x$allowed(warnings = allowed$warnings, notes = allowed$notes)

  return(x)
}
