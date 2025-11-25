library(mockery)
test_that("check_filename() works", {
  path <- tempfile("check_filename")
  dir_create(path)
  defer(unlink(path, recursive = TRUE))
  checklist$new(path, language = "en-GB", package = FALSE) |>
    write_checklist()

  # fail on white space in folder names
  dir_create(path(path, "with space"))
  expect_is(suppressMessages(x <- check_filename(path)), "checklist")
  expect_false(x$fail)
  x$set_required("filename conventions")
  write_checklist(x)
  x <- check_filename(x)
  expect_true(x$fail)
  unlink(path(path, "with space"))

  # fail on upper case in folder names
  dir_create(path(path, "UPPERCASE"))
  expect_true(check_filename(path)$fail)
  unlink(path(path, "UPPERCASE"))

  # fail on dash in folder names
  dir_create(path(path, "dash-separated"))
  expect_true(check_filename(path)$fail)
  unlink(path(path, "dash-separated"))

  # fail on dash in file names
  dir_create(path(path, "source"))
  writeLines("sessionInfo()", path(path, "source", "correct.R"))
  git_init(path = path)
  git_config_set(name = "user.name", value = "junk", repo = path)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = path)
  git_add(path("source", "correct.R"), repo = path)
  gert::git_commit("initial commit", repo = path)
  wrong_file <- path(path, "source", "this Is wrong.R")
  writeLines("sessionInfo()", wrong_file)
  expect_false(check_filename(path)$fail)
  git_add(path_rel(wrong_file, path), repo = path)
  gert::git_commit("initial commit", repo = path)
  expect_true(check_filename(path)$fail)
  unlink(wrong_file)
})

test_that("list_project_files works in a git repository", {
  skip_if_not_installed("gert")

  tmp <- tempfile("testrepo_")
  dir.create(tmp)
  oldwd <- getwd()
  on.exit(setwd(oldwd), add = TRUE)
  setwd(tmp)

  # Simulate project structure
  dir.create("source/a/b", recursive = TRUE)
  writeLines("test", "source/a/b/script.R")
  writeLines("test", "README.md")

  # Init git repo and add files
  gert::git_init(path = tmp)
  gert::git_config_set(name = "user.name", value = "junk", repo = tmp)
  gert::git_config_set(name = "user.email", value = "junk@inbo.be", repo = tmp)
  gert::git_add(".")
  gert::git_commit("Initial commit")

  # Run the function
  res <- list_project_files(tmp)

  # Check structure
  expect_type(res, "list")
  expect_named(res, c("files", "dirs"))

  # Check files contain expected entries
  expect_true("README.md" %in% res$files)
  expect_true("source/a/b/script.R" %in% res$files)

  # Check dirs contain all directory paths
  expect_true("." %in% res$dirs)
  expect_true("source" %in% res$dirs)
  expect_true("source/a" %in% res$dirs)
  expect_true("source/a/b" %in% res$dirs)
})

test_that("list_project_files works outside of a git repository", {
  # Simulate project structure
  tmp <- tempfile("norepo_")
  dir.create(tmp)
  dir.create(file.path(tmp, "data"))
  dir.create(file.path(tmp, "source/a"), recursive = TRUE)
  writeLines("test", file.path(tmp, "source/a/script.R"))
  writeLines("test", file.path(tmp, "data/test.txt"))

  # Run the function
  res <- list_project_files(tmp)

  # Check structure
  expect_type(res, "list")
  expect_named(res, c("files", "dirs"))

  # Check files contain expected entries
  expect_true("source/a/script.R" %in% res$files)
  expect_true("data/test.txt" %in% res$files)

  # Check dirs contain all directory paths
  expect_true("data" %in% res$dirs)
  expect_true("source" %in% res$dirs)
  expect_true("source/a" %in% res$dirs)
})
