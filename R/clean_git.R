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
#' checkout fetch is_local lookup_commit pull repository_head
#' @export
#' @family utils
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
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(repo$path)
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
  local_branches <- all_branches[vapply(all_branches, is_local, logical(1))]
  head_commits <- vapply(
    all_branches[names(all_branches) != "origin/HEAD"],
    function(x) {
      list(lookup_commit(x))
    },
    vector("list", 1)
  )
  upstream_branches <- vapply(
    local_branches,
    function(x) {
      list(branch_get_upstream(x))
    },
    vector("list", 1)
  )

  # local branches without upstream
  no_upstream <- vapply(upstream_branches, is.null, logical(1))
  no_upstream_ab <- vapply(
    head_commits[names(local_branches)[no_upstream]], FUN = ahead_behind,
    FUN.VALUE = integer(2), upstream = origin_main_commit
  )
  # warn for diverging branches
  diverged <- no_upstream_ab[2, ] > 0 & no_upstream_ab[1, ] > 0
  vapply(
    names(local_branches)[no_upstream][diverged],
    function(x) {
      warning("`", x, "` diverged from the main origin branch.")
      return(list())
    },
    list()
  )
  # remote full merged branches
  checkout(repo, branch = main_branch)
  delete_local <- no_upstream_ab[2, ] >= 0 & no_upstream_ab[1, ] == 0
  vapply(
    local_branches[no_upstream][delete_local],
    function(x) {
      branch_delete(x)
      return(list())
    },
    list()
  )

  # local branches with upstream
  local_branches <- local_branches[!no_upstream]
  upstream_ab <- vapply(
    local_branches,
    function(x) {
      ahead_behind(
        head_commits[[x$name]], head_commits[[paste0("origin/", x$name)]]
      )
    },
    integer(2)
  )
  # warn for diverging branches
  diverged <- upstream_ab[2, ] > 0 & upstream_ab[1, ] > 0
  vapply(
    names(local_branches)[diverged],
    function(x) {
      warning("`", x, "` diverged from the origin branch.")
      return(list())
    },
    list()
  )
  # bring branches up-to-date
  update_local <- upstream_ab[2, ] >= 0 & upstream_ab[1, ] == 0
  vapply(
    names(local_branches[update_local]),
    function(x) {
      checkout(repo, branch = x)
      pull(repo = repo)
      return(list())
    },
    list()
  )

  # which back to original branch if it still exists
  # otherwise select the main branch
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
