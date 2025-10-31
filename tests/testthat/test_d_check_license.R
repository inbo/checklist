library(mockery)
test_that("check_license() works", {
  cache <- tempfile("cache")
  dir_create(file.path(cache, "data"))
  defer(unlink(cache, recursive = TRUE))
  stub(new_author, "readline", mock("John", "Doe", "john@doe.com", ""))
  stub(new_author, "ask_orcid", mock(""))
  new_author(
    current = data.frame(),
    root = file.path(cache, "data"),
    org = org_list$new()$read()
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

  path <- tempfile("check_license")
  dir.create(path)
  oldwd <- setwd(path)
  defer(setwd(oldwd))
  defer(unlink(path, recursive = TRUE))

  package <- "checklicense"
  stub(create_package, "R_user_dir", mock_r_user_dir(cache), depth = 2)
  stub(create_package, "preferred_protocol", "git@github.com:inbo/%s.git")
  stub(
    create_package,
    "readline",
    mock("This is the title", "This is the description.")
  )
  stub(create_package, "ask_keywords", c("key", "word"))
  stub(create_package, "ask_language", "en-GB")
  stub(create_package, "ask_license", "MIT")
  hide_output <- tempfile(fileext = ".txt")
  defer(file_delete(hide_output))
  sink(hide_output)
  suppressMessages(create_package(path = path, package = package))
  sink()
  repo <- path(path, package)
  git_config_set(name = "user.name", value = "junk", repo = repo)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = repo)
  gert::git_commit("initial commit", repo = repo)

  org <- org_list$new()$read(repo)
  mit <- readLines(path(repo, "LICENSE.md"))
  expect_identical(
    mit[3],
    sprintf(
      "Copyright (c) %s %s",
      format(Sys.Date(), "%Y"),
      org$get_person(org$which_rightsholder$required, lang = "en-GB")$given
    )
  )
  expect_identical(
    file.exists(path(repo, "LICENSE")),
    TRUE
  )
  x <- check_license(repo)
  expect_identical(
    x$.__enclos_env__$private$errors$license,
    character(0)
  )

  # copyright holder mismatch
  mit[3] <- paste0("Copyright (c) ", format(Sys.Date(), "%Y"), " INBO")
  writeLines(mit, path(repo, "LICENSE.md"))
  expect_is(x <- check_license(repo), "checklist")
  expect_identical(
    x$.__enclos_env__$private$errors$license,
    c(
      "Copyright holder in LICENSE.md doesn't match the one in DESCRIPTION",
      "Copyright statement in LICENSE.md not in correct format"
    )
  )

  file_delete(path(repo, "LICENSE.md"))
  expect_is(x <- check_license(repo), "checklist")
  expect_identical(
    x$.__enclos_env__$private$errors$license,
    "No LICENSE.md file"
  )
})
