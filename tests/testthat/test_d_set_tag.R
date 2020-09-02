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
  current_ref <- Sys.getenv("GITHUB_REF")
  on.exit(Sys.setenv(GITHUB_REF = current_ref), add = TRUE)
  Sys.setenv(GITHUB_REF = "")
  current_actions <- Sys.getenv("GITHUB_ACTIONS")
  on.exit(Sys.setenv(GITHUB_ACTIONS = current_actions), add = TRUE)
  Sys.setenv(GITHUB_ACTIONS = "")
  current_event <- Sys.getenv("GITHUB_EVENT_NAME")
  on.exit(Sys.setenv(GITHUB_EVENT_NAME = current_event), add = TRUE)
  Sys.setenv(GITHUB_EVENT_NAME = "")
  expect_message(
    set_tag(file.path(path, package)),
    "Not on GitHub, not a push or not on master."
  )

  Sys.setenv(GITHUB_REF = "refs/heads/junk")
  expect_message(
    set_tag(file.path(path, package)),
    "Not on GitHub, not a push or not on master."
  )

  # on master, not GitHub
  Sys.setenv(GITHUB_REF = "refs/heads/master")
  expect_message(
    set_tag(file.path(path, package)),
    "Not on GitHub, not a push or not on master."
  )

  # on master, GitHub, not push
  Sys.setenv(GITHUB_ACTIONS = "true")
  expect_message(
    set_tag(file.path(path, package)),
    "Not on GitHub, not a push or not on master."
  )

  # on master, GitHub, not push
  Sys.setenv(GITHUB_EVENT_NAME = "push")
  expect_invisible(set_tag(file.path(path, package)))

  unlink(path, recursive = TRUE)
})
