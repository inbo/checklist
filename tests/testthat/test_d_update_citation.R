library(mockery)
test_that("update_citation() works", {
  stub(org_list_from_url, "R_user_dir", mock_r_user_dir(config_dir))
  org <- org_list_from_url("https://gitlab.com/thierryo/checklist.git")

  path <- tempfile("citation")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))
  package <- "citation"
  stub(create_package, "R_user_dir", mock_r_user_dir(config_dir), depth = 2)
  stub(create_package, "preferred_protocol", "git@gitlab.com:thierryo/%s.git")
  stub(
    create_package,
    "readline",
    mock("This is the title", "This is the description.")
  )
  stub(create_package, "ask_keywords", c("key", "word"))
  stub(create_package, "ask_language", "en-GB")
  stub(
    create_package,
    "package_maintainer",
    list(
      authors = c(
        person(
          given = "Given",
          family = "Test",
          email = "given.test@vlaanderen.be",
          comment = c(
            ORCID = "0000-0002-1825-0097",
            affiliation = "Vlaamse overheid"
          ),
          role = c("aut", "cre")
        ),
        person(
          given = "The checklist organisation",
          email = "info@organisation.checklist",
          role = c("cph", "fnd")
        )
      ),
      org = org
    )
  )
  hide_output <- tempfile(fileext = ".txt")
  defer(file_delete(hide_output))
  sink(hide_output)
  suppressMessages(create_package(path = path, package = package))
  sink()

  hide_output2 <- tempfile(fileext = ".txt")
  defer(file_delete(hide_output2))
  sink(hide_output2)
  expect_output(x <- suppressWarnings(update_citation(path(path, package))))
  sink()
  expect_is(x, "checklist")

  path(path, package, "inst", "CITATION") |> readLines() -> old_citation
  writeLines(
    old_citation[!grepl("^# .* citeme entry", old_citation)],
    path(path, package, "inst", "CITATION")
  )
  expect_is(
    {
      x <- suppressWarnings(update_citation(path(path, package), quiet = TRUE))
    },
    "checklist"
  )
  expect_named(x$.__enclos_env__$private$errors, "CITATION")
  expect_match(
    paste(x$.__enclos_env__$private$errors$CITATION, collapse = " "),
    "No `# begin citeme entry` found in `inst/CITATION`"
  )
  expect_match(
    paste(x$.__enclos_env__$private$errors$CITATION, collapse = " "),
    "No `# end citeme entry` found in `inst/CITATION`"
  )
  writeLines(old_citation, path(path, package, "inst", "CITATION"))

  org <- org_list$new()$read(path(path, package))

  this_description <- desc(path(path, package))
  this_description$add_urls("https://doi.org/10.5281/zenodo.4028303")
  rightsholder <- this_description$get_author(role = "cph")
  this_description$del_author(email = rightsholder$email)
  expect_equal(length(this_description$get_authors()), 1)
  this_description$write(path(path, package))
  expect_warning(
    z <- update_citation(path(path, package), quiet = TRUE),
    "Citation files not updated"
  )
  expect_equal(
    z$.__enclos_env__$private$errors$CITATION,
    c("no rightsholder listed", "no funder listed")
  )
  this_description$add_author(given = "unit", family = "test", role = "ctb")
  this_description$add_author(given = "test", family = "unit", role = "cph")
  this_description$write(path(path, package))
  file_delete(path(path, package, ".Rbuildignore"))
  expect_warning(
    z <- update_citation(path(path, package), quiet = TRUE),
    "Citation files not updated"
  )
  expect_equal(
    z$.__enclos_env__$private$errors$CITATION,
    c("all `rightsholder` without email", "no funder listed")
  )

  this_description$del_author(given = "test", family = "unit", role = "cph")
  this_description$add_author(
    given = "test",
    email = "info@test.be",
    role = "cph"
  )
  this_description$write(path(path, package))
  expect_warning(
    z <- update_citation(path(path, package), quiet = TRUE),
    "Citation files not updated"
  )
  expect_equal(
    z$.__enclos_env__$private$errors$CITATION,
    c(
      "`rightsholder` without matching email in `organisation.yml`",
      "no funder listed"
    )
  )
})
