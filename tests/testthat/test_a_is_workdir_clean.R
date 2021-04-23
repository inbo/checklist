test_that("is_workdir_clean", {
  path <- tempfile("clean")
  dir.create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)
  repo <- init(path)
  git2r::config(repo = repo, user.name = "junk", user.email = "junk@inbo.be")

  # ignore untracked files
  writeLines("foo", file.path(path, "junk.txt"))
  expect_true(is_workdir_clean(repo))

  # staged file
  add(repo, "junk.txt")
  expect_false(is_workdir_clean(repo))
  expect_error(
    assert_that(is_workdir_clean(repo)),
    "Working directory is not clean"
  )

  # all changes committed
  git2r::commit(repo = repo, message = "Initial commit")
  expect_true(is_workdir_clean(repo))

  # modified file
  writeLines("bar", file.path(path, "junk.txt"))
  expect_false(is_workdir_clean(repo))
})
