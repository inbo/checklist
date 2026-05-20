library(mockery)
test_that("project_maintainer", {
  stub(org_list_from_url, "R_user_dir", mock_r_user_dir(config_dir))
  org <- org_list_from_url("https://gitlab.com/thierryo/checklist.git")
  stub(project_maintainer, "select_individual", NULL)
  stub(project_maintainer, "ask_yes_no", mock(TRUE, FALSE))
  stub(
    project_maintainer,
    "ask_yes_no",
    mock(TRUE, FALSE, cycle = TRUE),
    depth = 2
  )

  stub(
    project_maintainer,
    "individual2badge",
    structure("[Someone, Else[^aut]", footnote = "[^aut]: author")
  )
  expect_type(x <- project_maintainer(org = org, lang = "en-GB"), "list")
})
