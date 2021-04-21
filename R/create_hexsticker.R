#' @title Make hexagonal logo for package
#'
#' @description This function makes a hexsticker in INBO style for the provided
#' package name.
#' It requires the package hexSticker to be installed.
#'
#' @param package_name package name that should be mentioned on the hexsticker
#' @param filename filename to save the sticker (default saved in man/figures)
#'
#' @return A figure is saved in the working directory or provided path
#'
#' @export
#'
#' @family utils
#'
#' @examples
#' # make tempfile to save logo (or just use (path and) filename)
#' output <- tempfile(pattern = "hexsticker", fileext = ".png")
#' create_hexsticker("checklist", filename = output)

create_hexsticker <-
  function(package_name, filename = "man/figures/hexsticker.png") {
  if (requireNamespace("hexSticker") & requireNamespace("showtext") &
      requireNamespace("sysfonts")) {
    background <- system.file("inbo-empty.png", package = "checklist")
    showtext::showtext_auto()
    sysfonts::font_add(
      family = "Flanders Art Sans",
      regular =
        system.file("fonts/flanders_art_sans_medium.ttf", package = "checklist")
    )
    hexSticker::sticker(
      background, s_x = 1, s_y = 1, s_width = 1, s_height = 1, asp = 0.85,
      package = package_name, p_y = 0.75, p_color = "#000000",
      p_family = "Flanders Art Sans", p_size = 24,
      h_color = "#c04384", filename = filename
    )
  } else {
    stop("Package hexSticker should be installed to create a hexsticker.")
  }
}