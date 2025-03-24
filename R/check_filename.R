#' Check the style of file and folder names
#'
#' A consistent naming schema avoids problems when working together,
#' especially when working with different OS.
#' Some OS (e.g. Windows) are case-insensitive whereas others (e.g. Linux) are
#' case-sensitive.
#' Note that the `checklist` GitHub Actions will test your code on Linux,
#' Windows and MacOS.
#'
#' The sections below describe the default rules.
#' We allow several exceptions when the community standard is different.
#' E.g. a package stores the function scripts in the `R` folder, while our
#' standard enforces lower case folder names.
#' Use the community standard, even if it does not conform with the `checklist`
#' rules.
#' Most likely `checklist` will have an exception for the name.
#' If not, you can file an [issue](https://github.com/inbo/checklist/issues) and
#' motivate why you think we should add an exception.
#'
#' @section Rules for folder names:
#' - Folder names should only contain lower case letters, numbers, dashes (`-`)
#'   and underscores (`_`).
#' - They can start with a single dot (`.`).
#' @section Default rules for file names:
#' - Base names should only contain lower case letters, numbers, dashes (`-`)
#'   and underscores (`_`).
#' - File extensions should only contain lower case letters and numbers.
#'   Exceptions: file extensions related to `R` must have an upper case `R` (
#'   `.R`, `.Rd`, `.Rda`, `.Rnw`, `.Rmd`, `.Rproj`).
#'   Exception to these exceptions: `R/sysdata.rda`.
#'
#' @template graphics
#'
#' @inheritParams read_checklist
#' @export
#' @importFrom fs path path_split
#' @importFrom gert git_ls
#' @family both
check_filename <- function(x = ".") {
  x <- read_checklist(x = x)
  if (
    is_repository(x$get_path) && nrow(git_ls(repo = x$get_path)) > 0
  ) {
    repo <- x$get_path
    # if a git repository: only check tracked files
    files <- git_ls(repo = repo)
    files <- files$path
    dirs <- unique(dirname(files))
  } else {
    dirs <- list.dirs(x$get_path, recursive = TRUE, full.names = FALSE)
    files <- list.files(x$get_path, recursive = TRUE, all.files = TRUE)
  }
  files <- files[!vapply(files, is_symlink, logical(1))]

  dirs <- lapply(dirs, split_path)
  # ignore git and RStudio files
  ignored_dirs <- vapply(
    dirs,
    function(x) {
     x[1] %in% c("", ".", ".git", ".Rproj.user") ||
        identical(x[1:4], c("inst", "local_tex", "fonts", "opentype")) ||
        "_freeze" %in% x
    },
    logical(1)
  )
  dirs <- dirs[!ignored_dirs]
  exceptions <- list(
    c("R"),
    c(".github", "ISSUE_TEMPLATE"), c(".github", "PULL_REQUEST_TEMPLATE")
  )
  dirs <- dirs[!dirs %in% exceptions]
  check_dir <- vapply(
    dirs,
    function(x) {
      all(grepl("^\\.?([a-z0-9_\\-\\/])+$", x, perl = TRUE))
    },
    logical(1)
  )
  problems <- sprintf(
    paste(
      "Folder names should only contain lower case letters, numbers, dashes",
      "and underscore.\nThey can start with a single dot.\nFailing folder: `%s`"
    ),
    vapply(
      dirs[!check_dir],
      function(x) {
        do.call(path, as.list(x))
      },
      character(1)
    )
  )

  # ignore git and RStudio files
  files <- files[!grepl("\\.(git|Rproj.user)/.*", files)]
  files <- files[!grepl("_freeze/.*", files)]
  # ignore some standardised files
  re <- sprintf(
    "^(%s)$",
    paste(
      c(
        "\\.[a-zA-Z]+ignore", "\\.Rprofile", "\\.[a-zA-Z]+\\.(json|yml)",
        "CITATION", "CODEOWNERS", "DESCRIPTION", "NAMESPACE", "CITATION\\.cff",
        "README\\.R?md", "NEWS\\.md",
        "CODE_OF_CONDUCT\\.md", "CONTRIBUTING\\.md", "LICENSE(\\.md)?",
        "SUPPORT\\.md", "SECURITY\\.md", "FUNDING\\.yml",
        "Dockerfile", "WORDLIST.*", "docker-compose.*\\.yml",
        "REVIEWING.md", "_redirects"
      ),
      collapse = "|"
    )
  )
  files <- files[!grepl(re, basename(files))]
  files <- files[!grepl("\\.(otf|ttf)$", basename(files))] # ignore fonts files
  files <- files[!grepl("man\\/.*\\.Rd", files)] # ignore Rd files
  files <- files[!grepl("R\\/sysdata.rda", files)] # ignore sysdata.rda
  base <- gsub("(.*)\\.(.*)?", "\\1", basename(files))
  problems <- c(
    problems,
    sprintf(
      "Basename must contain only lower case, numbers, `_` or `-`.
Fails: `%s`",
      files[!grepl("^[a-z0-9_-]*$", base)]
    )
  )

  # ignore .rda files in the data directory
  to_ignore <- !grepl("^data/[a-z0-9_]*\\.rda$", files)

  extension <- gsub("(.*)\\.(.*)?", "\\2", basename(files))
  # extension exceptions
  exception <- grepl("^R(d|da|nw|md|proj)?$", extension) |
    grepl("^([a-z0-9])*?$", extension)
  problems <- c(
    problems,
    sprintf(
      "File extension must be all lower case or numbers.\nFails: `%s`",
      files[!exception]
    )
  )
  # R related files requires upper case R
  problems <- c(
    problems,
    sprintf(
      "R file requires extension with upper case R.\nFails: `%s`",
      files[grepl("^r(proj|d|da|md|nw)?$", extension) & to_ignore]
    )
  )

  graphics_file <- extension %in% c("csl", graphics_ext)
  warnings <- c(
    sprintf(
      "Use `-` as separator in the basename of graphics files.
  File: `%s`",
      files[grepl("_+", base) & graphics_file]
    )
  )

  x$add_error(problems, item = "filename conventions", keep = FALSE)
  x$add_warnings(warnings, item = "filename conventions")

  return(x)
}

split_path <- function(path) {
  if (dirname(path) %in% c(".", path)) return(basename(path))
  return(c(split_path(dirname(path)), basename(path)))
}

is_symlink <- function(paths) {
  Sys.readlink(paths) |>
    nzchar(keepNA = TRUE) |>
    isTRUE()
}
