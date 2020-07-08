#' Write a check list with allowed issues in the package
#'
#' @inheritParams read_checklist
#' @inheritParams check_package
#' @importFrom yaml write_yaml
#' @export
write_checklist <- function(x = ".") {
  if (!inherits(x, "Checklist") || !"checklist" %in% x$get_checked) {
    x <- read_checklist(x = x)
  }
  if (!"rcmd" %in% x$get_checked) {
    x <- check_cran(x)
  }

  x$confirm_motivation("warnings")
  x$confirm_motivation("notes")
  x$add_motivation("warnings")
  x$add_motivation("notes")

  write_yaml(x$template, file.path(x$get_path, "checklist.yml"))
  return(invisible(NULL))
}
