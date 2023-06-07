test_that("organisation class", {
  org <- organisation$new()
  expect_output(print(org), regexp = "rightsholder")
})
