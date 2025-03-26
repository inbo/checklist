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
setup_package <- function(path = ".", license = c("GPL-3", "MIT")) {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  license <- match.arg(license)
  assert_that(
    is_file(path(path, "DESCRIPTION")),
    msg = paste("No DESCRIPTION file found at", path)
  )
  descript <- desc(path)
  package <- descript$get("Package")
  version <- descript$get_version()

  assert_that(is_workdir_clean(repo = path))

  # add checklist.yml
  if (!file_exists(path(path, "checklist.yml"))) {
    if (descript$has_fields("Language")) {
      x <- checklist$new(
        x = path, language = descript$get_field("Language"), package = TRUE
      )
    } else {
      x <- checklist$new(x = path, language = "en-GB", package = TRUE)
      descript$set("Language", "en-GB")
      path(x$get_path, "DESCRIPTION") |>
        descript$write()
    }
    x$set_required()
    x$set_ignore(c(".github", "LICENSE.md"))
    write_checklist(x)
    git_add("checklist.yml", force = TRUE, repo = path)
  }

  # make DESCRIPTION tidy
  suppressMessages(tidy_desc(path))
  git_add(files = "DESCRIPTION", force = TRUE, repo = path)

  if (is_file(path(path, ".gitignore"))) {
    path(path, ".gitignore") |>
      readLines() -> current
    path("generic_template", "gitignore") |>
      system.file(package = "checklist") |>
      readLines() -> new
    c(new, current) |>
      unique() |>
      c_sort() |>
      writeLines(path(path, ".gitignore"))
    git_add(".gitignore", force = TRUE, repo = path)
  } else {
    insert_file(
      repo = path, filename = "gitignore", template = "generic_template",
      target = path, new_name = ".gitignore"
    )
  }

  if (is_file(path(path, ".Rbuildignore"))) {
    path(path, ".Rbuildignore") |>
      readLines() -> current
    path("package_template", "rbuildignore") |>
      system.file(package = "checklist") |>
      readLines() -> new
    c(new, current) |>
      unique() |>
      c_sort() |>
      writeLines(path(path, ".Rbuildignore"))
    git_add(".Rbuildignore", force = TRUE, repo = path)
  } else {
    insert_file(
      repo = path, filename = "rbuildignore", template = "package_template",
      target = path, new_name = ".Rbuildignore"
    )
  }

  # add codecov.yml
  insert_file(
    repo = path, filename = "codecov.yml", template = "package_template",
    target = path
  )

  # add NEWS.md
  if (!is_file(path(path, "NEWS.md"))) {
    sprintf(
      paste(
        "# %s %s", "",
        "* Added a `NEWS.md` file to track changes to the package.",
        paste(
          "* Add [`checklist`](https://inbo.github.io/checklist/)",
          "infrastructure."
        ),
        sep = "\n"
      ),
      package, as.character(version)
    ) |>
      writeLines(path(path, "NEWS.md"))
    git_add("NEWS.md", force = TRUE, repo = path)
  }

  # add README.Rmd
  if (!is_file(path(path, "README.md"))) {
    license_batch <- switch(
      license,
      "GPL-3" =
        "https://img.shields.io/badge/license-GPL--3-blue.svg?style=flat",
      "MIT" = "https://img.shields.io/badge/license-MIT-blue.svg?style=flat"
    )
    license_site <- switch(
      license,
      "GPL-3" = "https://www.gnu.org/licenses/gpl-3.0.html",
      "MIT" = "https://opensource.org/licenses/MIT"
    )
    path("package_template", "README.Rmd") |>
      system.file(package = "checklist") |>
      readLines() |>
      gsub(pattern = "\\{\\{\\{ Package \\}\\}\\}", replacement = package) |>
      gsub(
        pattern = "\\{\\{\\{ license batch \\}\\}\\}",
        replacement = license_batch
      ) |>
      gsub(
        pattern = "\\{\\{\\{ license site \\}\\}\\}", replacement = license_site
      ) |>
      writeLines(path(path, "README.Rmd"))
    git_add("README.Rmd", force = TRUE, repo = path)
  }

  # add LICENSE.md
  if (length(dir_ls(path, regexp = "LICEN(S|C)E")) == 0) {
    switch(license, "GPL-3" = "gplv3.md", "MIT" = "mit.md") |>
      insert_file(
        repo = path, template = "generic_template", target = path,
        new_name = "LICENSE.md"
      )
    if (license == "MIT") {
      writeLines(
        c(paste0("YEAR: ", format(Sys.Date(), "%Y")),
          "COPYRIGHT HOLDER: Research Institute for Nature and Forest (INBO)"
        ),
        path(path, "LICENSE")
      )
      git_add("LICENSE", force = TRUE, repo = path)
      mit <- readLines(path(path, "LICENSE.md"))
      mit[3] <- gsub("<YEAR>", format(Sys.Date(), "%Y"), mit[3])
      mit[3] <- gsub("<COPYRIGHT HOLDERS>",
                     "Research Institute for Nature and Forest (INBO)",
                     mit[3])
      writeLines(mit, path(path, "LICENSE.md"))
    }
    git_add("LICENSE.md", force = TRUE, repo = path)
  }

  # Add code of conduct
  target <- path(path, ".github")
  dir_create(target)
  insert_file(
    repo = path, filename = "CODE_OF_CONDUCT.md", template = "generic_template",
    target = target
  )

  # Add contributing guidelines
  insert_file(
    repo = path, filename = "CONTRIBUTING.md", template = "package_template",
    target = target
  )

  # Add GitHub actions
  target <- path(path, ".github", "workflows")
  dir_create(target)
  insert_file(
    repo = path, filename = "check_on_branch.yml",
    template = "package_template", target = target
  )
  insert_file(
    repo = path, filename = "check_on_main.yml",
    template = "package_template", target = target
  )
  insert_file(
    repo = path, filename = "check_on_different_r_os.yml",
    template = "package_template", target = target
  )
  insert_file(
    repo = path, filename = "release.yml", template = "package_template",
    target = target
  )

  # Add pkgdown website
  path("package_template", "_pkgdown.yml") |>
    system.file(package = "checklist") |>
    readLines() -> pkgd
  pkgd <- gsub("\\{\\{\\{ Package \\}\\}\\}", package, pkgd)
  writeLines(pkgd, path(path, "_pkgdown.yml"))
  git_add("_pkgdown.yml", force = TRUE, repo = path)
  target <- path(path, "pkgdown")
  dir_create(target)
  insert_file(
    repo = path, filename = "pkgdown.css", template = "package_template",
    target = target, new_name = "extra.css"
  )
  target <- path(path, "man", "figures")
  dir_create(target)
  insert_file(
    repo = path, filename = "logo-en.png", template = "package_template",
    target = target
  )
  insert_file(
    repo = path, filename = "background-pattern.png",
    template = "package_template", target = target
  )
  insert_file(
    repo = path, filename = "flanders.woff2", template = "package_template",
    target = target
  )
  insert_file(
    repo = path, filename = "flanders.woff", template = "package_template",
    target = target
  )

  message("package prepared for checklist::check_package()")
  return(invisible(NULL))
}
