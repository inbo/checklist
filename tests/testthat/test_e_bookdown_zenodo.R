test_that("bookdown_zenodo() works", {
  skip_if_not_installed("zen4R")
  skip_if_not_installed("bookdown")
  expect_match(Sys.getenv("ZENODO_SANDBOX"), "^\\w{60}$")
  sandbox_token <- Sys.getenv("ZENODO_SANDBOX")

  root <- tempfile("bookdown")
  dir_create(root)
  system.file("bookdown", package = "checklist") |>
    dir_ls() |>
    file_copy(root)
  expect_warning(
    x <- bookdown_zenodo(
      root, logger = NULL, sandbox = TRUE, token = sandbox_token
    ),
    "Errors found parsing citation meta data"
  )
  expect_is(x, "citation_meta")
  expect_identical(x$get_errors, "No LICENSE.md file found")

  system.file("generic_template", "cc_by_4_0.md", package = "checklist") |>
    file_copy(path(root, "LICENSE.md"))
  zenodo_out <- tempfile(fileext = ".txt")
  defer(file_delete(zenodo_out))
  sink(zenodo_out)
  suppressMessages(
    x <- bookdown_zenodo(
      root, logger = NULL, sandbox = TRUE, token = sandbox_token
    )
  )
  sink()
  output <- readLines(zenodo_out)
  output <- output[!grepl("\\|(\\s|=|\\.)+\\|", output, perl = TRUE)]
  output <- output[!grepl("^(\\s|\\|)*$", output, perl = TRUE)]
  output <- output[!grepl("pandoc.+--to.+--from.+--output", output)]
  output <- output[!grepl("Nothing to remove", output)]
  expect_length(output, 0)
  manager <- zen4R::ZenodoManager$new(sandbox = TRUE, token = sandbox_token)
  expect_true(
    manager$deleteRecord(x$record_id),
    label = paste("Remove Zenodo sandbox record", x$links$html)
  )

  path(root, "index.Rmd") |>
    readLines() -> index
  head(index, 3) |>
    c("  - Josiah Carberry", tail(index, -10)) |>
    writeLines(path(root, "index.Rmd"))
  expect_warning(
    x <- citation_meta$new(root),
    "Errors found parsing citation meta data"
  )
  expect_identical(
    x$get_errors,
    c("no author with `corresponding: true`", "person must be a list")
  )
  head(index, 3) |>
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
