library(mockery)
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
    x <- bookdown_zenodo(root, logger = NULL, sandbox = TRUE),
    "index.Rmd not found"
  )
  expect_warning(
    meta <- citation_meta$new(root),
    "Errors found parsing citation meta data. Citation files not updated."
  )
  expect_s3_class(meta, c("citation_meta", "R6"))
  expect_true(grepl("index.Rmd not found", meta$get_errors))

  skip_if_not_installed("zen4R")
  system.file("bookdown", package = "checklist") |>
    dir_ls() |>
    file_copy(root, overwrite = TRUE)
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
      root,
      logger = NULL,
      sandbox = TRUE,
      token = sandbox_token
    )
  )
  sink()
  skip_on_os(os = "mac")
  skip_on_os(os = "windows")
  manager <- zen4R::ZenodoManager$new(sandbox = TRUE, token = sandbox_token)
  zen_com <- manager$getCommunityById("checklist")
  sprintf(
    "status:submitted AND receiver.community:%s AND topic.record:%s",
    zen_com$id,
    x$id
  ) |>
    manager$getRequests() -> reqs
  expect_true(
    manager$cancelRequest(reqs[[1]]$id),
    label = paste("Failed to delete review request", reqs[[1]]$id)
  )
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
    c(
      `Josiah Carberry` = paste(
        "`Josiah Carberry` is not in the required person format.",
        "Please update the YAML"
      )
    )
  )
  head(index, 9) |>
    c(tail(index, -11)) |>
    writeLines(path(root, "index.Rmd"))
  expect_warning(
    x <- citation_meta$new(root),
    "Errors found parsing citation meta data"
  )
  expect_identical(
    x$get_errors,
    "no author with `corresponding: true` or role `cre`"
  )
  path(root, "index.Rmd") |>
    writeLines(text = index)

  path(root, "abstract.Rmd") |>
    file_delete()
  expect_warning(
    x <- bookdown_zenodo(
      root,
      logger = NULL,
      sandbox = TRUE,
      token = sandbox_token
    ),
    "Errors found parsing citation meta data"
  )

  path(root, "index.Rmd") |>
    file_delete()
  expect_error(
    x <- bookdown_zenodo(
      root,
      logger = NULL,
      sandbox = TRUE,
      token = sandbox_token
    ),
    "index.Rmd not found in `path`"
  )
  expect_warning(
    x <- citation_meta$new(root),
    "Errors found parsing citation meta data"
  )
  expect_match(x$get_errors, "index.Rmd not found")
})
