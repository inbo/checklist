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
  repo <- repository(file.path(path, package))
  git2r::config(repo = repo, user.name = "junk", user.email = "junk@inbo.be")
  git2r::commit(repo, "initial commit")

  this_desc <- description$new(
    file = file.path(path, package, "DESCRIPTION")
  )
  this_desc$add_remotes("inbo/INBOmd")
  this_desc$write()
  add(repo, "DESCRIPTION")
  git2r::commit(repo, "add remotes")
  expect_is(x <- check_description(file.path(path, package)), "Checklist")
  expect_identical(
    x$.__enclos_env__$private$errors$DESCRIPTION,
    c(
      "Package version not updated",
      "DESCRIPTION not tidy. Use `checklist::tidy_desc()`"
    )
  )
  git2r::clone(
    url = file.path(path, package),
    local_path = file.path(path, "origin"),
    bare = TRUE, progress = FALSE
  )
  git2r::remote_add(repo, name = "origin", url = file.path(path, "origin"))
  git2r::fetch(repo, "origin", verbose = FALSE)
  git2r::branch_create(git2r::last_commit(repo), name = "junk")
  git2r::checkout(repo, "junk")
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
