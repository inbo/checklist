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
      description = "A dummy package.", language = "en-GB"
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
    "#' An example function
#' @param x the only argument
#' @export
dummy <- function(x) {
  return(x)
}",
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
  expect_is(
    {z <- check_spelling(path(path, package), quiet = TRUE)},
    "checklist"
  )
  expect_is(z$get_spelling, "checklist_spelling")
  expect_identical(nrow(z$get_spelling), 6L)
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
  on.exit(file.remove(hide_output), add = TRUE, after = TRUE)
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

  stub(change_language_interactive, "menu", 1, 2)
  expect_is(
    {
      hide_output2 <- tempfile(fileext = ".txt")
      on.exit(file.remove(hide_output2), add = TRUE, after = TRUE)
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
  stub(create_project, "interactive", TRUE, depth = 2)
  stub(create_project, "menu", 1, depth = 2)
  stub(create_project, "interactive", TRUE, depth = 3)
  stub(create_project, "menu", 1, depth = 3)
  expect_invisible(create_project(path, "spelling"))
  expect_is(check_project(path(path, "spelling"), quiet = TRUE), "checklist")
  dir_create(path(path, "spelling"), "source")
  writeLines("# Een testfunctie", path(path, "spelling", "source", "dummy.Rmd"))
  expect_is(
    check_project(path(path, "spelling"), fail = FALSE, quiet = TRUE),
    "checklist"
  )

  x <- read_checklist(path)
  stub(change_language_interactive, "menu", 3)
  stub(change_language_interactive2, "menu", 1, 2)
  expect_is(
    {
      hide_output <- tempfile(fileext = ".txt")
      on.exit(file.remove(hide_output), add = TRUE, after = TRUE)
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
      on.exit(file.remove(hide_output2), add = TRUE, after = TRUE)
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
      on.exit(file.remove(hide_output3), add = TRUE, after = TRUE)
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
      "wrongwords"
    ),
    path(path, "source", "language.qmd")
  )
  expect_is({
    z <- check_spelling(path)
  }, "checklist"
  )
  stub(checklist_print, "interactive", TRUE, depth = 1)
  expect_output(print(z))

  expect_output(quiet_cat("test", quiet = FALSE), "test")
  expect_silent(quiet_cat("test", quiet = TRUE))
})