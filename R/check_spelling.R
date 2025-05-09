#' Spell check a package or project
#'
#' This function checks by default any markdown (`.md`) or Rmarkdown (`.Rmd`)
#' file found within the project.
#' It also checks any R help file (`.Rd`) in the `man` folder.
#' Use the `set_exceptions()` method of the `checklist` object to exclude files
#' or use a different language.
#' Have a look at `vignette("spelling", package = "checklist")` for more
#' details.
#' @inheritParams read_checklist
#' @inheritParams check_package
#' @export
#' @importFrom assertthat assert_that is.flag noNA
#' @importFrom fs path
#' @importFrom tools loadPkgRdMacros loadRdMacros
#' @family both
check_spelling <- function(x = ".", quiet = FALSE) {
  assert_that(is.flag(quiet), noNA(quiet))
  x <- read_checklist(x = x)
  md_files <- x$get_md
  if (x$package) {
    rd_files <- x$get_rd
    macros <- path(R.home("share"), "Rd", "macros", "system.Rd") |>
      loadRdMacros(loadPkgRdMacros(x$get_path, macros = NULL))
  } else {
    rd_files <- data.frame(language = character(0), path = character(0))
    macros <- NULL
  }
  r_files <- x$get_r
  languages <- unique(c(md_files$language, rd_files$language, r_files$language))
  languages <- languages[languages != "ignore"]
  install_dictionary(languages)
  issues <- vapply(
    languages, root = x$get_path, r_files = r_files,
    md_files = md_files, rd_files = rd_files, macros = macros,
    FUN.VALUE = vector(mode = "list", length = 1),
    FUN = function(lang, root, r_files, md_files, rd_files, macros) {
      wordlist <- spelling_wordlist(
        lang = gsub("-", "_", lang), root = root, package = x$package
      )
      r_issues <- vapply(
        path(root, r_files$path[r_files$language == lang]),
        FUN = spelling_parse_r, FUN.VALUE = vector(mode = "list", length = 1),
        wordlist = wordlist
      )
      md_issues <- vapply(
        path(root, md_files$path[md_files$language == lang]),
        FUN = spelling_parse_md, FUN.VALUE = vector(mode = "list", length = 1),
        wordlist = wordlist, x = x
      )
      rd_issues <- vapply(
        path(root, rd_files$path[rd_files$language == lang]),
        FUN = spelling_parse_rd, FUN.VALUE = vector(mode = "list", length = 1),
        wordlist = wordlist, macros = macros
      )
      return(list(c(md_issues, rd_issues, r_issues)))
    }
  )
  if (length(issues) == 0) {
    issues <- data.frame(
      type = character(0), file = character(0), line = integer(0),
      column = integer(0), message = character(0), language = character(0)
    )
    class(issues) <- c("checklist_spelling", class(issues))
  } else {
    issues <- do.call(rbind, unlist(issues, recursive = FALSE))
  }
  rownames(issues) <- NULL
  attr(issues, "checklist_path") <- x$get_path
  if (!quiet && nrow(issues) > 0) {
    print(issues)
  }
  x$add_spelling(issues)
  return(x)
}

#' @importFrom fs file_exists path
#' @importFrom hunspell dictionary
spelling_wordlist <- function(lang = "en_GB", root = ".", package = FALSE) {
  path("spelling", "inbo.dic") |>
    system.file(package = "checklist") |>
    readLines() -> add_words
  if (package) {
    path(root, "DESCRIPTION") |>
      description$new() -> descr
    descr$get_authors() |>
      format(include = c("given", "family")) |>
      strsplit(split = " ") |>
      unlist() |>
      c(add_words, descr$get_field("Package")) |>
      unique() -> add_words
    if (requireNamespace("renv", quietly = TRUE)) {
      renv::dependencies(root, progress = FALSE)$Package |>
        c(add_words) |>
        unique() -> add_words
    }
  }

  path("spelling", gsub("(.*)_.*", "stats_\\1.dic", lang)) |>
    system.file(package = "checklist") -> dict
  if (file_exists(dict)) {
    readLines(dict) |>
      c(add_words) -> add_words
  }
  dict <- path(root, "inst", tolower(lang), ext = "dic")
  if (file_exists(dict)) {
    readLines(dict) |>
      c(add_words) -> add_words
  }
  dict <- dictionary(lang = lang, add_words = add_words)
  attr(dict, "checklist_language") <- gsub("_", "-", lang)
  return(dict)
}

