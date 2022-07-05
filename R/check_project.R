#' Run the required quality checks on a project
#'
#' Set or update the required checks via `setup_project()`.
#' @inheritParams read_checklist
#' @inheritParams check_package
#' @export
#' @importFrom assertthat assert_that
#' @importFrom fs is_file
#' @family source
check_project <- function(x = ".", fail = !interactive(), quiet = FALSE) {
  assert_that(
    inherits(x, "checklist") || is_file(path(x, "checklist.yml")),
    msg = "Please initialise the project first with `setup_project()`"
  )

  x <- read_checklist(x = x)
  if (x$package) {
    return(check_package(x = x, fail = fail, quiet = quiet))
  }

  if ("spelling" %in% x$get_required) {
    quiet_cat("Checking spelling\n", quiet = quiet)
    x <- check_spelling(x = x, quiet = quiet)
  }

  if ("lintr" %in% x$get_required) {
    quiet_cat("Checking code style\n", quiet = quiet)
    x <- check_lintr(x = x)
  }

  if ("filename conventions" %in% x$get_required) {
    quiet_cat("Checking filename conventions\n", quiet = quiet)
    x <- check_filename(x = x)
  }

  print(x, quiet = quiet)
  if (!x$fail) {
    quiet_cat("\nNo problems found. Good job!\n\n", quiet = quiet)
    return(invisible(x))
  }
  assert_that(!fail, msg = "Checking the project revealed some problems.")

  quiet_cat("\nChecking the project revealed some problems.\n\n", quiet = quiet)

  return(invisible(x))
}
