#' @title Make hexagonal logo for package
#'
#' @description This function makes a hexsticker in INBO style for the provided
#' package name.
#'
#' @param package_name package name that should be mentioned on the hexsticker
#' @param filename filename to save the sticker
#' @param icon optional filename to an svg file with an icon
#' @param scale Scales the `icon`.
#' @param x number of pixels to move the icon to the right.
#' Use negative numbers to move the icon to the left.
#' @param y number of pixels to move the icon to the bottom.
#' Use negative numbers to move the icon to the top.
#' @return A figure is saved in the working directory or provided path
#'
#' @export
#'
#' @family utils
#'
#' @examples
#' # make tempfile to save logo (or just use (path and) filename)
#' output <- tempfile(pattern = "hexsticker", fileext = ".svg")
#' create_hexsticker("checklist", filename = output)
#' @importFrom assertthat assert_that is.number
#' @importFrom utils browseURL
create_hexsticker <- function(
  package_name, filename = file.path("man", "figures", "logo.svg"), icon,
  x = 0, y = 0, scale = 1
) {
  base <- readLines(system.file("logo-background.svg", package = "checklist"))
  svg_name <- string2svg(package_name)
  text_size <- c(max(svg_name$x), max(svg_name$y))
  text_max_size <- c(454.6, 122)
  scaling <- min(text_max_size / text_size)
  svg_name$x <- svg_name$x - text_size[1] / 2
  svg_name$y <- svg_name$y - text_size[2] / 2
  svg_name[, c("x", "y")] <- scaling * svg_name[, c("x", "y")]
  svg_name$x <- svg_name$x + 260
  svg_name$y <- svg_name$y + 374
  svg_name <- sprintf(
    "%s %.2f %.2f%s", svg_name$command, svg_name$x, svg_name$y,
    c("", " Z")[c(0, diff(svg_name$path)) + 1]
  )
  svg_name <- sprintf(
    "  <g id=\"package: %s\">
    <path style=\"fill:#3C3D00\"  d=\"%s\"/>
  </g>",
  package_name, paste(svg_name, collapse = " ")
  )
  if (missing(icon)) {
    writeLines(c(head(base, -1), svg_name, tail(base, 1)), filename)
    return(browseURL(filename))
  }
  assert_that(is.number(scale), scale > 0, scale < 1)
  icon_svg <- prepare_icon(icon)
  viewbox <- sprintf(
    "<svg viewBox=\"0 0 %s %s\" x=\"%.1f\" y=\"%.1f\" width=\"%.1f%%\">",
    icon_svg$width, icon_svg$height, x, y, 100 * scale
  )
  writeLines(
    c(head(base, -1), svg_name, viewbox, icon_svg$svg, "</svg>", tail(base, 1)),
    filename
  )
  return(browseURL(filename))
}

#' @importFrom assertthat assert_that is.string
#' @importFrom graphics plot.new text
#' @importFrom grDevices dev.off svg
string2svg <- function(string) {
  assert_that(is.string(string))
  assert_that(requireNamespace("sysfonts"), msg = "Please install sysfonts")
  assert_that(requireNamespace("showtext"), msg = "Please install showtext")
  sysfonts::font_add(
    family = "Flanders Art Sans",
    regular =
      system.file("fonts/flanders_art_sans_medium.ttf", package = "checklist")
  )
  showtext::showtext_auto()
  tmp <- tempfile(fileext = ".svg")
  svg(tmp)
  plot.new()
  text(0.5, 0.5, string, family = "Flanders Art Sans", cex = 4)
  dev.off()
  svg_string <- readLines(tmp, encoding = "UTF8")
  svg_string <- head(tail(svg_string, -4), -2)
  svg_string <- gsub("<path .* d=\"(.*) \"/>", "\\1", svg_string)
  svg_string <- unlist(strsplit(svg_string, " ?Z ?"))
  svg_string <- vapply(
    strsplit(svg_string, " "),
    function(x) {
      x <- t(matrix(x, nrow = 3))
      colnames(x) <- c("command", "x", "y")
      x <- as.data.frame(x)
      x$x <- as.numeric(x$x)
      x$y <- as.numeric(x$y)
      return(list(x))
    },
    vector("list", 1)
  )
  svg_string <- svg_string[vapply(svg_string, nrow, integer(1)) > 1]
  svg_string <- do.call(rbind, svg_string)
  svg_string$path <- cumsum(svg_string$command == "M")
  svg_string$x <- svg_string$x - min(svg_string$x)
  svg_string$y <- svg_string$y - min(svg_string$y)
  scaling <- max(svg_string[, c("x", "y")])
  svg_string[, c("x", "y")] <- svg_string[, c("x", "y")] / scaling
  unlink(tmp)
  return(svg_string)
}

prepare_icon <- function(icon) {
  assert_that(is.string(icon))
  icon <- normalizePath(icon)
  base <- readLines(icon)
  base <- paste(base, collapse = "")
  if (grepl("viewBox", base)) {
    view_box <- gsub(".*?viewBox ?= ?\"?(.*?)\">.*", "\\1", base)
    view_box <- gsub("\".*", "", view_box)
    view_box <- strsplit(view_box, " ")[[1]]
    width <- view_box[3]
    height <- view_box[4]
  } else {
    width <- gsub(
      ".*<svg.*width=\"(.*)p(t|x)\" height=\"(.*)p(t|x)\".*>", "\\1", base
    )
    height <- gsub(
      ".*<svg.*width=\"(.*)p(t|x)\" height=\"(.*)p(t|x)\".*>", "\\3", base
    )
  }
  base <- gsub(".*<svg.*?>(.*)</svg>", "\\1", base)
  list(svg = base, width = width, height = height)
}
