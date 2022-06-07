#' Spell check a package or project
#'
#' This function checks by default any markdown (`.md`) or Rmarkdown (`.Rmd`)
#' file found within the project.
#' It also checks any R help file (`.Rd`) in the `man` folder.
#' Use the `set_exceptions()` method of the `checklist` object to exclude files
#' or use a different language.
#' @inheritParams read_checklist
#' @export
#' @importFrom tools loadPkgRdMacros loadRdMacros
#' @family both
check_spelling <- function(x = ".") {
  x <- read_checklist(x = x)
  md_files <- x$get_md
  rd_files <- x$get_rd
  macros <- loadRdMacros(
    file.path(R.home("share"), "Rd", "macros", "system.Rd"),
    loadPkgRdMacros(x$get_path, macros = NULL)
  )
  issues <- vapply(
    unique(c(md_files$language, rd_files$language)), root = x$get_path,
    md_files = md_files, rd_files = rd_files, macros = macros,
    FUN.VALUE = vector(mode = "list", length = 1),
    FUN = function(lang, root, md_files, rd_files, macros) {
      if (lang == "ignore") {
        return(list(NULL))
      }
      wordlist <- spelling_wordlist(lang = gsub("-", "_", lang), root = root)
      md_issues <- vapply(
        path(root, md_files$path[md_files$language == lang]),
        FUN = spelling_parse_md, FUN.VALUE = vector(mode = "list", length = 1),
        wordlist = wordlist
      )
      rd_issues <- vapply(
        path(root, rd_files$path[rd_files$language == lang]),
        FUN = spelling_parse_rd, FUN.VALUE = vector(mode = "list", length = 1),
        wordlist = wordlist, macros = macros
      )
      return(list(c(md_issues, rd_issues)))
    }
  )
  issues <- do.call(rbind, unlist(issues, recursive = FALSE))
  rownames(issues) <- NULL
  attr(issues, "checklist_path") <- x$get_path
  return(issues)
}

