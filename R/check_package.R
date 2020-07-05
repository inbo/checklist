#' A standardised test for R packages
#'
#' @param path The path of the package.
#' Defaults to `"."`
#' @param fail Should the function return an error in case of a problem?
#' Defaults to `TRUE`.
#' @importFrom assertthat assert_that is.flag is.string noNA
#' @importFrom lintr lint_package
#' @importFrom utils file_test
#' @export
check_package <- function(path = ".", fail = TRUE) {
  old_lint_option <- getOption("lintr.rstudio_source_markers", TRUE)
  options(lintr.rstudio_source_markers = FALSE)
  on.exit(options(lintr.rstudio_source_markers = old_lint_option))

  assert_that(is.string(path))
  assert_that(
    file_test("-d", path),
    msg = "`path` is not a directory."
  )
  assert_that(is.flag(fail))
  assert_that(noNA(fail))

  check_output <- check_cran(path = path)
  problem_summary <- check_output$problem_summary
  check_output <- check_output$check_output

  cat("
--------------------------------------------------------------------------------

Checking code style\n")
  lint_output <- lint_package(path = ".")
  cat("\n")
  if (length(lint_output)) {
    print(lint_output)
  } else {
    cat("no code style issues\n")
  }
  problem_summary$count <- problem_summary$count + length(lint_output)
  lint_m <- sort(table(vapply(lint_output, `[[`, character(1), "message")))
  problem_summary$linters <- sprintf("%2i files with %s", lint_m, names(lint_m))

  names(problem_summary) <- gsub("_", " ", names(problem_summary))

  if (problem_summary$count > 0) {
    cat("
################################################################################

Summary of problems:", problem_summary$count, "problem",
    ifelse(problem_summary$count > 1, "s", ""),
    " found

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
