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
  expect_null(
    create_readme(path = path, org = org, type = "project", lang = "en-GB")
  )
  expect_true(file_exists(path(path, "README.md")))
})
