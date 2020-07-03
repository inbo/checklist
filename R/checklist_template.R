#' Create a template with acceptable problems in the package
#'
#' @param output The output of `check_package()`.
#' @inheritParams check_package
#' @importFrom assertthat assert_that has_name
#' @importFrom utils file_test
#' @importFrom yaml write_yaml
#' @export
checklist_template <- function(output, path = ".") {
  assert_that(is.list(output))
  assert_that(has_name(output, "warnings"))
  assert_that(is.character(output$warnings))
  assert_that(has_name(output, "notes"))
  assert_that(is.character(output$notes))
  assert_that(is.string(path))
  assert_that(
    file_test("-d", path),
    msg = "`path` is not a directory."
  )

  key_value <- function(x) {
    list(motivation = "", value = x)
  }
  list(
    description = "Configuration file for checklist::check_pkg()",
    allowed = list(
      warnings = lapply(output$warnings, key_value),
      notes = lapply(output$notes, key_value)
    )
  ) -> template
  write_yaml(template, file.path(path, "checklist_template.yml"))
  return(NULL)
}
