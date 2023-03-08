#' @section Exceptions for some file formats:
#' Underscores (`_`) causes problems for graphical files when using LaTeX to
#' create pdf output.
#' This is how we generate pdf output from rmarkdown.
#' Therefore you need to use a dash (`-`) as separator instead of
#' an underscores (`_`).
#' Applies to files with extensions `eps`, `jpg`, `jpeg`, `pdf`, `png`, `ps`, `svg` and `.cls`.
#'
#' We ignore files with `.otf` or `.ttf` extensions.
#' These are fonts files which often require their own file name scheme.

