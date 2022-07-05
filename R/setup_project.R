#' Set-up `checklist` on an existing R project
#'
#' Use this function to set-up or change the `checklist` infrastructure for an
#' existing project.
#' The function interactively asks questions to set-up the required checks.
#' @param path the project root folder
#' @export
#' @importFrom assertthat assert_that is.string
#' @importFrom fs is_dir path path_real
#' @importFrom utils menu
#' @family setup
setup_project <- function(path = ".") {
  assert_that(is.string(path), is_dir(path), interactive())
  path <- path_real(path)
  files <- c("checklist.yml")
  checklist_file <- path(path, files)

  if (is_file(checklist_file)) {
    x <- read_checklist(path)
  } else {
    x <- checklist$new(x = path, language = "en-GB", package = FALSE)
    x$allowed()
    x$set_ignore(c(".github", "LICENSE.md"))
  }

  repo <- setup_vc(path = path)
  checks <- "checklist"

  answer <- menu(c("yes", "no"), title = "Check file name conventions?")
  checks <- c(checks, list("filename conventions", character(0))[[answer]])

  answer <- menu(c("yes", "no"), title = "Check code style?")
  checks <- c(checks, list("lintr", character(0))[[answer]])

  answer <- menu(
    c("English", "Dutch", "French"), title = "Default language of the project?"
  )
  x$set_default(c("en-GB", "nl-BE", "fr-FR")[answer])

  answer <- menu(c("yes", "no"), title = "Check spelling?")
  checks <- c(checks, list("spelling", character(0))[[answer]])

  answer <- menu(
    c("yes", "no"),
    title = "Check the LICENSE file? The file will be created when missing."
  )
  checks <- c(checks, list("license", character(0))[[answer]])
  files <- c(files, list("LICENSE.md", character(0))[[answer]])
  if (!file_exists(path(path, "LICENSE.md"))) {
    file_copy(
      system.file(
        file.path("generic_template", "cc_by_4_0.md"), package = "checklist"
      ),
      path(path, "LICENSE.md")
    )
  }

  x$set_required(checks = checks)
  write_checklist(x = x)

  if (is.null(repo)) {
    return(invisible(NULL))
  }
  git_add(files, force = TRUE, repo = repo)
  return(invisible(NULL))
}

#' @importFrom gert git_add git_find git_init
setup_vc <- function(path) {
  if (is_repository(path)) {
    assert_that(is_workdir_clean(path))
    repo <- git_find(path)
  } else {
    answer <- menu(c("yes", "no"), title = "Use version control?")
    if (answer == 2) {
      return(invisible(NULL))
    }
    repo <- git_init(path = path)
  }

  # add .gitignore
  template <- system.file(
    path("generic_template", "gitignore"), package = "checklist"
  )
  if (is_file(path(path, ".gitignore"))) {
    current <- readLines(path(path, ".gitignore"))
    new <- readLines(template)
    writeLines(
      sort(unique(c(new, current)), method = "radix"),
      path(path, ".gitignore")
    )
  } else {
    file_copy(template, path(path, ".gitignore"))
  }
  git_add(".gitignore", force = TRUE, repo = repo)

  # Add GitHub actions
  dir_create(path(path, ".github", "workflows"))
  file_copy(
    system.file(
      path("project_template", "check_project.yml"), package = "checklist"
    ),
    path(path, ".github", "workflows", "check_project.yml"), overwrite = TRUE
  )
  git_add(
    path(".github", "workflows", "check_project.yml"), force = TRUE, repo = repo
  )

  # Add code of conduct
  answer <- menu(c("yes", "no"), title = "Add a default code of conduct?")
  if (answer == 1) {
    dir_create(path(path, ".github"))
    file_copy(
      system.file(
        path("generic_template", "CODE_OF_CONDUCT.md"), package = "checklist"
      ),
      path(path, ".github", "CODE_OF_CONDUCT.md")
    )
    git_add(path(".github", "CODE_OF_CONDUCT.md"), force = TRUE, repo = repo)
  }

  # Add contributing guidelines
  answer <- menu(c("yes", "no"), title = "Add default contributing guidelines?")
  if (answer == 1) {
    file_copy(
      system.file(
        path("package_template", "CONTRIBUTING.md"), package = "checklist"
      ),
      path(path, ".github", "CONTRIBUTING.md")
    )
    git_add(path(".github", "CONTRIBUTING.md"), force = TRUE, repo = repo)
  }

  return(invisible(repo))
}
