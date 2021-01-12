#' Add or update the checklist infrastructure to an existing package
#' @param path The path to the package.
#' Defaults to `"."`.
#' @export
#' @importFrom assertthat assert_that
#' @importFrom desc desc
#' @importFrom git2r add repository
#' @importFrom utils file_test
#' @family setup
setup_package <- function(path = ".") {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  assert_that(
    file_test("-f", file.path(path, "DESCRIPTION")),
    msg = paste("No DESCRIPTION file found at", path)
  )
  package <- desc(path)$get("Package")

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

  # make DESCRIPTION tidy
  tidy_desc(path)
  add(repo = repo, "DESCRIPTION", force = TRUE)

  # add checklist.yml
  writeLines(
    "description: Configuration file for checklist::check_pkg()
package: yes
allowed:
  warnings: []
  notes: []",
    file.path(path, "checklist.yml")
  )
  add(repo = repo, "checklist.yml", force = TRUE)

  # add codecov.yml
  file.copy(
    system.file("package_template/codecov.yml", package = "checklist"),
    file.path(path, "codecov.yml")
  )
  add(repo = repo, "codecov.yml", force = TRUE)

  # add NEWS.md
  if (!file_test("-f", file.path(path, "NEWS.md"))) {
    news <- sprintf(
      "# %s 0.0.0\n\n* Added a `NEWS.md` file to track changes to the package.",
      package
    )
    writeLines(news, file.path(path, "NEWS.md"))
    add(repo = repo, "NEWS.md", force = TRUE)
  }

  # add README.Rmd
  if (!file_test("-f", file.path(path, "README.md"))) {
    readme <- readLines(
      system.file("package_template/README.Rmd", package = "checklist")
    )
    readme <- gsub("\\{\\{\\{ Package \\}\\}\\}", package, readme)
    writeLines(readme, file.path(path, "README.Rmd"))
    add(repo = repo, "README.Rmd", force = TRUE)
  }

  # add LICENSE.md
  if (length(list.files(path, "LICEN(S|C)E")) == 0) {
    file.copy(
      system.file("package_template/gplv3.md", package = "checklist"),
      file.path(path, "LICENSE.md")
    )
    add(repo = repo, "LICENSE.md", force = TRUE)
  }

  # Add code of conduct
  dir.create(file.path(path, ".github"), showWarnings = FALSE)
  file.copy(
    system.file("package_template/CODE_OF_CONDUCT.md", package = "checklist"),
    file.path(path, ".github", "CODE_OF_CONDUCT.md")
  )
  add(repo = repo, ".github/CODE_OF_CONDUCT.md", force = TRUE)

  # Add contributing guidelines
  file.copy(
    system.file("package_template/CONTRIBUTING.md", package = "checklist"),
    file.path(path, ".github", "CONTRIBUTING.md")
  )
  add(repo = repo, ".github/CONTRIBUTING.md", force = TRUE)

  # Add GitHub actions
  dir.create(file.path(path, ".github", "workflows"), showWarnings = FALSE)
  file.copy(
    system.file("package_template/check_on_branch.yml", package = "checklist"),
    file.path(path, ".github", "workflows", "check_on_branch.yml"),
    overwrite = TRUE
  )
  add(repo = repo, ".github/workflows/check_on_branch.yml", force = TRUE)
  file.copy(
    system.file("package_template/check_on_master.yml", package = "checklist"),
    file.path(path, ".github", "workflows", "check_on_master.yml"),
    overwrite = TRUE
  )
  add(repo = repo, ".github/workflows/check_on_master.yml", force = TRUE)
  file.copy(
    system.file(
      "package_template/check_on_different_r_os.yml",
      package = "checklist"
    ),
    file.path(path, ".github", "workflows", "check_on_different_r_os.yml"),
    overwrite = TRUE
  )
  add(
    repo = repo,
    ".github/workflows/check_on_different_r_os.yml",
    force = TRUE
  )

  # Add pkgdown website
  file.copy(
    system.file("package_template/_pkgdown.yml", package = "checklist"),
    file.path(path, "_pkgdown.yml")
  )
  add(repo = repo, "_pkgdown.yml", force = TRUE)
  dir.create(file.path(path, "pkgdown"), showWarnings = FALSE)
  file.copy(
    system.file("package_template/pkgdown.css", package = "checklist"),
    file.path(path, "pkgdown", "extra.css"), overwrite = TRUE
  )
  add(repo = repo, "pkgdown/extra.css", force = TRUE)

  message("package prepared for checklist::check_package()")
  return(invisible(NULL))
}
