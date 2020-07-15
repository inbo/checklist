#' Check the DESCRIPTION file
#' @inheritParams read_checklist
#' @importFrom assertthat has_name
#' @importFrom desc description
#' @importFrom git2r branches branch_target commits lookup_commit parents
#' repository repository_head reset sha when
#' @importFrom stats na.omit
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
  description <- desc::description$new(
    file = file.path(x$get_path, "DESCRIPTION")
  )

  version <- as.character(description$get_version())
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
  tidy_desc(description)
  description$write(file.path(x$get_path, "DESCRIPTION"))
  if (clean && !is_workdir_clean(repo)) {
    desc_error <- c(
      desc_error,
      "DESCRIPTION not tidy. Use `usethis::use_tidy_description()`"
    )
    if (length(unlist(status(repo, untracked = FALSE)))) {
      reset(repo)
    }
  }

  x$add_error(desc_error, "DESCRIPTION")
  return(x)
}

tidy_desc <- function(desc) {
  # Alphabetise dependencies
  deps <- desc$get_deps()
  deps <- deps[order(deps$type, deps$package), , drop = FALSE]
  desc$del_deps()
  desc$set_deps(deps)

  # Alphabetise remotes
  remotes <- desc$get_remotes()
  if (length(remotes) > 0) {
    desc$set_remotes(sort(remotes))
  }

  desc$set("Encoding" = "UTF-8")

  # Normalize all fields (includes reordering)
  # Wrap in a try() so it always succeeds, even if user options are malformed
  try(desc$normalize(), silent = TRUE)
}
