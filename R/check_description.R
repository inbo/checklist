#' Check the DESCRIPTION file
#' @inheritParams read_checklist
#' @importFrom assertthat has_name
#' @importFrom git2r branches branch_target commits repository repository_head
#' sha
#' @importFrom stats na.omit
#' @importFrom utils head tail
#' @export
check_description <- function(x = ".") {
  if (!inherits(x, "Checklist") || !"checklist" %in% x$get_checked) {
    x <- read_checklist(x = x)
  }

  repo <- repository(x$get_path)
  description <- file.path(x$get_path, "DESCRIPTION")
  assert_that(file_test("-f", description), msg = "DESCRIPTION file missing")

  version <- read.dcf(description)[, "Version"]
  "Incorrect version tag format. Use `0.0`, `0.0.0`"[
    !grepl("^[0-9]+\\.[0-9]+(\\.[0-9]+)?$", version)
  ] -> desc_error

  branch_sha <- vapply(branches(repo, "all"), branch_target, character(1))
  head_sha <- sha(repository_head(repo))
  current_branch <- head(names(which(branch_sha == head_sha)), 1)
  if (current_branch == "master") {
    old_sha <- vapply(
      tail(commits(repo, ref = "master", n = 2), 1), sha, character(1)
    )
    desc_diff <- system2(
      "git", args = c("diff", old_sha, head_sha, "DESCRIPTION"),
      stdout = TRUE
    )
  } else {
    desc_diff <- system2(
      "git", args = c("diff", "origin/master", "--", "DESCRIPTION"),
      stdout = TRUE
    )
  }
  old_version <- desc_diff[grep("\\-Version: ", desc_diff)]
  old_version <- gsub("-Version: ", "", old_version)
  version_bump <- ifelse(
    length(old_version),
    ifelse(
      package_version(old_version) < package_version(version),
      NA,
      "Package version not increased"
    ),
    "Package version not updated"
  )
  desc_error <- c(desc_error, na.omit(version_bump))

  x$add_error(desc_error, "DESCRIPTION")
  return(x)
}
