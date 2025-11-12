library(mockery)
test_that("ask_keywords", {
  keywords <- c("key", "word")
  stub(ask_keywords, "readline", mock("", paste(keywords, collapse = "   ;  ")))
  expect_warning(result <- ask_keywords(), "Please enter at least one keyword")
  expect_identical(result, keywords)
})
