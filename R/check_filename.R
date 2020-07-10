#' Check the style of file names
#' @inheritParams read_checklist
#' @export
check_filename <- function(x = ".") {
  if (!inherits(x, "Checklist") || !"checklist" %in% x$get_checked) {
    x <- read_checklist(x = x)
  }

  dirs <- list.dirs(x$get_path, recursive = TRUE, full.names = FALSE)
  # ignore git and RStudio files
  dirs <- dirs[!grepl("\\.(git|Rproj.user)(/.*)?$", dirs)]
  ok_dirs <- c("", "R")
  dirs <- dirs[!dirs %in% c(ok_dirs)]
  check_dir <- grepl("^\\.?([a-z0-9_])+", dirs)
  problems <- sprintf(
"Folder names should only contain lower case letters, numbers and underscore.
They can start with a single dot.
Failing folder: `%s`",
    dirs[!check_dir]
  )

  files <- list.files(x$get_path, recursive = TRUE, all.files = TRUE)
  # ignore git and RStudio files
  files <- files[-grep("\\.(git|Rproj.user)/.*", files)]
  # ignore some standardised files
  re <- sprintf(
    "^(%s)$",
    paste(
      c(
        "\\.[a-zA-Z]+ignore", "DESCRIPTION", "NAMESPACE", "README\\.R?md",
        "NEWS\\.md", "Dockerfile"
      ),
      collapse = "|"
    )
  )
  files <- files[!grepl(re, basename(files))]
  base <- gsub("(.*)\\.(.*)?", "\\1", basename(files))
  problems <- c(
    problems,
    sprintf(
      "Basename must contain only lower case, numbers or `_`.\nFails: `%s`",
      files[!grepl("^[a-z0-9_]*$", base)]
    )
  )

  extension <- gsub("(.*)\\.(.*)?", "\\2", basename(files))
  # extention exceptions
  exception <- grepl("^R(proj|d|md|nw)?$", extension)
  problems <- c(
    problems,
    sprintf(
      "File extension must be all lower case or numbers.\nFails: `%s`",
      files[!exception & !grepl("^([a-z0-9])*?$", extension)]
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

  x$add_error(problems, "filename conventions")

  return(x)
}
