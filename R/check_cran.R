#' Run all the package checks required by CRAN
#'
#' CRAN imposes an impressive list of tests on every package before publication.
#' This suite of test is available in every R installation.
#' Hence we use this full suite of tests too.
#' Notice that `check_package()` runs several additional tests.
#' @inheritParams read_checklist
#' @inheritParams rcmdcheck::rcmdcheck
#' @param time_out The time in seconds to wait for a response from the world
#' clock API.
#' Default is 15 seconds, but you can increase this if you have a slow internet
#' connection.
#' If the world clock API is not available, the system clock will be used
#' without a warning, but the check will be less reliable.
#' @return A `checklist` object.
#' @importFrom assertthat assert_that
#' @importFrom gert git_ahead_behind git_branch_exists git_info
#' @importFrom rmarkdown pandoc_exec
#' @importFrom rcmdcheck rcmdcheck
#' @importFrom withr defer with_path
#' @export
#' @family package
check_cran <- function(x = ".", quiet = FALSE, time_out = 30) {
  x <- read_checklist(x = x)
  assert_that(
    x$package,
    msg = "`check_cran()` is only relevant for packages.
`checklist.yml` indicates this is not a package."
  )

  # don't use fancy Quotes when checking
  old_options <- options()
  defer(options(old_options))
  options(useFancyQuotes = FALSE)

  # Save the original timeout option and set the new one
  old_timeout <- getOption("timeout")
  options(timeout = max(time_out, getOption("timeout")))
  Sys.setenv("R_DEFAULT_INTERNET_TIMEOUT" = time_out)

  # Attempt to read from the URL
  clock_is_available <- tryCatch(
    {
      suppressWarnings({
        # Open connection
        con <- url("http://worldclockapi.com/api/json/utc/now", "r")
        # Read one line to verify the connection is active and valid
        readLines(con, n = 1, warn = FALSE)
        close(con)
      })
      TRUE # Return TRUE if the above succeeds
    },
    error = function(e) {
      FALSE # Return FALSE if any error occurs (timeout, 404, unreachable)
    }
  )

  # Restore the original timeout
  options(timeout = old_timeout)

  # Set the environment variable if the clock is not available
  if (!clock_is_available) {
    Sys.setenv("_R_CHECK_SYSTEM_CLOCK_" = 0)
  }
  check_output <- with_path(
    dirname(pandoc_exec()),
    rcmdcheck(
      path = x$get_path,
      args = c("--timings", "--as-cran", "--no-manual", "--no-tests"),
      error_on = "never",
      quiet = quiet,
      timeout = Inf
    )
  )
  main_branch <- ifelse(
    is.na(git_info(repo = x$get_path)$head),
    "none",
    ifelse(git_branch_exists("main", repo = x$get_path), "main", "master")
  )
  if (
    main_branch != "none" &&
      git_ahead_behind(upstream = main_branch, repo = x$get_path)$upstream ==
        git_ahead_behind(upstream = main_branch, repo = x$get_path)$local &&
      any(grepl("Insufficient package version", check_output$warnings))
  ) {
    # nocov start
    incoming <- grepl(
      "checking CRAN incoming feasibility",
      check_output$warnings
    )
    gsub(
      "

Insufficient package version \\(submitted: .*, existing: .*\\)

Days since last update: [0-9]+",
      "",
      check_output$warnings[incoming]
    ) -> new_incoming
    if (length(strsplit(new_incoming, "\n")[[1]]) == 2) {
      check_output$warnings <- check_output$warnings[!incoming]
    }
  }
  # nocov end

  check_output$notes <- clean_incoming(check_output$notes)
  check_output$warnings <- gsub(" \\[\\d+s/\\d+s\\]", "", check_output$warnings)
  check_output$notes <- gsub(" \\[\\d+s/\\d+s\\]", "", check_output$notes)
  # remove timing output from warnings and notes
  check_output$warnings <- gsub(" \\[\\d+s\\]", "", check_output$warnings)
  check_output$notes <- gsub(" \\[\\d+s\\]", "", check_output$notes)
  x$add_rcmdcheck(
    errors = c(check_output$errors, check_test(x$get_path)),
    warnings = check_output$warnings,
    notes = check_output$notes
  )
  return(x)
}

clean_incoming <- function(issues) {
  if (length(issues) == 0) {
    return(issues)
  }
  if (any(grepl("Days since last update", issues))) {
    last_update <- grep("Days since last update", issues) # nocov start
    issues[last_update] <- gsub(
      "\n\nDays since last update: [0-9]+",
      "",
      issues[last_update]
    )
    if (length(strsplit(issues[last_update], "\n")[[1]]) == 2) {
      issues <- issues[-last_update]
    } # nocov end
  }
  if (any(grepl("New maintainer", issues))) {
    # nocov start
    issues <- gsub("\n\nNew maintainer:.*Old maintainer.*?<.*?>", "", issues)
    if (length(strsplit(issues, "\n")[[1]]) == 2) {
      issues <- character(0)
    } # nocov end
  }
  return(issues)
}

check_test <- function(package_path, quiet = FALSE) {
  test_folder <- path_(package_path, "tests")
  if (!dir.exists(test_folder)) {
    display_message("No tests found", verbose = !quiet)
    return(character(0))
  }
  test_files <- list.files(test_folder, pattern = "\\.R$", ignore.case = TRUE)
  if (length(test_files) == 0) {
    display_message("No tests found", verbose = !quiet)
    return(character(0))
  }
  path_(test_folder, test_files) |>
    sprintf(fmt = "Rscript --vanilla %s") |>
    paste(collapse = "\n") |>
    sprintf(fmt = "cd %2$s\n%1$s", test_folder) -> test_command
  test_output <- try(system(test_command, intern = TRUE))
  if (inherits(test_output, "try-error")) {
    display_message("unit test Try error", verbose = !quiet)
    return("unit test try error. please contact the package maintainer.")
  } else {
    grep("Rout.fail", test_output) |> paste(collapse = ", ") |> cat()
  }
  test_output <- paste(test_output, collapse = "\n")

  if (!grepl("Failed tests", test_output)) {
    test_output <- character(0)
  }
  display_message(test_output, verbose = !quiet)
  return(test_output)
}
