#' Create a draft pull request
#'
#' This function creates a draft pull request for the current version of the
#' package.
#'
#' @param x The path to the package.
#' @importFrom desc desc
#' @importFrom gert git_info git_remote_info
#' @importFrom gh gh
#' @export
#' @family git
create_draft_pr <- function(x = ".") {
  x <- read_checklist(x)
  stopifnot("Current version only relevant for R packages" = x$package)
  git_info <- git_info(repo = x$get_path)
  remote <- git_remote_info(remote = git_info$remote, repo = x$get_path)
  owner <- gsub("git@github.com:(.+)/(.+).git", "\\1", remote$url)
  repo <- gsub("git@github.com:(.+)/(.+).git", "\\2", remote$url)
  desc(x$get_path)$get_version() |>
    as.character() -> version
  output <- gh(
    "POST /repos/{owner}/{repo}/pulls",
    owner = owner,
    repo = repo,
    head = basename(git_info$head),
    base = basename(remote$head),
    title = sprintf(":bookmark:Version %s", version),
    draft = TRUE
  )
  return(invisible(output$url))
}
