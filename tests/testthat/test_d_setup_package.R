library(mockery)
test_that("setup_package() works", {
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
  git_remote_add("https://github.com/inbo/checklist_dummy.git", repo = cache)
  stub(get_default_org_list, "R_user_dir", mock_r_user_dir(cache))
  org <- get_default_org_list(cache)
  c("git:", "  protocol: ssh", "  organisation: https://github.com/inbo") |>
    writeLines(path(cache, "config.yml"))

  path <- tempfile("setup_package")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))

  package <- "setuppackage"
  stub(create_package, "R_user_dir", mock_r_user_dir(cache), depth = 2)
  stub(create_package, "preferred_protocol", "git@github.com:inbo/%s.git")
  stub(
    create_package,
    "readline",
    mock("This is the title", "This is the description.")
  )
  stub(create_package, "ask_keywords", c("key", "word"))
  stub(create_package, "ask_language", "en-GB")
  suppressMessages(create_package(path = path, package = package))
  repo <- path(path, package)
  new_files <- c(
    "_pkgdown.yml",
    ".gitignore",
    ".Rbuildignore",
    "checklist.yml",
    "codecov.yml",
    "LICENSE.md",
    "NEWS.md",
    "README.Rmd",
    path(".github", c("CODE_OF_CONDUCT.md", "CONTRIBUTING.md")),
    path(
      ".github",
      "workflows",
      c(
        "check_on_branch.yml",
        "check_on_different_r_os.yml",
        "check_on_main.yml",
        "release.yml"
      )
    ),
    path("pkgdown", "extra.css"),
    path(
      "man",
      "figures",
      c(
        "logo-en.png",
        "background-pattern.png",
        "flanders.woff2",
        "flanders.woff"
      )
    )
  )
  file_delete(path(path, package, new_files))
  git_add(files = new_files, repo = repo)
  git_config_set(name = "user.name", value = "junk", repo = repo)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = repo)
  gert::git_commit("initial commit", repo = repo)

  expect_message(
    setup_package(path(path, package)),
    "package prepared for checklist::check_package()"
  )
  expect_true(all(file.exists(path(path, package, new_files))))

  gert::git_commit_all("setup package", repo = repo)

  expect_message(
    setup_package(path(path, package)),
    "package prepared for checklist::check_package()"
  )

  path(path, package, "README.Rmd") |>
    readLines() -> old_readme
  expect_equal(length(grep("10.5281/zenodo.8063503", old_readme)), 0)
  expect_null(add_badges(path(path, package), doi = "10.5281/zenodo.8063503"))
  path(path, package, "README.Rmd") |>
    readLines() -> new_readme
  expect_equal(length(grep("10.5281/zenodo.8063503", new_readme)), 1)
  expect_equal(length(old_readme) + 1, length(new_readme))
})
