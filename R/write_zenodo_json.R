#' Write a `.zenodo.json` file
#'
#' Zenodo uses the `.zenodo.json` file to define the citation information.
#' See the [Zenodo developers website](
#'https://developers.zenodo.org/#add-metadata-to-your-github-repository-release)
#' for more information.
#'
#' @return An invisible `checklist` object.
#' @inheritParams read_checklist
#' @export
#' @importFrom assertthat assert_that
#' @importFrom desc description
#' @importFrom jsonlite toJSON
#' @importFrom gert git_status
#' @family package
write_zenodo_json <- function(x = ".") {
  .Deprecated(new = "update_citation", package = "checklist") # nocov start
  x <- update_citation(x = x)
  return(x) # nocov end
}

lang_2_iso_639_3 <- function(lang) {
  if (lang %in% iso_639_3$alpha_3) {
    return(lang)
  }
  short <- gsub("-.*", "", lang)
  if (short %in% iso_639_3$alpha_2) {
    return(iso_639_3$alpha_3[iso_639_3$alpha_2 == short])
  }
  attr(lang, "problem") <-
    "Language field in DESCRIPTION must be a valid language.
E.g. en-GB for (British) English and nl-BE for (Flemish) Dutch."
  return(lang)
}
