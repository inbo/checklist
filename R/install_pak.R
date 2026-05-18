#' Install extra packages defined in `checklist.yml`
#' @inheritParams read_checklist
#' @param ... Additional arguments passed to `pak::pkg_install()`
#' @export
#' @family utils
install_pak <- function(x = ".", ...) {
  x <- read_checklist(x = x)
  stopifnot("`pak` is not available" = requireNamespace("pak"))
  if (length(x$get_pak) > 0) {
    pak::pkg_install(pkg = x$get_pak, ...)
  }
  if (length(x$get_gha_install) > 0) {
    warning(
      paste(x$get_gha_install, collapse = "\n"),
      immediate. = TRUE,
      call. = FALSE
    )
    if (
      isTRUE(ask_yes_no("Do you want to run these commands?", default = TRUE))
    ) {
      system(x$get_gha_install)
    }
  }
  return(invisible(NULL))
}
