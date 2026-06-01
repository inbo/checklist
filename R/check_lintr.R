#' Check the packages for linters
#'
#' This functions does [static code analysis](
#' https://en.wikipedia.org/wiki/Static_program_analysis).
#' It relies on [lintr::lint_package()].
#' We recommend that you activate all code diagnostics in RStudio to help
#' meeting the requirements.
#' You can find this in the menu _Tools_ > _Global options_ > _Code_ >
#' _Diagnostics_.
#' Please have a look at `vignette("philosophy")` for more details on the rules.
#'
#' @details
#' When `check_lintr()` runs on a git repository, it checks whether the
#' organisation has a custom `.lintr` file in their `checklist` repository.
#' If so, it uses this file.
#' Otherwise it looks for a local `.lintr` file in the project directory.
#' If this file is not present, it uses the default `.lintr` file provided
#' with the `checklist` package.
#'
#' @inheritParams read_checklist
#' @inheritParams rcmdcheck::rcmdcheck
#' @export
#' @importFrom assertthat assert_that is.flag noNA
#' @importFrom gert git_submodule_list
#' @importFrom lintr lint_dir lint_package
#' @importFrom withr defer
#' @family both
check_lintr <- function(x = ".", quiet = FALSE) {
  assert_that(is.flag(quiet), noNA(quiet))
  stopifnot(
    "Please install the `cyclocomp` package" = requireNamespace("cyclocomp")
  )
  x <- read_checklist(x = x)
  options(lintr.linter_file = select_lintr_file(x$get_path))
  old_lint_option <- getOption("lintr.rstudio_source_markers", TRUE)
  options(lintr.rstudio_source_markers = interactive())
  defer(options(lintr.rstudio_source_markers = old_lint_option))
  missing_packages <- list_missing_packages(x$get_path)
  paste(missing_packages, collapse = ", ") |>
    sprintf(
      fmt = "The code depends on the following uninstalled packages: %s"
    ) -> missing_packages_msg
  x$add_error(
    missing_packages_msg[length(missing_packages) > 0],
    item = "lintr"
  )

  if (x$package) {
    exclusions <- list("tests/testthat/_problems")
    if (is_repository(x$get_path)) {
      exclusions <- c(exclusions, git_submodule_list(repo = x$get_path)$path)
    }
    linter <- lint_package(path = x$get_path, exclusions = exclusions)
  } else {
    list.dirs(path = x$get_path, recursive = TRUE, full.names = TRUE) |>
      grep(pattern = "/renv$", value = TRUE) |>
      as.list() |>
      unname() -> exclude_renv
    if (is_repository(x$get_path)) {
      exclude_renv <- c(
        exclude_renv,
        git_submodule_list(repo = x$get_path)$path
      )
    }
    linter <- lint_dir(
      x$get_path,
      pattern = "\\.[Rrq](md|nw)?$",
      exclusions = exclude_renv
    )
  }
  if (!quiet && length(linter) > 0) {
    print(linter)
  }
  x$add_linter(linter = linter, error = length(missing_packages) > 0)
  return(x)
}

#' @importFrom assertthat assert_that is.string noNA
#' @importFrom utils installed.packages
list_missing_packages <- function(x = ".") {
  if (!requireNamespace("renv", quietly = TRUE)) {
    warning(
      "`renv` is not installed. Please install it.",
      call. = FALSE,
      immediate. = TRUE
    )
    return(character(0))
  }
  assert_that(is.string(x), noNA(x), file_test("-d", x))
  renv::dependencies(x, progress = FALSE)$Package |>
    unique() |>
    sort() -> required_packages
  installed.packages() |> rownames() -> installed_packages
  required_packages[!required_packages %in% installed_packages]
}

#' @importFrom citeme org_list
select_lintr_file <- function(x) {
  if (!is_repository(x)) {
    return(local_or_default_lintr(x))
  }
  org <- org_list$new()$read(x)
  if (!grepl("^https://", org$get_git, perl = TRUE)) {
    return(local_or_default_lintr(x))
  }
  if (org$get_git == "https://github.com/inbo") {
    return(system.file("lintr", package = "checklist"))
  }
  R_user_dir("citeme", "config") |>
    file.path(
      tolower(org$get_git) |> gsub(pattern = "https://", replacement = ""),
      ".lintr"
    ) -> linter_file
  ifelse(file_test("-f", linter_file), linter_file, local_or_default_lintr(x))
}

local_or_default_lintr <- function(x) {
  if (file_test("-f", file.path(x, ".lintr"))) {
    return(file.path(x, ".lintr"))
  }
  system.file("lintr", package = "checklist")
}
