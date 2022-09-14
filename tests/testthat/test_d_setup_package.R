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
    path = path,
    package = package,
    title = "testing the ability of checklist to create a minimal package",
    description = "A dummy package.",
    maintainer = maintainer, language = "en-GB"
  )
  repo <- file.path(path, package)
  new_files <- c(
    "_pkgdown.yml", ".gitignore", ".Rbuildignore", "checklist.yml",
    "codecov.yml", "LICENSE.md", "NEWS.md", "README.Rmd",
    file.path(".github", c("CODE_OF_CONDUCT.md", "CONTRIBUTING.md")),
    file.path(
      ".github", "workflows",
      c(
        "check_on_branch.yml", "check_on_different_r_os.yml",
        "check_on_main.yml", "release.yml"
      )
    ),
    file.path("pkgdown", "extra.css"),
    file.path(
      "man", "figures",
      c(
        "logo-en.png", "background-pattern.png", "flanders.woff2",
        "flanders.woff"
      )
    )
  )
  file.remove(file.path(path, package, new_files))
  git_add(files = new_files, repo = repo)
  git_config_set(name = "user.name", value = "junk", repo = repo)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = repo)
  gert::git_commit("initial commit", repo = repo)

  expect_message(
    setup_package(file.path(path, package)),
    "package prepared for checklist::check_package()"
  )
  expect_true(all(file.exists(file.path(path, package, new_files))))
})
