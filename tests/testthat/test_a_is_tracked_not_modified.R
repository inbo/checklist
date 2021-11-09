test_that("is_tracked_not_modified() works", {
  path <- tempfile("tracked_not_modified")
  dir.create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  git_init(path = path)
  git_config_set(name = "user.name", value = "junk", repo = path)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = path)

  writeLines("Initial line", file.path(path, "testfile.R"))
  writeLines("testfile.R", file.path(path, ".gitignore"))

  # File is gitignored
  expect_identical(
    is_tracked_not_modified("testfile.R", repo = path),
    FALSE
  )

  # File is not gitignored, but untracked (new, unstaged file)
  unlink(file.path(path, ".gitignore"))
  expect_identical(
    is_tracked_not_modified("testfile.R", repo = path),
    FALSE
  )

  # Start tracking the file (new, staged file)
  git_add("testfile.R", repo = path)
  expect_identical(
    is_tracked_not_modified("testfile.R", repo = path),
    TRUE
  )

  # Commit the new file
  gert::git_commit("first commit", repo = path)
  expect_identical(
    is_tracked_not_modified("testfile.R", repo = path),
    TRUE
  )

  # Modify the file
  writeLines("New line", file.path(path, "testfile.R"))
  expect_identical(
    is_tracked_not_modified("testfile.R", repo = path),
    FALSE
  )

  # Commit the changes
  gert::git_commit_all("changes", repo = path)
  expect_identical(
    is_tracked_not_modified("testfile.R", repo = path),
    TRUE
  )
})
