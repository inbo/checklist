library(mockery)
test_that("setup_source() works", {
  path <- tempfile("setup_source")
  dir.create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  expect_error(
    setup_source(path = path),
    "The 'path' is not in a git repository"
  )
  repo <- init(path)

  expect_message({
      junk <- setup_source(path = path)
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

  expect_is({
      x <- check_source(path, fail = FALSE)
    },
    "Checklist"
  )

  writeLines("sessionInfo()", file.path(path, "junk.r"))
  expect_error(
    check_source(path, fail = TRUE),
    "Checking the source code revealed some problems"
  )
  expect_is({
    x <- check_source(path, fail = FALSE)
  },
  "Checklist"
  )
})
