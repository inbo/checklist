#' Make sure that the required environment variables are set on GitHub
#'
#' Some actions will fail when these environment variables are not set.
#' This function does only work on GitHub.
#' @return An invisible `Checklist` object.
#' @inheritParams read_checklist
#' @export
check_environment <- function(x = ".") {
  x <- read_checklist(x = x)
  if (!isTRUE(as.logical(Sys.getenv("GITHUB_ACTIONS", "FALSE")))) {
    return(invisible(x))
  }
  problems <- c(
    "PAT"[Sys.getenv("INPUT_TOKEN") == ""],
    "ORCID_TOKEN"[Sys.getenv("ORCID_TOKEN") == ""],
    "CODECOV_TOKEN"[Sys.getenv("CODECOV_TOKEN") == ""]
  )
  if (length(problems) == 0) {
    return(invisible(x))
  }
  fmt <- paste(
    "Missing repository secret(s) %s on GitHub.\nSee",
"https://inbo.github.io/checklist/articles/getting_started.html#online-setup-2",
    "for more details."
  )
  x$add_error(
    sprintf(fmt = fmt, paste(problems, collapse = ", ")),
    "repository secret"
  )
  return(invisible(x))
}
