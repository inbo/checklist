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
#' @param license What type of license should be used?
#' Choice between GPL-3 and MIT.
#' Default GPL-3.
#' @export
#' @importFrom assertthat assert_that
#' @importFrom desc desc
#' @importFrom gert git_add
#' @importFrom utils file_test
#' @family setup
setup_package <- function(path = ".",
                          license = c("GPL-3", "MIT")) {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  license <- match.arg(license)
  assert_that(
    file_test("-f", file.path(path, "DESCRIPTION")),
    msg = paste("No DESCRIPTION file found at", path)
  )
  package <- desc(path)$get("Package")

  assert_that(is_workdir_clean(repo = path))

  # make DESCRIPTION tidy
  tidy_desc(path)
  git_add(files = "DESCRIPTION", force = TRUE, repo = path)

  if (!file_test("-f", file.path(path, ".gitignore"))) {
    file.copy(
      system.file(
        file.path("generic_template", "gitignore"), package = "checklist"
      ),
      file.path(path, ".gitignore")
    )
  } else {
    current <- readLines(file.path(path, ".gitignore"))
    new <- readLines(
      system.file(
        file.path("generic_template", "gitignore"), package = "checklist"
      )
    )
    writeLines(
      sort(unique(c(new, current))),
      file.path(path, ".gitignore")
    )
  }
  git_add(".gitignore", force = TRUE, repo = path)

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
  git_add(".Rbuildignore", force = TRUE, repo = path)

  # add checklist.yml
  writeLines(
    "description: Configuration file for checklist::check_pkg()
package: yes
allowed:
  warnings: []
  notes: []",
    file.path(path, "checklist.yml")
  )
  git_add("checklist.yml", force = TRUE, repo = path)

  # add codecov.yml
  file.copy(
    system.file(
      file.path("package_template", "codecov.yml"), package = "checklist"
    ),
    file.path(path, "codecov.yml")
  )
  git_add("codecov.yml", force = TRUE, repo = path)

  # add NEWS.md
  if (!file_test("-f", file.path(path, "NEWS.md"))) {
    news <- sprintf(
      "# %s 0.0.0\n\n* Added a `NEWS.md` file to track changes to the package.",
      package
    )
    writeLines(news, file.path(path, "NEWS.md"))
    git_add("NEWS.md", force = TRUE, repo = path)
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
    git_add("README.Rmd", force = TRUE, repo = path)
  }

  # add LICENSE.md
  if (length(list.files(path, "LICEN(S|C)E")) == 0) {
    file.copy(
      switch(
        license,
        "GPL-3" = system.file(
          file.path("generic_template", "gplv3.md"), package = "checklist"
        ),
        "MIT" = system.file(
          file.path("generic_template", "mit.md"), package = "checklist"
        )
      ),
      file.path(path, "LICENSE.md")
    )
    if (license == "MIT") {
      mit <- readLines(file.path(path, "LICENSE.md"))
      mit[3] <- gsub("<YEAR>", format(Sys.Date(), "%Y"), mit[3])
      mit[3] <- gsub("<COPYRIGHT HOLDERS>",
                     "Research Institute for Nature and Forest",
                     mit[3])
      writeLines(mit, file.path(path, "LICENSE.md"))
    }
    git_add("LICENSE.md", force = TRUE, repo = path)
  }

  # Add code of conduct
  dir.create(file.path(path, ".github"), showWarnings = FALSE)
  file.copy(
    system.file(
      file.path("generic_template", "CODE_OF_CONDUCT.md"), package = "checklist"
    ),
    file.path(path, ".github", "CODE_OF_CONDUCT.md")
  )
  git_add(file.path(".github", "CODE_OF_CONDUCT.md"), force = TRUE,
                repo = path)

  # Add contributing guidelines
  file.copy(
    system.file(
      file.path("package_template", "CONTRIBUTING.md"), package = "checklist"
    ),
    file.path(path, ".github", "CONTRIBUTING.md")
  )
  git_add(file.path(".github", "CONTRIBUTING.md"), force = TRUE,
                repo = path)

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
  git_add(file.path(".github", "workflows", "check_on_branch.yml"),
    force = TRUE, repo = path
  )
  unlink(file.path(path, ".github", "workflows", "check_on_master.yml"))
  file.copy(
    system.file(
      file.path("package_template", "check_on_main.yml"),
      package = "checklist"
    ),
    file.path(path, ".github", "workflows", "check_on_main.yml"),
    overwrite = TRUE
  )
  git_add(file.path(".github", "workflows", "check_on_main.yml"),
                force = TRUE, repo = path)
  file.copy(
    system.file(
      file.path("package_template", "check_on_different_r_os.yml"),
      package = "checklist"
    ),
    file.path(path, ".github", "workflows", "check_on_different_r_os.yml"),
    overwrite = TRUE
  )
  git_add(
    file.path(".github", "workflows", "check_on_different_r_os.yml"),
    force = TRUE, repo = path)
  file.copy(
    system.file(
      file.path("package_template", "release.yml"), package = "checklist"
    ),
    file.path(path, ".github", "workflows", "release.yml"),
    overwrite = TRUE
  )
  git_add(
    file.path(".github", "workflows", "release.yml"),
    force = TRUE, repo = path)

  # Add pkgdown website
  pkgd <- readLines(
    system.file(
      file.path("package_template", "_pkgdown.yml"), package = "checklist"
    )
  )
  pkgd <- gsub("\\{\\{\\{ Package \\}\\}\\}", package, pkgd)
  writeLines(pkgd, file.path(path, "_pkgdown.yml"))
  git_add("_pkgdown.yml", force = TRUE, repo = path)
  dir.create(file.path(path, "pkgdown"), showWarnings = FALSE)
  file.copy(
    system.file(
      file.path("package_template", "pkgdown.css"), package = "checklist"
    ),
    file.path(path, "pkgdown", "extra.css"), overwrite = TRUE
  )
  git_add(file.path("pkgdown", "extra.css"), force = TRUE, repo = path)
  dir.create(
    file.path(path, "man", "figures"), showWarnings = FALSE, recursive = TRUE
  )
  file.copy(
    system.file(
      file.path("package_template", "logo-en.png"), package = "checklist"
    ),
    file.path(path, "man", "figures", "logo-en.png"), overwrite = TRUE
  )
  git_add(file.path("man", "figures", "logo-en.png"), force = TRUE,
                repo = path)
  file.copy(
    system.file(
      file.path("package_template", "background-pattern.png"),
      package = "checklist"
    ),
    file.path(path, "man", "figures", "background-pattern.png"),
    overwrite = TRUE
  )
  git_add(file.path("man", "figures", "background-pattern.png"),
    force = TRUE, repo = path)
  file.copy(
    system.file(
      file.path("package_template", "flanders.woff2"), package = "checklist"
    ),
    file.path(path, "man", "figures", "flanders.woff2"), overwrite = TRUE
  )
  git_add(file.path("man", "figures", "flanders.woff2"),
                force = TRUE, repo = path)
  file.copy(
    system.file(
      file.path("package_template", "flanders.woff"), package = "checklist"
    ),
    file.path(path, "man", "figures", "flanders.woff"), overwrite = TRUE
  )
  git_add(file.path("man", "figures", "flanders.woff"),
                force = TRUE, repo = path)

  message("package prepared for checklist::check_package()")
  return(invisible(NULL))
}
