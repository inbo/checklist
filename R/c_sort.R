#' Sort using the C locale
#'
#' Setting the locale before sorting ensures a stable sorting order
#' @inheritParams base::sort
#' @export
#' @importFrom withr defer
#' @family utils
c_sort <- function(x, ...) {
  old_ctype <- Sys.getlocale(category = "LC_CTYPE")
  old_collate <- Sys.getlocale(category = "LC_COLLATE")
  old_time <- Sys.getlocale(category = "LC_TIME")
  Sys.setlocale(category = "LC_CTYPE", locale = "C")
  Sys.setlocale(category = "LC_COLLATE", locale = "C")
  Sys.setlocale(category = "LC_TIME", locale = "C")
  defer(Sys.setlocale(category = "LC_CTYPE", locale = old_ctype))
  defer(Sys.setlocale(category = "LC_COLLATE", locale = old_collate))
  defer(Sys.setlocale(category = "LC_TIME", locale = old_time))
  sort(x, ...)
}
