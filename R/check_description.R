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
#' number in the main or master branch.
#' New commits in the main or master must have a larger version number than the
#' previous commit.
#' We recommend to protect the main or master branch and to not commit into the
#' main or master.
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
#' @importFrom fs path
#' @importFrom gert git_branch_list git_commit_id git_diff git_info
#' git_log git_stat_files git_status
#' @importFrom stats na.omit
#' @importFrom utils head tail
#' @export
#' @family package
check_description <- function(x = ".") {
  x <- read_checklist(x = x)
  assert_that(
    x$package,
    msg = "`check_description()` is only relevant for packages.
`checklist.yml` indicates this is not a package."
  )

  repo <- x$get_path
  this_desc <- description$new(file = path(x$get_path, "DESCRIPTION"))

  version <- as.character(this_desc$get_version())
  "Incorrect version tag format. Use `0.0` or `0.0.0`"[
    !grepl("^[0-9]+\\.[0-9]+(\\.[0-9]+)?$", version)
  ] -> desc_error
  notes <- character(0)
  if (!is.na(git_info(repo = repo)$head) && nrow(git_log(repo = repo)) > 1) {
    branch_info <- git_branch_list(repo = repo)
    head_sha <- git_commit_id(repo = repo)
    current_branch <- head(branch_info$name[branch_info$commit == head_sha], 1)
    if (length(current_branch) && current_branch %in% c("main", "master")) {
"Branch master detected. From Oct. 1, 2020, any new repositories you create uses
main as the default branch, instead of master. You can rename the default branch
from the web. More info on https://github.com/github/renaming"[
  current_branch == "master"
] -> notes
      descr_stats <- git_stat_files("DESCRIPTION", repo = repo)
      desc_diff <- git_diff(descr_stats$head, repo = repo)
      desc_diff <- desc_diff$patch[desc_diff$old == "DESCRIPTION"]
      desc_diff <- strsplit(desc_diff, "\n", fixed = TRUE)[[1]]
    } else {
      assert_that(
        all(
          grepl("origin", branch_info$name[!branch_info$local])
          ),
        msg = "no remote called `origin` available"
      )
      assert_that(
        any(branch_info$name %in%
          c("origin/main", "origin/master")),
        msg =
      "No `main` or `master` branch found in `origin`. Did you fetch `origin`?"
      )
      ref_branch <- ifelse(
        any(branch_info$name == "origin/main"), "origin/main", "origin/master"
      )
"Branch master detected. From Oct. 1, 2020, any new repositories you create uses
main as the default branch, instead of master. You can rename the default branch
from the web. More info on https://github.com/github/renaming"[
  !any(branch_info$name == "origin/main")
] -> notes
      commit1 <- git_commit_id(ref = ref_branch, repo = repo)
      commit2 <- git_commit_id(ref = "HEAD", repo = repo)
      desc_diff <- execshell(
        sprintf("git diff %s..%s -- ./DESCRIPTION", commit1, commit2),
        intern = TRUE,
        path = repo)
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
  status_before <- git_status(repo = repo)
  tidy_desc(x)
  desc_error <- c(
    desc_error,
    "DESCRIPTION not tidy. Use `checklist::tidy_desc()`"[
      !unchanged_repo(repo, status_before)
    ]
  )

  # check if the language is set
  desc_error <- c(
    desc_error,
    "Language field not set."[is.na(this_desc$get("Language"))]
  )

  x$add_error(desc_error, item = "DESCRIPTION", keep = FALSE)
  x$add_notes(notes, item = "DESCRIPTION")
  x$add_warnings(check_authors(this_desc), item = "DESCRIPTION")

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
  x <- read_checklist(x = x)

  # turn crayon off
  old_crayon <- getOption("crayon.enabled")
  on.exit(options("crayon.enabled" = old_crayon), add = TRUE)
  options("crayon.enabled" = FALSE)

  desc <- description$new(path(x$get_path, "DESCRIPTION"))

  # Alphabetise dependencies
  deps <- desc$get_deps()
  deps <- deps[order(deps$type, deps$package), , drop = FALSE]
  desc$del_deps()
  desc$set_deps(deps)

  # Alphabetise remotes
  remotes <- desc$get_remotes()
  if (length(remotes) > 0) {
    desc$set_remotes(c_sort(remotes))
  }

  desc$set("Encoding" = "UTF-8")

  # Normalize all fields (includes reordering)
  # Wrap in a try() so it always succeeds, even if user options are malformed
  try(desc$normalize(), silent = TRUE)
  path(x$get_path, "DESCRIPTION") |>
    desc$write()
  return(desc)
}

unchanged_repo <- function(repo, old_status) {
  current_status <- git_status(repo = repo)
  ok <- identical(
    current_status,
    old_status
  )
  new_files <- current_status$file
  old_files <- old_status$file
  changes <- c(
    new_files[!new_files %in% old_files], old_files[!old_files %in% new_files]
  )
  attr(ok, "files") <- sprintf(
    "changed files:\n%s", paste(changes, collapse = "\n")
  )
  return(ok)
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
#' - MIT
#'
#' We will consider pull requests adding support for other open source licenses.
#'
#' @inheritParams read_checklist
#' @importFrom assertthat assert_that
#' @importFrom desc description
#' @importFrom fs file_exists path
#' @export
#' @family package
check_license <- function(x = ".") {
  x <- read_checklist(x = x)
  if (x$package) {
    this_desc <- description$new(
      file = path(x$get_path, "DESCRIPTION")
    )

    # check if the license is allowed
    current_license <- this_desc$get_field("License")
    problems <- sprintf(
      "%s license currently not allowed.
Please send a pull request if you need support for this license.",
      this_desc$get_field("License")
    )[
      !current_license %in% c("GPL-3", "MIT + file LICENSE")
    ]
  } else {
    current_license <- "CC-BY"
    problems <- character(0)
  }

  # check if LICENSE.md exists
  if (!file_exists(path(x$get_path, "LICENSE.md"))) {
    x$add_error(
      errors = c(problems, "No LICENSE.md file"), item = "license", keep = FALSE
    )
    return(x)
  }

  # check if LICENSE.md matches the official version
  path(x$get_path, "LICENSE.md") |>
    readLines() -> current
  official <- switch(
    current_license, "GPL-3" = "gplv3.md", "MIT + file LICENSE" = "mit.md",
    "CC-BY" = "cc_by_4_0.md"
  )
  system.file("generic_template", official, package = "checklist") |>
    readLines() -> official
  if (current_license == "MIT + file LICENSE") {
    author <- this_desc$get_author(role = "cph")
    cph <- paste(c(author$given, author$family), collapse = " ")
    problems <- c(
      problems,
      "Copyright holder in LICENSE.md doesn't match the one in DESCRIPTION"[
        !grepl(paste0(cph, "$"), current[3])
      ]
    )
    problems <- c(
      problems,
      "Copyright statement in LICENSE.md not in correct format"[
        !grepl(
          paste0("^Copyright \\(c\\) \\d{4}(-(\\d{4})?)? ", cph, "$"),
          current[3]
        )
      ]
    )
    official <- official[-3]
    current <- current[-3]
  }
  problems <- c(
      problems,
      "LICENSE.md doesn't match the version in the checklist package"[
        (length(current) != length(official)) || any(current != official)
      ]
    )
  x$add_error(
    errors = problems,
    item = "license", keep = FALSE
  )
  return(x)
}

#' @importFrom utils person
check_authors <- function(this_desc) {
  authors <- this_desc$get_authors()
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
