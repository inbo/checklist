#' Make sure that the required environment variables are set on GitHub
#'
#' Some actions will fail when these environment variables are not set.
#' This function does only work on GitHub.
#' @return An invisible `checklist` object.
#' @inheritParams read_checklist
#' @export
#' @family package
check_environment <- function(x = ".") {
  x <- read_checklist(x = x)
  if (!isTRUE(as.logical(Sys.getenv("GITHUB_ACTIONS", "FALSE")))) {
    x$add_error(character(0), item = "repository secret", keep = FALSE)
    return(invisible(x))
  }
  problems <- c(
    "CODECOV_TOKEN"[Sys.getenv("CODECOV_TOKEN") == ""]
  )
  if (length(problems) == 0) {
    x$add_error(character(0), item = "repository secret", keep = FALSE)
    return(invisible(x))
  }
  fmt <- paste0(
    "Missing repository secret(s) %s on GitHub.\nSee ",
    "https://inbo.github.io/checklist/articles/getting_started.html",
    "#online-setup-2 for more details."
  )
  x$add_error(
    sprintf(fmt = fmt, paste(problems, collapse = ", ")),
    item = "repository secret",
    keep = FALSE
  )
  return(invisible(x))
}
