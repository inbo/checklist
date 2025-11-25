library(mockery)
test_that("ask_email", {
  stub(ask_email, "readline", mock("", "info", "info@inbo", "info@inbo.be"))
  expect_warning(result <- ask_email("email"), "Please enter a valid email")
  expect_identical(result, "info@inbo.be")
})
