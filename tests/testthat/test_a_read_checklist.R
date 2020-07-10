test_that("read_checklist works", {
  target <- tempfile("checklist")
  dir.create(target)
  # no checklist.yml
  expect_is(x <- read_checklist(target), "Checklist")
  expect_identical(read_checklist(x), x)
  expect_identical(x$get_path, target)
  expect_identical(x$get_checked, "checklist")
  expect_identical(x$.__enclos_env__$private$allowed_notes, character(0))
  expect_identical(x$.__enclos_env__$private$allowed_warnings, character(0))
  file.remove(target)
})
