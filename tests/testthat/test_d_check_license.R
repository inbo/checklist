library(mockery)
test_that("check_license() works", {
  maintainer <- person(
    given = "Thierry",
    family = "Onkelinx",
    role = c("aut", "cre"),
    email = "thierry.onkelinx@inbo.be",
    comment = c(ORCID = "0000-0001-8804-4216")
  )
  path <- tempfile("check_license")
  dir.create(path)
  oldwd <- setwd(path)
  defer(setwd(oldwd))
  defer(unlink(path, recursive = TRUE))

  cache <- tempfile("cache")
  dir_create(cache)
  c("git:", "  protocol: ssh", "  organisation: https://github.com/inbo") |>
    writeLines(path(cache, "config.yml"))
  stub(create_package, "R_user_dir", cache, depth = 2)
  package <- "checklicense"
  suppressMessages(
    create_package(
      path = path,
      package = package,
      keywords = "dummy",
      title = "testing the ability of checklist to create a minimal package",
      description = "A dummy package.",
      maintainer = maintainer,
      license = "MIT"
    )
  )
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
