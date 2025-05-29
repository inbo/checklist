#' Create a new branch after cleaning the repo
#'
#' This functions first runs `clean_git()`.
#' Then it creates the new branch from the (updated) main branch.
#'
#' @inheritParams gert::git_branch_create
#' @inheritParams gert::git_push
#' @importFrom assertthat assert_that is.string
#' @importFrom gert git_branch_list git_branch_create git_push
#' @export
#' @family git
new_branch <- function(branch, verbose = TRUE, checkout = TRUE, repo = ".") {
  assert_that(is.string(branch))

  clean_git(repo = repo, verbose = verbose)

  # determine main branch
  all_branches <- git_branch_list(repo = repo)
  main_branch <- ifelse(
    "origin/main" %in% all_branches$name,
    "main",
    ifelse("origin/master" %in% all_branches$name, "master", "unknown")
  )
  git_branch_create(
    branch = branch,
    checkout = checkout,
    repo = repo,
    ref = all_branches$commit[all_branches$name == main_branch]
  )
  git_push(
    remote = "origin",
    refspec = sprintf("refs/heads/%s", branch),
    set_upstream = TRUE,
    verbose = verbose,
    repo = repo
  )
  return(invisible(NULL))
}
