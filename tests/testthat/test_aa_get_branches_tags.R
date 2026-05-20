test_that("get_branches_tags", {
  expect_type(
    {
      branches <- get_branches_tags("inbo", "checklist")
    },
    "character"
  )
  expect_true("main" %in% branches)
})
