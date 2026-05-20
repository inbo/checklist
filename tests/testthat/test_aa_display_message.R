test_that("display_message", {
  expect_null(display_message("This is a message", verbose = FALSE))
  expect_message(display_message(
    "This is a message",
    verbose = TRUE,
    type = "message"
  ))
  expect_warning(display_message(
    "This is a message",
    verbose = TRUE,
    type = "warning"
  ))
  expect_output(display_message("This is a message", verbose = TRUE))
})
