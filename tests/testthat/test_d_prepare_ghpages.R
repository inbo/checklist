library(mockery)
test_that("create_package() works", {
  cache <- tempfile("cache")
  defer(unlink(cache, recursive = TRUE))
  dir_create(file.path(cache, "data"))
  stub(new_author, "readline", mock("John", "Doe", "john@doe.com", ""))
  stub(new_author, "ask_orcid", mock(""))
  expect_output(
    new_author(
      current = data.frame(),
      root = file.path(cache, "data"),
      org = org_list$new()$read()
    )
  )

  mock_r_user_dir <- function(alt_dir) {
    function(package, which = c("data", "config", "cache")) {
      which <- match.arg(which)
      return(file.path(alt_dir, which))
    }
  }

  git_init(cache)
  git_remote_add(
    "https://gitlab.com/thierryo/checklist_dummy.git",
    repo = cache
  )
  stub(get_default_org_list, "R_user_dir", mock_r_user_dir(cache), depth = 2)
  org <- get_default_org_list(cache)
  c("git:", "  protocol: ssh", "  organisation: https://gitlab.com/thierryo") |>
    writeLines(path(cache, "config.yml"))

  path <- tempfile("ghpages")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))
  origin_repo <- git_init(tempfile("ghpages_origin"), bare = TRUE)
  defer(unlink(origin_repo, recursive = TRUE))

  package <- "ghpages"
  stub(create_package, "R_user_dir", mock_r_user_dir(cache), depth = 2)
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
