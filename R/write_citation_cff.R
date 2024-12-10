#' Write a `CITATION.cff` file
#'
#' This file format contains the citation information.
#' It is supported by GitHub, Zenodo and Zotero.
#' This function is super-seeded by `update_citation()`.
#'
#' @return An invisible `checklist` object.
#' @inheritParams read_checklist
#' @param roles No longer used.
#' @export
#' @importFrom assertthat assert_that
#' @family both
write_citation_cff <- function(x = ".", roles) {
  # nocov start
  .Deprecated(new = "update_citation", package = "checklist")
  x <- update_citation(x = x)
  return(invisible(x))
  # nocov end
}
