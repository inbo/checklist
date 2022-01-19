#' Clean the git repository
#'
#' - update local branches that are behind their counterpart on origin.
#' - list local branches that have diverged from their counterpart the origin.
#' - list local branches without counterpart on origin that have diverged from
#'   the main branch.
#' - remove local branches without counterpart on origin and fully merged into
#'   the main branch.
#' - remove local copies of origin branches deleted at the origin.
#' @inheritParams gert::git_fetch
#' @importFrom assertthat assert_that
#' @importFrom gert git_ahead_behind git_branch git_branch_checkout
#' git_branch_create git_branch_delete git_branch_list git_fetch git_pull
#' git_remote_list
#' @export
#' @family utils
clean_git <- function(repo =  ".", verbose = TRUE) {
  assert_that(is_workdir_clean(repo))

  current_branch <- git_branch(repo = repo)

  # fetch the remote
  assert_that(
    "origin" %in% git_remote_list(repo)$name,
    msg = "no remote called `origin` found"
  )
  git_fetch(remote = "origin", verbose = verbose, repo = repo, prune = TRUE)

  # determine main branch
  branch_info <- git_branch_list(repo = repo)
  main_branch <- ifelse(
    any(branch_info$name == "origin/main"), "main", #nolint: nonportable_path_linter, line_length_linter.
    ifelse(any(branch_info$name == "origin/master"), "master", "unknown") #nolint: nonportable_path_linter, line_length_linter.
  )
  assert_that(
    main_branch %in% c("main", "master"),
    msg = "no branch `origin/main` or `origin/master` found." #nolint: nonportable_path_linter, line_length_linter.
  )

  origin_main_branch <- branch_info$name[
    branch_info$name == paste("origin", main_branch, sep = "/")
  ]

  # fix local branches
  if (!all(!branch_info$local)) {
    # local branches with upstream
    upstream_df <- branch_info[!is.na(branch_info$upstream), ]

    if (nrow(upstream_df) > 0) {
      # warn for diverging branches
      upstream_ab <- vapply(
        seq_len(nrow(upstream_df)), FUN.VALUE = vector("list", 1), repo = repo,
        FUN = function(i, repo) {
          list(
            git_ahead_behind(
              upstream = upstream_df$upstream[i], ref = upstream_df$ref[i],
              repo = repo
            )
          )
        }
      )
      names(upstream_ab) <- upstream_df$name

      ahead <- vapply(
        upstream_ab, FUN.VALUE = integer(1),
        FUN = function(x) {
          x$ahead
        }
      )
      behind <- vapply(
        upstream_ab, FUN.VALUE = integer(1),
        FUN = function(x) {
          x$behind
        }
      )
      diverged <- ahead > 0 & behind > 0
      diverged <- diverged[names(diverged) != "gh-pages"]
      vapply(
        names(diverged)[unlist(diverged)],
        function(x) {
          warning("`", x, "` diverged from the origin branch.", call. = FALSE)
          return(list())
        },
        list()
      )
      diverged <- ahead > 0 & behind == 0
      vapply(
        names(diverged)[unlist(diverged)],
        function(x) {
          warning("`", x, "` ahead of the origin branch.", call. = FALSE)
          return(list())
        },
        list()
      )
      # bring branches up-to-date
      update_local <- behind >= 0 & ahead == 0
      vapply(
        names(update_local)[unlist(update_local)],
        function(z) {
          git_branch_checkout(branch = z, repo = repo)
          if (verbose) {
            git_pull(repo = repo, verbose = TRUE)
          } else {
            hide_output <- tempfile(fileext = ".txt")
            on.exit(file.remove(hide_output), add = TRUE, after = TRUE)
            sink(hide_output)
            git_pull(repo = repo, verbose = FALSE)
            sink()
          }
          return(list())
        },
        list()
      )
    }

    # local branches without upstream
    local_branches_noup <-
      branch_info[is.na(branch_info$upstream) & branch_info$local, ]

    if (nrow(local_branches_noup) > 0) {
      no_upstream_ab <- vapply(
        local_branches_noup$ref, FUN.VALUE = vector("list", 1),
        upstream = origin_main_branch, repo = repo,
        FUN = function(i, upstream, repo) {
          list(
            git_ahead_behind(
              upstream = upstream, ref = i,
              repo = repo
            )
          )
        }
      )
      names(no_upstream_ab) <- local_branches_noup$name

      # warn for diverging branches
      diverged <- vapply(
        no_upstream_ab, FUN.VALUE = logical(1),
        FUN = function(x) {
          x$ahead > 0 & x$behind > 0
        }
      )
      diverged <- diverged[names(diverged) != "gh-pages"]
      vapply(
        names(diverged)[unlist(diverged)],
        function(x) {
          warning(
            "`", x, "` (no upstream) diverged from the main origin branch.",
            call. = FALSE
          )
          return(list())
        },
        list()
      )

      # remote full merged branches
      git_branch_checkout(branch = main_branch, repo = repo)
      delete_local <- vapply(
        no_upstream_ab, FUN.VALUE = logical(1),
        FUN = function(x) {
          x$behind >= 0 & x$ahead == 0
        }
      )
      vapply(
        names(delete_local)[unlist(delete_local)],
        function(x) {
          git_branch_delete(x, repo = repo)
          return(list())
        },
        list()
      )
    }
  }

  # switch back to original branch if it still exists
  # otherwise select the main branch
  all_branches <- git_branch_list(repo = repo)
  if (
    is.null(current_branch) || !current_branch %in% all_branches$name
  ) {
    git_branch_create(
      branch = main_branch, checkout = TRUE, repo = repo,
      ref = paste("refs", "remotes", "origin", main_branch, sep = "/")
    )
  } else {
    git_branch_checkout(branch = current_branch, repo = repo)
  }

  return(invisible(NULL))
}
