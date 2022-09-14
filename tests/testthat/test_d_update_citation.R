test_that("update_citation() works", {
  maintainer <- person(
    given = "Thierry", family = "Onkelinx", role = c("aut", "cre"),
    email = "thierry.onkelinx@inbo.be"
  )
  path <- tempfile("citation")
  dir.create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)
  package <- "citation"
  create_package(
    path = path, package = package,
    title = "testing the ability of checklist to create a minimal package",
    description = "A dummy package.", maintainer = maintainer,
    language = "en-GB"
  )

  expect_is({
    x <- update_citation(file.path(path, package))
  },
  "checklist"
  )
  expect_identical(x$get_roles, c("aut", "cre"))

  expect_is({
    x <- update_citation(file.path(path, package), roles = c("aut"))
  },
    "checklist"
  )
  expect_identical(x$get_roles, c("aut"))

  old_citation <- readLines(file.path(path, package, "inst", "CITATION"))
  writeLines(
    old_citation[!grepl("^# .* checklist entry", old_citation)],
    file.path(path, package, "inst", "CITATION")
  )
  expect_is({
    x <- update_citation(file.path(path, package))
  },
    "checklist"
  )
  expect_identical(
    x$.__enclos_env__$private$warnings,
    c(
      paste(
        "No `# begin checklist entry` found in `inst", "CITATION`", sep = "/"
      ),
      paste(
        "No `# end checklist entry` found in `inst", "CITATION`", sep = "/"
      )
    )
  )
  writeLines(old_citation, file.path(path, package, "inst", "CITATION"))

  this_description <- desc(file.path(path, package))
  this_description$add_urls("https://doi.org/10.5281/zenodo.4028303")
  this_description$del_author("Research Institute for Nature and Forest")
  this_description$add_author(given = "unit", family = "test", role = "ctb")
  this_description$add_author(given = "test", family = "unit", role = "cph")
  this_description$write(file.path(path, package))
  file.remove(file.path(path, package, ".Rbuildignore"))
  expect_is(update_citation(file.path(path, package)), "checklist")
})
