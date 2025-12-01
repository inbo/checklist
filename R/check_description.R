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
  notes <- character(0)
  if (is.na(git_info(repo = repo)$head) || nrow(git_log(repo = repo)) <= 1) {
    desc_error <- character(0)
  } else {
    branch_info <- git_branch_list(repo = repo)
    head_sha <- git_commit_id(repo = repo)
    current_branch <- head(branch_info$name[branch_info$commit == head_sha], 1)
    if (length(current_branch) && current_branch %in% c("main", "master")) {
      paste(
        "Branch master detected. From Oct. 1, 2020, any new repositories you",
        "create uses\nmain as the default branch, instead of master. You can",
        "rename the default branch\nfrom the web. More info on",
        "https://github.com/github/renaming"
      )[current_branch == "master"] -> notes
      descr_stats <- git_stat_files("DESCRIPTION", repo = repo)
      desc_diff <- git_diff(descr_stats$head, repo = repo)
      desc_diff <- desc_diff$patch[desc_diff$old == "DESCRIPTION"]
      desc_diff <- strsplit(desc_diff, "\n", fixed = TRUE)[[1]]
      desc_error <- character(0)
    } else {
      assert_that(
        all(grepl("origin", branch_info$name[!branch_info$local])),
        msg = "no remote called `origin` available"
      )
      assert_that(
        any(branch_info$name %in% c("origin/main", "origin/master")),
        msg = paste(
          "No `main` or `master` branch found in `origin`. Did you fetch",
          "`origin`?"
        )
      )
      ref_branch <- ifelse(
        any(branch_info$name == "origin/main"),
        "origin/main",
        "origin/master"
      )
      paste(
        "Branch master detected. From Oct. 1, 2020, any new repositories you",
        "create uses\n main as the default branch, instead of master. You can",
        "rename the default branch\nfrom the web. More info on",
        "https://github.com/github/renaming"
      )[!any(branch_info$name == "origin/main")] -> notes
      commit1 <- git_commit_id(ref = ref_branch, repo = repo)
      commit2 <- git_commit_id(ref = "HEAD", repo = repo)
      desc_diff <- execshell(
        sprintf("git diff %s..%s -- ./DESCRIPTION", commit1, commit2),
        intern = TRUE,
        path = repo
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
    desc_error <- na.omit(version_bump)
  }
  status_before <- git_status(repo = repo)
  tidy_desc(x)
  desc_error <- c(
    desc_error,
    "DESCRIPTION not tidy. Use `checklist::tidy_desc()`"[
      !unchanged_repo(repo, status_before)
    ]
  )

  this_desc <- description$new(file = path(x$get_path, "DESCRIPTION"))
  org <- org_list$new()$read(x$get_path)
  updated_authors <- check_authors(this_desc = this_desc, org = org)
  this_desc$set_authors(updated_authors)
  path(x$get_path, "DESCRIPTION") |>
    this_desc$write()
  version <- as.character(this_desc$get_version())
  c(
    desc_error,
    "Incorrect version tag format. Use `0.0` or `0.0.0`"[
      !grepl("^[0-9]+\\.[0-9]+(\\.[0-9]+)?$", version)
    ],
    "Language field not set."[is.na(this_desc$get("Language"))],
    attr(updated_authors, "errors")
  ) |>
    x$add_error(item = "DESCRIPTION", keep = FALSE)
  x$add_notes(notes, item = "DESCRIPTION")

  check_license(x = x, org = org)
}

#' Make your DESCRIPTION tidy
#'
#' A tidy `DESCRIPTION` uses a strict formatting and order of key-value pairs.
#' This function reads the current `DESCRIPTION` and overwrites it with a tidy
#' version.
#' @inheritParams read_checklist
#' @export
#' @importFrom desc description
#' @importFrom withr defer
#' @family package
tidy_desc <- function(x = ".") {
  x <- read_checklist(x = x)

  # turn crayon off
  old_crayon <- getOption("crayon.enabled")
  defer(options("crayon.enabled" = old_crayon))
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
    new_files[!new_files %in% old_files],
    old_files[!old_files %in% new_files]
  )
  attr(ok, "files") <- sprintf(
    "changed files:\n%s",
    paste(changes, collapse = "\n")
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
#' @inheritParams set_license
#' @importFrom assertthat assert_that
#' @importFrom desc description
#' @importFrom fs file_exists path
#' @export
#' @family package
check_license <- function(x = ".", org) {
  x <- read_checklist(x = x)
  if (missing(org)) {
    org <- org_list$new()$read(x$get_path)
  }
  if (x$package) {
    this_desc <- description$new(
      file = path(x$get_path, "DESCRIPTION")
    )

    # check if the license is allowed
    current_license <- this_desc$get_field("License")
    this_desc$get_author(role = "cph")$email |>
      org$get_allowed_licenses(type = "package") -> allowed_licenses
    names(allowed_licenses)[
      names(allowed_licenses) == "MIT"
    ] <- "MIT + file LICENSE"
    fmt <- paste(
      "%s license is not allowed in this organisation.",
      "Allowed licenses are: %s."
    )
    sprintf(
      fmt = fmt,
      current_license,
      paste(names(allowed_licenses), collapse = "; ")
    )[
      !current_license %in% names(allowed_licenses)
    ] -> problems
  } else {
    path(x$get_path, "README.md") |>
      readLines() -> readme
    regex <- paste0(
      "^\\[!\\[(.*)\\]\\(https:\\/\\/img\\.shields\\.io\\/badge\\/License-.*?",
      "-brightgreen\\)\\]\\((.*)\\)"
    )
    which_badge <- grep(regex, readme)
    c(
      "No standard license badge found in README.md"[length(which_badge) == 0],
      "Multiple license badges found in README.md"[length(which_badge) > 1]
    ) -> problems
    if (length(problems)) {
      x$add_error(
        errors = problems,
        item = "license",
        keep = FALSE
      )
      return(x)
    }
    gsub(regex, "\\2", readme[which_badge]) |>
      setNames(gsub(regex, "\\1", readme[which_badge])) -> current_license
    regex <- ".*mailto:(.*?)\\)\\[\\^cph\\].*"
    which_badge <- grep(regex, readme)
    gsub(regex, "\\1", readme[which_badge]) |>
      gsub(pattern = "%40", replacement = "@") |>
      org$get_allowed_licenses(type = "project") -> allowed_license
    fmt <- paste(
      "%s license is not allowed in this organisation.",
      "Allowed licenses are: %s."
    )
    c(
      sprintf(fmt, names(current_license), names(allowed_license))[
        !names(current_license) %in% names(allowed_license)
      ],
      sprintf("`%s` is not the allowed license URL", current_license)[
        current_license != allowed_license[names(current_license)]
      ],
      problems
    ) -> problems
    current_license <- names(current_license)
  }

  # check if LICENSE.md exists
  if (!file_exists(path(x$get_path, "LICENSE.md"))) {
    x$add_error(
      errors = c(problems, "No LICENSE.md file"),
      item = "license",
      keep = FALSE
    )
    set_license(x = x, license = current_license, org = org)
    return(x)
  }

  # check if LICENSE.md matches the official version
  path(x$get_path, "LICENSE.md") |>
    readLines() -> current
  get_official_license_location(license = current_license, org = org) |>
    readLines() -> official
  if (current_license == "MIT + file LICENSE") {
    author <- this_desc$get_author(role = "cph")
    stopifnot("no copyright holder found" = length(author) > 0)
    cph <- paste(c(author$given, author$family), collapse = " ")
    cph <- gsub(
      "([\\(\\)\\.\\\\\\|\\[\\]\\{\\}\\^\\$\\*\\+\\?])",
      "\\\\\\1",
      cph,
      perl = TRUE
    )
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
  if ((length(current) != length(official)) || any(current != official)) {
    problems <- c(
      problems,
      "LICENSE.md doesn't match the version in the checklist package"
    )
    set_license(x, license = current_license, org = org)
  }
  x$add_error(
    errors = problems,
    item = "license",
    keep = FALSE
  )
  return(x)
}

#' @importFrom assertthat assert_that is.string
#' @importFrom utils person
check_authors <- function(this_desc, org) {
  assert_that(inherits(org, "org_list"))
  rightsholder <- this_desc$get_author(role = "cph")
  funder <- this_desc$get_author(role = "fnd")
  problems <- org$validate_rules(rightsholder = rightsholder, funder = funder)
  authors <- this_desc$get_authors()
  lang <- ifelse(
    is.na(this_desc$get("Language")),
    "en-GB",
    this_desc$get("Language")
  )
  updated_person <- org$validate_person(person = authors, lang = lang)
  attr(updated_person, "errors") <- c(problems, attr(updated_person, "errors"))
  return(updated_person)
}
