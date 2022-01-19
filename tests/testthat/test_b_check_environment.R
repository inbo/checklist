test_that("check_environment() works", {
  tmp_dir <- tempfile()
  dir.create(tmp_dir)
  on.exit(file.remove(tmp_dir), add = TRUE)
  old_gha <- Sys.getenv("GITHUB_ACTIONS")
  on.exit(Sys.setenv(GITHUB_ACTIONS = old_gha), add = TRUE)
  old_input <- Sys.getenv("INPUT_TOKEN")
  on.exit(Sys.setenv(INPUT_TOKEN = old_input), add = TRUE)
  old_orcid <- Sys.getenv("ORCID_TOKEN")
  on.exit(Sys.setenv(ORCID_TOKEN = old_orcid), add = TRUE)
  old_codecov <- Sys.getenv("CODECOV_TOKEN")
  on.exit(Sys.setenv(CODECOV_TOKEN = old_codecov), add = TRUE)

  Sys.setenv(GITHUB_ACTIONS = "")
  expect_invisible(suppressMessages(x <- check_environment(tmp_dir)))
  expect_identical(x$.__enclos_env__$private$errors, list())

  Sys.setenv(GITHUB_ACTIONS = "true")
  Sys.setenv(INPUT_TOKEN = "")
  Sys.setenv(ORCID_TOKEN = "")
  Sys.setenv(CODECOV_TOKEN = "")
  expect_invisible(suppressMessages(x <- check_environment(tmp_dir)))
  expect_identical(
    x$.__enclos_env__$private$errors,
    list(
      `repository secret` = paste0(
        "Missing repository secret(s) PAT, ORCID_TOKEN, CODECOV_TOKEN on ",
        "GitHub.\nSee ",
"https://inbo.github.io/checklist/articles/getting_started.html#online-setup-2",
        " for more details."
      )
    )
  )

  Sys.setenv(INPUT_TOKEN = "bla")
  expect_invisible(suppressMessages(x <- check_environment(tmp_dir)))
  expect_identical(
    x$.__enclos_env__$private$errors,
    list(
      `repository secret` = paste0(
        "Missing repository secret(s) ORCID_TOKEN, CODECOV_TOKEN on ",
        "GitHub.\nSee ",
"https://inbo.github.io/checklist/articles/getting_started.html#online-setup-2",
        " for more details."
      )
    )
  )

  Sys.setenv(ORCID_TOKEN = "bla")
  expect_invisible(suppressMessages(x <- check_environment(tmp_dir)))
  expect_identical(
    x$.__enclos_env__$private$errors,
    list(
      `repository secret` = paste0(
        "Missing repository secret(s) CODECOV_TOKEN on ",
        "GitHub.\nSee ",
"https://inbo.github.io/checklist/articles/getting_started.html#online-setup-2",
        " for more details."
      )
    )
  )

  Sys.setenv(CODECOV_TOKEN = "bla")
  expect_invisible(suppressMessages(x <- check_environment(tmp_dir)))
  expect_identical(x$.__enclos_env__$private$errors, list())

  Sys.setenv(ORCID_TOKEN = "")
  expect_invisible(suppressMessages(x <- check_environment(tmp_dir)))
  expect_identical(
    x$.__enclos_env__$private$errors,
    list(
      `repository secret` = paste0(
        "Missing repository secret(s) ORCID_TOKEN on ",
        "GitHub.\nSee ",
"https://inbo.github.io/checklist/articles/getting_started.html#online-setup-2",
        " for more details."
      )
    )
  )

  Sys.setenv(INPUT_TOKEN = "")
  expect_invisible(suppressMessages(x <- check_environment(tmp_dir)))
  expect_identical(
    x$.__enclos_env__$private$errors,
    list(
      `repository secret` = paste0(
        "Missing repository secret(s) PAT, ORCID_TOKEN on ",
        "GitHub.\nSee ",
"https://inbo.github.io/checklist/articles/getting_started.html#online-setup-2",
        " for more details."
      )
    )
  )

  Sys.setenv(ORCID_TOKEN = "bla")
  expect_invisible(suppressMessages(x <- check_environment(tmp_dir)))
  expect_identical(
    x$.__enclos_env__$private$errors,
    list(
      `repository secret` = paste0(
        "Missing repository secret(s) PAT on ",
        "GitHub.\nSee ",
"https://inbo.github.io/checklist/articles/getting_started.html#online-setup-2",
        " for more details."
      )
    )
  )

  Sys.setenv(CODECOV_TOKEN = "")
  expect_invisible(suppressMessages(x <- check_environment(tmp_dir)))
  expect_identical(
    x$.__enclos_env__$private$errors,
    list(
      `repository secret` = paste0(
        "Missing repository secret(s) PAT, CODECOV_TOKEN on ",
        "GitHub.\nSee ",
"https://inbo.github.io/checklist/articles/getting_started.html#online-setup-2",
        " for more details."
      )
    )
  )
})