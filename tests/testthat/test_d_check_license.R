test_that("check_license() works", {
  maintainer <- person(
    given = "Thierry",
    family = "Onkelinx",
    role = c("aut", "cre"),
    email = "thierry.onkelinx@inbo.be",
    comment = c(ORCID = "0000-0001-8804-4216")
  )
  change_cph <- function(cph = "test escape characters ().[]") {
    descr <- readLines(path(repo, "DESCRIPTION"))
    cph_line <- grep("cph", descr, value = FALSE)
    new_cph <- paste0(
      "    person(\"", cph,
      "\", , , \"info@inbo.be\", role = c(\"cph\", \"fnd\"))"
      )
    descr[cph_line] <- new_cph
    writeLines(descr, path(repo, "DESCRIPTION"))
    license <- readLines(path(repo, "LICENSE"))
    license[2] <- paste0("COPYRIGHT HOLDER: ", cph)
    writeLines(license, path(repo, "LICENSE"))
    license_md <- readLines(path(repo, "LICENSE.md"))
    license_md[3] <- paste0("Copyright (c) ", format(Sys.Date(), "%Y"),
                         " ", cph)
    writeLines(license_md, path(repo, "LICENSE.md"))
  }
  path <- tempfile("check_license")
  dir.create(path)
  oldwd <- setwd(path)
  on.exit(setwd(oldwd), add = TRUE)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  package <- "checklicense"
  suppressMessages(
    create_package(
      path = path, package = package, keywords = "dummy", communities = "inbo",
      title = "testing the ability of checklist to create a minimal package",
      description = "A dummy package.", maintainer = maintainer, license = "MIT"
    )
  )
  repo <- path(path, package)
  git_config_set(name = "user.name", value = "junk", repo = repo)
  git_config_set(name = "user.email", value = "junk@inbo.be", repo = repo)
  gert::git_commit("initial commit", repo = repo)

  mit <- readLines(path(repo, "LICENSE.md"))
  expect_identical(
    mit[3],
    paste0("Copyright (c) ", format(Sys.Date(), "%Y"),
           " Research Institute for Nature and Forest (INBO)")
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
  mit[3] <- paste0("Copyright (c) ", format(Sys.Date(), "%Y"),
                   " INBO")
  writeLines(mit, path(repo, "LICENSE.md"))
  expect_is(x <- check_license(repo), "checklist")
  expect_identical(
    x$.__enclos_env__$private$errors$license,
    c("Copyright holder in LICENSE.md doesn't match the one in DESCRIPTION",
      "Copyright statement in LICENSE.md not in correct format"))

  # test all escape characters in copyright holder
  change_cph()
  x <- check_license(repo)
  expect_identical(
    x$.__enclos_env__$private$errors$license,
    character(0)
  )

  file_delete(path(repo, "LICENSE.md"))
  expect_is(x <- check_license(repo), "checklist")
  expect_identical(
    x$.__enclos_env__$private$errors$license,
    "No LICENSE.md file"
  )
})
