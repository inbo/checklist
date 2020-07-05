#' Run the package checks required by CRAN
#' @inheritParams check_package
#' @importFrom assertthat assert_that is.string
#' @importFrom rcmdcheck rcmdcheck
#' @importFrom utils file_test
#' @export
check_cran <- function(path = ".") {
  assert_that(is.string(path))
  assert_that(
    file_test("-d", path),
    msg = "`path` is not a directory."
  )

  checklist <- read_checklist(path = path)
  check_output <- rcmdcheck(
    path = path,
    args = c("--timings", "--as-cran", "--no-manual"),
    error_on = "never"
  )

  problem_summary <- list(
    count = length(check_output$errors),
    errors = check_output$errors
  )

  warning_ok <- vapply(checklist$allowed$warnings, `[[`, character(1), "value")
  problem <- !check_output$warnings %in% warning_ok
  problem_summary$new_warnings <- check_output$warnings[problem]
  problem_summary$count <- problem_summary$count + sum(problem)
  problem <- !warning_ok %in% check_output$warnings
  problem_summary$`missing_warnings` <- warning_ok[problem]
  problem_summary$count <- problem_summary$count + sum(problem)

  notes_ok <- vapply(checklist$allowed$notes, `[[`, character(1), "value")
  problem <- !check_output$notes %in% notes_ok
  problem_summary$new_notes <- check_output$notes[problem]
  problem_summary$count <- problem_summary$count + sum(problem)
  problem <- !notes_ok %in% check_output$notes
  problem_summary$missing_notes <- notes_ok[problem]
  problem_summary$count <- problem_summary$count + sum(problem)

  return(
    list(
      check_output = check_output,
      problem_summary = problem_summary
    )
  )
}
