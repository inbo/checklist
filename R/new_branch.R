#' Create a new branch after cleaning the repo
#'
#' First run `clean_git()`.
#' Then create the new branch from the (updated) main branch.
#'
#' @param branch Name of the new branch
#' @inheritParams git2r::repository
#' @inheritParams git2r::fetch
#' @inheritParams git2r::branch_create
#' @importFrom assertthat assert_that is.string
#' @importFrom git2r branch_create checkout lookup_commit push remote_url
#' repository
#' @export
#' @family utils
new_branch <- function(branch, path =  ".", verbose = TRUE, force = FALSE) {
  assert_that(is.string(branch))
  if (inherits(path, "git_repository")) {
    repo <- path
  } else {
    repo <- repository(path)
  }
  clean_git(path = repo, verbose = verbose)

  assert_that(
    !grepl("^http", remote_url(repo, "origin")),
    msg = "new_branch() does not handle remotes with http URL"
  )

  # determine main branch
  all_branches <- branches(repo)
  main_branch <- ifelse(
    "origin/main" %in% names(all_branches), "main",
    ifelse("origin/master" %in% names(all_branches), "master", "unknown")
  )
  new_branch <- branch_create(
    lookup_commit(all_branches[[main_branch]]), name = branch, force = force
  )
  checkout(repo, branch)
  push(repo, "origin", sprintf("refs/heads/%s", branch), set_upstream = TRUE)
  return(invisible(NULL))
}
