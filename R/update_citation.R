#' Create or update the citation files
#'
#' The function extracts citation meta data from the project.
#' Then it checks the required meta data.
#' Upon success, it writes several files.
#'
#' - `.zenodo.json` contains the citation information in the format that
#'   [Zenodo](https://zenodo.org) requires.
#' - `CITATION.cff` provides the citation information in the format that
#'   [GitHub](https://github.com) requires.
#' - `inst/CITATION` provides the citation information in the format that
#'   R packages require.
#'   It is only relevant for packages.
#'
#' @note
#'
#' Source of the citation meta data:
#' - package: `DESCRIPTION`
#' - project: `README.md`
#'
#' Should you want to add more information to the `inst/CITATION` file,
#' add it to that file outside `# begin checklist entry` and
#' `# end checklist entry`.
#'
#' @return An invisible `checklist` object.
#' @inheritParams read_checklist
#' @inheritParams check_package
#' @export
#' @importFrom assertthat assert_that
#' @importFrom citeme citation_meta
#' @importFrom desc description
#' @importFrom gert git_status
#' @importFrom utils file_test
#' @family both
update_citation <- function(x = ".", quiet = FALSE) {
  if (inherits(x, "checklist")) {
    cit_meta <- citation_meta$new(x$get_path)
  } else {
    cit_meta <- citation_meta$new(x)
  }
  x <- read_checklist(x = x)
  print(cit_meta, quiet = quiet)
  if (length(cit_meta$get_errors) > 0) {
    warning(cit_meta$get_errors)
  }
  x$add_warnings(as.character(cit_meta$get_warnings), item = "CITATION")
  x$add_error(cit_meta$get_errors, item = "CITATION", keep = FALSE)
  x$add_notes(cit_meta$get_notes, item = "CITATION")
  return(invisible(x))
}
