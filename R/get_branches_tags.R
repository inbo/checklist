#' Get branches and tags of a GitHub repository
#' @param owner Repository owner
#' @param repo Repository name
#' @return A sorted character vector of branch and tag names, excluding the
#'   `gh-pages` branch.
#' @importFrom gh gh
#' @export
#' @family git
get_branches_tags <- function(owner, repo) {
  paste("", "repos", "%s", "%s", "branches", sep = "/") |>
    sprintf(owner, repo) |>
    gh() |>
    vapply(FUN = `[[`, FUN.VALUE = character(1), "name") -> branches
  paste("", "repos", "%s", "%s", "tags", sep = "/") |>
    sprintf(owner, repo) |>
    gh() |>
    vapply(FUN = `[[`, FUN.VALUE = character(1), "name") -> tags
  c(branches[branches != "gh-pages"], tags) |>
    sort()
}
