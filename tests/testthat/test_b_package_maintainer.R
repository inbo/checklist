library(mockery)
test_that("package_maintainer", {
  stub(org_list_from_url, "R_user_dir", mock_r_user_dir(config_dir))
  org <- org_list_from_url("https://gitlab.com/thierryo/checklist.git")
  stub(package_maintainer, "select_individual", NULL)
  stub(package_maintainer, "ask_yes_no", mock(TRUE, FALSE))
  stub(
    package_maintainer,
    "ask_yes_no",
    mock(TRUE, FALSE, cycle = TRUE),
    depth = 2
  )

  stub(
    package_maintainer,
    "individual2person",
    person(given = "Someone", family = "Else", role = c("aut", "cre"))
  )
  expect_type(x <- package_maintainer(org = org, lang = "en-GB"), "list")
})
