#' add checklist badges to a README
#'
#' - `check_package`: add a package check badge
#' - `check_project`: add a project check badge
#' @inheritParams read_checklist
#' @param ... Additional arguments
#' @importFrom assertthat assert_that
#' @importFrom fs dir_ls path
#' @export
#' @family both
#' @examples
#' \dontrun{
#'   add_badges(check_project = "inbo/checklist")
#'   add_badges(check_package = "inbo/checklist")
#' }
add_checklist_badges <- function(x = ".", ...) {
  x <- read_checklist(x = x)
  dir_ls(x$get_path, regexp = "README.R?md$") |> sort() |> tail(1) -> readme
  assert_that(length(readme) == 1, msg = "No README.md or README.Rmd found")
  text <- readLines(readme)
  badges_start <- grep("<!-- badges: start -->", text)
  assert_that(
    length(badges_start) == 1,
    msg = "Problematic badge delimiters in README"
  )
  dots <- list(...)
  # fmt: skip
  formats <- c(
    check_package = paste0(
      "[![R build status](https://github.com/%1$s/actions/workflows/",
      "check_on_main.yml/badge.svg)](https://github.com/%1$s/actions)"
    ),
    check_project = paste0(
      "[![Build status](https://github.com/%1$s/actions/workflows/",
      "check_project.yml/badge.svg)](https://github.com/%1$s/actions)"
    )
  )
  dots <- dots[names(dots) %in% names(formats)]
  formats <- formats[names(dots)]
  vapply(
    names(dots),
    FUN.VALUE = character(1),
    formats = formats,
    dots = dots,
    FUN = function(i, formats, dots) {
      list(fmt = formats[i]) |> c(dots[i]) |> do.call(what = sprintf)
    }
  ) -> new_badge
  head(text, badges_start) |>
    c(new_badge, tail(text, -badges_start)) |>
    writeLines(readme)
}
