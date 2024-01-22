#' Set-up `checklist` on an existing R project
#'
#' Use this function to set-up or change the `checklist` infrastructure for an
#' existing project.
#' The function interactively asks questions to set-up the required checks.
#' @param path the project root folder
#' @export
#' @importFrom assertthat assert_that is.string
#' @importFrom fs dir_create file_copy is_dir path path_real path_rel
#' @family setup
setup_project <- function(path = ".") {
  assert_that(is.string(path), is_dir(path))
  path <- path_real(path)
  checklist_file <- path(path, "checklist.yml")

  if (is_file(checklist_file)) {
    x <- read_checklist(path)
  } else {
    x <- checklist$new(x = path, language = "en-GB", package = FALSE)
    x$allowed()
    x$set_ignore(c(".github", "LICENSE.md"))
  }

  dir_create(path, c("data", "media", "output", "source"))

  if (!file_exists(path(path, "source", "checklist.R"))) {
    path("project_template", "checklist.R") |>
      system.file(package = "checklist") |>
      file_copy(path(path, "source", "checklist.R"))
  }
  org <- read_organisation(path)
  repo <- setup_vc(path = path, org = org)
  renv_activate(path = path)
  files <- create_readme(path = path, org = org)
  checks <- c(
    "checklist",
    "folder conventions"[isTRUE(ask_yes_no("Check folder conventions?"))],
    "filename conventions"[isTRUE(ask_yes_no("Check file name conventions?"))],
    "lintr"[isTRUE(ask_yes_no("Check code style?"))],
    "license"[
      isTRUE(
        ask_yes_no(
          "Check the LICENSE file? The file will be created when missing."
        )
      )
    ],
    "spelling"[isTRUE(ask_yes_no("Check spelling?"))],
    "CITATION"[isTRUE(ask_yes_no("Check citation?"))]
  )

  answer <- menu_first(
    c("English", "Dutch", "French"), title = "Default language of the project?"
  )
  x$set_default(c("en-GB", "nl-BE", "fr-FR")[answer])

  if ("license" %in% checks && !file_exists(path(path, "LICENSE.md"))) {
    insert_file(
      repo = repo, filename = "cc_by_4_0.md", template = "generic_template",
      target = path, new_name = "LICENSE.md"
    )
  }

  x$set_required(checks = checks)
  write_checklist(x = x)

  if (is.null(repo)) {
    return(invisible(NULL))
  }
  dir_ls(path, regexp = "Rproj$") |>
    path_rel(path) |>
    c(
      "LICENSE.md"["license" %in% checks], files, "checklist.yml",
      path("source", "checklist.R"), "renv", "renv.lock"
    ) |>
    git_add(repo = repo)
  return(invisible(NULL))
}

#' @importFrom fs dir_create file_copy file_exists is_file path
#' @importFrom gert git_add git_find git_init git_remote_add
setup_vc <- function(path, org) {
  if (is_repository(path)) {
    assert_that(is_workdir_clean(path))
    repo <- git_find(path)
  } else {
    if (!isTRUE(ask_yes_no("Use version control?"))) {
      return(invisible(NULL))
    }
    repo <- git_init(path = path)
    preferred_protocol(org) |>
      sprintf(basename(path)) |>
      git_remote_add(repo = repo)
  }

  # add .gitignore
  template <- system.file(
    path("generic_template", "gitignore"), package = "checklist"
  )
  if (is_file(path(path, ".gitignore"))) {
    current <- readLines(path(path, ".gitignore"))
    new <- readLines(template)
    writeLines(
      c_sort(unique(c(new, current))),
      path(path, ".gitignore")
    )
  } else {
    file_copy(template, path(path, ".gitignore"))
  }
  git_add(".gitignore", force = TRUE, repo = repo)

  # Add GitHub actions
  target <- path(path, ".github", "workflows")
  dir_create(target)
  insert_file(
    repo = repo, filename = "check_project.yml", template = "project_template",
    target = target
  )
  path(".github", "workflows", "check_project.yml") |>
    git_add(force = TRUE, repo = repo)

  # Add code of conduct
  if (
    !file_exists(path(path, ".github", "CODE_OF_CONDUCT.md")) &&
    isTRUE(ask_yes_no("Add a default code of conduct?"))
  ) {
    target <- path(path, ".github")
    insert_file(
      repo = repo, filename = "CODE_OF_CONDUCT.md",
      template = "generic_template", target = target
    )
    path(".github", "CODE_OF_CONDUCT.md") |>
      git_add(force = TRUE, repo = repo)
  }

  # Add contributing guidelines
  if (
    !file_exists(path(path, ".github", "CONTRIBUTING.md")) &&
    isTRUE(ask_yes_no("Add default contributing guidelines?"))
  ) {
    insert_file(
      repo = repo, filename = "CONTRIBUTING.md", template = "package_template",
      target = target
    )
    path(".github", "CONTRIBUTING.md") |>
      git_add(force = TRUE, repo = repo)
  }

  return(invisible(repo))
}


