#' Set-up `checklist` on an existing R project
#'
#' Use this function to set-up or change the `checklist` infrastructure for an
#' existing project.
#' The function interactively asks questions to set-up the required checks.
#' @param path the project root folder
#' @export
#' @importFrom assertthat assert_that is.string
#' @importFrom citeme ask_language ask_yes_no org_list org_list_from_url
#' @family setup
setup_project <- function(path = ".") {
  assert_that(is.string(path), file_test("-d", path))
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  checklist_file <- path_(path, "checklist.yml")

  if (file_test("-f", checklist_file)) {
    x <- read_checklist(path)
    language <- x$default
    org <- org_list$new()$read(path)
  } else {
    if (is_repository(path)) {
      git <- git_remote_list(path)$url
    } else {
      preferred_protocol() |> sprintf(basename(path)) -> git
    }
    org <- org_list_from_url(git)
    language <- ask_language(org, prompt = "What is the main project language?")
    x <- checklist$new(x = path, language = language, package = FALSE)
    x$allowed()
    x$set_ignore(c(".github", "LICENSE.md"))
  }

  vapply(
    path_(path, c("data", "media", "output", "source")),
    dir.create,
    logical(1),
    recursive = TRUE,
    showWarnings = FALSE
  )

  if (!file_test("-f", path_(path, "source", "checklist.R"))) {
    path_("project_template", "checklist.R") |>
      system.file(package = "checklist") |>
      file.copy(path_(path, "source", "checklist.R"))
  }
  renv_activate(path = path)
  create_readme(path = path, org = org, lang = language, type = "project")
  checks <- c(
    "checklist",
    "folder conventions"[isTRUE(ask_yes_no("Check folder conventions?"))],
    "filename conventions"[isTRUE(ask_yes_no("Check file name conventions?"))],
    "lintr"[isTRUE(ask_yes_no("Check code style?"))],
    "license"[isTRUE(ask_yes_no(
      "Check the LICENSE file? The file will be created when missing."
    ))],
    "organisation",
    "spelling"[isTRUE(ask_yes_no("Check spelling?"))],
    "CITATION"[isTRUE(ask_yes_no("Check citation?"))]
  )

  if ("license" %in% checks && !file_test("-f", path_(path, "LICENSE.md"))) {
    set_license(x, org = org)
  }

  x$set_required(checks = checks)
  write_checklist(x = x)
  setup_vc(path = path, url = git)
  return(invisible(NULL))
}
