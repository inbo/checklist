library(mockery)
test_that("ask_language", {
  cache_org("https://github.com/inbo", config_folder = config_dir)
  org <- org_list_from_url("https://github.com/inbo/checklist.git")
  expect_identical(ask_language(org), "nl-BE")
  stub(ask_language, "menu_first", 5)
  stub(ask_language, "readline", mock("", "nl-NL"))
  expect_identical(ask_language(org), "nl-NL")
})
