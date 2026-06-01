#' Initialise a new R project
#'
#' This function creates a new RStudio project with `checklist` functionality.
#' @param path The folder in which to create the project as a folder.
#' @param project The name of the project.
#' @export
#' @importFrom assertthat assert_that is.flag is.string noNA
#' @importFrom citeme ask_language ask_yes_no new_org_list org_list
#' @importFrom citeme org_list_from_url select_license
#' @family setup
create_project <- function(path, project) {
  assert_that(is.string(path), noNA(path), file_test("-d", path))
  assert_that(is.string(project), noNA(project))
  assert_that(
    !file_test("-d", file.path(path, project)),
    msg = "Existing project folder"
  )

  # ask interactive information
  title <- readline(prompt = "Enter the title: ")
  description <- readline(prompt = "Enter the description: ")
  keywords <- ask_keywords()
  use_vc <- ask_yes_no("Use version control?")
  if (use_vc) {
    preferred_protocol() |> sprintf(project) -> git
    org <- org_list_from_url(git)
  } else {
    org <- new_org_list()
  }
  license <- select_license(org, type = "project")
  language <- ask_language(org, prompt = "What is the main project language?")
  info <- project_maintainer(org = org, lang = language)
  authors <- info$authors
  org <- info$org
  cc <- use_vc && ask_yes_no("Add a default code of conduct?")
  cg <- use_vc && ask_yes_no("Add default contributing guidelines?")
  use_renv <- ask_yes_no(
    "Use `renv` to lock package versions with the project?",
    default = FALSE
  )
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

  path <- file.path(path, project)
  dir.create(path, recursive = TRUE, showWarnings = FALSE)

  # create default folders
  vapply(
    file.path(path, c("data", "media", "output", "source")),
    dir.create,
    logical(1),
    recursive = TRUE,
    showWarnings = FALSE
  )
  org$write(x = path)
  # create RStudio project
  file.copy(
    system.file(
      file.path("project_template", "rproj.template"),
      package = "checklist"
    ),
    paste0(file.path(path, project), ".Rproj")
  )
  file.path("project_template", "checklist.R") |>
    system.file(package = "checklist") |>
    file.copy(file.path(path, "source", "checklist.R"))
  create_readme(
    path = path,
    authors = authors,
    title = title,
    description = description,
    keywords = keywords,
    org = org,
    license = license,
    lang = language,
    type = "project"
  )
  renv_activate(path = path, use_renv = use_renv)
  x <- checklist$new(x = path, language = language, package = FALSE)
  x$allowed()
  x$set_ignore(c(".github", "LICENSE.md"))
  x$set_default(language)
  x$set_required(checks = checks)
  write_checklist(x)

  set_license(x, license = license, org = org)
  setup_vc(path = path, url = git, use_vc = use_vc, use_cc = cc, use_cg = cg)

  if (
    !interactive() ||
      !requireNamespace("rstudioapi", quietly = TRUE) ||
      !rstudioapi::isAvailable()
  ) {
    return(invisible(NULL))
  }
  rstudioapi::openProject(path, newSession = TRUE)
}
