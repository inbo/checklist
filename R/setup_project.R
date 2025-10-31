#' Set-up `checklist` on an existing R project
#'
#' Use this function to set-up or change the `checklist` infrastructure for an
#' existing project.
#' The function interactively asks questions to set-up the required checks.
#' @param path the project root folder
#' @export
#' @importFrom assertthat assert_that is.string
#' @importFrom fs dir_create file_copy is_dir path path_real path_rel
#' @family setup
setup_project <- function(path = ".") {
  assert_that(is.string(path), is_dir(path))
  path <- path_real(path)
  checklist_file <- path(path, "checklist.yml")

  if (is_file(checklist_file)) {
    x <- read_checklist(path)
    language <- x$default
  } else {
    if (is_repository(path)) {
      git <- git_remote_list(path)$url
    } else {
      preferred_protocol() |>
        sprintf(basename(path)) -> git
    }
    org <- org_list_from_url(git)
    language <- ask_language(org)
    x <- checklist$new(x = path, language = language, package = FALSE)
    x$allowed()
    x$set_ignore(c(".github", "LICENSE.md"))
  }

  dir_create(path, c("data", "media", "output", "source"))

  if (!file_exists(path(path, "source", "checklist.R"))) {
    path("project_template", "checklist.R") |>
      system.file(package = "checklist") |>
      file_copy(path(path, "source", "checklist.R"))
  }
  renv_activate(path = path)
  files <- create_readme(path = path, org = org, lang = language)
  checks <- c(
    "checklist",
    "folder conventions"[isTRUE(ask_yes_no("Check folder conventions?"))],
    "filename conventions"[isTRUE(ask_yes_no("Check file name conventions?"))],
    "lintr"[isTRUE(ask_yes_no("Check code style?"))],
    "license"[
      isTRUE(
        ask_yes_no(
          "Check the LICENSE file? The file will be created when missing."
        )
      )
    ],
    "organisation",
    "spelling"[isTRUE(ask_yes_no("Check spelling?"))],
    "CITATION"[isTRUE(ask_yes_no("Check citation?"))]
  )

  if ("license" %in% checks && !file_exists(path(path, "LICENSE.md"))) {
    set_license(x)
  }

  x$set_required(checks = checks)
  write_checklist(x = x)
  repo <- setup_vc(path = path, url = git)
  return(invisible(NULL))
}
