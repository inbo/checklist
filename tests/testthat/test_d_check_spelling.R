library(mockery)
test_that("check_spelling() on a package", {
  old_option <- getOption("checklist.rstudio_source_markers", TRUE)
  options("checklist.rstudio_source_markers" = FALSE)
  on.exit(options("checklist.rstudio_source_markers" = old_option), add = TRUE)
  maintainer <- person(
    given = "Thierry", family = "Onkelinx", role = c("aut", "cre"),
    email = "thierry.onkelinx@inbo.be",
    comment = c(ORCID = "0000-0001-8804-4216")
  )
  path <- tempfile("check_spelling")
  dir_create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  package <- "spelling"
  suppressMessages(
    create_package(
      path = path, package = package, maintainer = maintainer,
      title = "testing the ability of checklist to create a minimal package",
      description = "A dummy package.", language = "en-GB", keywords = "dummy",
      communities = "inbo",
    )
  )
  expect_is({
    z <- check_spelling(path(path, package))
  },
    "checklist"
  )
  expect_identical(nrow(z$get_spelling), 0L)
  expect_invisible(print(z$get_spelling))

  writeLines(
    c(
      "#' Een voorbeeldfunctie", "#' @param x het enige argument",
      "#' @examples", "#' print(1)",
      "#' @export", "dummy <- function(x) {", "  return(x)", "}"
    ),
    path(path, package, "R", "dummy.R")
  )
  suppressMessages(document(path(path, package), quiet = TRUE))
  writeLines(
    c(
      readLines(path(path, package, "README.Rmd")),
      "<!-- spell-check: ignore:start -->", "<!-- spell-check: ignore:end -->",
      "<script>", "</script>", "\\"
    ),
    path(path, package, "README.Rmd")
  )
  writeLines(
    c("junk <- function(x) {", "  return(x)", "}"),
    path(path, package, "R", "junk.R")
  )
  writeLines(
    c(
      "\\name{test}", "\\alias{test}", "\\title{Test function}",
      "\\usage{test(x = 1)}", "\\arguments{\\item{x}{argument.}}",
      "\\value{TRUE}", "\\description{Some words}"
    ),
    path(path, package, "man", "test.Rd")
  )
  expect_is(
    {z <- check_spelling(path(path, package), quiet = TRUE)},
    "checklist"
  )
  expect_is(z$get_spelling, "checklist_spelling")
  expect_identical(nrow(z$get_spelling), 4L)
  expect_output(print(z$get_spelling), "Overview of words")
  expect_invisible(custom_dictionary(z))
  expect_is(
    {z <- check_spelling(path(path, package))},
    "checklist"
  )
  expect_identical(nrow(z$get_spelling), 0L)
  expect_invisible(print(z$get_spelling))

  x <- read_checklist(path(path, package))
  expect_is(x$set_default("en-GB"), "checklist")
  expect_is(
    {z <- x$set_other(list("nl-BE" = "man"))},
    "checklist"
  )
  expect_is(
    {z <- x$get_rd},
    "checklist_language"
  )
  hide_output <- tempfile(fileext = ".txt")
  on.exit(file_delete(hide_output), add = TRUE, after = TRUE)
  sink(hide_output)
  expect_invisible(print(z, hide_ignore = TRUE))
  sink()

  expect_is(
    {z <- spelling_check(text = "", filename = NULL, wordlist = NULL)},
    "checklist_spelling"
  )
  expect_identical(nrow(z), 0L)
  expect_false(install_dictionary("junk"))
  expect_true(install_dutch("nl-BE"))
  expect_true(install_french("fr-FR"))
  expect_true(install_german("de-DE"))

  stub(change_language_interactive, "menu", 1, 2)
  expect_is(
    {
      hide_output2 <- tempfile(fileext = ".txt")
      on.exit(file_delete(hide_output2), add = TRUE, after = TRUE)
      sink(hide_output2)
      z <- x$set_exceptions()
      sink()
      z
    },
    "checklist"
  )
})

