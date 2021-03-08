#' @title Make hexagonal logo for package
#'
#' @description This function makes a hexsticker in INBO style for the provided
#' package name.
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
#' create_hexsticker("checklist", filename = "hexsticker.png")

create_hexsticker <-
  function(package_name, filename = "man/figures/hexsticker.png") {
  if (require("hexSticker")) {
    background <- system.file("inbo-empty.png", package = "checklist")
    sticker(
      background, s_x = 1, s_y = 1, s_width = 1, s_height = 1, asp = 0.85,
      package = package_name, p_y = 0.75, p_color = "#000000",
      p_family = "Flanders Art Sans", p_size = 24, p_fontface = "bold",
      h_color = "#c04384", filename = filename
    )
  }
}

