#' Check the package metadata
#'
#' Use the checks from [codemetar::give_opinions()].
#' @inheritParams read_checklist
#' @return A `checklist` object.
#' @importFrom assertthat assert_that
#' @importFrom codemetar give_opinions
#' @importFrom gert git_status
#' @export
#' @family package
check_codemeta <- function(x = ".") {
  x <- read_checklist(x = x)
  assert_that(
    x$package,
    msg = "`check_codemeta()` is only relevant for packages.
`checklist.yml` indicates this is not a package."
  )

  repo <- x$get_path
  status_before <- git_status(repo = repo)
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(x$get_path)
  opinions <- give_opinions(x$get_path)
  x$add_error(
    "Code metadata needs to be updated. Run `codemetar::write_codemeta()`."[
      !unchanged_repo(repo, status_before)
    ],
    item = "codemeta", keep = FALSE
  )
  x$add_notes(
    sprintf("in %s fix %s", opinions$where, opinions$fixme), "codemeta"
  )

  return(x)
}
