#' @importFrom citeme ask_yes_no
#' @importFrom gert git_add git_find git_init git_remote_add
setup_vc <- function(path, url, use_vc, use_cc, use_cg) {
  if (!is_repository(path)) {
    if (missing(use_vc)) {
      use_vc <- ask_yes_no("Use version control?")
    }
    if (!use_vc) {
      return(path)
    }
    git_init(path = path)
    git_remote_add(url = url, repo = path)
    list.files(path, recursive = TRUE) |>
      c(".Rprofile") |>
      git_add(force = TRUE, repo = path)
  } else {
    use_vc <- TRUE
  }

  # add .gitignore
  template <- system.file(
    path_("generic_template", "gitignore"),
    package = "checklist"
  )
  if (file_test("-f", path_(path, ".gitignore"))) {
    current <- readLines(path_(path, ".gitignore"))
    new <- readLines(template)
    writeLines(c_sort(unique(c(new, current))), path_(path, ".gitignore"))
  } else {
    file.copy(template, path_(path, ".gitignore"))
  }
  git_add(".gitignore", force = TRUE, repo = path)

  # Add GitHub actions
  path_(path, ".github", "workflows") |>
    dir.create(recursive = TRUE, showWarnings = FALSE)
  insert_file(
    repo = path,
    filename = "check_project.yml",
    template = "project_template",
    target = path_(".github", "workflows")
  )

  add_code_conduct(path, use_cc = use_cc)
  add_contributing_guidelines(path, use_cg = use_cg)
  return(path)
}

add_code_conduct <- function(path, use_cc) {
  if (!is_repository(path)) {
    return(path)
  }
  if (missing(use_cc)) {
    use_cc <- ask_yes_no("Add default code of conduct?")
  }
  if (!use_cc) {
    return(path)
  }
  insert_file(
    repo = path,
    filename = "CODE_OF_CONDUCT.md",
    template = "generic_template",
    target = ".github"
  )
  return(path)
}

add_contributing_guidelines <- function(path, use_cg) {
  if (!is_repository(path)) {
    return(path)
  }
  if (missing(use_cg)) {
    use_cg <- ask_yes_no("Add default contributing guidelines?")
  }
  if (!use_cg) {
    return(path)
  }
  insert_file(
    repo = path,
    filename = "CONTRIBUTING.md",
    template = "generic_template",
    target = ".github"
  )
  return(path)
}
