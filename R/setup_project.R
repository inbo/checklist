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
  checklist_file <- path(path, "checklist.yml")
  if (is_file(checklist_file)) {
    x <- read_checklist(path)
  } else {
    x <- checklist$new(x = path, language = "en-GB", package = FALSE)
    x <- x$allowed()
  }
  setup_vc(path = path)
  checks <- "checklist"
  answer <- menu(c("yes", "no"), title = "check file name conventions?")
  checks <- c(checks, list("filename conventions", character(0))[[answer]])
  answer <- menu(c("yes", "no"), title = "check code style?")
  checks <- c(checks, list("lintr", character(0))[[answer]])
  answer <- menu(
    c("English", "Dutch", "French"), title = "Default language of the project?"
  )
  x$set_default(c("en-GB", "nl-BE", "fr-FR")[answer])
  answer <- menu(c("yes", "no"), title = "check spelling?")
  checks <- c(checks, list("spelling", character(0))[[answer]])
  x$set_required(checks = checks)
  write_checklist(x = x)
}

#' @importFrom gert git_add git_init
setup_vc <- function(path) {
  if (is_repository(path)) {
    assert_that(is_workdir_clean(path))
  } else {
    answer <- menu(c("yes", "no"), title = "use version control?")
    if (answer == 2) {
      return(invisible(NULL))
    }
    git_init(path = path)
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
  git_add(".gitignore", force = TRUE, repo = path)

  # Add GitHub actions
  dir_create(path(path, ".github", "workflows"))
  file_copy(
    system.file(
      path("project_template", "check_project.yml"), package = "checklist"
    ),
    path(path, ".github", "workflows", "check_project.yml"), overwrite = TRUE
  )
  git_add(
    path(".github", "workflows", "check_project.yml"), force = TRUE, repo = path
  )

  return(invisible(NULL))
}
