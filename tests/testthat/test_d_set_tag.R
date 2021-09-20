test_that("set_tag() works", {
  # prepare first commit
  maintainer <- person(
    given = "Thierry",
    family = "Onkelinx",
    role = c("aut", "cre"),
    email = "thierry.onkelinx@inbo.be",
    comment = c(ORCID = "0000-0001-8804-4216")
  )
  path <- tempfile("settag")
  dir.create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  gert::git_config_global_set(name = "init.defaultBranch", value = "main")

  package <- "settag"
  create_package(
    path = path,
    package = package,
    title = "testing the ability of checklist to create a minimal package",
    description = "A dummy package.",
    maintainer = maintainer
  )
  repo <- git_init(file.path(path, package))
  git_config_set(name = "user.name", value = "junk", repo = repo)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = repo)
  gert::git_clone(
    url = file.path(path, package),
    path = file.path(path, "origin"),
    bare = TRUE,
    verbose = FALSE
  )
  gert::git_remote_add(name = "origin", url = file.path(path, "origin"),
                       repo = repo)
  gert::git_commit(message = "Initital commit", repo = repo)
  git_push(remote = "origin", refspec = "refs/heads/main",
                 set_upstream = TRUE, repo = repo)

  # not on GITHUB or main
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
    "Not on GitHub, not a push or not on main or master."
  )

  Sys.setenv(GITHUB_REF = "refs/heads/junk")  # nolint
  expect_message(
    set_tag(file.path(path, package)),
    "Not on GitHub, not a push or not on main or master."
  )

  # on master, not GitHub
  Sys.setenv(GITHUB_REF = "refs/heads/master") # nolint
  expect_message(
    set_tag(file.path(path, package)),
    "Not on GitHub, not a push or not on main or master."
  )
  Sys.setenv(GITHUB_REF = "refs/heads/main") # nolint
  expect_message(
    set_tag(file.path(path, package)),
    "Not on GitHub, not a push or not on main or master."
  )

  # on master, GitHub, not push
  Sys.setenv(GITHUB_ACTIONS = "true")
  expect_message(
    set_tag(file.path(path, package)),
    "Not on GitHub, not a push or not on main or master."
  )
  Sys.setenv(GITHUB_REF = "refs/heads/master") # nolint
  expect_message(
    set_tag(file.path(path, package)),
    "Not on GitHub, not a push or not on main or master."
  )

  # on master, GitHub, push
  Sys.setenv(GITHUB_EVENT_NAME = "push")
  expect_invisible(set_tag(file.path(path, package)))
  Sys.setenv(GITHUB_REF = "refs/heads/main") # nolint
  expect_message(set_tag(file.path(path, package)), "tag.*already exists")
})
