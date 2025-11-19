library(mockery)
test_that("ask_new_license", {
  licenses <- c(MIT = "url", `GPL-3` = "url2", `Apache-2.0` = "url3")
  expect_identical(ask_new_license(licenses = licenses), licenses[1])

  stub(ask_new_license, "menu_first", mock(length(licenses) + 2))
  expect_identical(ask_new_license(licenses), character(0))

  extra <- c(
    `CC0` = "http://creativecommons.org/publicdomain/zero/1.0/",
    `CC-BY-4.0` = "http://creativecommons.org/licenses/by/4.0/"
  )
  stub(
    ask_new_license,
    "menu_first",
    mock(length(licenses) + 1, length(licenses) + 1)
  )
  stub(
    ask_new_license,
    "readline",
    mock(names(extra)[1], extra[1], names(extra)[2], extra[2])
  )
  stub(ask_new_license, "ask_yes_no", mock(TRUE, FALSE))
  expect_identical(ask_new_license(licenses), extra)
})
