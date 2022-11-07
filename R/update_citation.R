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
#' @importFrom desc description
#' @importFrom gert git_status
#' @importFrom utils file_test
#' @family package
update_citation <- function(x = ".", quiet = FALSE) {
  x <- read_checklist(x = x)
  cit_meta <- citation_meta$new(x$get_path)
  print(cit_meta, quiet = quiet)
  if (length(cit_meta$get_warnings) > 0) {
    x$add_warnings(cit_meta$get_warnings, "CITATION")
  }
  if (length(cit_meta$get_errors) > 0) {
    x$add_error(cit_meta$get_errors, item = "CITATION", keep = FALSE)
  }
  if (length(cit_meta$get_notes) > 0) {
    x$add_notes(cit_meta$get_notes, item = "CITATION")
  }
  return(invisible(x))
}
