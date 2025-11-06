library(mockery)
test_that("create_package() works", {
  skip_if(identical(Sys.getenv("SKIP_TEST"), "true"))

  cache <- tempfile("cache")
  defer(unlink(cache, recursive = TRUE))
  dir_create(file.path(cache, "data"))
  stub(new_author, "readline", mock("John", "Doe", "john@doe.com", ""))
  stub(new_author, "ask_orcid", mock(""))
  expect_output(
    new_author(
      current = data.frame(),
      root = file.path(cache, "data"),
      org = org_list$new()$read()
    )
  )

  mock_r_user_dir <- function(alt_dir) {
    function(package, which = c("data", "config", "cache")) {
      which <- match.arg(which)
      return(file.path(alt_dir, which))
    }
  }

  git_init(cache)
  git_remote_add(
    "https://gitlab.com/thierryo/checklist_dummy.git",
    repo = cache
  )
  stub(get_default_org_list, "R_user_dir", mock_r_user_dir(cache), depth = 2)
  org <- get_default_org_list(cache)
  c("git:", "  protocol: ssh", "  organisation: https://gitlab.com/thierryo") |>
    writeLines(path(cache, "config.yml"))

  path <- tempfile("create_package")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))

  package <- "create"
  stub(create_package, "R_user_dir", mock_r_user_dir(cache), depth = 2)
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
  expect_message(
    create_package(path = path, package = package),
    regexp = sprintf("package created at `.*%s`", package)
  )
  sink()

  repo <- path(path, package)
  stub(store_authors, "R_user_dir", mock_r_user_dir(cache))
  expect_invisible(store_authors(repo))

  new_files <- c(
    "_pkgdown.yml",
    ".gitignore",
    ".Rbuildignore",
    "checklist.yml",
    "codecov.yml",
    "DESCRIPTION",
    "LICENSE.md",
    "NEWS.md",
    "README.Rmd",
    paste0(package, ".Rproj"),
    path(".github", c("CODE_OF_CONDUCT.md", "CONTRIBUTING.md")),
    path(
      ".github",
      "workflows",
      c(
        "check_on_branch.yml",
        "check_on_different_r_os.yml",
        "check_on_main.yml",
        "release.yml"
      )
    ),
    path("pkgdown", "extra.css"),
    path(
      "man",
      "figures",
      c(
        "logo-en.png",
        "background-pattern.png",
        "flanders.woff2",
        "flanders.woff"
      )
    )
  )
  expect_true(all(is_file(path(path, package, new_files))))

  expect_is(
    {
      suppressWarnings({
        x <- check_package(path(path, package), fail = FALSE, quiet = TRUE)
      })
    },
    "checklist"
  )
  expect_true(is_file(path(path, package, ".zenodo.json")))
  expect_true(is_file(path(path, package, "CITATION.cff")))

  expect_error({
    check_package(
      path(path, package),
      fail = TRUE,
      quiet = TRUE,
      pkgdown = TRUE
    )
  })

  stub(x$add_motivation, "yesno", TRUE, depth = 2)
  stub(x$add_motivation, "readline", "junk", depth = 2)
  expect_s3_class(x$add_motivation(which = "notes"), "checklist")
  expect_length(
    x$.__enclos_env__$private$allowed_notes,
    length(x$.__enclos_env__$private$notes)
  )

  stub(x$confirm_motivation, "yesno", TRUE, depth = 2)
  expect_s3_class(x$confirm_motivation(which = "notes"), "checklist")
  expect_length(
    x$.__enclos_env__$private$allowed_notes,
    length(x$.__enclos_env__$private$notes)
  )

  stub(write_checklist, "x$add_motivation", NULL)
  stub(write_checklist, "x$confirm_motivation", NULL)
  old_checklist <- read_checklist(path(path, package))
  expect_invisible(write_checklist(x))
  expect_false(
    identical(
      old_checklist$.__enclos_env__$private$allowed_notes,
      x$.__enclos_env__$private$allowed_notes
    )
  )

  stub(x$confirm_motivation, "yesno", FALSE, depth = 2)
  expect_s3_class(x$confirm_motivation(which = "notes"), "checklist")
  expect_length(x$.__enclos_env__$private$allowed_notes, 0)

  writeLines("dummy<-function(){F}", path(path, package, "R", "dummy.R"))
  expect_s3_class(
    x <- check_lintr(path(path, package), quiet = TRUE),
    "checklist"
  )
  expect_length(x$.__enclos_env__$private$linter, 6)
  expect_output(print(x), "6 linters found")

  path(path, package, "NEWS.md") |>
    readLines() -> news_old
  tail(news_old, -1) |>
    writeLines(path(path, package, "NEWS.md"))
  expect_match(check_news(x), "No reference to a package version")

  unlink(path(path, package, "NEWS.md"))
  expect_equal(check_news(x), "Missing NEWS.md")
})
