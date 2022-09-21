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
#' @importFrom fs dir_create dir_ls file_copy is_file path
#' @importFrom gert git_add
#' @importFrom utils file_test
#' @family setup
setup_package <- function(path = ".",
                          license = c("GPL-3", "MIT")) {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  license <- match.arg(license)
  assert_that(
    file_test("-f", path(path, "DESCRIPTION")),
    msg = paste("No DESCRIPTION file found at", path)
  )
  package <- desc(path)$get("Package")

  assert_that(is_workdir_clean(repo = path))

  # make DESCRIPTION tidy
  tidy_desc(path)
  git_add(files = "DESCRIPTION", force = TRUE, repo = path)

  if (is_file(path(path, ".gitignore"))) {
    current <- readLines(path(path, ".gitignore"))
    new <- readLines(
      system.file(path("generic_template", "gitignore"), package = "checklist")
    )
    writeLines(c_sort(unique(c(new, current))), path(path, ".gitignore"))
  } else {
    file_copy(
      system.file(path("generic_template", "gitignore"), package = "checklist"),
      path(path, ".gitignore")
    )
  }
  git_add(".gitignore", force = TRUE, repo = path)

  if (is_file(path(path, ".Rbuildignore"))) {
    current <- readLines(path(path, ".Rbuildignore"))
    new <- readLines(
      system.file(
        path("package_template", "rbuildignore"), package = "checklist"
      )
    )
    writeLines(c_sort(unique(c(new, current))), path(path, ".Rbuildignore"))
  } else {
    file_copy(
      system.file(
        path("package_template", "rbuildignore"), package = "checklist"
      ),
      path(path, ".Rbuildignore")
    )
  }
  git_add(".Rbuildignore", force = TRUE, repo = path)

  # add checklist.yml
  suppressMessages({
    x <- read_checklist(x = path)
  })
  x$package <- TRUE
  x$set_required()
  x$set_ignore(c(".github", "LICENSE.md"))
  write_checklist(x)
  git_add("checklist.yml", force = TRUE, repo = path)

  # add codecov.yml
  file_copy(
    system.file(path("package_template", "codecov.yml"), package = "checklist"),
    path(path, "codecov.yml")
  )
  git_add("codecov.yml", force = TRUE, repo = path)

  # add NEWS.md
  if (!is_file(path(path, "NEWS.md"))) {
    news <- sprintf(
      "# %s 0.0.0\n\n* Added a `NEWS.md` file to track changes to the package.",
      package
    )
    writeLines(news, path(path, "NEWS.md"))
    git_add("NEWS.md", force = TRUE, repo = path)
  }

  # add README.Rmd
  if (!is_file(path(path, "README.md"))) {
    readme <- readLines(
      system.file(path("package_template", "README.Rmd"), package = "checklist")
    )
    readme <- gsub("\\{\\{\\{ Package \\}\\}\\}", package, readme)
    license_batch <- switch(
      license,
      "GPL-3" =
        "https://img.shields.io/badge/license-GPL--3-blue.svg?style=flat",
      "MIT" = "https://img.shields.io/badge/license-MIT-blue.svg?style=flat")
    license_site <- switch(
      license,
      "GPL-3" = "https://www.gnu.org/licenses/gpl-3.0.html",
      "MIT" = "https://opensource.org/licenses/MIT"
    )
    readme <- gsub("\\{\\{\\{ license batch \\}\\}\\}", license_batch, readme)
    readme <- gsub("\\{\\{\\{ license site \\}\\}\\}", license_site, readme)
    writeLines(readme, path(path, "README.Rmd"))
    git_add("README.Rmd", force = TRUE, repo = path)
  }

  # add LICENSE.md
  if (length(dir_ls(path, regexp = "LICEN(S|C)E")) == 0) {
    file.copy(
      switch(
        license,
        "GPL-3" = system.file(
          path("generic_template", "gplv3.md"), package = "checklist"),
        "MIT" = system.file(
          path("generic_template", "mit.md"), package = "checklist"
        )
      ),
      path(path, "LICENSE.md")
    )
    if (license == "MIT") {
      writeLines(
        c(paste0("YEAR: ", format(Sys.Date(), "%Y")),
          "COPYRIGHT HOLDER: Research Institute for Nature and Forest"
        ),
        path(path, "LICENSE")
      )
      git_add("LICENSE", force = TRUE, repo = path)
      mit <- readLines(path(path, "LICENSE.md"))
      mit[3] <- gsub("<YEAR>", format(Sys.Date(), "%Y"), mit[3])
      mit[3] <- gsub("<COPYRIGHT HOLDERS>",
                     "Research Institute for Nature and Forest",
                     mit[3])
      writeLines(mit, path(path, "LICENSE.md"))
    }
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

  # Add contributing guidelines
  file_copy(
    system.file(
      path("package_template", "CONTRIBUTING.md"), package = "checklist"
    ),
    path(path, ".github", "CONTRIBUTING.md")
  )
  git_add(path(".github", "CONTRIBUTING.md"), force = TRUE, repo = path)

  # Add GitHub actions
  dir_create(path(path, ".github", "workflows"))
  file_copy(
    system.file(
      path("package_template", "check_on_branch.yml"), package = "checklist"
    ),
    path(path, ".github", "workflows", "check_on_branch.yml"), overwrite = TRUE
  )
  git_add(
    path(".github", "workflows", "check_on_branch.yml"), force = TRUE,
    repo = path
  )
  unlink(path(path, ".github", "workflows", "check_on_master.yml"))
  file_copy(
    system.file(
      path("package_template", "check_on_main.yml"), package = "checklist"
    ),
    path(path, ".github", "workflows", "check_on_main.yml"), overwrite = TRUE
  )
  git_add(
    path(".github", "workflows", "check_on_main.yml"), force = TRUE, repo = path
  )
  file_copy(
    system.file(
      path("package_template", "check_on_different_r_os.yml"),
      package = "checklist"
    ),
    path(path, ".github", "workflows", "check_on_different_r_os.yml"),
    overwrite = TRUE
  )
  git_add(
    path(".github", "workflows", "check_on_different_r_os.yml"),
    force = TRUE, repo = path
  )
  file_copy(
    system.file(path("package_template", "release.yml"), package = "checklist"),
    path(path, ".github", "workflows", "release.yml"), overwrite = TRUE
  )
  git_add(
    path(".github", "workflows", "release.yml"), force = TRUE, repo = path
  )

  # Add pkgdown website
  pkgd <- readLines(
    system.file(path("package_template", "_pkgdown.yml"), package = "checklist")
  )
  pkgd <- gsub("\\{\\{\\{ Package \\}\\}\\}", package, pkgd)
  writeLines(pkgd, path(path, "_pkgdown.yml"))
  git_add("_pkgdown.yml", force = TRUE, repo = path)
  dir_create(path(path, "pkgdown"))
  file_copy(
    system.file(path("package_template", "pkgdown.css"), package = "checklist"),
    path(path, "pkgdown", "extra.css"), overwrite = TRUE
  )
  git_add(path("pkgdown", "extra.css"), force = TRUE, repo = path)
  dir_create(path(path, "man", "figures"))
  file_copy(
    system.file(path("package_template", "logo-en.png"), package = "checklist"),
    path(path, "man", "figures", "logo-en.png"), overwrite = TRUE
  )
  git_add(path("man", "figures", "logo-en.png"), force = TRUE, repo = path)
  file_copy(
    system.file(
      path("package_template", "background-pattern.png"), package = "checklist"
    ),
    path(path, "man", "figures", "background-pattern.png"), overwrite = TRUE
  )
  git_add(
    path("man", "figures", "background-pattern.png"), force = TRUE, repo = path
  )
  file_copy(
    system.file(
      path("package_template", "flanders.woff2"), package = "checklist"
    ),
    path(path, "man", "figures", "flanders.woff2"), overwrite = TRUE
  )
  git_add(path("man", "figures", "flanders.woff2"), force = TRUE, repo = path)
  file_copy(
    system.file(
      path("package_template", "flanders.woff"), package = "checklist"
    ),
    path(path, "man", "figures", "flanders.woff"), overwrite = TRUE
  )
  git_add(path("man", "figures", "flanders.woff"), force = TRUE, repo = path)

  message("package prepared for checklist::check_package()")
  return(invisible(NULL))
}