#' @importFrom fs file_exists path
#' @importFrom hunspell dictionary
#' @importFrom renv dependencies
spelling_wordlist <- function(lang = "en_GB", root = ".") {
  path("spelling", "inbo.dic") |>
    system.file(package = "checklist") |>
    readLines() %>%
    c(unique(dependencies(root, progress = FALSE)$Package)) -> add_words

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
    return(
      data.frame(
        type = character(0), file = character(0), line = integer(0),
        column = integer(0), message = character(0), language = character(0)
      )
    )
  }
  problems <- hunspell(text = text, dict = wordlist)
  relevant <- which(vapply(problems, length, integer(1)) > 0)
  if (length(relevant) == 0) {
    return(
      data.frame(
        type = character(0), file = character(0), line = integer(0),
        column = integer(0), message = character(0), language = character(0)
      )
    )
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
            detect <- gregexpr(word, text[i])[[1]]
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

#' @importFrom tools RdTextFilter
spelling_parse_rd <- function(rd_file, macros, wordlist) {
  text <- RdTextFilter(rd_file, macros = macros)
  # remove e-mail
  text <- gsub(email_regexp, "", text, perl = TRUE)
  # remove functions
  text <- gsub("[a-zA-Z0-9]+:{2,3}[\\w\\.]+\\(.*?\\)", "", text, perl = TRUE)
  list(spelling_check(
    text = text, filename = rd_file, wordlist = wordlist
  ))
}

#' @importFrom assertthat assert_that
spelling_parse_md <- function(md_file, wordlist) {
  raw_text <- readLines(md_file)
  text <- spelling_parse_md_yaml(text = raw_text)
  # remove chunks
  chunks <- grep("^```", text)
  assert_that(
    length(chunks) %% 2 == 0,
    msg = paste("Odd number of chunk delimiters detected in", md_file)
  )
  while (length(chunks)) {
    text[chunks[1]:chunks[2]] <- ""
    chunks <- tail(chunks, -2)
  }
  # remove in line chunks
  text <- gsub("\\`r .*?`", "", text)
  # remove ignored sections
  start <- grep("<!-- spell-check: ignore:start -->", text)
  end <- grep("<!-- spell-check: ignore:end -->", text)
  assert_that(
    length(start) == length(end),
    msg = paste(
      "unmatched `spell-check: ignore:start` and `spell-check: ignore:end` in",
      md_file
    )
  )
  assert_that(
    all(start < end),
    msg = paste(
      "`spell-check: ignore:end` appears before `spell-check: ignore:start`",
      "found in", md_file
    )
  )
  assert_that(
    all(head(end, -1) < tail(start, -1)),
    msg = paste(
      "new `spell-check: ignore:start` found without closing the previous in",
      md_file
    )
  )
  while (length(start)) {
    text[start[1]:end[1]] <- ""
    start <- tail(start, -1)
    end <- tail(end, -1)
  }
  # remove ignored lines
  text <- gsub(".*<!-- spell-check: ignore -->.*", "", text)
  # remove bookdown references
  text <- gsub("\\\\@ref\\(.*?\\)", "", text)
  # remove bookdown anchor
  text <- gsub("\\{#.*?\\}", "", text)
  # remove bookdown text references
  text <- gsub("\\(ref:.*?\\)", "", text)
  # remove stand alone math
  text <- gsub("\\$\\$.*?\\$\\$", "", text)
  # remove inline math
  text <- gsub("\\$.*?\\$", "", text)
  # remove citation
  text <- gsub("\\S*@\\S+", "", text, perl = TRUE)
  # replace non braking spaces
  text <- gsub("&nbsp;", " ", text)
  # remove LaTeX commands
  text <- gsub("\\\\\\w+", "", text)
  # remove Markdown urls
  text <- gsub("\\[(.*?)\\]\\(.+?\\)", " \\1 ", text)
  text <- gsub("\\[(.*?)\\]\\(.+?\\)", " \\1 ", text)
  text <- gsub("(http|https|ftp):\\/\\/[\\w\\.\\/\\-\\%:\\?=#]+", "", text, perl = TRUE)
  # remove e-mail
  text <- gsub(email_regexp, "", text, perl = TRUE)
  # remove text between matching back ticks on the same line
  text <- gsub("`.+?`", "", text)
  # remove markdown comments
  text <- gsub("<!--.*?-->", "", text)
  # remove HTML image with alt tag while keeping the alt tag
  text <- gsub("<.*?alt ?= ?\"(.*?)\".*?>", "\"\\1\"", text)
  # remove HTML image without alt tag
  text <- gsub("<img.*?>", "", text)
  list(spelling_check(
    text = text, raw_text = raw_text, filename = md_file, wordlist = wordlist
  ))
}

#' @importFrom utils head
spelling_parse_md_yaml <- function(text) {
  header <- head(grep("---", text), 2)
  if (length(header) < 2) {
    return(text)
  }
  header <- header[1]:header[2]
  text[header][!grepl("(title|description)", text[header])] <- ""
  text[header] <- gsub(".*?:(.*)", "\\1", text[header])
  return(text)
}

#' Display a `checklist_spelling` summary
#' @param x The `checklist_spelling` object
#' @param ... currently ignored
#' @export
#' @importFrom fs path_common path_rel
#' @importFrom stats aggregate
#' @family both
print.checklist_spelling <- function(x, ...) {
  if (length(x) == 0) {
    return(invisible(NULL))
  }
  if (
    getOption("checklist.rstudio_source_markers", TRUE) &&
      requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::hasFun("sourceMarkers")
  ) {
    return(rstudio_source_markers(issues = x))
  }
  common <- path_common(x$file)
  x$file <- path_rel(x$file, start = common)
  x$file <- factor(
    x$file, levels = names(sort(table(x$file), decreasing = TRUE))
  )
  x$message <- factor(
    x$message, levels = names(sort(table(x$message), decreasing = TRUE))
  )
  display <- aggregate(
    column ~ file + language + message + line, x, FUN = paste, collapse = "|"
  )
  display$line <- sprintf("%i (%s)", display$line, display$column)
  display <- aggregate(
    line ~ file + language + message, display, FUN = paste, collapse = ", "
  )
  display <- display[order(display$message), ]
  display$message <- sprintf("%s: %s", display$message, display$line)
  display <- aggregate(
    message ~ file + language, display, FUN = paste, collapse = "\n"
  )
  display <- display[order(display$file), ]
  cat(
    "Overview of words missing from dictionary.",
    "i (j) indicates that the word occures at line i, column j", sep = "\n"
  )
  cat(
    sprintf("\n%s (%s)\n\n%s\n", display$file, display$language, display$message),
    sep = rules(".")
  )
  return(invisible(NULL))
}

#' @importFrom fs path_common
rstudio_source_markers <- function(issues) {
  assert_that(
    requireNamespace("rstudioapi", quietly = TRUE),
    msg = "This function requires the `rstudioapi` package"
  )
  common <- path_common(issues$file)
  issues$message <- sprintf(
    "`%s` not found in the dictionary or wordlist for %s.", issues$message,
    issues$language
  )
  issues$file <- factor(
    issues$file, levels = names(sort(table(issues$file), decreasing = TRUE))
  )
  issues <- issues[order(issues$file), ]
  issues$file <- as.character(issues$file)
  # request source markers
  rstudioapi::callFun(
    "sourceMarkers", name = "checklist_spelling", markers = issues,
    basePath = common, autoSelect = "first"
  )
}