test_that("check_spelling() on a project", {
  path <- tempfile("check_spelling")
  dir_create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  system.file("DESCRIPTION", package = "checklist") |>
    dirname() |>
    store_authors()
  stub(create_project, "readline", "test")
  expect_invisible(
    {
      hide_create <- tempfile(fileext = ".txt")
      on.exit(file_delete(hide_create), add = TRUE, after = TRUE)
      sink(hide_create)
      z <- create_project(path, "spelling")
      sink()
    }
  )

  expect_is(
    check_project(path(path, "spelling"), fail = FALSE, quiet = TRUE),
    "checklist"
  )
  hide_author <- tempfile(fileext = ".txt")
  on.exit(file_delete(hide_author), add = TRUE, after = TRUE)
  sink(hide_author)
  aut <- use_author()
  c(aut$given, aut$family) |>
    strsplit(" ") |>
    unlist() |>
    unique() |>
    add_words(path(path, "spelling", "inst", "en_gb"))
  sink()
  expect_is(check_project(path(path, "spelling"), quiet = TRUE), "checklist")

  x <- read_checklist(path)
  stub(change_language_interactive, "menu", 3)
  stub(change_language_interactive2, "menu", 1, 2)
  expect_is(
    {
      hide_output <- tempfile(fileext = ".txt")
      on.exit(file_delete(hide_output), add = TRUE, after = TRUE)
      sink(hide_output)
      z <- change_language_interactive(
        data.frame(language = "en-GB", path = "a.Rmd")
      )
      sink()
      z
    },
    "list"
  )

  stub(change_language_interactive2, "menu", 2)
  expect_is(
    {
      hide_output2 <- tempfile(fileext = ".txt")
      on.exit(file_delete(hide_output2), add = TRUE, after = TRUE)
      sink(hide_output2)
      z <- change_language_interactive2(
        data.frame(language = "en-GB", path = "a.Rmd"), main = "en-GB",
        other_lang = character(0)
      )
      sink()
      z
    },
    "list"
  )

  stub(change_language_interactive2, "menu", 3)
  expect_is(
    {
      hide_output3 <- tempfile(fileext = ".txt")
      on.exit(file_delete(hide_output3), add = TRUE, after = TRUE)
      sink(hide_output3)
      z <- change_language_interactive2(
        data.frame(language = "en-GB", path = path("a", c("a.Rmd", "b.Rmd"))),
        main = "en-GB", other_lang = character(0)
      )
      sink()
      z
    },
    "list"
  )
})

test_that("check_spelling() works on a quarto project", {
  path <- tempfile("quarto")
  dir_create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)
  dir_create(path, "source")
  writeLines(
    c("project:", "  type: book"),
    path(path, "source", "_quarto.yml")
  )
  expect_identical(
    list_quarto_md(path(path, "source", "_quarto.yml"), root = path),
    list(data.frame(quarto_lang = character(0), path = character(0)))
  )
  writeLines("lang: en-GB", path(path, "source", "_quarto.yml"))
  expect_warning(
    {z <- list_quarto_md(path(path, "source", "_quarto.yml"), root = path)},
    "contact the maintainer"
  )
  expect_identical(
    z,
    list(data.frame(quarto_lang = character(0), path = character(0)))
  )
  writeLines(
    c(
      "project:", "  type: book", "lang: en-GB", "book:", "  chapters:",
      "    - language.qmd"
    ),
    path(path, "source", "_quarto.yml")
  )
  writeLines(
    c(
      "# Language", "::: {lang=nl-BE}", "vlinder [papillon]{lang=fr-FR}", ":::",
      "wrongwords", ":::", "Other section", ":::"
    ),
    path(path, "source", "language.qmd")
  )
  expect_is({
    z <- check_spelling(path, quiet = TRUE)
  }, "checklist"
  )
  stub(checklist_print, "interactive", TRUE, depth = 1)
  hide_output <- tempfile(fileext = ".txt")
  on.exit(file_delete(hide_output), add = TRUE, after = TRUE)
  sink(hide_output)
  expect_output(print(z))
  sink()

  expect_output(quiet_cat("test", quiet = FALSE), "test")
  expect_silent(quiet_cat("test", quiet = TRUE))
})
