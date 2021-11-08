test_that("clean_git with `main` as main branch", {
  origin_repo <- git_init(tempfile("clean_git_origin"), bare = TRUE)
  on.exit(unlink(origin_repo, recursive = TRUE), add = TRUE)
  repo <- gert::git_clone(url = origin_repo,
                          path = tempfile("clean_git"), verbose = FALSE)
  on.exit(unlink(repo, recursive = TRUE), add = TRUE)
  repo2 <- gert::git_clone(url = origin_repo, path = tempfile("clean_git2"),
                           verbose = FALSE)
  on.exit(unlink(repo2, recursive = TRUE), add = TRUE)


  git_config_set(name = "user.name", value = "junk", repo = repo)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = repo)
  git_config_set(name = "user.name", value = "junk", repo = repo2)
  git_config_set(name = "user.email", value = "junk@inbo.be",
                       repo = repo2)

  writeLines("foo", file.path(repo, "junk.txt"))
  git_add("junk.txt", repo = repo)
  junk <- gert::git_commit(message = "Initial commit", repo = repo)
  branch_info <- git_branch_list(repo = repo)
  refspec <- branch_info$ref[branch_info$name == git_branch(repo = repo)]
  git_push(remote = "origin",
           refspec =  refspec,
           set_upstream = TRUE,
           repo = repo)
  git_branch_create(branch = "branch", checkout = TRUE, repo = repo)
  writeLines("foo", file.path(repo, "junk2.txt"))
  git_add("junk2.txt", repo = repo)
  junk2 <- gert::git_commit(message = "branch commit", repo = repo)
  git_push(remote = "origin",
           refspec = "refs/heads/branch",
           set_upstream = TRUE,
           repo = repo)

  # checkout main when no local branches
  branch_info_repo <- git_branch_list(repo = repo)
  branch_info_repo2 <- git_branch_list(repo = repo2)
  expect_identical(branch_info_repo2$name, character(0))
  expect_invisible(clean_git(repo = repo2, verbose = FALSE))
  branch_info_repo <- git_branch_list(repo = repo)
  branch_info_repo2 <- git_branch_list(repo = repo2)
  expect_identical(
    branch_info_repo$commit[branch_info_repo$name == "branch"],
    branch_info_repo2$commit[branch_info_repo2$name == "origin/branch"]
  )

  # update local branches that are behind
  writeLines("bar", file.path(repo, "junk2.txt"))
  git_add("junk2.txt", repo = repo)
  junk <- gert::git_commit(message = "branch commit", repo = repo)
  git_push(repo = repo)
  git_branch_create(branch = "branch", checkout = TRUE, repo = repo2)
  gert::git_branch_set_upstream(upstream = "origin/branch", repo = repo2)
  expect_invisible(clean_git(repo = repo2, verbose = FALSE))
  branch_info_repo <- git_branch_list(repo = repo)
  branch_info_repo2 <- git_branch_list(repo = repo2)
  expect_identical(
    branch_info_repo$commit[branch_info_repo$name == "branch"],
    branch_info_repo2$commit[branch_info_repo2$name == "origin/branch"]
  )

  ab <- git_ahead_behind(
    upstream = "origin/branch",
    ref = "branch",
    repo = repo2)

  expect_identical(
    c(ab$ahead, ab$behind),
    c(0L, 0L)
  )
  expect_identical(
    git_commit_id(repo = repo2),
    branch_info_repo2$commit[branch_info_repo2$name == "branch"]
  )

  # don't push local changes ahead
  writeLines("junk", file.path(repo2, "junk2.txt"))
  git_add("junk2.txt", repo = repo2)
  junk <- gert::git_commit(message = "branch commit", repo = repo2)

  ab <- git_ahead_behind(
    upstream = "origin/branch",
    ref = "branch",
    repo = repo2)

  expect_identical(
    c(ab$ahead, ab$behind),
    c(1L, 0L)
  )
  expect_invisible(clean_git(repo = repo2, verbose = FALSE))

  ab <- git_ahead_behind(
    upstream = "origin/branch",
    ref = "branch",
    repo = repo2)

  expect_identical(
    c(ab$ahead, ab$behind),
    c(1L, 0L)
  )

  branch_info_repo <- git_branch_list(repo = repo)
  branch_info_repo2 <- git_branch_list(repo = repo2)

  expect_identical(
    git_commit_id(repo = repo2),
    branch_info_repo2$commit[branch_info_repo2$name == "branch"]
  )

  # issue warnings when branch is ahead and behind
  writeLines("bar", file.path(repo, "junk.txt"))
  git_add("junk.txt", repo = repo)
  junk <- gert::git_commit(message = "branch commit", repo = repo)
  git_push(repo = repo)
  expect_warning(
    clean_git(repo = repo2, verbose = FALSE),
    "diverged from the origin branch"
  )

  ab <- git_ahead_behind(
    upstream = "origin/branch",
    ref = "branch",
    repo = repo2)

  expect_identical(
    c(ab$ahead, ab$behind),
    c(1L, 1L)
  )

  # remove local branches fully merged into the main branch
  branch_info <- git_branch_list(repo = repo)
  mainbranch <- branch_info$name[branch_info$name %in% c("main", "master")]
  git_branch_checkout(mainbranch, repo = repo)
  branch_info_repo <- git_branch_list(repo = repo)
  gert::git_merge(ref = "branch",
                  commit = TRUE,
                  squash = FALSE,
                  repo = repo)
  git_push(repo = repo)
  branch_info_origin_repo <- git_branch_list(repo = origin_repo)
  git_branch_delete(branch = "branch", repo = origin_repo)
  expect_invisible(clean_git(repo = repo, verbose = FALSE))
  branch_info_repo <- git_branch_list(repo = repo)
  expect_identical(branch_info_repo$name,
                   c(mainbranch, paste0("origin/", mainbranch)))
  expect_identical(git_branch(repo = repo), mainbranch)

  # keep diverging local branches without tracking remote
  expect_warning(
    clean_git(repo = repo2, verbose = FALSE),
    "diverged from the main origin branch"
  )
  branch_info_repo2 <- git_branch_list(repo = repo2)
  expect_identical(branch_info_repo2$name,
                   c("branch", mainbranch, paste0("origin/", mainbranch)))

  ab <- git_ahead_behind(
    upstream = paste0("origin/", mainbranch),
    ref = "branch",
    repo = repo2)

  expect_identical(
    c(ab$ahead, ab$behind),
    c(1L, 1L)
  )
  expect_identical(git_branch(repo = repo2), "branch")
})
