library(mockery)
test_that("create_package() works", {
  stub(org_list_from_url, "R_user_dir", mock_r_user_dir(config_dir))
  org <- org_list_from_url("https://gitlab.com/thierryo/checklist.git")

  path <- tempfile("ghpages")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))
  origin_repo <- git_init(tempfile("ghpages_origin"), bare = TRUE)
  defer(unlink(origin_repo, recursive = TRUE))

  package <- "ghpages"
  stub(create_package, "R_user_dir", mock_r_user_dir(config_dir), depth = 2)
  stub(create_package, "preferred_protocol", "git@gitlab.com:thierryo/%s.git")
  stub(
    create_package,
    "readline",
    mock("This is the title", "This is the description.")
  )
  stub(create_package, "ask_keywords", c("key", "word"))
  stub(create_package, "ask_language", "en-GB")
  hide_output <- tempfile(fileext = ".txt")
  defer(file_delete(hide_output))
  sink(hide_output)
  create_package(path = path, package = package)
  sink()

  repo <- path(path, package)

  git_config_set("user.name", "unit test", repo = repo)
  git_config_set("user.email", "unit@test.com", repo = repo)
  git_add(list.files(repo, recursive = TRUE), repo = repo)
  git_commit("initial commit", repo = repo)
  gert::git_remote_remove("origin", repo = repo)

  expect_false(git_branch_exists("gh-pages", repo = repo))
  old_head <- git_info(repo = repo)$head
  expect_error(prepare_ghpages(repo), "no remote called `origin` found")
  expect_identical(old_head, git_info(repo = repo)$head)
  expect_false(git_branch_exists("gh-pages", repo = repo))

  gert::git_remote_add(origin_repo, repo = repo)
  expect_error(
    prepare_ghpages(repo),
    "no branch `origin/main` or `origin/master` found"
  )

  git_push(repo = repo, verbose = FALSE)
  expect_invisible(output <- prepare_ghpages(repo, verbose = FALSE))
  expect_true(output)
  expect_true(git_branch_exists("gh-pages", repo = repo))

  expect_invisible(output <- prepare_ghpages(repo, verbose = FALSE))
  expect_false(output)
})
