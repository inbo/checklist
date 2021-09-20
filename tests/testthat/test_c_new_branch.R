test_that("new_branch() creates a branch from the main branch", {
  origin_path <- tempfile("new_branch_origin")
  dir.create(origin_path)
  on.exit(unlink(origin_path, recursive = TRUE), add = TRUE)

  path <- tempfile("new_branch")
  dir.create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  gert::git_config_global_set(name = "init.defaultBranch", value = "main")

  origin_repo <- git_init(path = origin_path, bare = TRUE)
  repo <- gert::git_clone(url = origin_path, path = path, verbose = FALSE)

  git_config_set(name = "user.name", value = "junk", repo = repo)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = repo)


  writeLines("foo", file.path(path, "junk.txt"))
  git_add("junk.txt", repo = repo)
  initial <- gert::git_commit(message = "Initial commit", repo = repo)
  git_push(remote = "origin", refspec = "refs/heads/main",
                 set_upstream = TRUE, repo = repo)
  git_branch_create(branch = "branch", checkout = TRUE, repo = repo)
  writeLines("foo", file.path(path, "junk2.txt"))
  git_add("junk2.txt", repo = repo)
  junk <- gert::git_commit(message = "branch commit", repo = repo)
  git_push(remote = "origin", refspec = "refs/heads/branch",
                 set_upstream = TRUE, repo = repo)
  expect_invisible(new_branch("new", checkout = TRUE, repo = path))
  expect_identical(git_branch(repo = repo), "new")
  expect_identical(git_commit_id(repo = repo), initial)
  expect_invisible(new_branch(branch = "new2", checkout = TRUE, repo = repo))
  expect_identical(git_branch(repo = repo), "new2")
  expect_identical(git_commit_id(repo = repo), initial)
})
