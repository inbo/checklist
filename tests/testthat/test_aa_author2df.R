test_that("yesno", {
  empty <- data.frame(
    given = character(0),
    family = character(0),
    email = character(0),
    orcid = character(0),
    affiliation = character(0),
    role = character(0)
  )
  simple <- data.frame(
    given = "Thierry",
    family = "Onkelinx",
    email = "",
    orcid = "",
    affiliation = "",
    role = ""
  )
  expect_error(author2df(TRUE))
  expect_error(author2df(FALSE))
  expect_identical(author2df(NA), empty)
  expect_identical(author2df(NULL), empty)
  expect_warning(df <- author2df("Thierry Onkelinx"))
  expect_identical(df, simple)
  expect_warning(df <- author2df(list("Thierry Onkelinx")))
  expect_identical(df, simple)
})
