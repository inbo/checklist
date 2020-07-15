#' Set a new tag
#' @export
#' @inheritParams read_checklist
#' @importFrom assertthat assert_that
#' @importFrom git2r config push repository tag
set_tag <- function(x = ".") {
  if (Sys.getenv("GITHUB_REF") != "refs/heads/master") {
    message("Not on GitHub or not on master.")
    return(invisible(NULL))
  }
  if (!inherits(x, "Checklist") || !"checklist" %in% x$get_checked) {
    x <- read_checklist(x = x)
  }
  assert_that(
    x$package,
    msg = "`check_description()` is only relevant for packages.
`checklist.yml` indicates this is not a package."
  )
  repo <- repository(x$get_path)
  description <- desc::description$new(
    file = file.path(x$get_path, "DESCRIPTION")
  )
  version <- as.character(description$get_version())
  news <- readLines(file.path(x$get_path, "NEWS.md"))
  regex <- paste("#", description$get("Package"), "[0-9]+\\.[0-9]+(\\.[0-9]+)")
  start <- grep(regex, news)
  end <- c(tail(start, -1) - 1, length(news))
  current <- grepl(paste("#", description$get("Package"), version), news[start])
  assert_that(any(current), msg = "Current version not found in NEWS.md")
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
    user.name = "Checklist package",
    user.email = "checklist@inbo.be"
  )
  tag(
    repo,
    name = paste0("v", version),
    message = paste(news[seq(start[current], end[current])], collapse = "\n")
  )
  push(repo)
}
