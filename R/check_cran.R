#' Run all the package checks required by CRAN
#'
#' CRAN imposes an impressive list of tests on every package before publication.
#' This suite of test is available in every R installation.
#' Hence we use this full suite of tests too.
#' Notice that `check_package()` runs several additional tests.
#' @inheritParams read_checklist
#' @inheritParams rcmdcheck::rcmdcheck
#' @return A `Checklist` object.
#' @importFrom assertthat assert_that
#' @importFrom gert git_info
#' @importFrom httr HEAD
#' @importFrom rmarkdown pandoc_exec
#' @importFrom rcmdcheck rcmdcheck
#' @importFrom withr with_path
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
  on.exit(options(old_options), add = TRUE)
  options(useFancyQuotes = FALSE)

  # test if the worlds clock is available
  clock_status <- HEAD("http://worldclockapi.com/api/json/utc/now")$status_code
  if (clock_status != 200) {
    Sys.setenv("_R_CHECK_SYSTEM_CLOCK_" = 0)
  }

  check_output <- with_path(
    dirname(pandoc_exec()),
    rcmdcheck(
      path = x$get_path, args = c("--timings", "--as-cran", "--no-manual"),
      error_on = "never", quiet = quiet
    )
  )
  repo <- try(git_info(x$get_path), silent = TRUE)
  if (
    !inherits(repo, "try-error") && repo$shorthand %in% c("main", "master") &&
    any(grepl("Insufficient package version", check_output$warnings))
  ) {
    incoming <- grepl("Insufficient package version", check_output$warnings)
    gsub(
  "

Insufficient package version \\(submitted: .*, existing: .*\\)

Days since last update: [0-9]+", "", check_output$warnings[incoming]
    ) -> new_incoming
    if (length(strsplit(new_incoming, "\n")[[1]]) == 2) {
      check_output$warnings <- check_output$warnings[!incoming]
    }
  }
  x$add_rcmdcheck(
    errors = check_output$errors,
    warnings = check_output$warnings,
    notes = check_output$notes
  )
  return(x)
}
