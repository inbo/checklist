#' Check the style of file and folder names
#'
#' A consistent naming schema avoids problems when working together,
#' especially when working with different OS.
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
#' @section Default rules for file names:
#' - Base names should only contain lower case letters, numbers and
#'   underscore (`_`).
#' - File extensions should only contains lower case letters and numbers.
#'   Exceptions: file extensions related to `R` must have an upper case `R` (
#'   `.R`, `.Rd`, `.Rda`, `.Rnw`, `.Rmd`, `.Rproj`).
#'   Exception to these exceptions: `R/sysdata.rda`.
#'
#' @section Exceptions for some file formats:
#' Underscores (`_`) causes problems for graphical files when using LaTeX to
#' create pdf output.
#' This is how we generate pdf output from rmarkdown.
#' Therefore you need to use a dash (`-`) as separator instead of
#' an underscores (`_`).
#' Applies to files with extensions `.csl`, `.eps`, `.jpg`, `.jpeg`, `.pdf`,
#' `.png` and `.ps`.
#'
#' We ignore files with `.otf` or `.ttf` extensions.
#' These are fonts files which often require their own file name scheme.
#'
#' @inheritParams read_checklist
#' @export
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

  dirs <- lapply(dirs, split_path)
  # ignore git and RStudio files
  ignored_dirs <- vapply(
    dirs,
    function(x) {
     x[1] %in% c("", ".", ".git", ".Rproj.user") |
        identical(x[1:4], c("inst", "local_tex", "fonts", "opentype"))
    },
    logical(1)
  )
  dirs <- dirs[!ignored_dirs]
  exceptions <- list(
    c("R"), c("data-raw"), c("man-roxygen"),
    c(".github", "ISSUE_TEMPLATE"), c(".github", "PULL_REQUEST_TEMPLATE")
  )
  dirs <- dirs[!dirs %in% exceptions]
  check_dir <- vapply(
    dirs,
    function(x) {
      all(grepl("^\\.?([a-z0-9_\\/])+$", x))
    },
    logical(1)
  )
  problems <- sprintf(
"Folder names should only contain lower case letters, numbers and underscore.
They can start with a single dot.
Failing folder: `%s`",
    vapply(
      dirs[!check_dir],
      function(x) {
        do.call(file.path, as.list(x))
      },
      character(1)
    )
  )

  # ignore git and RStudio files
  files <- files[!grepl("\\.(git|Rproj.user)/.*", files)]
  # ignore some standardised files
  re <- sprintf(
    "^(%s)$",
    paste(
      c(
        "\\.[a-zA-Z]+ignore", "\\.Rprofile", "\\.[a-zA-Z]+\\.(json|yml)",
        "CITATION", "DESCRIPTION", "NAMESPACE", "CITATION.cff",
        "README\\.R?md", "NEWS\\.md",
        "CODE_OF_CONDUCT.md", "CONTRIBUTING.md", "LICENSE.md", "SUPPORT.md",
        "SECURITY.md", "FUNDING.yml",
        "Dockerfile", "docker-compose.*.yml",
        ".*-package\\.Rd", "cran-comments.md", "WORDLIST.*"
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

  graphics_file <- extension %in% c(
    "csl", "eps", "jpg", "jpeg", "pdf", "png", "ps", "svg"
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

  x$add_error(problems, item = "filename conventions", keep = FALSE)
  x$add_warnings(warnings, item = "filename conventions")

  return(x)
}

split_path <- function(path) {
  if (dirname(path) %in% c(".", path)) return(basename(path))
  return(c(split_path(dirname(path)), basename(path)))
}
