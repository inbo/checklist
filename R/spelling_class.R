#' @title The spelling R6 class
#' @description A class with the configuration for spell checkking
#' @export
#' @importFrom R6 R6Class
#' @family class
spelling <- R6Class(
  "Spelling",
  public = list(
    #' @description Initialize a new Spelling object.
    #' @param language the default language.
    #' @param base_path the base path of the project
    #' @importFrom assertthat assert_that is.string noNA
    #' @importFrom fs dir_exists file_exists path_real
    initialize = function(language, base_path = ".") {
      assert_that(is.string(base_path), noNA(base_path), dir_exists(base_path))
      private$path <- path_real(base_path)
      if (file_exists(path(base_path, "DESCRIPTION"))) {
        desc_lang <- desc(base_path)$get_or_fail("Language")
        assert_that(
          missing(language) || language == desc_lang,
          msg = "different `language` found in DESCRIPTION"
        )
        language <- unname(desc_lang)
      }
      private$main <- validate_language(language)
      invisible(self)
    },
    #' @description Print the Spelling object.
    #' @param ... currently ignored.
    print = function(...) {
      dots <- list(...)
      if (!is.null(dots$quiet) && dots$quiet) {
        return(invisible(NULL))
      }
      cat("Root:", private$path, "\n\n")
      print(rbind(self$get_md, self$get_rd))
      return(invisible(NULL))
    },
    #' @description Define which files to ignore or to spell check in a
    #' different language.
    set_exceptions = function() {
      exceptions <- change_language_interactive(
        rbind(self$get_md, self$get_rd), main = private$main,
        ignore = private$ignore, other = private$other
      )
      private$ignore <- exceptions$ignore
      private$other <- exceptions$other
      return(self)
    },
    #' @description Manually set the ignore vector.
    #' Only use this if you known what you are doing.
    #' @param ignore The character vector with ignore file patterns.
    set_ignore = function(ignore) {
      assert_that(is.character(ignore))
      private$ignore <- ignore
      return(self)
    },
    #' @description Manually set the other list.
    #' Only use this if you known what you are doing.
    #' @param other a list with file patterns per additional language.
    set_other = function(other) {
      assert_that(is.list(other))
      assert_that(
        length(other) == 0 || length(names(other)) > 0,
        msg = "`other` must be a named list"
      )
      vapply(names(other), validate_language, character(1))
      private$other <- other
      return(self)
    }
  ),
  active = list(
    #' @field default The default language of the project.
    default = function() {
      return(private$main)
    },
    #' @field get_md The markdown files within the project.
    #' @importFrom fs dir_ls path
    get_md = function() {
      md_files <- dir_ls(
        private$path, recurse = TRUE, type = "file", regexp = "\\.[Rr]?md$",
        all = TRUE
      )
      get_language(files = md_files, private = private)
    },
    #' @field get_rd The Rd files within the project.
    #' @importFrom fs dir_ls
    get_rd = function() {
      rd_files <- dir_ls(
        path(private$path, "man"), recurse = FALSE, type = "file", all = TRUE,
        regexp = "\\.[Rr]d$"
      )
      get_language(files = rd_files, private = private)
    },
    #' @field settings A list with current spell checking settings.
    settings = function() {
      return(
        list(
          root = private$path, default = private$main, ignore = private$ignore,
          other = private$other
        )
      )
    }
  ),
  private = list(
    main = character(0), ignore = character(0), other = list(),
    path = character(0)
  )
)

#' @importFrom assertthat assert_that is.string noNA
validate_language <- function(language) {
  assert_that(is.string(language), noNA(language))
  assert_that(
    grepl("[a-z]{2}-[A-Z]{2}", language),
    msg = "`language` must be in xx-YY format"
  )
  return(language)
}

