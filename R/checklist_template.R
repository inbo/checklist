#' Create a template with acceptable problems in the package
#'
#' @inheritParams read_checklist
#' @inheritParams check_package
#' @importFrom yaml write_yaml
#' @export
checklist_template <- function(x = ".") {
  if (!inherits(x, "Checklist") || !"checklist" %in% x$get_checked) {
    x <- read_checklist(x = x)
  }
  if (!"rcmdcheck" %in% x$get_checked) {
    x <- check_cran(x)
  }

  write_yaml(x$template, file.path(x$get_path, "checklist_template.yml"))
  return(invisible(NULL))
}
