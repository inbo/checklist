#' Set a New Tag
#'
#' This function is a part of the GitHub Action.
#' Therefore it only works when run in a GitHub Action on the master branch.
#' Otherwise it will only return a message.
#' It sets a new tag at the current commit using the related entry from
#' `NEWS.md` as message.
#' This tag will turn into a release.
#'
#' @inheritParams read_checklist
#' @export
#' @importFrom assertthat assert_that
#' @importFrom git2r config is_detached push repository tag tags
#' @family package
set_tag <- function(x = ".") {
  if (
    !as.logical(Sys.getenv("GITHUB_ACTIONS", "false")) ||
      Sys.getenv("GITHUB_REF") != "refs/heads/master" || # nolint
      Sys.getenv("GITHUB_EVENT_NAME") != "push"
  ) {
    message("Not on GitHub, not a push or not on master.")
    return(invisible(NULL))
  }
  x <- read_checklist(x = x)
  assert_that(
    x$package,
    msg = "`set_tag()` is only relevant for packages.
`checklist.yml` indicates this is not a package."
  )
  repo <- repository(x$get_path)
  assert_that(
    !is_detached(repo),
    msg = "`set_tag()` doesn't work on a repository with detached HEAD."
  )
  description <- description$new(
    file = file.path(x$get_path, "DESCRIPTION")
  )
  version <- as.character(description$get_version())
  news <- readLines(file.path(x$get_path, "NEWS.md"))
  regex <- paste("#", description$get("Package"), "[0-9]+\\.[0-9]+(\\.[0-9]+)") # nolint
  start <- grep(regex, news)
  end <- c(tail(start, -1) - 1, length(news))
  current <- grepl(paste("#", description$get("Package"), version), news[start])
  assert_that(any(current), msg = "Current version not found in NEWS.md")
  if (paste0("v", version) %in% names(tags(repo))) {
    message("tag v", version, " already exists.")
    return(invisible(NULL))
  }
  old_config <- config(repo)
  on.exit(
    config(
      repo,
      user.name = old_config$local$user.name,
      user.email = old_config$local$user.email
    ),
    add = TRUE
  )
  config(
    repo = repo,
    user.name = "Checklist bot",
    user.email = "checklist@inbo.be"
  )
  tag_message <- paste(news[seq(start[current], end[current])], collapse = "\n")
  tag(repo, name = paste0("v", version), message = tag_message)
  push(
    repo, refspec = paste0(file.path("refs", "tags", "v", fsep = "/"), version)
  )
  return(invisible(NULL))
}
