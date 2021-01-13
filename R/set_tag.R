#' Set a New Tag and Create a Release
#'
#' This function only works when run in a GitHub Action on the master branch.
#' Otherwise it will only return a message.
#' @export
#' @inheritParams read_checklist
#' @param token The GitHub access token
#' @importFrom assertthat assert_that
#' @importFrom git2r config is_detached repository tag tags
#' @family package
set_tag <- function(x = ".", token) {
  if (
    !as.logical(Sys.getenv("GITHUB_ACTIONS", "false")) ||
      Sys.getenv("GITHUB_REF") != "refs/heads/master" ||
      Sys.getenv("GITHUB_EVENT_NAME") != "push"
  ) {
    message("Not on GitHub, not a push or not on master.")
    return(invisible(NULL))
  }
  if (!inherits(x, "Checklist") || !"checklist" %in% x$get_checked) {
    x <- read_checklist(x = x)
  }
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
  regex <- paste("#", description$get("Package"), "[0-9]+\\.[0-9]+(\\.[0-9]+)")
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
  cmd <- sprintf(
    "cd %s; git push origin; git push origin v%s", repo$path, version
  )
  system(cmd)

  create_release(
    repo = repo, version = version, tag_message = tag_message, token = token
  )
  return(invisible(NULL))
}

#' @importFrom httr add_headers POST
#' @importFrom git2r remote_url
create_release <- function(repo, version, tag_message, token) {
  url <- remote_url(repo, "origin")
  if (!grepl("github.com", url)) {
    warning("no `origin` or `origin` not on GitHub.")
    return(invisible(NULL))
  }
  owner <- tolower(gsub(".*github.com:(.*?)/(.*?)\\.git", "\\1", url))
  repo <- gsub(".*github.com:(.*?)/(.*?)\\.git", "\\2", url)
  url <- sprintf("https://api.github.com/repos/%s/%s/releases", owner, repo)
  body <- c(
    tag_name = paste0("\"v", version, "\""),
    name = paste("\"Version", version, "\""),
    body = paste0("\"", tag_message, "\""),
    draft = "false",
    prerelease = "false"
  )
  body <- sprintf(
    "{\n%s\n}",
    paste(
      sprintf("  \"%s\" : %s", names(body), body),
      collapse = ",\n"
    )
  )
  POST(
    url = url,
    config = add_headers(
      # "User-Agent" = "inbo/checklist package",
      Authorization = paste("Bearer", token),
      accept = "application/vnd.github.v3+json"
    ),
    body = body,
    encode = "raw"
  )
}
