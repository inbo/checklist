test_that("read_checklist works", {
  target <- tempfile("checklist")
  dir.create(target)
  # no checklist.yml
  expect_is(x <- read_checklist(target), "Checklist")
  expect_identical(read_checklist(x), x)
  expect_identical(x$get_path, normalizePath(target, winslash = "/"))
  expect_identical(x$get_checked, "checklist")
  expect_is(x$.__enclos_env__$private$allowed_notes, "list")
  expect_is(x$.__enclos_env__$private$allowed_warnings, "list")
  expect_length(x$.__enclos_env__$private$allowed_notes, 0)
  expect_length(x$.__enclos_env__$private$allowed_warnings, 0)
  unlink(target, recursive = TRUE)
})
