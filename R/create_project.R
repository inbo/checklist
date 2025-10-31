#' Initialise a new R project
#'
#' This function creates a new RStudio project with `checklist` functionality.
#' @param path The folder in which to create the project as a folder.
#' @param project The name of the project.
#' @export
#' @importFrom assertthat assert_that is.flag is.string noNA
#' @importFrom fs dir_create dir_exists file_copy is_dir path
#' @family setup
create_project <- function(path, project) {
  assert_that(is.string(path), noNA(path), is_dir(path))
  assert_that(is.string(project), noNA(project))
  assert_that(!dir_exists(path(path, project)), msg = "Existing project folder")

  # ask interactive information
  title <- readline(prompt = "Enter the title: ")
  description <- readline(prompt = "Enter the description: ")
  keywords <- ask_keywords()
  preferred_protocol() |>
    sprintf(project) -> git
  org <- org_list_from_url(git)
  license <- ask_license(org, type = "project")
  language <- ask_language(org)
  authors <- project_maintainer(org, language)
  use_vc <- ask_yes_no("Use version control?")
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

  path <- path(path, project)
  dir_create(path)

  # create default folders
  dir_create(path, c("data", "media", "output", "source"))
  # create RStudio project
  file_copy(
    system.file(
      path("project_template", "rproj.template"),
      package = "checklist"
    ),
    path(path, project, ext = "Rproj")
  )
  path("project_template", "checklist.R") |>
    system.file(package = "checklist") |>
    file_copy(path(path, "source", "checklist.R"))
  create_readme(
    path = path,
    authors = authors,
    title = title,
    description = description,
    keywords = keywords
  )
  renv_activate(path = path, use_renv = use_renv)
  x <- checklist$new(x = path, language = language, package = FALSE)
  x$allowed()
  x$set_ignore(c(".github", "LICENSE.md"))
  x$set_default(language)
  x$set_required(checks = checks)
  write_checklist(x)

  if ("license" %in% checks) {
    set_license(x)
  }

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
