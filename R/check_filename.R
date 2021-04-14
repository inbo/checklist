#' Check the style of file and folder names
#'
#' A consistent naming schema avoids problems when working together, especially when working with different OS.
#' Some OS (e.g. Windows) are case-insensitive whereas others (e.g. Linux) are
#' case-sensitive.
#' Note that the checklist GitHub Actions will test your code on Linux,
#' Windows and MacOS.
#'
#' The sections below describe the default rules.
#' We allow several exceptions when the community standard is different.
#' E.g. a package stores the function scripts in the `R` folder, while our
#' standard enforces lower case folder names.
#' Use the community standard, even if it does conform with the checklist
#' rules.
#' Most likely checklist will have an exception for the name.
#' If not, you can file an [issue](https://github.com/inbo/checklist/issues) and
#' motivate why you think we should add an exception.
#'
#' @section Rules for folder names:
#' - Folder names should only contain lower case letters, numbers and
#'   underscore (`_`).
#' - They can start with a single dot (`.`).
#' @section Rules for file names:
#' - Base names should only contain lower case letters, numbers and
#'   underscore (`_`).
#' - File extensions should only contains lower case letters and numbers.
#'   Exceptions: file extensions related to `R` must have an upper case `R` (
#'   `.R`, `.Rmd`, `.Rd`, `.Rnw`, `.Rproj`).
#'
#' @section Rules for graphical file names:
#' - Applies to files with extensions "csl", "eps", "jpg", "jpeg", "pdf", "png"
#' and "ps"
#' - Same rules except that you need to use a dash (`-`) as separator instead of
#'   an underscore (`_`).
#' @inheritParams read_checklist
#' @export
#' @importFrom git2r in_repository ls_tree
#' @family both
check_filename <- function(x = ".") {
  if (!inherits(x, "Checklist") || !"checklist" %in% x$get_checked) {
    x <- read_checklist(x = x)
  }

  if (in_repository(x$get_path)) {
    repo <- repository(x$get_path)
    files <- unlist(status(repo, untracked = FALSE))
    if (length(files) == 0) {
      files <- ls_tree(repo = repo)
      dirs <- unique(files$path)
      files <- paste0(files$path, files$name)
      dirs <- gsub("/$", "", dirs)
    } else {
      dirs <- unique(dirname(files))
      dirs <- dirs[dirs != "."]
    }
  } else {
    dirs <- list.dirs(x$get_path, recursive = TRUE, full.names = FALSE)
    files <- list.files(x$get_path, recursive = TRUE, all.files = TRUE)
  }

  # ignore git and RStudio files
  dirs <- dirs[!grepl("\\.(git|Rproj.user)(/.*)?$", dirs)]
  ok_dirs <- c(
    "", "R", ".github/ISSUE_TEMPLATE", ".github/PULL_REQUEST_TEMPLATE",
    "data-raw", "man-roxygen"
  )
  dirs <- dirs[!dirs %in% c(ok_dirs)]
  dirs <- dirs[
    !grepl(file.path("inst", "local_tex", "fonts", "opentype"), dirs)
  ]
  check_dir <- grepl("^\\.?([a-z0-9_\\/])+$", dirs)
  problems <- sprintf(
"Folder names should only contain lower case letters, numbers and underscore.
They can start with a single dot.
Failing folder: `%s`",
    dirs[!check_dir]
  )

  # ignore git and RStudio files
  files <- files[!grepl("\\.(git|Rproj.user)/.*", files)]
  # ignore some standardised files
  re <- sprintf(
    "^(%s)$",
    paste(
      c(
        "\\.[a-zA-Z]+ignore", "\\.Rprofile", "\\.[a-zA-Z]+\\.(json|yml)",
        "DESCRIPTION", "NAMESPACE",
        "README\\.R?md", "NEWS\\.md",
        "CODE_OF_CONDUCT.md", "CONTRIBUTING.md", "LICENSE.md", "SUPPORT.md",
        "SECURITY.md", "FUNDING.yml",
        "Dockerfile",
        ".*-package\\.Rd", "cran-comments.md", "WORDLIST"
      ),
      collapse = "|"
    )
  )
  files <- files[!grepl(re, basename(files))]
  files <- files[!grepl("\\.(otf|ttf)$", basename(files))] # ignore fonts files
  base <- gsub("(.*)\\.(.*)?", "\\1", basename(files))
  problems <- c(
    problems,
    sprintf(
      "Basename must contain only lower case, numbers, `_` or `-`.
Fails: `%s`",
      files[!grepl("^[a-z0-9_-]*$", base)]
    )
  )

  extension <- gsub("(.*)\\.(.*)?", "\\2", basename(files))
  # extension exceptions
  exception <- grepl("^R(proj|d|md|nw)?$", extension) |
    grepl("^([a-z0-9])*?$", extension)
  problems <- c(
    problems,
    sprintf(
      "File extension must be all lower case or numbers.\nFails: `%s`",
      files[!exception]
    )
  )
  # R related requires upper case R
  problems <- c(
    problems,
    sprintf(
      "R file requires extension with upper case R.\nFails: `%s`",
      files[grepl("^r(proj|d|md|nw)?$", extension)]
    )
  )

  graphics_file <- extension %in% c(
    "csl", "eps", "jpg", "jpeg", "pdf", "png", "ps"
  )
  warnings <- c(
    sprintf(
      "Use `_` as separator in the basename of non-graphics files.
  File: `%s`",
      files[grepl("-+", base) & !graphics_file]
    ),
    sprintf(
      "Use `-` as separator in the basename of graphics files.
  File: `%s`",
      files[grepl("_+", base) & graphics_file]
    )
  )

  x$add_warnings(warnings)
  x$add_error(problems, "filename conventions")

  return(x)
}
