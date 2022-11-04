test_that("is_tracked_not_modified() works", {
  path <- tempfile("tracked_not_modified")
  dir_create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  git_init(path = path)
  git_config_set(name = "user.name", value = "junk", repo = path)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = path)

  writeLines("Initial line", path(path, "testfile.R"))
  writeLines("testfile.R", path(path, ".gitignore"))

  # File is gitignored
  expect_false(is_tracked_not_modified("testfile.R", repo = path))

  # File is not gitignored, but untracked (new, unstaged file)
  unlink(path(path, ".gitignore"))
  expect_false(is_tracked_not_modified("testfile.R", repo = path))

  # Start tracking the file (new, staged file)
  git_add("testfile.R", repo = path)
  expect_true(is_tracked_not_modified("testfile.R", repo = path))

  # Commit the new file
  gert::git_commit("first commit", repo = path)
  expect_true(is_tracked_not_modified("testfile.R", repo = path))

  # Modify the file
  writeLines("New line", path(path, "testfile.R"))
  expect_false(is_tracked_not_modified("testfile.R", repo = path))

  # Commit the changes
  gert::git_commit_all("changes", repo = path)
  expect_true(is_tracked_not_modified("testfile.R", repo = path))
})
