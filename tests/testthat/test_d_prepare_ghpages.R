test_that("create_package() works", {
  maintainer <- person(
    given = "Thierry",
    family = "Onkelinx",
    role = c("aut", "cre"),
    email = "thierry.onkelinx@inbo.be",
    comment = c(ORCID = "0000-0001-8804-4216")
  )
  path <- tempfile("ghpages")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))
  origin_repo <- git_init(tempfile("ghpages_origin"), bare = TRUE)
  defer(unlink(origin_repo, recursive = TRUE))

  package <- "ghpages"
  expect_message(
    create_package(
      path = path,
      package = package,
      keywords = "dummy",
      communities = "inbo",
      title = "testing the ability of checklist to create a minimal package",
      description = "A dummy package.",
      maintainer = maintainer,
      language = "en-GB"
    ),
    regexp = sprintf("package created at `.*%s`", package)
  )

  repo <- path(path, package)

  git_config_set("user.name", "unit test", repo = repo)
  git_config_set("user.email", "unit@test.com", repo = repo)
  git_add(list.files(repo, recursive = TRUE), repo = repo)
  git_commit("initial commit", repo = repo)

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
