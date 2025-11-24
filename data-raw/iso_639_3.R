iso_raw <- readLines(
  "https://iso639-3.sil.org/sites/iso639-3/files/downloads/iso-639-3.tab",
  encoding = "UTF-8"
)
iso_list <- strsplit(iso_raw[-1], split = "\t")
iso_639_3 <- data.frame(
  alpha_3 = vapply(iso_list, `[`, character(1), 1),
  alpha_2 = vapply(iso_list, `[`, character(1), 4),
  name = vapply(iso_list, `[`, character(1), 7)
)
email_regexp <- paste0(
  "([-!#-'*+\\/-9=?A-Z^-~]+(\\.[-!#-'*+\\/-9=?A-Z^-~]+)*|\"([]!#-[^-~ \\t]|(\\",
  "\\[\\t -~]))+\")@([0-9A-Za-z]([0-9A-Za-z-]{0,61}[0-9A-Za-z])?(\\.[0-9A-Za-z",
  "]([0-9A-Za-z-]{0,61}[0-9A-Za-z])?)*|\\[((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9",
  "]?[0-9])(\\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}|IPv6:((((0|[1-9",
  "A-Fa-f][0-9A-Fa-f]{0,3}):){6}|::((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){5}|[0-9A",
  "-Fa-f]{0,4}::((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){4}|(((0|[1-9A-Fa-f][0-9A-Fa",
  "-f]{0,3}):)?(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}))?::((0|[1-9A-Fa-f][0-9A-Fa-f]{0",
  ",3}):){3}|(((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){0,2}(0|[1-9A-Fa-f][0-9A-Fa-f]",
  "{0,3}))?::((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){2}|(((0|[1-9A-Fa-f][0-9A-Fa-f]",
  "{0,3}):){0,3}(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}))?::(0|[1-9A-Fa-f][0-9A-Fa-f]{0",
  ",3}):|(((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){0,4}(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3",
  "}))?::)((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3})|(25",
  "[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|",
  "[1-9]?[0-9])){3})|(((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){0,5}(0|[1-9A-Fa-f][0-",
  "9A-Fa-f]{0,3}))?::(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3})|(((0|[1-9A-Fa-f][0-9A-Fa-",
  "f]{0,3}):){0,6}(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}))?::)|(?!IPv6:)[0-9A-Za-z-]*[",
  "0-9A-Za-z]:[!-Z^-~]+)])"
)
graphics_ext <- c(
  "csl",
  "eps",
  "gif",
  "jpg",
  "jpeg",
  "pdf",
  "png",
  "ps",
  "svg",
  "tiff",
  "tif",
  "wmf"
)
sprintf("`%s`", graphics_ext) |>
  paste(collapse = ", ") |>
  sprintf(
    fmt = "#' @section Exceptions for some file formats:
#' Underscores (`_`) causes problems for graphical files when using LaTeX to
#' create pdf output.
#' This is how we generate pdf output from rmarkdown.
#' Therefore you need to use a dash (`-`) as separator instead of
#' an underscores (`_`).
#' Applies to files with extensions %s and `.cls`.
#'
#' We ignore files with `.otf` or `.ttf` extensions.
#' These are fonts files which often require their own file name scheme.
"
  ) |>
  writeLines("man-roxygen/graphics.R")
open_data_ext <- c("csv", "gpkg", "tsv", "txt")
save(
  email_regexp,
  graphics_ext,
  iso_639_3,
  open_data_ext,
  file = "R/sysdata.rda"
)
