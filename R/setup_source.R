#' Add or update the checklist infrastructure to a repository with source files.
#'
#' This adds the required GitHub workflows to run `check_source()` automatically
#' whenever you push commits to GitHub.
#' It also adds a
#' [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/) license file,
#' a
#' [`CODE_OF_CONDUCT.md`](https://inbo.github.io/checklist/CODE_OF_CONDUCT.html)
#' and the checklist configuration file (`checklist.yml`).
#' @param path The path to the project.
#' Defaults to `"."`.
#' @export
#' @family setup
setup_source <- function(path = ".") {
  # nocov start
  .Defunct(new = "setup_project", package = "checklist")
  # nocov end
}
