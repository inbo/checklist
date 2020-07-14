#' Check the DESCRIPTION file
#' @inheritParams read_checklist
#' @importFrom assertthat has_name
#' @importFrom git2r branches branch_target commits lookup_commit parents
#' repository repository_head reset sha when
#' @importFrom stats na.omit
#' @importFrom usethis use_tidy_description
#' @importFrom utils head tail
#' @export
check_description <- function(x = ".") {
  if (!inherits(x, "Checklist") || !"checklist" %in% x$get_checked) {
    x <- read_checklist(x = x)
  }
  assert_that(
    x$package,
    msg = "`check_description()` is only relevant for packages.
`checklist.yml` indicates this is not a package."
  )

  repo <- repository(x$get_path)
  description <- file.path(x$get_path, "DESCRIPTION")
  assert_that(file_test("-f", description), msg = "DESCRIPTION file missing")

  version <- read.dcf(description)[, "Version"]
  "Incorrect version tag format. Use `0.0`, `0.0.0`"[
    !grepl("^[0-9]+\\.[0-9]+(\\.[0-9]+)?$", version)
  ] -> desc_error

  if (length(commits(repo)) > 1) {
    branch_sha <- vapply(branches(repo, "all"), branch_target, character(1))
    head_sha <- sha(repository_head(repo))
    current_branch <- head(names(which(branch_sha == head_sha)), 1)
    if (length(current_branch) && current_branch == "master") {
      parent_commits <- parents(lookup_commit(repository_head(repo)))
      oldest <- head(order(vapply(parent_commits, when, character(1))), 1)
      old_sha <- sha(parent_commits[[oldest]])
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
  }
  clean <- is_workdir_clean(repo)
  use_tidy_description()
  if (clean && !is_workdir_clean(repo)) {
    desc_error <- c(
      desc_error,
      "DESCRIPTION not tidy. use `usethis::use_tidy_description()`"
    )
    reset(repo)
  }

  x$add_error(desc_error, "DESCRIPTION")
  return(x)
}
