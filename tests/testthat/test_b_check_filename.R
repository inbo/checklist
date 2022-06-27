library(mockery)
test_that("check_filename() works", {
  path <- tempfile("check_filename")
  dir_create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  # fail on white space in folder names
  dir_create(path(path, "with space"))
  expect_is(suppressMessages(x <- check_filename(path)), "checklist")
  expect_true(x$fail)
  unlink(path(path, "with space"))

  # fail on upper case in folder names
  dir_create(path(path, "UPPERCASE"))
  expect_true(suppressMessages(check_filename(path)$fail))
  unlink(path(path, "UPPERCASE"))

  # fail on dash in folder names
  dir_create(path(path, "source"))
  writeLines("sessionInfo()", file.path(path, "source", "correct.R"))
  git_init(path = path)
  git_config_set(name = "user.name", value = "junk", repo = path)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = path)
  git_add(file.path("source", "correct.R"), repo = path)
  gert::git_commit("initial commit", repo = path)
  dir_create(path(path, "dash-separated"))
  expect_false(suppressMessages(check_filename(path)$fail))
  unlink(path(path, "dash-separated"))

  # fail on dash in filenames
  writeLines("sessionInfo()", path(path, "source", "this-is-wrong.R"))
  expect_false(suppressMessages(check_filename(path)$fail))
  unlink(path(path, "source", "this-is-wrong.R"))
})
