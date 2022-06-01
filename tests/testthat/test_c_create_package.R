library(mockery)
test_that("create_package() works", {
  maintainer <- person(
    given = "Thierry",
    family = "Onkelinx",
    role = c("aut", "cre"),
    email = "thierry.onkelinx@inbo.be",
    comment = c(ORCID = "0000-0001-8804-4216")
  )
  path <- tempfile("create_package")
  dir.create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  package <- "create"
  expect_message(
    create_package(
      path = path,
      package = package,
      title = "testing the ability of checklist to create a minimal package",
      description = "A dummy package.",
      maintainer = maintainer, language = "en-GB"
    ),
    regexp = sprintf("package created at `.*%s`", package)
  )

  repo <- file.path(path, package)

  new_files <- c(
    "_pkgdown.yml", ".gitignore", ".Rbuildignore", "checklist.yml",
    "codecov.yml", "DESCRIPTION", "LICENSE.md", "NEWS.md", "README.Rmd",
    paste0(package, ".Rproj"),
    file.path(".github", c("CODE_OF_CONDUCT.md", "CONTRIBUTING.md")),
    file.path(
      ".github", "workflows",
      c(
        "check_on_branch.yml", "check_on_different_r_os.yml",
        "check_on_main.yml", "release.yml"
      )
    ),
    file.path("pkgdown", "extra.css"),
    file.path(
      "man", "figures",
      c(
        "logo-en.png", "background-pattern.png", "flanders.woff2",
        "flanders.woff"
      )
    )
  )
  expect_true(
    all(file.exists(file.path(path, package, new_files)))
  )

  expect_is({
      x <- check_package(file.path(path, package), fail = FALSE, quiet = TRUE)
    },
    "Checklist"
  )
  expect_true(file_test("-f", file.path(path, package, ".zenodo.json")))
  expect_true(file_test("-f", file.path(path, package, "CITATION.cff")))

  expect_error({
    check_package(
      file.path(path, package), fail = TRUE, quiet = TRUE, pkgdown = TRUE
    )
  })

  stub(x$add_motivation, "yesno", TRUE, depth = 2)
  stub(x$add_motivation, "readline", "junk", depth = 2)
  expect_is(
    x$add_motivation(which = "notes"),
    "Checklist"
  )
  expect_length(x$.__enclos_env__$private$allowed_notes, 2)

  stub(x$confirm_motivation, "yesno", TRUE, depth = 2)
  expect_is(
    x$confirm_motivation(which = "notes"),
    "Checklist"
  )
  expect_length(x$.__enclos_env__$private$allowed_notes, 2)

  stub(write_checklist, "x$add_motivation", NULL)
  stub(write_checklist, "x$confirm_motivation", NULL)
  old_checklist <- read_checklist(file.path(path, package))
  expect_invisible(write_checklist(x))
  expect_false(
    identical(
      old_checklist$.__enclos_env__$private$allowed_notes,
      x$.__enclos_env__$private$allowed_notes
    )
  )

  stub(x$confirm_motivation, "yesno", FALSE, depth = 2)
  expect_is(
    x$confirm_motivation(which = "notes"),
    "Checklist"
  )
  expect_length(x$.__enclos_env__$private$allowed_notes, 0)

  writeLines("dummy<-function(){F}", file.path(path, package, "R", "dummy.R"))
  expect_is(
    x <- check_lintr(file.path(path, package), quiet = TRUE), "Checklist"
  )
  expect_length(x$.__enclos_env__$private$linter, 6)
  expect_output(print(x), "6 linters found")
})
