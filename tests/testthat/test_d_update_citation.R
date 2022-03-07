test_that("update_citation() works", {
  maintainer <- person(
    given = "Thierry",
    family = "Onkelinx",
    role = c("aut", "cre"),
    email = "thierry.onkelinx@inbo.be",
    comment = c(ORCID = "0000-0001-8804-4216")
  )
  path <- tempfile("citation")
  dir.create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)
  package <- "citation"
  create_package(
    path = path,
    package = package,
    title = "testing the ability of checklist to create a minimal package",
    description = "A dummy package.",
    maintainer = maintainer, language = "eng"
  )

  expect_is({
    x <- update_citation(file.path(path, package))
  },
  "Checklist"
  )
  expect_identical(x$get_roles, c("aut", "cre"))

  expect_is({
    x <- update_citation(file.path(path, package), roles = c("aut"))
  },
    "Checklist"
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
    "Checklist"
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
})
