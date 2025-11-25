library(mockery)
test_that("setup_package() works", {
  stub(org_list_from_url, "R_user_dir", mock_r_user_dir(config_dir))
  org <- org_list_from_url("https://gitlab.com/thierryo/checklist.git")

  path <- tempfile("setup_package")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))

  package <- "setuppackage"
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
  suppressMessages(create_package(path = path, package = package))
  sink()
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
    path("man", "figures", "background-pattern.png")
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
