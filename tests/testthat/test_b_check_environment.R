test_that("check_environment() works", {
  tmp_dir <- tempfile()
  dir_create(tmp_dir)
  defer(file_delete(tmp_dir))
  checklist$new(tmp_dir, language = "en-GB", package = FALSE) |>
    write_checklist()
  old_gha <- Sys.getenv("GITHUB_ACTIONS")
  old_codecov <- Sys.getenv("CODECOV_TOKEN")

  Sys.setenv(GITHUB_ACTIONS = "")
  expect_invisible(suppressMessages(x <- check_environment(tmp_dir)))
  expect_identical(
    x$.__enclos_env__$private$errors,
    list(`repository secret` = character(0))
  )

  Sys.setenv(GITHUB_ACTIONS = "true")
  Sys.setenv(CODECOV_TOKEN = "")
  expect_invisible(suppressMessages(x <- check_environment(tmp_dir)))
  expect_identical(
    x$.__enclos_env__$private$errors,
    list(
      `repository secret` = paste0(
        "Missing repository secret(s) CODECOV_TOKEN on ",
        "GitHub.\nSee ",
        paste0(
          "https://inbo.github.io/checklist/articles/",
          "getting_started.html#online-setup-2"
        ),
        " for more details."
      )
    )
  )
  Sys.setenv(GITHUB_ACTIONS = old_gha)
  Sys.setenv(CODECOV_TOKEN = old_codecov)
})
