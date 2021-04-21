#' Add or update the checklist infrastructure to an existing package
#'
#' Use this function when you have an existing package and you want to use the
#' checklist functionality.
#' Please keep in mind that the checklist is an opinionated list of checks.
#' It might require some breaking changes in your package.
#' Please DO READ `vignette("getting_started")` before running this function.
#'
#' @template checklist_structure
#'
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
  assert_that(is_workdir_clean(repo))

  # make DESCRIPTION tidy
  tidy_desc(path)
  add(repo = repo, "DESCRIPTION", force = TRUE)

  if (!file_test("-f", file.path(path, ".Rbuildignore"))) {
    file.copy(
      system.file(
        file.path("package_template", "rbuildignore"), package = "checklist"
      ),
      file.path(path, ".Rbuildignore")
    )
  } else {
    current <- readLines(file.path(path, ".Rbuildignore"))
    new <- readLines(
      system.file(
        file.path("package_template", "rbuildignore"), package = "checklist"
      )
    )
    writeLines(
      sort(unique(c(new, current))),
      file.path(path, ".Rbuildignore")
    )
  }
  add(repo = repo, ".Rbuildignore", force = TRUE)

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
    system.file(
      file.path("package_template", "codecov.yml"), package = "checklist"
    ),
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
      system.file(
        file.path("package_template", "README.Rmd"), package = "checklist"
      )
    )
    readme <- gsub("\\{\\{\\{ Package \\}\\}\\}", package, readme)
    writeLines(readme, file.path(path, "README.Rmd"))
    add(repo = repo, "README.Rmd", force = TRUE)
  }

  # add LICENSE.md
  if (length(list.files(path, "LICEN(S|C)E")) == 0) {
    file.copy(
      system.file(
        file.path("generic_template", "gplv3.md"), package = "checklist"
      ),
      file.path(path, "LICENSE.md")
    )
    add(repo = repo, "LICENSE.md", force = TRUE)
  }

  # Add code of conduct
  dir.create(file.path(path, ".github"), showWarnings = FALSE)
  file.copy(
    system.file(
      file.path("generic_template", "CODE_OF_CONDUCT.md"), package = "checklist"
    ),
    file.path(path, ".github", "CODE_OF_CONDUCT.md")
  )
  add(repo = repo, file.path(".github", "CODE_OF_CONDUCT.md"), force = TRUE)

  # Add contributing guidelines
  file.copy(
    system.file(
      file.path("package_template", "CONTRIBUTING.md"), package = "checklist"
    ),
    file.path(path, ".github", "CONTRIBUTING.md")
  )
  add(repo = repo, file.path(".github", "CONTRIBUTING.md"), force = TRUE)

  # Add GitHub actions
  dir.create(file.path(path, ".github", "workflows"), showWarnings = FALSE)
  file.copy(
    system.file(
      file.path("package_template", "check_on_branch.yml"),
      package = "checklist"
    ),
    file.path(path, ".github", "workflows", "check_on_branch.yml"),
    overwrite = TRUE
  )
  add(
    repo = repo, force = TRUE,
    file.path(".github", "workflows", "check_on_branch.yml")
  )
  file.copy(
    system.file(
      file.path("package_template", "check_on_master.yml"),
      package = "checklist"
    ),
    file.path(path, ".github", "workflows", "check_on_master.yml"),
    overwrite = TRUE
  )
  add(
    repo = repo, force = TRUE,
    file.path(".github", "workflows", "check_on_master.yml")
  )
  file.copy(
    system.file(
      file.path("package_template", "check_on_different_r_os.yml"),
      package = "checklist"
    ),
    file.path(path, ".github", "workflows", "check_on_different_r_os.yml"),
    overwrite = TRUE
  )
  add(
    repo = repo, force = TRUE,
    file.path(".github", "workflows", "check_on_different_r_os.yml")
  )
  file.copy(
    system.file(
      file.path("package_template", "release.yml"), package = "checklist"
    ),
    file.path(path, ".github", "workflows", "release.yml"),
    overwrite = TRUE
  )
  add(
    repo = repo, file.path(".github", "workflows", "release.yml"), force = TRUE
  )

  # Add pkgdown website
  file.copy(
    system.file(
      file.path("package_template", "_pkgdown.yml"), package = "checklist"
    ),
    file.path(path, "_pkgdown.yml")
  )
  add(repo = repo, "_pkgdown.yml", force = TRUE)
  dir.create(file.path(path, "pkgdown"), showWarnings = FALSE)
  file.copy(
    system.file(
      file.path("package_template", "pkgdown.css"), package = "checklist"
    ),
    file.path(path, "pkgdown", "extra.css"), overwrite = TRUE
  )
  add(repo = repo, file.path("pkgdown", "extra.css"), force = TRUE)
  dir.create(
    file.path(path, "man", "figures"), showWarnings = FALSE, recursive = TRUE
  )
  file.copy(
    system.file(
      file.path("help", "figures", "logo-en.png"), package = "checklist"
    ),
    file.path(path, "man", "figures", "logo-en.png"), overwrite = TRUE
  )
  add(repo = repo, file.path("man", "figures", "logo-en.png"), force = TRUE)
  file.copy(
    system.file(
      file.path("help", "figures", "background-pattern.png"),
      package = "checklist"
    ),
    file.path(path, "man", "figures", "background-pattern.png"),
    overwrite = TRUE
  )
  add(
    repo = repo, file.path("man", "figures", "background-pattern.png"),
    force = TRUE
  )
  file.copy(
    system.file(
      file.path("package_template", "flanders.woff2"), package = "checklist"
    ),
    file.path(path, "man", "figures", "flanders.woff2"), overwrite = TRUE
  )
  add(repo = repo, file.path("man", "figures", "flanders.woff2"), force = TRUE)
  file.copy(
    system.file(
      file.path("package_template", "flanders.woff"), package = "checklist"
    ),
    file.path(path, "man", "figures", "flanders.woff"), overwrite = TRUE
  )
  add(repo = repo, file.path("man", "figures", "flanders.woff"), force = TRUE)

  message("package prepared for checklist::check_package()")
  return(invisible(NULL))
}
