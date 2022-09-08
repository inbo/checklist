#' Sort using the C locale
#'
#' Setting the locale before sorting ensures a stable sorting order
#' @inheritParams base::sort
#' @export
#' @family utils
c_sort <- function(x, ...) {
  old_ctype <- Sys.getlocale(category = "LC_CTYPE")
  old_collate <- Sys.getlocale(category = "LC_COLLATE")
  old_time <- Sys.getlocale(category = "LC_TIME")
  Sys.setlocale(category = "LC_CTYPE", locale = "C")
  Sys.setlocale(category = "LC_COLLATE", locale = "C")
  Sys.setlocale(category = "LC_TIME", locale = "C")
  on.exit(Sys.setlocale(category = "LC_CTYPE", locale = old_ctype), add = TRUE)
  on.exit(
    Sys.setlocale(category = "LC_COLLATE", locale = old_collate),
    add = TRUE
  )
  on.exit(Sys.setlocale(category = "LC_TIME", locale = old_time), add = TRUE)
  sort(x, ...)
}