#' @importFrom hunspell hunspell
spelling_check <- function(text, filename, wordlist, raw_text = text) {
  if (all(text == "")) {
    result <- data.frame(
      type = character(0), file = character(0), line = integer(0),
      column = integer(0), message = character(0), language = character(0)
    )
    class(result) <- c("checklist_spelling", class(result))
    return(result)
  }
  problems <- hunspell(text = text, dict = wordlist)
  relevant <- which(vapply(problems, length, integer(1)) > 0)
  if (length(relevant) == 0) {
    result <- data.frame(
      type = character(0), file = character(0), line = integer(0),
      column = integer(0), message = character(0), language = character(0)
    )
    class(result) <- c("checklist_spelling", class(result))
    return(result)
  }
  result <- vapply(
    relevant, FUN.VALUE = vector(mode = "list", length = 1),
    text = raw_text, problems = problems,
    FUN = function(i, text, problems) {
      list(
        vapply(
          problems[[i]], FUN.VALUE = vector(mode = "list", length = 1),
          text = text, i = i,
          FUN = function(word, text, i) {
            detect <- gregexpr(spelling_clean_problem(word), text[i])[[1]]
            if (min(detect) == -1) {
              return(
                list(
                  data.frame(
                    line = integer(0), column = integer(0),
                    message = character(0)
                  )
                )
              )
            }
            list(
              data.frame(line = i, column = as.vector(detect), message = word)
            )
          }
        )
      )
    }
  )
  result <- do.call(rbind, unlist(result, recursive = FALSE))
  # append meta data
  result$file <- filename
  result$type <- "warning"
  result$language <- attr(wordlist, "checklist_language")
  rownames(result) <- NULL
  class(result) <- c("checklist_spelling", class(result))

  # remove false positives
  # negative numbers
  result <- result[!grepl("^-[0-9]+$", result$message), ]
  # multiple dashes
  result <- result[!grepl("^-{2, }$", result$message), ]
  # remove trailing dots
  result$message <- gsub("\\.$", "", result$message)

  return(result)
}

spelling_clean_problem <- function(problem) {
  # escape trailing backspace
  problem <- gsub("\\\\$", "\\\\\\\\", problem)
  # escape special regexp characters
  problem <- gsub("\\+", "\\\\+", problem)
  return(problem)
}

#' Display a `checklist_spelling` summary
#' @param x The `checklist_spelling` object
#' @param ... currently ignored
#' @export
#' @importFrom fs path_common path_rel
#' @importFrom stats aggregate
#' @family both
print.checklist_spelling <- function(x, ...) {
  if (length(x) == 0 || nrow(x) == 0) {
    return(invisible(NULL))
  }
  if (
    getOption("checklist.rstudio_source_markers", TRUE) &&
      requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::hasFun("sourceMarkers")
  ) {
    return(rstudio_source_markers(issues = x)) # nocov
  }
  common <- path_common(x$file)
  x$file <- path_rel(x$file, start = common)
  x <- x[order(x$file, x$line, x$message), ]
  display <- aggregate(
    column ~ file + language + message + line, x, FUN = paste, collapse = "|"
  )
  display$line <- sprintf("%i (%s)", display$line, display$column)
  display <- aggregate(
    line ~ file + language + message, display, FUN = paste, collapse = ", "
  )
  display$message <- sprintf("%s: %s", display$message, display$line)
  display <- aggregate(
    message ~ file + language, display, FUN = paste, collapse = "\n"
  )
  cat(
    "Overview of words missing from dictionary.",
    "i (j) indicates that the word occures at line i, column j", sep = "\n"
  )
  cat(
    sprintf(
      "\n%s (%s)\n\n%s\n", display$file, display$language, display$message
    ),
    sep = rules(".")
  )
  return(invisible(NULL))
}

