library(mockery)
test_that("ask_language", {
  org <- cache_org(
    url = "https://github.com/inbo",
    config_folder = path(config_dir, "config")
  )
  expect_identical(ask_language(org), "nl-BE")
  stub(ask_language, "menu_first", 5)
  stub(ask_language, "readline", mock("", "nl-NL"))
  expect_identical(ask_language(org), "nl-NL")
})
