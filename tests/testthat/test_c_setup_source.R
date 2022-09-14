library(mockery)
test_that("setup_source() works", {
  path <- tempfile("setup_source")
  dir.create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  expect_error(
    setup_source(path = path, language = "en-GB"),
    regexp = "could not find repository from"
  )
  git_init(path = path)
  git_config_set(name = "user.name", value = "junk", repo = path)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = path)

  expect_message({
      junk <- setup_source(path = path, language = "en-GB")
    },
    "project prepared for checklist::check_source()"
  )
  expect_null(junk)

  new_files <- c(
    "checklist.yml", "LICENSE.md",
    file.path(".github", "CODE_OF_CONDUCT.md"),
    file.path(".github", "workflows", "check_source.yml")
  )
  expect_true(
    all(file.exists(file.path(path, new_files)))
  )

  gert::git_commit_all(message = "initial commit", repo = path)

  expect_is({
      hide_output <- tempfile(fileext = ".txt")
      on.exit(file.remove(hide_output), add = TRUE, after = TRUE)
      sink(hide_output)
      x <- check_source(path, fail = FALSE)
      sink()
      x
    },
    "checklist"
  )

  writeLines("sessionInfo()", file.path(path, "junk.r"))
  git_add(files = "junk.r", repo = path)
  expect_error({
      hide_output2 <- tempfile(fileext = ".txt")
      on.exit(file.remove(hide_output2), add = TRUE, after = TRUE)
      sink(hide_output2)
      x <- check_source(path, fail = TRUE)
      sink()
      x
    },
    "Checking the source code revealed some problems"
  )
  expect_is({
    hide_output3 <- tempfile(fileext = ".txt")
    on.exit(file.remove(hide_output3), add = TRUE, after = TRUE)
    sink(hide_output3)
    x <- check_source(path, fail = FALSE)
    sink()
    x
  },
  "checklist"
  )
})
