#' add badges to a README
#'
#' - `doi`: add a DOI badge
#' - `url`: add a website badge
#' @inheritParams read_checklist
#' @param ... Aditional arguments
#' @importFrom assertthat assert_that
#' @importFrom fs dir_ls path
#' @export
#' @family both
#' @examples
#' \dontrun{
#'   add_badges(url = "https://www.inbo.be")
#'   add_badges(doi = "10.5281/zenodo.8063503")
#'   add_badges(url = "https://www.inbo.be", doi = "10.5281/zenodo.8063503")
#' }
add_badges <- function(x = ".", ...) {
  x <- read_checklist(x = x)
  dir_ls(x$get_path, regexp = "README.R?md$") |>
    sort() |>
    tail(1) -> readme
  assert_that(length(readme) == 1, msg = "No README.md or README.Rmd found")
  text <- readLines(readme)
  badges_start <- grep("<!-- badges: start -->", text)
  assert_that(
    length(badges_start) == 1, msg = "Problematic badge delimiters in README"
  )
  dots <- list(...)
  formats <- c(
    url =
      "[![website](https://img.shields.io/badge/website-%1$s-c04384)](%1$s)",
    doi =
"[![DOI](https://https://zenodo.org/badge/DOI/%1$s.svg)](https://doi.org/%1$s)"
  )
  dots <- dots[names(formats)]
  formats <- formats[names(dots)]
  vapply(
    names(dots), FUN.VALUE = character(1), formats = formats, dots = dots,
    FUN = function(i, formats, dots) {
      list(fmt = formats[i]) |>
        c(dots[i]) |>
        do.call(what = sprintf)
    }
  ) -> new_badge
  head(text, badges_start) |>
    c(new_badge, tail(text, - badges_start)) |>
    writeLines(readme)
}
