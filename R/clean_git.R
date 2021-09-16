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
#' checkout fetch is_local lookup_commit pull remotes repository_head
#' @importFrom gert git_ahead_behind git_branch git_branch_checkout
#' git_branch_create git_branch_delete git_branch_list git_fetch
#' @export
#' @family utils
clean_git <- function(path =  ".", verbose = TRUE) {
  assert_that(is_workdir_clean(path))

  current_branch <- gert::git_branch(repo = path)
  branch_info <- gert::git_branch_list(repo = path)
  assert_that(
    all(
      grepl("origin", branch_info$name[!branch_info$local])
    ),
    msg = "no remote called `origin` found"
  )

  # fetch the remote
  git_fetch(remote = "origin", verbose = verbose, repo = path)
  # remove remote branches deleted at the remote
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(path)
  system("git remote prune origin")
  # determine main branch
  main_branch <- ifelse(
    any(branch_info$name == "origin/main"), "main",
    ifelse(any(branch_info$name == "origin/master"), "master", "unknown")
  )
  assert_that(
    main_branch %in% c("main", "master"),
    msg = "no branch `origin/main` or `origin/master` found."
  )

  origin_main_commit <- branch_info$commit[
    branch_info$name == paste("origin", main_branch, sep = "/")]

  # fix local branches

  # local branches with upstream
  upstream_df <- branch_info[!is.na(branch_info$upstream), ]

  # warn for diverging branches
  upstream_ab <- mapply(gert::git_ahead_behind,
         upstream = upstream_df$upstream,
         ref = upstream_df$ref,
         repo = repo,
         SIMPLIFY = FALSE,
         USE.NAMES = FALSE)
  names(upstream_ab) <- upstream_df$name

  diverged <- lapply(upstream_ab, function(x) {x$ahead > 0 & x$behind > 0})
  diverged <- diverged[names(diverged) != "gh-pages"]
  vapply(
    names(diverged)[diverged],
    function(x) {
      warning("`", x, "` diverged from the origin branch.", call. = FALSE)
      return(list())
    },
    list()
  )
  # bring branches up-to-date
  update_local <- lapply(upstream_ab,
                         function(x) {x$behind >= 0 & x$ahead == 0})
  vapply(
    names(update_local)[update_local],
    function(x) {
      gert::git_branch_checkout(branch = x, repo = path)
      gert::git_pull(repo = path)
      return(list())
    },
    list()
  )

  # local branches without upstream
  local_branches_noup <-
    branch_info[is.na(branch_info$upstream) & branch_info$local, ]
  no_upstream_ab <- mapply(
    gert::git_ahead_behind,
    upstream = branch_info$name[
      branch_info$name == paste("origin", main_branch, sep = "/")],
    ref = local_branches_noup$ref,
    repo = path,
    SIMPLIFY = FALSE,
    USE.NAMES = FALSE)
  names(no_upstream_ab) <- local_branches_noup$name


  # warn for diverging branches
  diverged <- lapply(no_upstream_ab, function(x) {x$ahead > 0 & x$behind > 0})
  diverged <- diverged[names(diverged) != "gh-pages"]
  vapply(
    names(diverged)[diverged],
    function(x) {
      warning("`", x, "` diverged from the main origin branch.", call. = FALSE)
      return(list())
    },
    list()
  )
  # remote full merged branches
  git_branch_checkout(branch = main_branch, repo = path)
  delete_local <- lapply(
    no_upstream_ab, function(x) {x$behind >= 0 & x$ahead == 0})
  vapply(
    names(delete_local)[delete_local],
    function(x) {
      git_branch_delete(x, repo = path)
      return(list())
    },
    list()
  )

  # switch back to original branch if it still exists
  # otherwise select the main branch
  all_branches <- git_branch_list(repo = path)
  if (
    is.null(current_branch) || !current_branch %in% all_branches$name
  ) {
    git_branch_create(main_branch, checkout = TRUE, repo = path)
  } else {
    git_branch_checkout(branch = current_branch, repo = path)
  }

  return(invisible(NULL))
}
