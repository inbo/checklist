library(mockery)
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
  defer(unlink(path, recursive = TRUE))

  cache <- tempfile("cache")
  dir_create(cache)
  c("git:", "  protocol: ssh", "  organisation: https://github.com/inbo") |>
    writeLines(path(cache, "config.yml"))
  stub(create_package, "R_user_dir", cache, depth = 2)
  package <- "settag"
  create_package(
    path = path,
    package = package,
    keywords = "dummy",
    title = "testing the ability of checklist to create a minimal package",
    description = "A dummy package.",
    maintainer = maintainer,
    language = "en-GB"
  )
  repo <- git_init(path(path, package))
  git_config_set(name = "user.name", value = "junk", repo = repo)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = repo)
  gert::git_clone(
    url = path(path, package),
    path = path(path, "origin"),
    bare = TRUE,
    verbose = FALSE
  )
  gert::git_remote_add(name = "origin", url = path(path, "origin"), repo = repo)
  gert::git_commit(message = "Initital commit", repo = repo)
  branch_info <- git_branch_list(repo = repo)
  refspec <- branch_info$ref[branch_info$name == git_branch(repo = repo)]
  git_push(
    remote = "origin",
    refspec = refspec,
    set_upstream = TRUE,
    repo = repo
  )

  # not on GITHUB or main
  current_ref <- Sys.getenv("GITHUB_REF")
  defer(Sys.setenv(GITHUB_REF = current_ref))
  Sys.setenv(GITHUB_REF = "")
  current_actions <- Sys.getenv("GITHUB_ACTIONS")
  defer(Sys.setenv(GITHUB_ACTIONS = current_actions))
  Sys.setenv(GITHUB_ACTIONS = "")
  current_event <- Sys.getenv("GITHUB_EVENT_NAME")
  defer(Sys.setenv(GITHUB_EVENT_NAME = current_event))
  Sys.setenv(GITHUB_EVENT_NAME = "")
  expect_message(
    set_tag(path(path, package)),
    "Not on GitHub, not a push or not on main or master."
  )

  Sys.setenv(GITHUB_REF = "refs/heads/junk")
  expect_message(
    set_tag(path(path, package)),
    "Not on GitHub, not a push or not on main or master."
  )

  # on master, not GitHub
  Sys.setenv(
    GITHUB_REF = "refs/heads/master"
  )
  expect_message(
    set_tag(path(path, package)),
    "Not on GitHub, not a push or not on main or master."
  )
  Sys.setenv(GITHUB_REF = "refs/heads/main")
  expect_message(
    set_tag(path(path, package)),
    "Not on GitHub, not a push or not on main or master."
  )

  # on master, GitHub, not push
  Sys.setenv(GITHUB_ACTIONS = "true")
  expect_message(
    set_tag(path(path, package)),
    "Not on GitHub, not a push or not on main or master."
  )
  Sys.setenv(
    GITHUB_REF = "refs/heads/master"
  )
  expect_message(
    set_tag(path(path, package)),
    "Not on GitHub, not a push or not on main or master."
  )

  # on master, GitHub, push
  Sys.setenv(GITHUB_EVENT_NAME = "push")
  expect_invisible(set_tag(path(path, package)))
  Sys.setenv(GITHUB_REF = "refs/heads/main")
  expect_message(set_tag(path(path, package)), "tag.*already exists")
})
