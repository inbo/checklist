#' Add AI agents
#' @inheritParams read_checklist
#' @export
#' @family both
add_agents <- function(x) {
  x <- read_checklist(x)
  if (!x$package) {
    warnings("Agents are currently only available for packages. Skipping.")
    return(invisible(NULL))
  }
  path <- x$get_path

  file.path(path, ".github", "agents", fsep = "/") |>
    dir.create(recursive = TRUE, showWarnings = FALSE)
  insert_file(
    repo = path,
    filename = "checklist_agent.md",
    template = "agents",
    target = file.path(".github", "agents")
  )
  insert_file(
    repo = path,
    filename = "docs_agent.md",
    template = "agents",
    target = file.path(".github", "agents")
  )
  insert_file(
    repo = path,
    filename = "package_code_agent.md",
    template = "agents",
    target = file.path(".github", "agents")
  )
  insert_file(
    repo = path,
    filename = "test_agent.md",
    template = "agents",
    target = file.path(".github", "agents")
  )
  return(invisible(NULL))
}
