test_that("setup_package() works", {
  maintainer <- person(
    given = "Thierry",
    family = "Onkelinx",
    role = c("aut", "cre"),
    email = "thierry.onkelinx@inbo.be",
    comment = c(ORCID = "0000-0001-8804-4216")
  )
  path <- tempfile("setup_package")
  dir.create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  package <- "setuppackage"
  create_package(
    path = path, package = package, keywords = "dummy", communities = "inbo",
    title = "testing the ability of checklist to create a minimal package",
    description = "A dummy package.", maintainer = maintainer,
    language = "en-GB"
  )
  repo <- path(path, package)
  new_files <- c(
    "_pkgdown.yml", ".gitignore", ".Rbuildignore", "checklist.yml",
    "codecov.yml", "LICENSE.md", "NEWS.md", "README.Rmd",
    path(".github", c("CODE_OF_CONDUCT.md", "CONTRIBUTING.md")),
    path(
      ".github", "workflows",
      c(
        "check_on_branch.yml", "check_on_different_r_os.yml",
        "check_on_main.yml", "release.yml"
      )
    ),
    path("pkgdown", "extra.css"),
    path(
      "man", "figures",
      c(
        "logo-en.png", "background-pattern.png", "flanders.woff2",
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
})
