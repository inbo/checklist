test_that("check_description() works", {
  maintainer <- person(
    given = "Thierry",
    family = "Onkelinx",
    role = c("aut", "cre"),
    email = "thierry.onkelinx@inbo.be",
    comment = c(ORCID = "0000-0001-8804-4216")
  )
  path <- tempfile("check_description")
  dir.create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  package <- "checkdescription"
  suppressMessages(
    create_package(
      path = path,
      package = package,
      title = "testing the ability of checklist to create a minimal package",
      description = "A dummy package.",
      maintainer = maintainer
    )
  )
  repo <- file.path(path, package)
  git_config_set(name = "user.name", value = "junk", repo = repo)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = repo)
  gert::git_commit("initial commit", repo = repo)

  this_desc <- desc::description$new(
    file = file.path(path, package, "DESCRIPTION")
  )
  this_desc$add_remotes("inbo/INBOmd")
  this_desc$write()
  git_add(files = "DESCRIPTION", repo = repo)
  gert::git_commit(message = "add remotes", repo = repo)
  expect_is(x <- check_description(repo), "Checklist")
  expect_identical(
    x$.__enclos_env__$private$errors$DESCRIPTION,
    c(
      "Package version not updated",
      "DESCRIPTION not tidy. Use `checklist::tidy_desc()`"
    )
  )
  gert::git_clone(
    url = file.path(path, package),
    path = file.path(path, "origin"),
    bare = TRUE, verbose = FALSE
  )
  gert::git_remote_add(url = file.path(path, "origin"),
                       name = "origin", repo = repo)
  git_fetch(remote = "origin", repo = repo, verbose = FALSE)
  git_branch_create(branch = "junk",
                          ref = "HEAD",
                          checkout = TRUE,
                          repo = repo)

  expect_is(x <- check_description(file.path(path, package)), "Checklist")
  expect_identical(
    x$.__enclos_env__$private$errors$DESCRIPTION, "Package version not updated"
  )

  file.remove(file.path(path, package, "LICENSE.md"))
  expect_is(x <- check_license(file.path(path, package)), "Checklist")
  expect_identical(
    x$.__enclos_env__$private$errors$license,
    "No LICENSE.md file"
  )
})