#' @importFrom fs path_common
rstudio_source_markers <- function(issues) { # nocov start
  # nocov_start
  assert_that(
    requireNamespace("rstudioapi", quietly = TRUE),
    msg = "This function requires the `rstudioapi` package"
  )
  common <- path_common(issues$file)
  issues$message <- sprintf(
    "`%s` not found in the dictionary or wordlist for %s.", issues$message,
    issues$language
  )
  issues <- unique(issues[order(issues$file, issues$line, issues$column), ])
  issues$file <- as.character(issues$file)
  # request source markers
  rstudioapi::callFun(
    "sourceMarkers", name = "checklist_spelling", markers = issues,
    basePath = common, autoSelect = "first"
  )
} # nocov end

#' @importFrom hunspell list_dictionaries
install_dictionary <- function(lang) {
  lang <- lang[lang != "ignore"]
  available <- list_dictionaries()
  ok <- gsub("-", "_", lang) %in% available
  if (all(ok)) {
    return(TRUE)
  }
  install_dutch(lang[!ok])
  install_french(lang[!ok])
  install_german(lang[!ok])
}

#' @importFrom fs file_copy
install_dutch <- function(lang) {
  if (length(grep("^nl", lang)) == 0) {
    return(FALSE)
  }
  assert_that(
    requireNamespace("curl", quietly = TRUE),
    msg = "The `curl` package is missing"
  )
  target <- system.file("dict", package = "hunspell")
  curl::curl_download(
    "https://github.com/inbo/hunspell-dict/raw/main/nl_NL.dic",
    path(target, "nl_NL.dic")
  )
  curl::curl_download(
    "https://github.com/inbo/hunspell-dict/raw/main/nl_NL.aff",
    path(target, "nl_NL.aff")
  )
  file_copy(
    path(target, "nl_NL.dic"), path(target, "nl_BE.dic"), overwrite = TRUE
  )
  file_copy(
    path(target, "nl_NL.aff"), path(target, "nl_BE.aff"), overwrite = TRUE
  )
  return(TRUE)
}

#' @importFrom fs file_copy file_move
#' @importFrom utils unzip
install_french <- function(lang) {
  if (length(grep("^fr", lang)) == 0) {
    return(FALSE)
  }
  assert_that(
    requireNamespace("curl", quietly = TRUE),
    msg = "The `curl` package is missing"
  )
  target <- system.file("dict", package = "hunspell")
  curl::curl_download(
    "https://github.com/inbo/hunspell-dict/raw/main/fr_FR.dic",
    path(target, "fr_FR.dic")
  )
  curl::curl_download(
    "https://github.com/inbo/hunspell-dict/raw/main/fr_FR.aff",
    path(target, "fr_FR.aff")
  )
  file_copy(
    path(target, "fr_FR.dic"), path(target, "fr_BE.dic"), overwrite = TRUE
  )
  file_copy(
    path(target, "fr_FR.aff"), path(target, "fr_BE.aff"), overwrite = TRUE
  )
  return(TRUE)
}

#' @importFrom fs file_copy file_move
#' @importFrom utils unzip
install_german <- function(lang) {
  if (length(grep("^de", lang)) == 0) {
    return(FALSE)
  }
  assert_that(
    requireNamespace("curl", quietly = TRUE),
    msg = "The `curl` package is missing"
  )
  target <- system.file("dict", package = "hunspell")
  curl::curl_download(
    "https://github.com/inbo/hunspell-dict/raw/main/de_DE.dic",
    path(target, "de_DE.dic")
  )
  curl::curl_download(
    "https://github.com/inbo/hunspell-dict/raw/main/de_DE.aff",
    path(target, "de_DE.aff")
  )
  return(TRUE)
}