#' @importFrom fs path_has_parent path_rel
get_language <- function(files, private) {
  files <- data.frame(
    language = private$main, path = path_rel(files, start = private$path)
  )
  for (current in names(private$other)) {
    test_current <- outer(files$path, private$other[[current]], path_has_parent)
    files$language[apply(test_current, 1, any)] <- current
  }
  test_ignore <- outer(files, private$ignore, path_has_parent)
  files$language[apply(test_ignore, 1, any)] <- "ignore"
  class(files) <- c("checklist_language", class(files))
  attr(files, "checklist_default") <- private$main
  attr(files, "checklist_ignore") <- private$ignore
  return(files)
}

#' @importFrom fs path path_norm path_split
#' @importFrom utils menu
change_language_interactive <- function(
    x, main = "en-GB", other = list(), ignore = character(0)
) {
  print(x)
  answer <- menu(
    c(
      "Keep current configuration.",
      sprintf("Use %s for all files.", main),
      "Change the settings for some files."
    ),
    title = "\nHow should `checklist` spell check the files above?"
  )
  if (answer == 1) {
    return(invisible(list(other = other, ignore = ignore)))
  }
  other_lang <- names(other)
  other <- list()
  ignore <- character(0)
  if (answer == 2) {
    return(invisible(list(other = other, ignore = ignore)))
  }
  x <- x[order(x$path, method = "radix"), ]
  to_do <- rep(TRUE, nrow(x))
  detail <- path_split(x$path)
  n_max <- max(vapply(detail, length, integer(1)))
  detail <- vapply(
    detail, FUN.VALUE = character(n_max), n_max = n_max,
    FUN = function(x, n_max) {
      c(x, rep("", n_max - length(x)))
    }
  )
  detail <- rbind(".", detail)
  while (any(to_do)) {
    detail[1, ] <- path_norm(path(detail[1, ], detail[2, ]))
    detail <- detail[-2, , drop = FALSE]
    for (i in unique(detail[1, to_do])) {
      current <- which(to_do)[detail[1, to_do] == i]
      print(x[current, ], hide_ignore = TRUE)
      answer <- menu(
        c(
          paste(
            "use", c(main, other_lang),
            "for all files"[length(current) > 1]
          ),
          "use an additional language",
          "change the settings for some files"[length(current) > 1],
          paste("ignore",  "all files"[length(current) > 1])
        ),
        title = "\nHow should `checklist` spell check the files above?"
      )
      if (answer == 1) {
        to_do[current] <- FALSE
      } else if (1 < answer && answer <= (length(other_lang) + 1)) {
        other[[other_lang[answer - 1]]] <- sort(
          c(other[[other_lang[answer - 1]]], i),
          method = "radix"
        )
        to_do[current] <- FALSE
      } else if (answer == (length(other_lang) + 2)) {
        language <- validate_language(readline("Which language? "))
        other[[language]] <- i
        other_lang <- names(other)
        to_do[current] <- FALSE
      } else if (answer == (length(other_lang) + 3 + (length(current) > 1))) {
        ignore <- sort(c(ignore, i), method = "radix")
        to_do[current] <- FALSE
      }
    }
  }
  return(invisible(list(other = other, ignore = ignore)))
}

#' @export
#' @importFrom assertthat assert_that is.flag noNA
print.checklist_language <- function(x, ..., hide_ignore = FALSE) {
  assert_that(is.flag(hide_ignore), noNA(hide_ignore))

  cat("Default language:", attr(x, "checklist_default"), "\n\n")
  print(
    sort(x$path[x$language == attr(x, "checklist_default")], method = "radix")
  )
  x <- x[!x$language %in% c(attr(x, "checklist_default"), "ignore"), ]
  while (length(unique(x$language))) {
    current <- head(unique(x$language), 1)
    cat("\nAdditional language:", current, "\n\n")
    print(sort(x$path[x$language == current], method = "radix"))
    x <- x[x$language != current, ]
  }
  if (hide_ignore) {
    return(invisible(NULL))
  }
  if (length(attr(x, "checklist_ignore")) == 0) {
    cat("\nNo ignore patterns.")
    return(invisible(NULL))
  }
  cat("\nIgnore patterns:\n\n")
  cat(attr(x, "checklist_ignore"))
  return(invisible(NULL))
}
