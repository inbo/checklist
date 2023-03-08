#' Set a New Tag
#'
#' This function is a part of the GitHub Action.
#' Therefore it only works when run in a GitHub Action on the main or master
#' branch.
#' Otherwise it will only return a message.
#' It sets a new tag at the current commit using the related entry from
#' `NEWS.md` as message.
#' This tag will turn into a release.
#'
#' @inheritParams read_checklist
#' @export
#' @importFrom assertthat assert_that
#' @importFrom fs path
#' @importFrom gert git_config git_config_set git_info git_tag_create
#' git_tag_list
#' @family package
set_tag <- function(x = ".") {
  if (
    !as.logical(Sys.getenv("GITHUB_ACTIONS", "false")) ||
    !Sys.getenv("GITHUB_REF") %in% c("refs/heads/main", "refs/heads/master") ||
      Sys.getenv("GITHUB_EVENT_NAME") != "push"
  ) {
    message("Not on GitHub, not a push or not on main or master.")
    return(invisible(NULL))
  }
  x <- read_checklist(x = x)
  assert_that(
    x$package,
    msg = "`set_tag()` is only relevant for packages.
`checklist.yml` indicates this is not a package."
  )
  repo <- x$get_path
  assert_that(
    git_info(repo = repo)$shorthand != "HEAD",
    msg = "`set_tag()` doesn't work on a repository with detached HEAD."
  )
  description <- description$new(
    file = path(x$get_path, "DESCRIPTION")
  )
  version <- as.character(description$get_version())
  path(x$get_path, "NEWS.md") |>
    readLines() -> news
  regex <- sprintf(
    "^# %s [0-9]+\\.[0-9]+(\\.[0-9]+){0,1}$",
    description$get("Package")
  )
  start <- grep(regex, news)
  end <- c(tail(start, -1) - 1, length(news))
  current <- grepl(paste("#", description$get("Package"), version), news[start])
  assert_that(any(current), msg = "Current version not found in NEWS.md")
  if (paste0("v", version) %in% git_tag_list(repo = repo)$name) {
    message("tag v", version, " already exists.")
    return(invisible(NULL))
  }
  old_config <- git_config(repo = repo)
  on.exit(
    git_config_set(
      "user.name",
      old_config$value[old_config$name == "user.name"],
      repo = repo),
    add = TRUE
  )
  on.exit(
    git_config_set(
      "user.email",
      old_config$value[old_config$name == "user.email"],
      repo = repo),
    add = TRUE
  )
  git_config_set(
    "user.name", "Checklist bot",
    repo = repo
  )
  git_config_set(
    "user.email", "checklist@inbo.be",
    repo = repo
  )

  tag_message <- paste(news[seq(start[current], end[current])], collapse = "\n")
  git_tag_create(
    name = paste0("v", version),
    message = tag_message,
    repo = repo)
  return(invisible(NULL))
}
