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
  hide_output <- tempfile(fileext = ".txt")
  defer(file_delete(hide_output))
  sink(hide_output)
  suppressMessages(create_package(path = path, package = package))
  sink()

  hide_output2 <- tempfile(fileext = ".txt")
  defer(file_delete(hide_output2))
  sink(hide_output2)
  expect_output(x <- update_citation(path(path, package)))
  sink()
  expect_is(x, "checklist")

  path(path, package, "inst", "CITATION") |>
    readLines() -> old_citation
  writeLines(
    old_citation[!grepl("^# .* checklist entry", old_citation)],
    path(path, package, "inst", "CITATION")
  )
  expect_is(
    {
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

test_that("update_citation() works on a quarto document", {
  path <- tempfile("citation_quarto")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))
  checklist$new(x = path, package = FALSE, language = "en-GB") |>
    write_checklist()
  hide_output3 <- tempfile(fileext = ".txt")
  defer(file_delete(hide_output3))
  sink(hide_output3)
  expect_warning(z <- update_citation(path))
  sink()
  expect_match(z$.__enclos_env__$private$errors$CITATION, "README.md not found")
  c(
    "lang: en-GB",
    "book:",
    "  title: Title for the example website",
    "  subtitle: The optional subtitle",
    "  shorttitle: short-title",
    "  publication_date: 2024-12-31",
    "  embargo: 2025-12-31",
    "  author:",
    "  - name:",
    "      given: Given",
    "      family: Test",
    "    email: given.family@vlaanderen.be",
    "    corresponding: true",
    "    orcid: 0000-0002-1825-0097",
    "    affiliation:",
    "      - Government of Flanders",
    "  - name:",
    "      given: Second",
    "      family: Author",
    "    email: second.author@vlaanderen.be",
    "    orcid: 0000-0002-1825-0097",
    "    affiliation:",
    "      - Government of Flanders",
    "  reviewer:",
    "    - name:",
    "        given: First",
    "        family: Reviewer",
    "      email: reviewer@vlaanderen.be",
    "      orcid: 0000-0002-1825-0097",
    "      affiliation:",
    "        - Government of Flanders",
    "  rightsholder:",
    "  - name:",
    "      given: Government of Flanders",
    "    email: info@vlaanderen.be",
    "  funder:",
    "  - name:",
    "      given: Government of Flanders",
    "    email: info@vlaanderen.be",
    "  year: 9999",
    "  reportnr: 3.14",
    "  ordernr: optional order number",
    "  depotnr: optional depot number",
    "  publisher: Government of Flanders",
    "  publication_type: publication-report",
    "  keywords: [example, citation, quarto]",
    "  community: inbo"
  ) |>
    writeLines(path(path, "_quarto.yml"))
  hide_output4 <- tempfile(fileext = ".txt")
  defer(file_delete(hide_output4))
  sink(hide_output4)
  expect_warning(z <- update_citation(path))
  sink()

  path(path, "_quarto.yml") |>
    readLines() |>
    c("  license: CC-BY-4.0") |>
    writeLines(path(path, "_quarto.yml"))
  hide_output5 <- tempfile(fileext = ".txt")
  defer(file_delete(hide_output5))
  sink(hide_output5)
  expect_warning(z <- update_citation(path))
  sink()
  c(
    "<!-- description: start -->",
    "This is the description",
    "<!-- description: end -->"
  ) |>
    writeLines(path(path, "index.md"))
  org_list$new(
    org_item$new(
      name = c(`en-GB` = "Government of Flanders"),
      email = "info@vlaanderen.be"
    )
  )$write(path)
  expect_false(file_exists(path(path, ".zenodo.json")))
  expect_output(z <- update_citation(path))
  expect_true(file_exists(path(path, ".zenodo.json")))
})
