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
#' @importFrom citeme ask_language individual2badge individual2df org_list
#' @importFrom desc desc
#' @importFrom gert git_add
#' @importFrom utils file_test
#' @family setup
setup_package <- function(path = ".") {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  assert_that(
    file_test("-f", path_(path, "DESCRIPTION")),
    msg = paste("No DESCRIPTION file found at", path)
  )
  descript <- desc(path)
  package <- descript$get("Package")
  version <- descript$get_version()
  license <- descript$get("License")

  assert_that(is_workdir_clean(repo = path))

  # add checklist.yml
  if (!file_test("-f", path_(path, "checklist.yml"))) {
    if (descript$has_fields("Language")) {
      x <- checklist$new(
        x = path,
        language = descript$get_field("Language"),
        package = TRUE
      )
    } else {
      language <- ask_language(
        org = org_list$new()$read(path),
        prompt = "Which is the main language of the package?"
      )
      x <- checklist$new(x = path, language = language, package = TRUE)
      descript$set("Language", language)
      path_(x$get_path, "DESCRIPTION") |> descript$write()
    }
    x$set_required()
    x$set_ignore(c(".github", "LICENSE.md"))
    write_checklist(x)
    git_add("checklist.yml", force = TRUE, repo = path)
  } else {
    x <- read_checklist(x = path)
  }

  # make DESCRIPTION tidy
  suppressMessages(tidy_desc(path))
  git_add(files = "DESCRIPTION", force = TRUE, repo = path)

  if (file_test("-f", path_(path, ".gitignore"))) {
    path_(path, ".gitignore") |> readLines() -> current
    path_("generic_template", "gitignore") |>
      system.file(package = "checklist") |>
      readLines() -> new
    c(new, current) |>
      unique() |>
      c_sort() |>
      writeLines(path_(path, ".gitignore"))
    git_add(".gitignore", force = TRUE, repo = path)
  } else {
    insert_file(
      repo = path,
      filename = "gitignore",
      template = "generic_template",
      new_name = ".gitignore"
    )
  }

  if (file_test("-f", path_(path, ".Rbuildignore"))) {
    path_(path, ".Rbuildignore") |> readLines() -> current
    path_("package_template", "rbuildignore") |>
      system.file(package = "checklist") |>
      readLines() -> new
    c(new, current) |>
      unique() |>
      c_sort() |>
      writeLines(path_(path, ".Rbuildignore"))
    git_add(".Rbuildignore", force = TRUE, repo = path)
  } else {
    insert_file(
      repo = path,
      filename = "rbuildignore",
      template = "package_template",
      new_name = ".Rbuildignore"
    )
  }

  # add codecov.yml
  insert_file(
    repo = path,
    filename = "codecov.yml",
    template = "package_template"
  )

  # add NEWS.md
  if (!file_test("-f", path_(path, "NEWS.md"))) {
    sprintf(
      paste(
        "# %s %s",
        "",
        "* Added a `NEWS.md` file to track changes to the package.",
        paste(
          "* Add [`checklist`](https://inbo.github.io/checklist/)",
          "infrastructure."
        ),
        sep = "\n"
      ),
      package,
      as.character(version)
    ) |>
      writeLines(path_(path, "NEWS.md"))
    git_add("NEWS.md", force = TRUE, repo = path)
  }

  # add README.Rmd
  org <- org_list$new()$read(path)
  create_readme(
    path = path,
    org = org,
    authors = descript$get_authors() |> individual2df() |> individual2badge(),
    title = sprintf("%s: %s", package, descript$get_field("Title")),
    description = descript$get_field("Description"),
    keywords = descript$get_field("Config/citeme/keywords"),
    license = license,
    lang = x$default,
    type = "package"
  )
  git_add("README.Rmd", force = TRUE, repo = path)

  # add LICENSE.md
  set_license(path, org = org, license = descript$get_field("License"))
  git_add("LICENSE.md", force = TRUE, repo = path)

  # Add code of conduct
  path_(path, ".github") |>
    dir.create(recursive = TRUE, showWarnings = FALSE)
  insert_file(
    repo = path,
    filename = "CODE_OF_CONDUCT.md",
    template = "generic_template",
    target = ".github"
  )

  # Add contributing guidelines
  insert_file(
    repo = path,
    filename = "CONTRIBUTING.md",
    template = "generic_template",
    target = ".github"
  )

  # Add GitHub actions
  path_(path, ".github", "workflows") |>
    dir.create(recursive = TRUE, showWarnings = FALSE)
  insert_file(
    repo = path,
    filename = "check_on_branch.yml",
    template = "package_template",
    target = path_(".github", "workflows")
  )
  insert_file(
    repo = path,
    filename = "check_on_main.yml",
    template = "package_template",
    target = path_(".github", "workflows")
  )
  insert_file(
    repo = path,
    filename = "check_on_different_r_os.yml",
    template = "package_template",
    target = path_(".github", "workflows")
  )
  insert_file(
    repo = path,
    filename = "release.yml",
    template = "package_template",
    target = path_(".github", "workflows")
  )

  # Add agents
  add_agents(x)
  add_issue_templates(x)

  # Add pkgdown website
  setup_pkgdown(x = path, org = org, lang = x$default)

  message("package prepared for checklist::check_package()")
  return(invisible(NULL))
}
