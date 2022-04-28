#' Prepare a `gh-pages` branch with a place holder page
#' @inheritParams read_checklist
#' @inheritParams gert::git_fetch
#' @export
#' @importFrom assertthat assert_that
#' @importFrom desc desc
#' @importFrom gert git_add git_branch git_branch_checkout git_branch_exists
#' git_commit git_rm git_status
#' @family setup
prepare_ghpages <- function(x = ".", verbose = TRUE) {
  x <- read_checklist(x)
  assert_that(x$package, msg = "prepare_ghpage is only intended for packages")
  clean_git(x$get_path, verbose = verbose)
  if (git_branch_exists("gh-pages", repo = x$get_path)) {
    if (verbose) {
      message("gh-pages branch already exists")
    }
    return(invisible(FALSE))
  }
  current_branch <- git_branch(repo = x$get_path)
  package_name <- desc(x$get_path)$get_field("Package")
  git_branch_checkout(branch = "gh-pages", repo = x$get_path, orphan = TRUE)
  existing <- git_status(repo = x$get_path)
  git_rm(existing$file, repo = x$get_path)
  file.remove(file.path(x$get_path, existing$file))
  writeLines(
    sprintf(
      "<html><body><h1>Place holder for the %s package</h1></body></html>",
      package_name
    ),
    file.path(x$get_path, "index.html")
  )
  git_add("index.html", repo = x$get_path, force = TRUE)
  git_commit("placeholder", repo = x$get_path)
  git_push(remote = "origin", repo = x$get_path, verbose = verbose)
  git_branch_checkout(branch = current_branch, repo = x$get_path)
  if (verbose) {
    message("gh-pages branch created and pushed")
  }
  return(invisible(TRUE))
}
