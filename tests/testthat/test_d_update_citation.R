test_that("update_citation() works", {
  maintainer <- person(
    given = "Thierry", family = "Onkelinx", role = c("aut", "cre"),
    email = "thierry.onkelinx@inbo.be",
    comment = c(
      ORCID = "0000-0001-8804-4216",
      affiliation = "Research Institute for Nature and Forest (INBO)"
    )
  )
  path <- tempfile("citation")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))
  package <- "citation"
  create_package(
    path = path, package = package, keywords = "dummy", communities = "inbo",
    title = "testing the ability of checklist to create a minimal package",
    description = "A dummy package.", maintainer = maintainer,
    language = "en-GB"
  )

  hide_output <- tempfile(fileext = ".txt")
  defer(file_delete(hide_output))
  sink(hide_output)
  expect_output(x <- update_citation(path(path, package)))
  sink()
  expect_is(x, "checklist")

  path(path, package, "inst", "CITATION") |>
    readLines() -> old_citation
  writeLines(
    old_citation[!grepl("^# .* checklist entry", old_citation)],
    path(path, package, "inst", "CITATION")
  )
  expect_is({
    x <- update_citation(path(path, package), quiet = TRUE)
  },
  "checklist"
  )
  expect_named(x$.__enclos_env__$private$errors, "CITATION")
  expect_match(
    paste(x$.__enclos_env__$private$errors$CITATION, collapse = " "),
    "No `# begin checklist entry` found in `inst/CITATION`"
  )
  expect_match(
    paste(x$.__enclos_env__$private$errors$CITATION, collapse = " "),
    "No `# end checklist entry` found in `inst/CITATION`"
  )
  writeLines(old_citation, path(path, package, "inst", "CITATION"))

  org <- organisation$new()

  this_description <- desc(path(path, package))
  this_description$add_urls("https://doi.org/10.5281/zenodo.4028303")
  gsub("([\\(\\)])", "\\\\\\1", org$get_rightsholder) |>
    this_description$del_author()
  expect_equal(length(this_description$get_authors()), 1)
  this_description$write(path(path, package))
  expect_is(
    z <- update_citation(path(path, package), quiet = TRUE), "checklist"
  )
  expect_equal(
    z$.__enclos_env__$private$notes,
    c("no rightsholder listed", "no funder listed")
  )
  this_description$add_author(given = "unit", family = "test", role = "ctb")
  this_description$add_author(given = "test", family = "unit", role = "cph")
  this_description$write(path(path, package))
  file_delete(path(path, package, ".Rbuildignore"))
  expect_is(
    z <- update_citation(path(path, package), quiet = TRUE), "checklist"
  )
  expect_equal(
    z$.__enclos_env__$private$notes,
    c(
      "no funder listed",
      sprintf("rightsholder differs from `%s`", org$get_rightsholder)
    )
  )
  new_org <- organisation$new(
    email = NA_character_, funder = NA_character_, rightsholder = "test"
  )
  write_organisation(new_org, path(path, package))
  expect_is(
    z <- update_citation(path(path, package), quiet = TRUE), "checklist"
  )
  expect_length(z$.__enclos_env__$private$notes, 0)
})
