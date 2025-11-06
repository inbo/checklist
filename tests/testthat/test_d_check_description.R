library(mockery)
test_that("check_description() works", {
  cache <- tempfile("cache")
  dir_create(file.path(cache, "data"))
  defer(unlink(cache, recursive = TRUE))
  stub(new_author, "readline", mock("John", "Doe", "john@doe.com", ""))
  stub(new_author, "ask_orcid", mock(""))
  expect_output(new_author(
    current = data.frame(),
    root = file.path(cache, "data"),
    org = org_list$new()$read()
  ))

  mock_r_user_dir <- function(alt_dir) {
    function(package, which = c("data", "config", "cache")) {
      which <- match.arg(which)
      return(file.path(alt_dir, which))
    }
  }

  git_init(cache)
  git_remote_add(
    "https://gitlab.com/thierryo/checklist_dummy.git",
    repo = cache
  )
  stub(get_default_org_list, "R_user_dir", mock_r_user_dir(cache), depth = 2)
  org <- get_default_org_list(cache)
  c("git:", "  protocol: ssh", "  organisation: https://gitlab.com/thierryo") |>
    writeLines(path(cache, "config.yml"))

  path <- tempfile("check_description")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))

  package <- "checkdescription"
  stub(create_package, "R_user_dir", mock_r_user_dir(cache), depth = 2)
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
  git_config_set(name = "user.name", value = "junk", repo = repo)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = repo)
  gert::git_commit("initial commit", repo = repo)

  path(path, package, "DESCRIPTION") |>
    desc::description$new() -> this_desc
  this_desc$add_remotes("inbo/INBOmd")
  this_desc$write()
  git_add(files = "DESCRIPTION", repo = repo)
  gert::git_commit(message = "add remotes", repo = repo)
  expect_is(x <- check_description(repo), "checklist")
  expect_identical(
    x$.__enclos_env__$private$errors$DESCRIPTION,
    c(
      "Package version not updated",
      "DESCRIPTION not tidy. Use `checklist::tidy_desc()`"
    )
  )

  # upgrade to dev version number
  desc::desc_bump_version(which = "dev", file = repo)
  git_add(files = "DESCRIPTION", repo = repo)
  gert::git_commit(message = "bump dev version", repo = repo)
  expect_is(x <- check_description(repo), "checklist")
  expect_identical(
    x$.__enclos_env__$private$errors$DESCRIPTION,
    "Incorrect version tag format. Use `0.0` or `0.0.0`"
  )

  # upgrade to patch version number
  desc::desc_bump_version(which = "patch", file = repo)
  git_add(files = "DESCRIPTION", repo = repo)
  gert::git_commit(message = "bump patch version", repo = repo)
  expect_is(x <- check_description(repo), "checklist")
  expect_identical(
    x$.__enclos_env__$private$errors$DESCRIPTION,
    character(0)
  )

  this_desc <- desc::description$new(
    file = path(path, package, "DESCRIPTION")
  )
  this_desc$del_remotes("inbo/INBOmd")
  this_desc$write()
  git_add(files = "DESCRIPTION", repo = repo)
  gert::git_commit(message = "remove remotes", repo = repo)
  expect_is(x <- check_description(repo), "checklist")
  expect_identical(
    x$.__enclos_env__$private$errors$DESCRIPTION,
    "Package version not updated"
  )

  gert::git_clone(
    url = path(path, package),
    path = path(path, "origin"),
    bare = TRUE,
    verbose = FALSE
  )
  gert::git_remote_remove(remote = "origin", repo = repo)
  gert::git_remote_add(
    url = path(path, "origin"),
    name = "origin",
    repo = repo
  )
  git_fetch(remote = "origin", repo = repo, verbose = FALSE)
  git_branch_create(branch = "junk", ref = "HEAD", checkout = TRUE, repo = repo)

  stub(check_description, "R_user_dir", mock_r_user_dir(cache), depth = 2)
  expect_is(x <- check_description(path(path, package)), "checklist")
  expect_identical(
    x$.__enclos_env__$private$errors$DESCRIPTION,
    "Package version not updated"
  )
})
