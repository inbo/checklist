#' @importFrom hunspell dictionary en_stats
spelling_wordlist <- function(lang = "en_GB", root = ".") {
  add_words <- en_stats
  wordlist_file <- file.path(root, "inst", paste0("wordlist.", tolower(lang)))
  if (file.exists(wordlist_file)) {
    add_words <- c(add_words, readLines(wordlist_file))
  }
  dict <- dictionary(lang = lang, add_words = add_words)
  attr(dict, "checklist_language") <- gsub("_", "-", lang)
  return(dict)
}

#' @importFrom hunspell hunspell
spelling_check <- function(text, filename, wordlist) {
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
    text = text, problems = problems,
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
  result$file <- filename
  result$type <- "warning"
  result$language <- attr(wordlist, "checklist_language")
  rownames(result) <- NULL
  class(result) <- c("checklist_spelling", class(result))
  return(result)
}

#' @importFrom tools RdTextFilter
spelling_parse_rd <- function(rd_file, marcros, wordlist) {
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
  text <- readLines(md_file)
  text <- spelling_parse_md_yaml(text = text)
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
  text <- gsub("(http|https|ftp):\\/\\/[\\w|\\.|\\/|-]+", "", text, perl = TRUE)
  # remove e-mail
  text <- gsub(email_regexp, "", text, perl = TRUE)
  # remove spell-check ignore
  text <- gsub(".*<!-- spell-check: ignore -->.*", "", text)
  list(spelling_check(
    text = text, filename = md_file, wordlist = wordlist
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

#' Spell check a package or project
#' @inheritParams read_checklist
#' @export
#' @importFrom tools loadPkgRdMacros loadRdMacros
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
      wordlist <- spelling_wordlist(lang = gsub("-", "_", lang), root = root)
      md_issues <- vapply(
        path(root, md_files$path[md_files$language == lang]),
        FUN = spelling_parse_md, FUN.VALUE = vector(mode = "list", length = 1),
        wordlist = wordlist
      )
      rd_issues <- vapply(
        path(root, rd_files$path[rd_files$language == lang]),
        FUN = spelling_parse_rd, FUN.VALUE = vector(mode = "list", length = 1),
        wordlist = wordlist
      )
      return(list(c(md_issues, rd_issues)))
    }
  )
  issues <- do.call(rbind, unlist(issues, recursive = FALSE))
  rownames(issues) <- NULL
  return(issues)
}

#' Display a `checklist_spelling` summary
#' @param x The `checklist_spelling` object
#' @param ... currently ignored
#' @export
#' @importFrom fs path_common path_rel
print.checklist_spelling <- function(x, ...) {
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
