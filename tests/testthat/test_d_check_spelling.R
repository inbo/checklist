library(mockery)
test_that("check_spelling() on a package", {
  old_option <- getOption("checklist.rstudio_source_markers", TRUE)
  options("checklist.rstudio_source_markers" = FALSE)
  defer(options("checklist.rstudio_source_markers" = old_option))
  maintainer <- person(
    given = "Thierry",
    family = "Onkelinx",
    role = c("aut", "cre"),
    email = "thierry.onkelinx@inbo.be",
    comment = c(ORCID = "0000-0001-8804-4216")
  )
  path <- tempfile("check_spelling")
  dir_create(path)
  defer(unlink(path, recursive = TRUE))

  cache <- tempfile("cache")
  dir_create(cache)
  c("git:", "  protocol: ssh", "  organisation: https://github.com/inbo") |>
    writeLines(path(cache, "config.yml"))
  stub(create_package, "R_user_dir", cache, depth = 2)
  package <- "spelling"
  suppressMessages(
    create_package(
      path = path,
      package = package,
      maintainer = maintainer,
      title = "testing the ability of checklist to create a minimal package",
      description = "A dummy package.",
      language = "en-GB",
      keywords = "dummy"
    )
  )
  skip_if(identical(Sys.getenv("SKIP_TEST"), "true"))
  expect_is(
    {
      z <- check_spelling(path(path, package))
    },
    "checklist"
  )
  skip_if(identical(Sys.getenv("SKIP_TEST"), "true"))
  expect_identical(nrow(z$get_spelling), 0L)
  expect_invisible(print(z$get_spelling))

  writeLines(
    c(
      "#' Een voorbeeldfunctie",
      "#' @param x het enige argument",
      "#' @examples",
      "#' print(1)",
      "#' @export",
      "dummy <- function(x) {",
      "  return(x)",
      "}"
    ),
    path(path, package, "R", "dummy.R")
  )
  suppressMessages(document(path(path, package), quiet = TRUE))
  writeLines(
    c(
      readLines(path(path, package, "README.Rmd")),
      "<!-- spell-check: ignore:start -->",
      "<!-- spell-check: ignore:end -->",
      "<script>",
      "</script>",
      "\\"
    ),
    path(path, package, "README.Rmd")
  )
  writeLines(
    c("junk <- function(x) {", "  return(x)", "}"),
    path(path, package, "R", "junk.R")
  )
  writeLines(
    c(
      "\\name{test}",
      "\\alias{test}",
      "\\title{Test function}",
      "\\usage{test(x = 1)}",
      "\\arguments{\\item{x}{argument.}}",
      "\\value{TRUE}",
      "\\description{Some words}"
    ),
    path(path, package, "man", "test.Rd")
  )
  expect_is(
    {
      z <- check_spelling(path(path, package), quiet = TRUE)
    },
    "checklist"
  )
  expect_is(z$get_spelling, "checklist_spelling")
  expect_identical(nrow(z$get_spelling), 4L)
  expect_output(print(z$get_spelling), "Overview of words")
  expect_invisible(custom_dictionary(z))
  expect_is(
    {
      z <- check_spelling(path(path, package))
    },
    "checklist"
  )
  expect_identical(nrow(z$get_spelling), 0L)
  expect_invisible(print(z$get_spelling))

  x <- read_checklist(path(path, package))
  expect_is(x$set_default("en-GB"), "checklist")
  expect_is(
    {
      z <- x$set_other(list("nl-BE" = "man"))
    },
    "checklist"
  )
  expect_is(
    {
      z <- x$get_rd
    },
    "checklist_language"
  )
  hide_output <- tempfile(fileext = ".txt")
  defer(file_delete(hide_output))
  sink(hide_output)
  expect_invisible(print(z, hide_ignore = TRUE))
  sink()

  expect_is(
    {
      z <- spelling_check(text = "", filename = NULL, wordlist = NULL)
    },
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
      defer(file_delete(hide_output2))
      sink(hide_output2)
      z <- x$set_exceptions()
      sink()
      z
    },
    "checklist"
  )
})

