#' A standardised test for R packages
#'
#' @param path The path of the package.
#' Defaults to `"."`
#' @param fail Should the function return an error in case of a problem?
#' Defaults to `TRUE`.
#' @importFrom assertthat assert_that is.flag is.string noNA
#' @importFrom rcmdcheck rcmdcheck
#' @importFrom utils file_test
#' @export
check_package <- function(path = ".", fail = TRUE) {
  assert_that(is.string(path))
  assert_that(
    file_test("-d", path),
    msg = "`path` is not a directory."
  )
  assert_that(is.flag(fail))
  assert_that(noNA(fail))
  checklist <- read_checklist(path = path)
  check_output <- rcmdcheck(
    path = path,
    args = c("--timings", "--as-cran"),
    error_on = "never"
  )

  problem_summary <- list(
    count = length(check_output$errors),
    errors = check_output$errors
  )

  warning_ok <- vapply(checklist$allowed$warnings, `[[`, character(1), "value")
  problem <- !check_output$warnings %in% warning_ok
  problem_summary$`new warnings` <- check_output$warnings[problem]
  problem_summary$count <- problem_summary$count + sum(problem)
  problem <- !warning_ok %in% check_output$warnings
  problem_summary$`missing warnings` <- warning_ok[problem]
  problem_summary$count <- problem_summary$count + sum(problem)

  notes_ok <- vapply(checklist$allowed$notes, `[[`, character(1), "value")
  problem <- !check_output$notes %in% notes_ok
  problem_summary$`new notes` <- check_output$notes[problem]
  problem_summary$count <- problem_summary$count + sum(problem)
  problem <- !notes_ok %in% check_output$notes
  problem_summary$`missing notes` <- notes_ok[problem]
  problem_summary$count <- problem_summary$count + sum(problem)

  if (problem_summary$count > 0) {
    cat("
################################################################################

Summary of problems:", problem_summary$count, "problems found

################################################################################
")
    problem_summary$count <- NULL
    where_problem <- vapply(problem_summary, length, integer(1))
    problem_summary <- problem_summary[where_problem > 0]
    where_problem <- where_problem[where_problem > 0]
    for (i in seq_along(problem_summary)) {
      if (i > 1) {
        cat("
--------------------------------------------------------------------------------
")
      }
      cat(
        "\n", names(problem_summary)[i], ": ", where_problem[i], " problem",
        ifelse(where_problem[i] > 1, "s", ""), "\n\n", sep = ""
      )
      problem_list <- sprintf(
        "problem %i:\n\n%s",
        seq_along(problem_summary[[i]]), problem_summary[[i]]
      )
      cat(problem_list, sep = "\n\n")
    }
    cat("
################################################################################
")
    cat("
Please fix all problems. If a problem can't be fixed, you can silence the
problem by adding it to a `checklist.yml` file at the root of the package.

Use `checklist::checklist_template(checklist::check_package(fail = FALSE))` to
generate a template for `checklist.yml`.
")
    if (fail) {
      stop("Checking the package reveals some problems.")
    } else {
      cat("\nChecking the package reveals some problems.\n\n")
    }
  } else {
    cat("\nNo problems found. Good job!\n\n")
  }
  return(invisible(check_output))
}
