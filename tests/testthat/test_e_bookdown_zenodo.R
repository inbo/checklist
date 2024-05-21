test_that("bookdown_zenodo() works", {
  skip_if_not_installed("bookdown")
  skip_if(Sys.getenv("MY_UNIVERSE") != "") # skip test on r-universe.dev
  root <- tempfile("bookdown")
  dir_create(root)
  system.file("bookdown", package = "checklist") |>
    dir_ls() |>
    file_copy(root)
  path(root, "index.Rmd") |>
    file_delete()
  expect_error(
    x <- bookdown_zenodo(
      root, logger = NULL, sandbox = TRUE, token = sandbox_token
    ),
    "index.Rmd not found"
  )
  expect_warning(
    meta <- citation_meta$new(root),
    "Errors found parsing citation meta data. Citation files not updated."
  )
  expect_s3_class(meta, c("citation_meta", "R6"))
  expect_true(grepl("index.Rmd not found", meta$get_errors))

  system.file("bookdown", package = "checklist") |>
    dir_ls() |>
    file_copy(root, overwrite = TRUE)
  expect_warning(
    x <- bookdown_zenodo(
      root, logger = NULL, sandbox = TRUE, token = sandbox_token
    ),
    "Errors found parsing citation meta data"
  )
  expect_is(x, "citation_meta")
  expect_identical(x$get_errors, "No LICENSE.md file found")

  skip_if_not_installed("zen4R")
  system.file("generic_template", "mit.md", package = "checklist") |>
    file_copy(path(root, "LICENSE.md"))
  expect_warning(
    x <- bookdown_zenodo(root, logger = NULL, sandbox = TRUE, token = "junk"),
    "Errors found parsing citation meta data. Citation files not updated."
  )
  expect_equal(x$get_errors, "LICENSE.md doesn't match with CC-BY-4.0 license")

  system.file("generic_template", "cc_by_4_0.md", package = "checklist") |>
    file_copy(path(root, "LICENSE.md"), overwrite = TRUE)
  path(root, "index.Rmd") |>
    readLines() |>
    tail(-1) -> index
  c("---", "embargo: 2030-01-23", index) |>
    writeLines(path(root, "index.Rmd"))
  zenodo_out <- tempfile(fileext = ".txt")
  defer(file_delete(zenodo_out))
  sink(zenodo_out)
  expect_error(
    bookdown_zenodo(root, logger = NULL, sandbox = TRUE, token = "junk")
  )
  sink()

  expect_match(Sys.getenv("ZENODO_SANDBOX"), "^\\w{60}$")
  sandbox_token <- Sys.getenv("ZENODO_SANDBOX")
  zenodo_out2 <- tempfile(fileext = ".txt")
  defer(file_delete(zenodo_out2))
  sink(zenodo_out2)
  suppressMessages(
    x <- bookdown_zenodo(
      root, logger = NULL, sandbox = TRUE, token = sandbox_token
    )
  )
  sink()
  manager <- zen4R::ZenodoManager$new(sandbox = TRUE, token = sandbox_token)
  expect_true(
    manager$deleteRecord(x$id),
    label = paste("Remove Zenodo sandbox record", x$links$self_html)
  )

  path(root, "index.Rmd") |>
    readLines() -> index
  head(index, 4) |>
    c("  - Josiah Carberry", tail(index, -11)) |>
    writeLines(path(root, "index.Rmd"))
  expect_warning(
    x <- citation_meta$new(root),
    "Errors found parsing citation meta data"
  )
  expect_identical(
    x$get_errors,
    c("no author with `corresponding: true`", "person must be a list")
  )
  head(index, 4) |>
    c("  - name: Josiah Carberry", tail(index, -10)) |>
    writeLines(path(root, "index.Rmd"))
  expect_warning(
    x <- citation_meta$new(root),
    "Errors found parsing citation meta data"
  )
  expect_identical(
    x$get_errors,
    c(
      "no author with `corresponding: true`",
      "person `name` element is not a list"
    )
  )
  path(root, "index.Rmd") |>
    writeLines(text = index)

  system.file("generic_template", "gplv3.md", package = "checklist") |>
    file_copy(path(root, "LICENSE.md"), overwrite = TRUE)
  expect_warning(
    x <- bookdown_zenodo(
      root, logger = NULL, sandbox = TRUE, token = sandbox_token
    ),
    "Errors found parsing citation meta data"
  )

  path(root, "abstract.Rmd") |>
    file_delete()
  expect_warning(
    x <- bookdown_zenodo(
      root, logger = NULL, sandbox = TRUE, token = sandbox_token
    ),
    "Errors found parsing citation meta data"
  )

  path(root, "index.Rmd") |>
    file_delete()
  expect_error(
    x <- bookdown_zenodo(
      root, logger = NULL, sandbox = TRUE, token = sandbox_token
    ),
    "index.Rmd not found in `path`"
  )
  expect_warning(
    x <- citation_meta$new(root), "Errors found parsing citation meta data"
  )
  expect_match(x$get_errors, "index.Rmd not found")
})

test_that("yaml_author_format", {
  x <- yaml_author_format(person = "me")
  expect_identical(class(x), "list")
  expect_identical(attr(x[[1]], "errors")[[1]], "person must be a list")
  x <- yaml_author_format(person = list("me"))
  expect_identical(class(x), "list")
  expect_identical(attr(x[[1]], "errors")[[1]], "person has no `name` element")
})
