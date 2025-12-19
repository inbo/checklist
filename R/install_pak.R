#' Install extra packages defined in `checklist.yml`
#' @inheritParams read_checklist
#' @param ... Additional arguments passed to `pak::pkg_install()`
#' @export
install_pak <- function(x = ".", ...) {
  x <- read_checklist(x = x)
  stopifnot("`pak` is not available" = requireNamespace("pak"))
  if (length(x$get_pak) == 0) {
    return(invisible(NULL))
  }
  pak::pkg_install(pkg = x$get_pak, ...)
  return(invisible(NULL))
}
