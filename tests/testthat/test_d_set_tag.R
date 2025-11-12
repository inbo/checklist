library(mockery)
test_that("set_tag() works", {
  # prepare first commit
  stub(org_list_from_url, "R_user_dir", mock_r_user_dir(config_dir))
  org <- org_list_from_url("https://gitlab.com/thierryo/checklist.git")

  path <- tempfile("settag")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))

  package <- "settag"
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

  repo <- git_init(path(path, package))
  git_config_set(name = "user.name", value = "junk", repo = repo)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = repo)
  gert::git_clone(
    url = path(path, package),
    path = path(path, "origin"),
    bare = TRUE,
    verbose = FALSE
  )
  gert::git_remote_remove("origin", repo = repo)
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
  current_actions <- Sys.getenv("GITHUB_ACTIONS", "false")
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
