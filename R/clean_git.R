#' Clean the git repository
#'
#' - update local branches that are behind their counterpart on origin.
#' - list local branches that have diverged from their counterpart the origin.
#' - list local branches without counterpart on origin that have diverged from
#'   the main branch.
#' - remove local branches without counterpart on origin and fully merged into
#'   the main branch.
#' - remove local copies of origin branches deleted at the origin.
#' @inheritParams git2r::repository
#' @inheritParams git2r::fetch
#' @importFrom assertthat assert_that
#' @importFrom git2r ahead_behind branches branch_delete branch_get_upstream
#' checkout lookup_commit
#' fetch is_local lookup pull repository_head
#' @export
clean_git <- function(path =  ".", verbose = TRUE) {
  if (inherits(path, "git_repository")) {
    repo <- path
  } else {
    repo <- repository(path)
  }
  assert_that(is_workdir_clean(repo))

  current_branch <- repository_head(repo)
  assert_that("origin" %in% remotes(repo), msg = "no `origin` remote found")

  # fetch the remote
  fetch(repo, "origin", verbose = verbose)
  # remove remote branches deleted at the remote
  system("git remote prune origin")
  # determine main branch
  all_branches <- branches(repo)
  main_branch <- ifelse(
    "origin/main" %in% names(all_branches), "main",
    ifelse("origin/master" %in% names(all_branches), "master", "unknown")
  )
  assert_that(
    main_branch %in% c("main", "master"),
    msg = "no branch `origin/main` or `origin/master` found."
  )

  origin_main <- all_branches[[paste("origin", main_branch, sep = "/")]]
  origin_main_commit <- lookup_commit(origin_main)

  # fix local branches
  for (local_branch in all_branches) {
    if (!is_local(local_branch)) {
      next
    }
    upstream_branch <- branch_get_upstream(local_branch)
    local_commit <- lookup_commit(local_branch)
    if (is.null(upstream_branch)) {
      delta_main <- ahead_behind(local_commit, origin_main_commit)
      if (delta_main[2] >= 0) {
        if (delta_main[1] > 0) {
          warning(
            "`", local_branch$name, "` diverged from the main origin branch."
          )
          next
        }
        branch_delete(local_branch)
      }
      next
    }
    upstream_commit <- lookup_commit(upstream_branch)
    delta_upstream <- ahead_behind(local_commit, upstream_commit)
    if (delta_upstream[2] > 0) {
      if (delta_upstream[1] > 0) {
        warning("`", local_branch$name, "` diverged from the origin branch.")
        next
      }
      checkout(repo, branch = local_branch$name)
      pull(repo)
    }
  }

  # which back to original branch if it still exists
  all_branches <- branches(repo)
  if (
    is.null(current_branch) || !current_branch$name %in% names(all_branches)
  ) {
    checkout(repo, main_branch, create = TRUE)
  } else {
    checkout(repo, branch = current_branch$name)
  }

  return(invisible(NULL))
}
