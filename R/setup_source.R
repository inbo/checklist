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
#' @inheritParams create_package
#' @export
#' @importFrom assertthat assert_that
#' @importFrom desc desc
#' @importFrom fs dir_create file_copy path path_real
#' @importFrom gert git_add
#' @importFrom utils file_test
#' @family setup
setup_source <- function(path = ".", language = "en-GB") {
  path <- path_real(path)
  assert_that(is_workdir_clean(repo = path))
  x <- checklist$new(x = path, language = language, package = FALSE)
  x$set_required(c("filename conventions", "lintr"))
  write_checklist(x = x)
  git_add("checklist.yml", force = TRUE, repo = path)

  # add LICENSE.md
  if (length(list.files(path, "LICEN(S|C)E")) == 0) {
    file_copy(
      system.file(
        file.path("generic_template", "cc_by_4_0.md"), package = "checklist"
      ),
      path(path, "LICENSE.md")
    )
    git_add("LICENSE.md", force = TRUE, repo = path)
  }

  # Add code of conduct
  dir_create(path(path, ".github"))
  file_copy(
    system.file(
      path("generic_template", "CODE_OF_CONDUCT.md"), package = "checklist"
    ),
    path(path, ".github", "CODE_OF_CONDUCT.md")
  )
  git_add(path(".github", "CODE_OF_CONDUCT.md"), force = TRUE, repo = path)

  # Add GitHub actions
  dir_create(path(path, ".github", "workflows"))
  file_copy(
    system.file(
      path("source_template", "check_source.yml"), package = "checklist"
    ),
    path(path, ".github", "workflows", "check_source.yml"),
    overwrite = TRUE
  )
  git_add(
    path(".github", "workflows", "check_source.yml"),
    force = TRUE, repo = path
  )

  message("project prepared for checklist::check_source()")
  return(invisible(NULL))
}
