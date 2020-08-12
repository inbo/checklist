#' Set a new tag
#' @export
#' @inheritParams read_checklist
#' @importFrom assertthat assert_that
#' @importFrom git2r config repository tag tags
#' @family package
set_tag <- function(x = ".") {
  if (
    !as.logical(Sys.getenv("GITHUB_ACTIONS", "false")) ||
      Sys.getenv("GITHUB_REF") != "refs/heads/master" ||
      Sys.getenv("GITHUB_EVENT_NAME") != "push"
  ) {
    message("Not on GitHub, not a push or not on master.")
    return(invisible(NULL))
  }
  if (!inherits(x, "Checklist") || !"checklist" %in% x$get_checked) {
    x <- read_checklist(x = x)
  }
  assert_that(
    x$package,
    msg = "`set_tag()` is only relevant for packages.
`checklist.yml` indicates this is not a package."
  )
  repo <- repository(x$get_path)
  description <- description$new(
    file = file.path(x$get_path, "DESCRIPTION")
  )
  version <- as.character(description$get_version())
  news <- readLines(file.path(x$get_path, "NEWS.md"))
  regex <- paste("#", description$get("Package"), "[0-9]+\\.[0-9]+(\\.[0-9]+)")
  start <- grep(regex, news)
  end <- c(tail(start, -1) - 1, length(news))
  current <- grepl(paste("#", description$get("Package"), version), news[start])
  assert_that(any(current), msg = "Current version not found in NEWS.md")
  if (paste0("v", version) %in% names(tags(repo))) {
    message("tag v", version, " already exists.")
    return(invisible(NULL))
  }
  old_config <- config(repo)
  on.exit({
    config(
      repo,
      user.name = old_config$local$user.name,
      user.email = old_config$local$user.email
    )
  })
  config(
    repo = repo,
    user.name = "Checklist bot",
    user.email = "checklist@inbo.be"
  )
  tag(
    repo,
    name = paste0("v", version),
    message = paste(news[seq(start[current], end[current])], collapse = "\n")
  )
  system2("git", args = c("push", paste0("v", version)))
  return(invisible(NULL))
}
