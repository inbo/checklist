#' Add or update the checklist infrastructure to a repository with source files.
#' @param path The path to the project.
#' Defaults to `"."`.
#' @export
#' @importFrom assertthat assert_that
#' @importFrom desc desc
#' @importFrom git2r add repository
#' @importFrom utils file_test
#' @family setup
setup_source <- function(path = ".") {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  repo <- repository(path)
  assert_that(
    identical(
      status(repo, untracked = FALSE),
      structure(
        list(
          staged = structure(list(), .Names = character(0)),
          unstaged = structure(list(), .Names = character(0))
        ),
        class = "git_status"
      )
    ),
    msg = "Working directory is not clean. Please commit changes first."
  )

  # add checklist.yml
  writeLines(
    "description: Configuration file for checklist::check_pkg()
package: no
allowed:
  warnings: []
  notes: []",
    file.path(path, "checklist.yml")
  )
  add(repo = repo, "checklist.yml", force = TRUE)

  # add LICENSE.md
  if (length(list.files(path, "LICEN(S|C)E")) == 0) {
    file.copy(
      system.file("generic_template/cc_by_sa_4_0.md", package = "checklist"),
      file.path(path, "LICENSE.md")
    )
    add(repo = repo, "LICENSE.md", force = TRUE)
  }

  # Add code of conduct
  dir.create(file.path(path, ".github"), showWarnings = FALSE)
  file.copy(
    system.file("generic_template/CODE_OF_CONDUCT.md", package = "checklist"),
    file.path(path, ".github", "CODE_OF_CONDUCT.md")
  )
  add(repo = repo, ".github/CODE_OF_CONDUCT.md", force = TRUE)

  # Add GitHub actions
  dir.create(file.path(path, ".github", "workflows"), showWarnings = FALSE)
  file.copy(
    system.file("source_template/check_source.yml", package = "checklist"),
    file.path(path, ".github", "workflows", "check_source.yml"),
    overwrite = TRUE
  )
  add(repo = repo, ".github/workflows/check_source.yml", force = TRUE)

  message("project prepared for checklist::check_source()")
  return(invisible(NULL))
}