test_that("check_spelling() on a project", {
  skip_if(identical(Sys.getenv("SKIP_TEST"), "true"))
  path <- tempfile("check_spelling")
  dir_create(path)
  defer(unlink(path, recursive = TRUE))

  r_user_dir <- tempfile("author")
  dir.create(r_user_dir)
  stub(new_author, "readline", mock("John", "Doe", "john@doe.com", ""))
  stub(new_author, "ask_orcid", mock(""))
  org <- read_organisation()
  expect_output(
    new_author(current = data.frame(), root = r_user_dir, org = org)
  )
  stub(create_project, "R_user_dir", r_user_dir, depth = 5)
  stub(create_project, "readline", "test")
  expect_invisible(
    {
      hide_create <- tempfile(fileext = ".txt")
      defer(file_delete(hide_create))
      sink(hide_create)
      z <- create_project(path, "spelling")
      sink()
    }
  )

  path(path, "spelling", "source", "bookdown") |>
    dir_create()
  path |>
    path("spelling", "source", "bookdown", c("_bookdown.yml", "test.Rproj")) |>
    fs::file_create()

  stub(store_authors, "R_user_dir", r_user_dir)
  expect_invisible(store_authors(path(path, "spelling")))

  expect_is(
    {
      x <- check_project(path(path, "spelling"), fail = FALSE, quiet = TRUE)
    },
    "checklist"
  )
  git_config_set(
    name = "user.name",
    value = "junk",
    repo = path(path, "spelling")
  )
  git_config_set(
    name = "user.email",
    value = "junk@inbo.be",
    repo = path(path, "spelling")
  )
  git_status(repo = path(path, "spelling"))$file |>
    git_add(repo = path(path, "spelling"))
  git_commit("initial commit", repo = path(path, "spelling"))
  stub(
    write_checklist,
    "x$add_motivation",
    function(which = c("warnings", "notes")) {
      which <- match.arg(which)
      current <- get(which, envir = x$.__enclos_env__$private)
      new_motivation <- rep("unit test", length(current))
      new_allowed <- current
      new_allowed <- lapply(
        order(new_allowed),
        function(i) {
          list(motivation = new_motivation[i], value = new_allowed[i])
        }
      )
      assign(
        paste0("allowed_", which),
        new_allowed,
        envir = x$.__enclos_env__$private
      )
      return(invisible(x))
    }
  )
  write_checklist(x = x)

  r_user_dir <- tempfile("author")
  dir.create(r_user_dir)
  stub(new_author, "readline", mock("John", "Doe", "john@doe.com", ""))
  stub(new_author, "ask_orcid", mock(""))
  expect_output(
    new_author(current = data.frame(), root = r_user_dir, org = org)
  )

  hide_author <- tempfile(fileext = ".txt")
  defer(file_delete(hide_author))
  sink(hide_author)
  stub(use_author, "R_user_dir", r_user_dir)
  aut <- use_author()
  c(aut$given, aut$family) |>
    strsplit(" ") |>
    unlist() |>
    unique() |>
    add_words(path(path, "spelling", "inst", "en_gb"))
  sink()
  expect_is(check_project(path(path, "spelling"), quiet = TRUE), "checklist")

  path(path, "spelling") |>
    read_checklist() -> x
  stub(change_language_interactive, "menu", 3)
  stub(change_language_interactive2, "menu", 1, 2)
  expect_is(
    {
      hide_output <- tempfile(fileext = ".txt")
      defer(file_delete(hide_output))
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
      defer(file_delete(hide_output2))
      sink(hide_output2)
      z <- change_language_interactive2(
        data.frame(language = "en-GB", path = "a.Rmd"),
        main = "en-GB",
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
      defer(file_delete(hide_output3))
      sink(hide_output3)
      z <- change_language_interactive2(
        data.frame(language = "en-GB", path = path("a", c("a.Rmd", "b.Rmd"))),
        main = "en-GB",
        other_lang = character(0)
      )
      sink()
      z
    },
    "list"
  )

  gert::git_commit_all(
    message = "Initial commit",
    repo = path(path, "spelling")
  )
  stub(setup_project, "interactive", TRUE, depth = 2)
  expect_output(setup_project(path(path, "spelling")))

  path("generic_template", "gplv3.md") |>
    system.file(package = "checklist") |>
    file_copy(path(path, "spelling", "LICENSE.md"), overwrite = TRUE)
  expect_warning(z <- update_citation(path(path, "spelling"), quiet = TRUE))
  expect_match(
    z$.__enclos_env__$private$errors$CITATION,
    "LICENSE.md doesn't match"
  )
  path(path, "spelling", "LICENSE.md") |>
    unlink()
  expect_warning(z <- update_citation(path(path, "spelling"), quiet = TRUE))
  expect_match(
    z$.__enclos_env__$private$errors$CITATION,
    "No LICENSE.md file found"
  )
  gert::git_reset_hard(repo = path(path, "spelling"))

  path(path, "spelling", "README.md") |>
    readLines() -> readme_old
  writeLines(
    readme_old[!grepl("badges: start", readme_old)],
    path(path, "spelling", "README.md")
  )
  expect_warning(z <- update_citation(path(path, "spelling"), quiet = TRUE))
  expect_true(
    any(grepl("Mismatch between", z$.__enclos_env__$private$errors$CITATION))
  )

  badge_end <- grep("badges: end", readme_old)
  badge_doi <- paste0(
    "[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4028303.svg)]",
    "(https://doi.org/10.5281/zenodo.4028302)"
  )
  writeLines(
    c(
      head(readme_old, badge_end - 1),
      badge_doi,
      paste0(
        "![r-universe name]",
        "(https://inbo.r-universe.dev/badges/:name?color=c04384)"
      ),
      readme_old[badge_end],
      "<!-- version: 0.1 -->",
      tail(readme_old, badge_end)
    ),
    path(path, "spelling", "README.md")
  )
  expect_warning(z <- update_citation(path(path, "spelling"), quiet = TRUE))
  expect_true(
    any(grepl("different DOI", z$.__enclos_env__$private$errors$CITATION))
  )

  writeLines(
    readme_old[!grepl("description: start", readme_old)],
    path(path, "spelling", "README.md")
  )
  expect_warning(z <- update_citation(path(path, "spelling"), quiet = TRUE))
  expect_true(
    any(grepl("Mismatch between", z$.__enclos_env__$private$errors$CITATION))
  )

  writeLines(
    readme_old[!grepl("\\*\\*keywords\\*\\*:", readme_old)],
    path(path, "spelling", "README.md")
  )
  expect_warning(z <- update_citation(path(path, "spelling"), quiet = TRUE))
  expect_true(
    any(grepl("No keywords found", z$.__enclos_env__$private$errors$CITATION))
  )

  unlink(path(path, "spelling", "README.md"))
  expect_warning(z <- update_citation(path(path, "spelling"), quiet = TRUE))
  expect_match(z$.__enclos_env__$private$errors$CITATION, "README.md not found")
})

test_that("check_spelling() works on a quarto project", {
  skip_if(identical(Sys.getenv("SKIP_TEST"), "true"))
  path <- tempfile("quarto")
  dir_create(path)
  defer(unlink(path, recursive = TRUE))
  checklist$new(path, language = "en-GB", package = FALSE) |>
    write_checklist()
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
  expect_identical(
    list_quarto_md(path(path, "source", "_quarto.yml"), root = path),
    list(data.frame(quarto_lang = character(0), path = character(0)))
  )
  writeLines(
    c(
      "project:",
      "  type: book",
      "lang: en-GB",
      "book:",
      "  chapters:",
      "    - language.qmd"
    ),
    path(path, "source", "_quarto.yml")
  )
  writeLines(
    c(
      "# Language",
      "::: {lang=nl-BE}",
      "vlinder [papillon]{lang=fr-FR}",
      ":::",
      "wrongwords",
      ":::",
      "Other section",
      ":::"
    ),
    path(path, "source", "language.qmd")
  )
  expect_is(
    {
      z <- check_spelling(path, quiet = TRUE)
    },
    "checklist"
  )
  stub(checklist_print, "interactive", TRUE, depth = 1)
  hide_output <- tempfile(fileext = ".txt")
  defer(file_delete(hide_output))
  sink(hide_output)
  expect_output(print(z))
  sink()

  expect_output(quiet_cat("test", quiet = FALSE), "test")
  expect_silent(quiet_cat("test", quiet = TRUE))
})

test_that("strip_eqn() works", {
  expect_equal(strip_eqn("\\eqn{\\alpha}"), "")
  expect_equal(strip_eqn("\\deqn{\\alpha}"), "")
  expect_equal(strip_eqn("\\doi{10.1214/ss/1032280214}"), "")
  expect_equal(strip_eqn("\\pkg{checklist}"), "")
  expect_equal(strip_eqn("the \\pkg{boot} package"), "the package")
  expect_equal(
    strip_eqn("where \\eqn{\\alpha} and \\eqn{\\beta} are"),
    "where and are"
  )
})
