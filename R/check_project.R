#' Run the required quality checks on a project
#'
#' Set or update the required checks via `setup_project()`.
#' @inheritParams read_checklist
#' @inheritParams check_package
#' @export
#' @importFrom assertthat assert_that
#' @importFrom fs is_file
#' @family project
check_project <- function(x = ".", fail = !interactive(), quiet = FALSE) {
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
    x <- check_lintr(x = x, quiet = quiet)
  }

  if ("folder conventions" %in% x$get_required) {
    quiet_cat("Checking folders conventions\n", quiet = quiet)
    x <- check_folder(x = x)
  }

  if ("filename conventions" %in% x$get_required) {
    quiet_cat("Checking filename conventions\n", quiet = quiet)
    x <- check_filename(x = x)
  }

  if ("license" %in% x$get_required) {
    quiet_cat("Checking the license\n", quiet = quiet)
    x <- check_license(x = x)
  }

  if ("CITATION" %in% x$get_required) {
    quiet_cat("Checking the citation information\n", quiet = quiet)
    x <- update_citation(x = x, quiet = quiet)
  }

  org <- org_list$new()$read(x$get_path)
  org$check(x = x$get_path) |>
    x$add_error(item = "organisation") -> x

  print(x, quiet = quiet)
  if (!x$fail) {
    quiet_cat("\nNo problems found. Good job!\n\n", quiet = quiet)
    return(invisible(x))
  }
  assert_that(!fail, msg = "Checking the project revealed some problems.")

  quiet_cat("\nChecking the project revealed some problems.\n\n", quiet = quiet)

  return(invisible(x))
}
