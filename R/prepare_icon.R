#' @importFrom assertthat assert_that is.string
prepare_icon <- function(icon) {
  assert_that(is.string(icon))
  icon <- normalizePath(icon, winslash = "/", mustWork = TRUE)
  base <- readLines(icon)
  base <- paste(base, collapse = "")
  if (grepl("viewBox", base)) {
    view_box <- gsub(".*?viewBox ?= ?[\"\']?(.*?)[\"\']>.*", "\\1", base)
    view_box <- gsub("\".*", "", view_box)
    view_box <- strsplit(view_box, " ")[[1]]
    width <- view_box[3]
    height <- view_box[4]
  } else {
    width <- gsub(
      ".*<svg.*width=[\"\'](.*)p(t|x)[\"\'] height=[\"\'](.*)p(t|x)[\"\'].*>",
      "\\1",
      base
    )
    height <- gsub(
      ".*<svg.*width=[\"\'](.*)p(t|x)[\"\'] height=[\"\'](.*)p(t|x)[\"\'].*>",
      "\\3",
      base
    )
  }
  base <- gsub(".*<svg.*?>(.*)</svg>", "\\1", base)
  list(svg = base, width = width, height = height)
}
