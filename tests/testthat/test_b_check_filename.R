library(mockery)
test_that("check_filename() works", {
  path <- tempfile("check_filename")
  dir.create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  # fail on white space in folder names
  dir.create(file.path(path, "with space"))
  expect_is(suppressMessages(x <- check_filename(path)), "Checklist")
  expect_true(x$fail)
  unlink(file.path(path, "with space"))

  # fail on upper case in folder names
  gert::git_init(path = path)
  gert::git_config_set(name = "user.name", value = "junk", repo = path)
  gert::git_config_set(name = "user.email", value = "junk@inbo.be", repo = path)

  dir.create(file.path(path, "UPPERCASE"))
  expect_true(suppressMessages(check_filename(path)$fail))
  unlink(file.path(path, "UPPERCASE"))

  # fail on dash in folder names
  dir.create(file.path(path, "source"))
  writeLines("sessionInfo()", file.path(path, "source", "correct.R"))
  gert::git_add(file.path("source", "correct.R"), repo = path)
  gert::git_commit("initial commit", repo = path)
  dir.create(file.path(path, "dash-separated"))
  expect_true(suppressMessages(check_filename(path)$fail))
  unlink(file.path(path, "dash-separated"))

  # fail on dash in filenames
  writeLines("sessionInfo()", file.path(path, "source", "this-is-wrong.R"))
  expect_true(suppressMessages(check_filename(path)$fail))
  unlink(file.path(path, "source", "this-is-wrong.R"))
})
