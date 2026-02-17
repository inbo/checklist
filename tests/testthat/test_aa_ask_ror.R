library(mockery)
test_that("ask_ror", {
  stub(ask_ror, "readline", mock(""))
  expect_identical(ask_ror("What ROR"), "")
  stub(
    ask_ror,
    "readline",
    mock("https://ror.org", "00j54wy13", "00j54wy13")
  )
  expect_warning(result <- ask_ror("What ROR"), "`ror` must be in ")
  expect_identical(result, "00j54wy13")
})
