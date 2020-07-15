test_that("set_tag() works", {
  # prepare first commit
  maintainer <- person(
    given = "Thierry",
    family = "Onkelinx",
    role = c("aut", "cre"),
    email = "thierry.onkelinx@inbo.be",
    comment = c(ORCID = "0000-0001-8804-4216")
  )
  path <- tempfile("test_package")
  package <- "junk"
  dir.create(path)
  create_package(
    path = path,
    package = package,
    title = "testing the ability of checklist to create a minimal package",
    description = "A dummy package.",
    maintainer = maintainer
  )
  repo <- git2r::repository(file.path(path, package))
  git2r::config(repo = repo, user.name = "junk", user.email = "junk@inbo.be")
  git2r::clone(
    url = file.path(path, package),
    local_path = file.path(path, "origin"),
    bare = TRUE
  )
  git2r::remote_add(repo, name = "origin", url = file.path(path, "origin"))
  git2r::commit(repo = repo, message = "Initital commit")
  git2r::push(
    repo, name = "origin", refspec = "refs/heads/master", set_upstream = TRUE
  )

  # not on GITHUB or master
  current_env <- Sys.getenv("GITHUB_REF")
  on.exit(Sys.setenv(GITHUB_REF = current_env))
  Sys.setenv(GITHUB_REF = "")
  expect_message(
    set_tag(file.path(path, package)),
    "Not on GitHub or not on master."
  )
  Sys.setenv(GITHUB_REF = "refs/heads/junk")
  expect_message(
    set_tag(file.path(path, package)),
    "Not on GitHub or not on master."
  )

  # on master
  Sys.setenv(GITHUB_REF = "refs/heads/master")
  expect_invisible(set_tag(file.path(path, package)))

  unlink(path, recursive = TRUE)
})