#' Initialise a new R project
#'
#' This function creates a new RStudio project with `checklist` functionality.
#' @param path The folder in which to create the project as a folder.
#' @param project The name of the project.
#' @export
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom fs dir_create dir_exists file_copy is_dir path
#' @family setup
create_project <- function(path, project) {
  assert_that(is.string(path), noNA(path), is_dir(path))
  assert_that(is.string(project), noNA(project))
  assert_that(!dir_exists(path(path, project)), msg = "Existing project folder")
  dir_create(path(path, project))

  # create RStudio project
  file_copy(
    system.file(
      path("project_template", "rproj.template"), package = "checklist"
    ),
    path(path, project, project, ext = "Rproj")
  )

  setup_project(path(path, project))

  if (
    !interactive() || !requireNamespace("rstudioapi", quietly = TRUE) ||
      !rstudioapi::isAvailable()
  ) {
    return(invisible(NULL))
  }
  path(path, project) |>
    rstudioapi::openProject(newSession = TRUE)
}

#' @importFrom fs file_exists path
create_readme <- function(path, org) {
  if (file_exists(path(path, "README.md"))) {
    return(character(0))
  }
  cat("Which person to use as author and contact person?\n")
  author <- author2badge(role = c("aut", "cre"), org = org)
  while (isTRUE(ask_yes_no("add another author?", default = FALSE))) {
    extra <- author2badge(org = org)
    attr(author, "footnote") |>
      c(attr(extra, "footnote")) |>
      unique() -> footnote
    c(author, extra) |>
      `attr<-`(which = "footnote", value = footnote) -> author
  }
  title <- readline(prompt = "Enter the title of the project?")
  readline(prompt = "Enter one or more keywords separated by `;`") |>
    strsplit(";") |>
    unlist() |>
    gsub(pattern = "^\\s+", replacement = "") |>
    gsub(pattern = "\\s+$", replacement = "") |>
    paste(collapse = "; ") |>
    sprintf(fmt = "**keywords**: %s") -> keywords
  c("[^cph]: copyright holder", "[^fnd]: funder", attr(author, "footnote")) |>
    unique() -> footnote
  if (!is_repository(path)) {
    badges <- character(0)
  } else {
    remotes <- git_remote_list(repo = path)
    remotes$url[remotes$name == "origin"] |>
      gsub(pattern = "git@(.*?):(.*)", replacement = "https://\\1/\\2") |>
      gsub(pattern = "https://.*?@", replacement = "https://") |>
      gsub(pattern = "\\.git$", replacement = "") -> repo_url
    if (length(repo_url) > 0 && !grepl("github.com", repo_url)) {
      badges <- character(0)
    } else {
      gsub("https://github.com/", "", repo_url) |>
        sprintf(
          fmt = paste0(
            "![GitHub](https://img.shields.io/github/license/%1$s)\n",
            "![GitHub Workflow Status](https://img.shields.io/github/actions/",
            "workflow/status/%1$s/check-project)\n",
            "![GitHub repo size](https://img.shields.io/github/repo-size/%1$s)"
          )
        ) -> badges
    }
  }
  c(
    "<!-- badges: start -->", badges, "<!-- badges: end -->", "",
    paste("#", title), "", author,
    paste0(org$get_rightsholder, "[^cph][^fnd]"), "", footnote,
    "", keywords, "",
    sprintf(
      "<!-- community: %s -->", paste(org$get_community, collapse = "; ")
    ),
    "", "<!-- description: start -->",
    "Replace this with a short description of the project.",
    "It becomes the abstract of the project in the citation information.",
    "And the project description at https://zenodo.org",
    "<!-- description: end -->", "",
    "Anything below here is visible in the README but not in the citation."
  ) |>
    writeLines(path(path, "README.md"))
  return("README.md")
}

#' @importFrom assertthat assert_that
#' @importFrom fs dir_create path
#' @importFrom tools R_user_dir
#' @importFrom utils menu
#' @importFrom yaml read_yaml write_yaml
preferred_protocol <- function(org) {
  assert_that(inherits(org, "organisation"))
  config <- list()
  R_user_dir("checklist", which = "config") |>
    path("config.yml") -> config_file
  if (file_exists(config_file)) {
    config <- read_yaml(config_file)
  }
  if (
    !has_name(config, "git") || !has_name(config$git, "protocol")
  ) {
    c("https (easy)", "ssh (more secure)") |>
      menu_first(title = "Which protocol do you prefer?") -> protocol
    config[["git"]][["protocol"]] <- c("https", "ssh")[protocol]
    dirname(config_file) |>
      dir_create()
    write_yaml(x = config, file = config_file, fileEncoding = "UTF-8")
  }
  sprintf("Which GitHub organisation. Leave empty for `%s`.", org$get_github) |>
    readline() -> config[["git"]][["organisation"]]
  ifelse(
    config$git$protocol == "https", "https://github.com/%s/%%s.git",
    "git@github.com:%s/%%s.git"
  ) |>
    sprintf(config$git$organisation)
}

#' Function to ask a simple yes no question
#' @inheritParams utils::askYesNo
#' @importFrom utils askYesNo
#' @export
#' @family utils
ask_yes_no <- function(
  msg, default = TRUE,
  prompts = getOption("askYesNo", gettext(c("Yes", "No", "Cancel"))), ...
) {
  if (!interactive()) {
    return(default)
  }
  askYesNo(msg = msg, default = default, prompts = prompts, ...)
}

#' @importFrom fs file_exists path
renv_activate <- function(path) {
  if (file_exists(path(path, "renv.lock"))) {
    return(invisible(NULL))
  }
  if (
    isFALSE(
      ask_yes_no(
        "Use `renv` to lock package versions with the project?", default = FALSE
      )
    )
  ) {
    return(invisible(NULL))
  }
  # nocov start
  sprintf("Rscript -e 'renv::init(\"%s\", restart = FALSE)'", path) |>
    execshell()
  # nocov end
}
