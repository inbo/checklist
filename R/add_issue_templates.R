#' Add issue and pull request templates
#' @inheritParams read_checklist
#' @export
#' @family both
add_issue_templates <- function(x) {
  x <- read_checklist(x)
  if (!x$package) {
    warnings("Templates are currently only available for packages. Skipping.")
    return(invisible(NULL))
  }
  path <- x$get_path

  file.path(path, ".github", "ISSUE_TEMPLATE", fsep = "/") |>
    dir.create(recursive = TRUE, showWarnings = FALSE)
  insert_file(
    repo = path,
    filename = "config.yml",
    template = path("package_template", "ISSUE_TEMPLATE"),
    target = path(".github", "ISSUE_TEMPLATE")
  )
  insert_file(
    repo = path,
    filename = "bug_report.yml",
    template = path("package_template", "ISSUE_TEMPLATE"),
    target = path(".github", "ISSUE_TEMPLATE")
  )
  insert_file(
    repo = path,
    filename = "feature_request.yml",
    template = path("package_template", "ISSUE_TEMPLATE"),
    target = path(".github", "ISSUE_TEMPLATE")
  )
  insert_file(
    repo = path,
    filename = "documentation.yml",
    template = path("package_template", "ISSUE_TEMPLATE"),
    target = path(".github", "ISSUE_TEMPLATE")
  )
  return(invisible(NULL))
}
