library(mockery)
test_that("create readme", {
  stub(org_list_from_url, "R_user_dir", mock_r_user_dir(config_dir))
  org <- org_list_from_url("https://gitlab.com/thierryo/checklist.git")

  path <- tempfile("readme")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))
  git_init(path = path)
  git_remote_add("https://github.com/inbo/checklist_dummy.git", repo = path)

  stub(
    create_readme,
    "readline",
    mock("title of the project", "A short description")
  )
  stub(create_readme, "ask_keywords", mock("keyword"))
  stub(
    create_readme,
    "project_maintainer",
    list(
      authors = data.frame(
        given = c("Given", "The checklist organisation") |>
          rep(each = 2),
        family = c("Test", "") |>
          rep(each = 2),
        email = c("given.test@vlaanderen.be", "info@organisation.checklist") |>
          rep(each = 2),
        orcid = c("0000-0002-1825-0097", "") |>
          rep(each = 2),
        affiliation = c("Vlaamse overheid", "") |>
          rep(each = 2),
        role = c("aut", "cre", "fnd", "cph")
      ) |>
        individual2badge(),
      org = org
    )
  )
  expect_null(create_readme(
    path = path,
    org = org,
    type = "project",
    lang = "en-GB"
  ))
  expect_true(file_test("-f", path_(path, "README.md")))
})
