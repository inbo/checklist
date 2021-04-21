#' Add or update the checklist infrastructure to a repository with source files.
#'
#' This adds the required GitHub workflows to run `check_source()` automatically
#' whenever you push commits to GitHub.
#' It also adds a
#' [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) license file,
#' a [CODE_OF_CONDUCT.md](https://inbo.github.io/checklist/CODE_OF_CONDUCT.html)
#' and the checklist configuration file (`checklist.yml`).
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
  assert_that(is_workdir_clean(repo))

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
      system.file(
        file.path("generic_template", "cc_by_sa_4_0.md"), package = "checklist"
      ),
      file.path(path, "LICENSE.md")
    )
    add(repo = repo, "LICENSE.md", force = TRUE)
  }

  # Add code of conduct
  dir.create(file.path(path, ".github"), showWarnings = FALSE)
  file.copy(
    system.file(
      file.path("generic_template", "CODE_OF_CONDUCT.md"),
      package = "checklist"
    ),
    file.path(path, ".github", "CODE_OF_CONDUCT.md")
  )
  add(repo = repo, file.path(".github", "CODE_OF_CONDUCT.md"), force = TRUE)

  # Add GitHub actions
  dir.create(file.path(path, ".github", "workflows"), showWarnings = FALSE)
  file.copy(
    system.file(
      file.path("source_template", "check_source.yml"), package = "checklist"),
    file.path(path, ".github", "workflows", "check_source.yml"),
    overwrite = TRUE
  )
  add(
    repo = repo, file.path(".github", "workflows", "check_source.yml"),
    force = TRUE
  )

  message("project prepared for checklist::check_source()")
  return(invisible(NULL))
}
