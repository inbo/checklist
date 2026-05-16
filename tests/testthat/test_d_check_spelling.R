library(mockery)
test_that("check_spelling() on a package", {
  stub(org_list_from_url, "R_user_dir", mock_r_user_dir(config_dir))
  org <- org_list_from_url("https://gitlab.com/thierryo/checklist.git")

  old_option <- getOption("checklist.rstudio_source_markers", TRUE)
  options("checklist.rstudio_source_markers" = FALSE)
  defer(options("checklist.rstudio_source_markers" = old_option))
  path <- tempfile("check_spelling")
  dir_create(path)
  defer(unlink(path, recursive = TRUE))

  package <- "spelling"
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
            affiliation = "Flemish government"
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
  suppressMessages(create_package(path = path, package = package))
  git_config_set(name = "user.name", value = "junk", repo = path(path, package))
  git_config_set(
    name = "user.email",
    value = "junk@inbo.be",
    repo = path(path, package)
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
  git_add(path("R", "dummy.R"), repo = path(path, package))
  suppressMessages(document(path(path, package), quiet = TRUE))
  git_add(path("man", "dummy.Rd"), repo = path(path, package))
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
  git_add(path("README.Rmd"), repo = path(path, package))
  writeLines(
    c("junk <- function(x) {", "  return(x)", "}"),
    path(path, package, "R", "junk.R")
  )
  git_add(path("R", "junk.R"), repo = path(path, package))
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
  git_add(path("man", "test.Rd"), repo = path(path, package))
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

  stub(org_list_from_url, "R_user_dir", mock_r_user_dir(config_dir))
  org <- org_list_from_url("https://gitlab.com/thierryo/citeme.git")

  path <- tempfile("check_spelling")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))
  project <- "check_spelling"
  stub(create_project, "R_user_dir", mock_r_user_dir(config_dir), depth = 2)
  stub(create_project, "preferred_protocol", "git@gitlab.com:thierryo/%s.git")
  stub(
    create_project,
    "readline",
    mock("This is the title", "This is the description.")
  )
  stub(create_project, "ask_keywords", c("key", "word"))
  stub(create_project, "ask_language", "en-GB")
  stub(
    create_project,
    "project_maintainer",
    list(
      authors = data.frame(
        given = c("Given", "The checklist organisation"),
        family = c("Test", ""),
        email = c("given.test@vlaanderen.be", "info@organisation.checklist"),
        orcid = c("0000-0002-1825-0097", ""),
        affiliation = c("Flemish government", ""),
        role = c("aut, cre", "fnd, cph")
      ) |>
        individual2badge(),
      org = org
    ),
    depth = 2
  )

  expect_invisible({
    hide_create <- tempfile(fileext = ".txt")
    defer(file_delete(hide_create))
    sink(hide_create)
    z <- create_project(path, "spelling")
    sink()
  })

  path(path, "spelling", "source", "bookdown") |> dir_create()
  path |>
    path("spelling", "source", "bookdown", c("_bookdown.yml", "test.Rproj")) |>
    fs::file_create()

  expect_is(
    {
      x <- suppressWarnings(check_project(
        path(path, "spelling"),
        fail = FALSE,
        quiet = TRUE
      ))
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
      new_allowed <- lapply(order(new_allowed), function(i) {
        list(motivation = new_motivation[i], value = new_allowed[i])
      })
      assign(
        paste0("allowed_", which),
        new_allowed,
        envir = x$.__enclos_env__$private
      )
      return(invisible(x))
    }
  )
  write_checklist(x = x)

  expect_is(
    check_project(path(path, "spelling"), fail = FALSE, quiet = TRUE),
    "checklist"
  )
  path(path, "spelling") |> read_checklist() -> x
  stub(change_language_interactive, "menu_first", mock(3, 1))
  expect_is(
    {
      hide_output <- tempfile(fileext = ".txt")
      defer(file_delete(hide_output))
      sink(hide_output)
      z <- change_language_interactive(data.frame(
        language = "en-GB",
        path = "a.Rmd"
      ))
      sink()
      z
    },
    "list"
  )

  stub(change_language_interactive2, "menu_first", 2)
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

  stub(change_language_interactive2, "menu_first", 3)
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
  stub(
    setup_project,
    "write_checklist",
    function(x = ".") {
      x <- suppressMessages(read_checklist(x = x))
      path(x$get_path, "checklist.yml") |> write_yaml(x = x$template)
      return(invisible(NULL))
    },
    depth = 2
  )
  expect_invisible(suppressWarnings(setup_project(path(path, "spelling"))))

  # add problematic Dutch words
  c(
    "INBO-plantenlijsten",
    "klei- en zandbodems",
    "INBO-projecten",
    "INBO-tijd",
    "hij/zij",
    "hem/haar",
    "1-out-all-out",
    "-berekeningen",
    "aan-/afwezigheid",
    "soortnaam/variëteit/",
    "hij/zij/..."
  ) |>
    writeLines(path(path, "spelling", "source", "nederlands.md"))
  path(path, "spelling", "checklist.yml") |> readLines() -> old_checklist
  head(old_checklist, -1) |>
    c(
      "  other:",
      "    nl-BE:",
      "    - source/nederlands.md",
      tail(old_checklist, 1)
    ) |>
    writeLines(path(path, "spelling", "checklist.yml"))
  z <- check_spelling(x = path(path, "spelling"), quiet = TRUE)
  expect_equal(nrow(z$get_spelling), 0)

  # fix README
  path(path, "spelling", "README.md") |> readLines() -> readme_old
  writeLines(
    readme_old[!grepl("badges: start", readme_old)],
    path(path, "spelling", "README.md")
  )
  z <- check_spelling(x = path(path, "spelling"), quiet = TRUE)

  expect_warning(z <- update_citation(path(path, "spelling"), quiet = TRUE))
  expect_true(any(grepl(
    "Mismatch between",
    z$.__enclos_env__$private$errors$CITATION
  )))

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
      tail(readme_old, -badge_end)
    ),
    path(path, "spelling", "README.md")
  )
  expect_warning(z <- update_citation(path(path, "spelling"), quiet = TRUE))
  expect_true(any(grepl(
    "different DOI",
    z$.__enclos_env__$private$errors$CITATION
  )))

  writeLines(
    readme_old[!grepl("description: start", readme_old)],
    path(path, "spelling", "README.md")
  )
  expect_warning(z <- update_citation(path(path, "spelling"), quiet = TRUE))
  expect_true(any(grepl(
    "Mismatch between",
    z$.__enclos_env__$private$errors$CITATION
  )))

  writeLines(
    readme_old[!grepl("\\*\\*keywords\\*\\*:", readme_old)],
    path(path, "spelling", "README.md")
  )
  expect_warning(z <- update_citation(path(path, "spelling"), quiet = TRUE))
  expect_true(any(grepl(
    "No keywords found",
    z$.__enclos_env__$private$errors$CITATION
  )))

  unlink(path(path, "spelling", "README.md"))
  expect_warning(z <- update_citation(path(path, "spelling"), quiet = TRUE))
  expect_match(
    z$.__enclos_env__$private$errors$CITATION,
    "no supported file found in `path`"
  )
})

test_that("check_spelling() works on a quarto project", {
  skip_if(identical(Sys.getenv("SKIP_TEST"), "true"))
  path <- tempfile("quarto")
  dir_create(path)
  defer(unlink(path, recursive = TRUE))
  checklist$new(path, language = "en-GB", package = FALSE) |> write_checklist()
  dir_create(path, "source")
  writeLines(c("project:", "  type: book"), path(path, "source", "_quarto.yml"))
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
