#' Check the `DESCRIPTION` file
#'
#' The `DESCRIPTION` file contains the most important meta-data of the package.
#' A good `DESCRIPTION` is tidy, has a meaningful version number, full
#' author details and a clear license.
#'
#' This function ensures the `DESCRIPTION` is tidy, using `tidy_desc()`.
#'
#' The version number of the package must have either a `0.0` or a `0.0.0`
#' format (see [this discussion](https://github.com/inbo/checklist/issues/1) why
#' we allow only these formats).
#' The version number in every branch must be larger than the current version
#' number in the master branch.
#' New commits in the master must have a larger version number than the previous
#' commit.
#' We recommend to protect the master branch and to not commit into the master.
#'
#' Furthermore we check the author information.
#' - Is INBO listed as copyright holder and funder?
#' - Has every author an ORCID?
#'
#' We check the license through `check_license()`.
#'
#' @inheritParams read_checklist
#' @importFrom assertthat assert_that
#' @importFrom desc description
#' @importFrom git2r branches branch_target commits lookup_commit parents
#' repository repository_head sha when
#' @importFrom stats na.omit
#' @importFrom utils head tail
#' @export
#' @family package
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
  description <- description$new(
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
  status_before <- status(repo)
  tidy_desc(x)
  desc_error <- c(
    desc_error,
    "DESCRIPTION not tidy. Use `checklist::tidy_desc()`"[
      !unchanged_repo(repo, status_before)
    ],
    check_authors(description)
  )
  x$add_error(desc_error, "DESCRIPTION")

  check_license(x = x)
}

#' Make your DESCRIPTION tidy
#'
#' A tidy `DESCRIPTION` uses a strict formatting and order of key-value pairs.
#' This function reads the current `DESCRIPTION` and overwrites it with a tidy
#' version.
#' @inheritParams read_checklist
#' @export
#' @importFrom desc description
#' @family package
tidy_desc <- function(x = ".") {
  if (!inherits(x, "Checklist") || !"checklist" %in% x$get_checked) {
    x <- read_checklist(x = x)
  }

  # set locale to get a stable sorting order
  old_ctype <- Sys.getlocale(category = "LC_CTYPE")
  old_collate <- Sys.getlocale(category = "LC_COLLATE")
  old_time <- Sys.getlocale(category = "LC_TIME")
  Sys.setlocale(category = "LC_CTYPE", locale = "C")
  Sys.setlocale(category = "LC_COLLATE", locale = "C")
  Sys.setlocale(category = "LC_TIME", locale = "C")
  on.exit(Sys.setlocale(category = "LC_CTYPE", locale = old_ctype), add = TRUE)
  on.exit(
    Sys.setlocale(category = "LC_COLLATE", locale = old_collate),
    add = TRUE
  )
  on.exit(Sys.setlocale(category = "LC_TIME", locale = old_time), add = TRUE)

  # turn crayon off
  old_crayon <- getOption("crayon.enabled")
  on.exit(options("crayon.enabled" = old_crayon), add = TRUE)
  options("crayon.enabled" = FALSE)

  desc <- description$new(file.path(x$get_path, "DESCRIPTION"))

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
  desc$write(file.path(x$get_path, "DESCRIPTION"))
  return(desc)
}

unchanged_repo <- function(repo, old_status) {
  current_status <- status(repo)
  identical(
    current_status$staged,
    old_status$staged
  ) &&
    identical(
      current_status$unstaged,
      old_status$unstaged
    ) &&
    identical(
      current_status$untracked,
      old_status$untracked
    )
}

#' Check the license of a package
#'
#' Every package needs a clear license.
#' Without a license, the end-users have no clue under what conditions they can
#' use the package.
#' You must specify the license in the `DESCRIPTION` and provide a `LICENSE.md`
#' file.
#'
#' @details
#' This functions checks if the `DESCRIPTION` mentions one of the standard
#' licenses.
#' The `LICENSE.md` must match this license.
#' Use `setup_package()` to add the correct `LICENSE.md` to the package.
#'
#' Currently, following licenses are allowed:
#' - GPL-3
#'
#' We will consider pull requests adding support for other open source licenses.
#'
#' @inheritParams read_checklist
#' @importFrom assertthat assert_that
#' @importFrom desc description
#' @export
#' @family package
check_license <- function(x = ".") {
  if (!inherits(x, "Checklist") || !"checklist" %in% x$get_checked) {
    x <- read_checklist(x = x)
  }
  assert_that(
    x$package,
    msg = "`check_license()` is only relevant for packages.
`checklist.yml` indicates this is not a package."
  )
  description <- description$new(
    file = file.path(x$get_path, "DESCRIPTION")
  )

  # check if the license is allowed
  problems <- sprintf(
    "%s license currently not allowed.
Please send a pull request if you need support for this license.",
    description$get_field("License")
  )[
    !description$get_field("License") %in% c("GPL-3")
  ]

  # check if LICENSE.md exists
  if (!file_test("-f", file.path(x$get_path, "LICENSE.md"))) {
    x$add_error(
      errors = c(problems, "No LICENSE.md file"),
      item = "license"
    )
    return(x)
  }

  # check if LICENSE.md matches the official version
  current <- readLines(file.path(x$get_path, "LICENSE.md"))
  official <- switch(
    description$get_field("License"),
    "GPL-3" = system.file("generic_template", "gplv3.md", package = "checklist")
  )
  official <- readLines(official)
  x$add_error(
    errors = c(
      problems,
      "LICENSE.md doesn't match the version in the checklist package"[
        (length(current) != length(official)) || any(current != official)
      ]
    ),
    item = "license"
  )

  return(x)
}

check_authors <- function(description) {
  authors <- description$get_authors()
  authors <- lapply(authors, unlist, recursive = FALSE)
  inbo <- person(
    given = "Research Institute for Nature and Forest",
    role = c("cph", "fnd"), email = "info@inbo.be"
  )
  problems <- paste(
    "Research Institute for Nature and Forest must be listed as copyright",
    "holder and funder and use info@inbo.be as email."
  )[!inbo %in% authors]
  authors <- authors[!authors %in% inbo]
  orcid <- sapply(authors, `[[`, "comment")
  c(
    problems,
    "Every author and contributor must have an ORCID"[
      any(names(orcid) != "ORCID")
    ]
  )

}
