#' @importFrom fs dir_create file_copy file_exists is_file path
#' @importFrom gert git_add git_find git_init git_remote_add
setup_vc <- function(
  path,
  url,
  use_vc,
  use_cc = use_vc && ask_yes_no("Add a default code of conduct?"),
  use_cg = use_vc && ask_yes_no("Add default contributing guidelines?")
) {
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
  }

  # add .gitignore
  template <- system.file(
    path("generic_template", "gitignore"),
    package = "checklist"
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
  git_add(".gitignore", force = TRUE, repo = path)

  # Add GitHub actions
  target <- path(path, ".github", "workflows")
  dir_create(target)
  insert_file(
    repo = path,
    filename = "check_project.yml",
    template = "project_template",
    target = target
  )

  # Add code of conduct
  if (missing(use_cc)) {
    use_cc <- ask_yes_no("Add a default code of conduct?")
  }
  if (use_cc && !file_exists(path(path, ".github", "CODE_OF_CONDUCT.md"))) {
    target <- path(path, ".github")
    insert_file(
      repo = path,
      filename = "CODE_OF_CONDUCT.md",
      template = "generic_template",
      target = target
    )
  }

  # Add contributing guidelines
  if (missing(use_cg)) {
    use_cg <- ask_yes_no("Add default contributing guidelines?")
  }
  if (use_cg && !file_exists(path(path, ".github", "CONTRIBUTING.md"))) {
    insert_file(
      repo = path,
      filename = "CONTRIBUTING.md",
      template = "package_template",
      target = target
    )
  }
  return(path)
}
