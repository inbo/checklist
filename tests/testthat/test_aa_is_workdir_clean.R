test_that("is_workdir_clean", {
  path <- tempfile("clean")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))

  git_init(path = path)
  git_config_set(name = "user.name", value = "junk", repo = path)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = path)

  # ignore untracked files
  writeLines("foo", path(path, "junk.txt"))
  expect_true(is_workdir_clean(repo = path))

  # staged file
  git_add("junk.txt", repo = path)
  expect_false(is_workdir_clean(repo = path))
  expect_error(
    assert_that(is_workdir_clean(repo = path)),
    "Working directory is not clean. Please commit or stash changes first."
  )

  # all changes committed
  gert::git_commit_all(message = "Initial commit", repo = path)
  expect_true(is_workdir_clean(repo = path))

  # modified file
  writeLines("bar", path(path, "junk.txt"))
  expect_false(is_workdir_clean(repo = path))
})
