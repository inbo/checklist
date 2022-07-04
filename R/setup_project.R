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
