test_that("clean_git with `main` as main branch", {
  origin_path <- tempfile("clean_git_origin")
  dir.create(origin_path)
  on.exit(unlink(origin_path, recursive = TRUE), add = TRUE)

  path <- tempfile("clean_git")
  dir.create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  path2 <- tempfile("clean_git2")
  dir.create(path2)
  on.exit(unlink(path2, recursive = TRUE), add = TRUE)

  origin_repo <- gert::git_init(origin_path, bare = TRUE)
  repo <- gert::git_clone(url = origin_path, path = path, verbose = FALSE)
  repo2 <- gert::git_clone(url = origin_path, path = path2, verbose = FALSE)

  gert::git_config_set(name = "user.name", value = "junk", repo = repo)
  gert::git_config_set(name = "user.email", value = "junk@inbo.be", repo = repo)
  gert::git_config_set(name = "user.name", value = "junk", repo = repo2)
  gert::git_config_set(name = "user.email", value = "junk@inbo.be",
                       repo = repo2)

  writeLines("foo", file.path(repo, "junk.txt"))
  gert::git_add("junk.txt", repo = repo)
  junk <- gert::git_commit(message = "Initial commit", repo = repo)
  gert::git_push(remote = "origin",
                 refspec =  "refs/heads/main",
                 set_upstream = TRUE,
                 repo = repo)
  gert::git_branch_create(branch = "branch", checkout = TRUE, repo = repo)
  writeLines("foo", file.path(repo, "junk2.txt"))
  gert::git_add("junk2.txt", repo = repo)
  junk2 <- gert::git_commit(message = "branch commit", repo = repo)
  gert::git_push(remote = "origin",
                 refspec = "refs/heads/branch",
                 set_upstream = TRUE,
                 repo = repo)

  # checkout main when no local branches
  branch_info_repo <- gert::git_branch_list(repo = repo)
  branch_info_repo2 <- gert::git_branch_list(repo = repo2)
  expect_identical(branch_info_repo2$name, character(0))
  expect_invisible(clean_git(repo = repo2, verbose = FALSE))
  branch_info_repo <- gert::git_branch_list(repo = repo)
  branch_info_repo2 <- gert::git_branch_list(repo = repo2)
  expect_identical(
    branch_info_repo$commit[branch_info_repo$name == "branch"],
    branch_info_repo2$commit[branch_info_repo2$name == "origin/branch"]
  )

  # update local branches that are behind
  writeLines("bar", file.path(path, "junk2.txt"))
  gert::git_add("junk2.txt", repo = repo)
  junk <- gert::git_commit(message = "branch commit", repo = repo)
  gert::git_push(repo = repo)
  gert::git_branch_create(branch = "branch", checkout = TRUE, repo = repo2)
  gert::git_branch_set_upstream(upstream = "origin/branch", repo = repo2)
  expect_invisible(clean_git(repo = repo2, verbose = FALSE))
  branch_info_repo <- gert::git_branch_list(repo = repo)
  branch_info_repo2 <- gert::git_branch_list(repo = repo2)
  expect_identical(
    branch_info_repo$commit[branch_info_repo$name == "branch"],
    branch_info_repo2$commit[branch_info_repo2$name == "origin/branch"]
  )

  ab <- gert::git_ahead_behind(
    upstream = "origin/branch",
    ref = "branch",
    repo = repo2)

  expect_identical(
    c(ab$ahead, ab$behind),
    c(0L, 0L)
  )
  expect_identical(
    gert::git_commit_id(repo = repo2),
    branch_info_repo2$commit[branch_info_repo2$name == "branch"]
  )

  # don't push local changes ahead
  writeLines("junk", file.path(path2, "junk2.txt"))
  gert::git_add("junk2.txt", repo = repo2)
  junk <- gert::git_commit(message = "branch commit", repo = repo2)

  ab <- gert::git_ahead_behind(
    upstream = "origin/branch",
    ref = "branch",
    repo = repo2)

  expect_identical(
    c(ab$ahead, ab$behind),
    c(1L, 0L)
  )
  expect_invisible(clean_git(repo = repo2, verbose = FALSE))

  ab <- gert::git_ahead_behind(
    upstream = "origin/branch",
    ref = "branch",
    repo = repo2)

  expect_identical(
    c(ab$ahead, ab$behind),
    c(1L, 0L)
  )

  branch_info_repo <- gert::git_branch_list(repo = repo)
  branch_info_repo2 <- gert::git_branch_list(repo = repo2)

  expect_identical(
    gert::git_commit_id(repo = repo2),
    branch_info_repo2$commit[branch_info_repo2$name == "branch"]
  )

  # issue warnings when branch is ahead and behind
  writeLines("bar", file.path(path, "junk.txt"))
  gert::git_add("junk.txt", repo = repo)
  junk <- gert::git_commit(message = "branch commit", repo = repo)
  gert::git_push(repo = repo)
  expect_warning(
    clean_git(repo = repo2, verbose = FALSE),
    "diverged from the origin branch"
  )

  ab <- gert::git_ahead_behind(
    upstream = "origin/branch",
    ref = "branch",
    repo = repo2)

  expect_identical(
    c(ab$ahead, ab$behind),
    c(1L, 1L)
  )

  # remove local branches fully merged into the main branch
  gert::git_branch_checkout("main", repo = repo)
  branch_info_repo <- gert::git_branch_list(repo = repo)
  gert::git_merge(ref = "branch",
                  commit = TRUE,
                  squash = FALSE,
                  repo = repo)
  gert::git_push(repo = repo)
  branch_info_origin_repo <- gert::git_branch_list(repo = origin_repo)
  gert::git_branch_delete(branch = "branch", repo = origin_repo)
  expect_invisible(clean_git(path, verbose = FALSE))
  branch_info_repo <- gert::git_branch_list(repo = repo)
  expect_identical(branch_info_repo$name, c("main", "origin/main"))
  expect_identical(gert::git_branch(repo = repo), "main")

  # keep diverging local branches without tracking remote
  expect_warning(
    clean_git(path2, verbose = FALSE),
    "diverged from the main origin branch"
  )
  branch_info_repo2 <- gert::git_branch_list(repo = repo2)
  expect_identical(branch_info_repo2$name, c("branch", "main", "origin/main"))

  ab <- gert::git_ahead_behind(
    upstream = "origin/main",
    ref = "branch",
    repo = repo2)

  expect_identical(
    c(ab$ahead, ab$behind),
    c(1L, 1L)
  )
  expect_identical(gert::git_branch(repo = repo2), "branch")
})
