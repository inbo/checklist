library(mockery)
test_that("check_license() works", {
  stub(org_list_from_url, "R_user_dir", mock_r_user_dir(config_dir))
  org <- org_list_from_url("https://gitlab.com/thierryo/checklist.git")

  path <- tempfile("check_license")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))

  package <- "checklicense"
  stub(create_package, "R_user_dir", mock_r_user_dir(config_dir), depth = 2)
  stub(create_package, "preferred_protocol", "git@gitlab.com:thierryo/%s.git")
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
  x <- check_license(repo, org = org)
  expect_identical(
    x$.__enclos_env__$private$errors$license,
    character(0)
  )

  # copyright holder mismatch
  mit[3] <- paste0("Copyright (c) ", format(Sys.Date(), "%Y"), " INBO")
  writeLines(mit, path(repo, "LICENSE.md"))
  expect_is(x <- check_license(repo, org = org), "checklist")
  expect_identical(
    x$.__enclos_env__$private$errors$license,
    c(
      "Copyright holder in LICENSE.md doesn't match the one in DESCRIPTION",
      "Copyright statement in LICENSE.md not in correct format"
    )
  )

  file_delete(path(repo, "LICENSE.md"))
  expect_is(x <- check_license(repo, org = org), "checklist")
  expect_identical(
    x$.__enclos_env__$private$errors$license,
    "No LICENSE.md file"
  )
})
