#' Run all the package checks required by CRAN
#'
#' CRAN imposes an impressive list of tests on every package before publication.
#' This suite of test is available in every R installation.
#' Hence we use this full suite of tests too.
#' Notice that `check_package()` runs several additional tests.
#' @inheritParams read_checklist
#' @inheritParams rcmdcheck::rcmdcheck
#' @return A `checklist` object.
#' @importFrom assertthat assert_that
#' @importFrom gert git_ahead_behind git_branch_exists git_info
#' @importFrom httr HEAD
#' @importFrom rmarkdown pandoc_exec
#' @importFrom rcmdcheck rcmdcheck
#' @importFrom withr defer with_path
#' @export
#' @family package
check_cran <- function(x = ".", quiet = FALSE) {
  x <- read_checklist(x = x)
  assert_that(
    x$package,
    msg = "`check_cran()` is only relevant for packages.
`checklist.yml` indicates this is not a package."
  )

  # don't use fancy Quotes when checking
  old_options <- options()
  defer(options(old_options))
  Sys.setenv("R_DEFAULT_INTERNET_TIMEOUT" = 360)
  options(useFancyQuotes = FALSE, timeout = max(360, getOption("timeout")))

  # test if the worlds clock is available
  clock_status <- HEAD("http://worldclockapi.com/api/json/utc/now")$status_code
  if (clock_status != 200) {
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

display_message <- function(x, verbose, type = c("cat", "message", "warning")) {
  if (isFALSE(verbose)) {
    return(invisible(NULL))
  }
  type <- match.arg(type)
  stopifnot(is.character(x))
  switch(
    type,
    cat = cat(x, "\n"),
    message = message(x),
    warning = warning(x, call. = FALSE, immediate. = TRUE)
  )
  return(invisible(NULL))
}

check_test <- function(package_path, quiet = FALSE) {
  test_folder <- file.path(package_path, "tests")
  if (!dir.exists(test_folder)) {
    display_message("No tests found", verbose = !quiet)
    return(character(0))
  }
  test_files <- list.files(test_folder, pattern = "\\.R$", ignore.case = TRUE)
  if (length(test_files) == 0) {
    display_message("No tests found", verbose = !quiet)
    return(character(0))
  }
  file.path(test_folder, test_files) |>
    sprintf(fmt = "Rscript --vanilla %s") |>
    paste(collapse = "\n") |>
    sprintf(fmt = "cd %2$s\n%1$s", test_folder) |>
    system(intern = TRUE) |>
    paste(collapse = "\n") -> test_output

  if (!grepl("Failed tests", test_output)) {
    test_output <- character(0)
  }
  display_message(test_output, verbose = !quiet)
  return(test_output)
}
