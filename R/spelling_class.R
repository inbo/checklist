#' @title The spelling R6 class
#' @description A class with the configuration for spell checking
#' @export
#' @importFrom R6 R6Class
#' @family class
spelling <- R6Class(
  "spelling",
  public = list(
    #' @description Initialize a new `spelling` object.
    #' @param language the default language.
    #' @param base_path the base path of the project
    #' @importFrom assertthat assert_that is.string noNA
    #' @importFrom fs dir_exists file_exists path_real
    initialize = function(language, base_path = ".") {
      assert_that(is.string(base_path), noNA(base_path), dir_exists(base_path))
      private$path <- path_real(base_path)
      if (file_exists(path(base_path, "DESCRIPTION"))) {
        desc_lang <- desc(base_path)$get_field("Language", default = NA)
        assert_that(
          !is.na(desc_lang),
          msg = paste(
            "No `Language` field found in DESCRIPTION.",
            "Please add `Language: en-GB` to DESCRIPTION."
          )
        )
        assert_that(
          missing(language) || language == desc_lang,
          msg = "different `language` found in DESCRIPTION"
        )
        language <- unname(desc_lang)
      }
      private$main <- validate_language(language)
      invisible(self)
    },
    #' @description Print the `spelling` object.
    #' @param ... currently ignored.
    print = function(...) {
      dots <- list(...)
      cat("Root:", private$path, "\n\n")
      print(rbind(self$get_md, self$get_rd, self$get_r))
      return(invisible(NULL))
    },
    #' @description Define which files to ignore or to spell check in a
    #' different language.
    #' @param language The language.
    set_default = function(language) {
      private$main <- validate_language(language)
      private$other[[private$main]] <- NULL
      return(self)
    },
    #' @description Define which files to ignore or to spell check in a
    #' different language.
    set_exceptions = function() {
      exceptions <- change_language_interactive(
        rbind(self$get_md, self$get_rd, self$get_r),
        main = private$main,
        ignore = private$ignore,
        other = private$other
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
        private$path,
        recurse = TRUE,
        type = "file",
        regexp = "\\.[Rrq]?md$",
        all = TRUE
      )
      get_language(files = md_files, private = private)
    },
    #' @field get_r The R files within the project.
    #' @importFrom fs dir_exists dir_ls
    get_r = function() {
      r_files <- dir_ls(
        private$path,
        recurse = TRUE,
        type = "file",
        regexp = "\\.[R|r]$",
        all = TRUE
      )
      get_language(files = r_files, private = private)
    },
    #' @field get_rd The Rd files within the project.
    #' @importFrom fs dir_exists dir_ls
    get_rd = function() {
      if (dir_exists(path(private$path, "man"))) {
        rd_files <- dir_ls(
          path(private$path, "man"),
          recurse = FALSE,
          type = "file",
          all = TRUE,
          regexp = "\\.[Rr]d$"
        )
      } else {
        rd_files <- character(0)
      }
      get_language(files = rd_files, private = private)
    },
    #' @field settings A list with current spell checking settings.
    settings = function() {
      return(
        list(
          root = private$path,
          default = private$main,
          ignore = private$ignore,
          other = private$other
        )
      )
    }
  ),
  private = list(
    main = character(0),
    ignore = character(0),
    other = list(),
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

#' @importFrom fs path_filter path_has_parent path_rel
get_language <- function(files, private) {
  if (length(files) == 0) {
    files <- data.frame(language = character(0), path = character(0))
    class(files) <- c("checklist_language", class(files))
    attr(files, "checklist_default") <- private$main
    attr(files, "checklist_ignore") <- private$ignore
    return(files)
  }
  path_rel(files, start = private$path) |>
    path_filter(path("*renv", "library*"), invert = TRUE) -> files
  files <- data.frame(language = private$main, path = files)
  for (current in names(private$other)) {
    test_current <- outer(files$path, private$other[[current]], path_has_parent)
    files$language[apply(test_current, 1, any)] <- current
  }
  test_ignore <- outer(files$path, private$ignore, path_has_parent)
  files$language[apply(test_ignore, 1, any)] <- "ignore"
  dir_ls(private$path, regexp = "_quarto\\.yml", recurse = TRUE) |>
    vapply(
      FUN = list_quarto_md,
      FUN.VALUE = vector(mode = "list", length = 1L),
      root = private$path
    ) |>
    c(list(data.frame(quarto_lang = character(0), path = character(0)))) |>
    do.call(what = rbind) |>
    merge(x = files, all.x = TRUE, by = "path") -> files
  files$language <- ifelse(
    is.na(files$quarto_lang),
    files$language,
    files$quarto_lang
  )
  files$quarto_lang <- NULL
  class(files) <- c("checklist_language", class(files))
  attr(files, "checklist_default") <- private$main
  attr(files, "checklist_ignore") <- private$ignore
  return(files)
}

#' @importFrom assertthat has_name
#' @importFrom fs path path_dir path_rel
#' @importFrom yaml read_yaml
list_quarto_md <- function(quarto, root) {
  settings <- read_yaml(quarto)
  if (has_name(settings, "book")) {
    files <- yaml_extract_filename(settings$book)
  } else if (has_name(settings, "website")) {
    files <- yaml_extract_filename(settings$website)
  } else {
    return(list(data.frame(quarto_lang = character(0), path = character(0))))
  }
  unlist(files) |>
    unname() |>
    unique() -> files
  path_dir(quarto) |>
    path_rel(root) |>
    path(files) -> files
  files <- files[file_test("-f", path(root, files))]
  path(root, files) |>
    vapply(
      FUN.VALUE = character(1),
      lang = settings$lang,
      FUN = function(x, lang) {
        coalesce(yaml_front_matter(x)$lang, lang, NA_character_)
      }
    ) -> languages
  list(data.frame(quarto_lang = languages, path = files))
}

#' @importFrom fs path path_norm path_split
#' @importFrom utils menu
change_language_interactive <- function(
  x,
  main = "en-GB",
  other = list(),
  ignore = character(0)
) {
  print(x)
  answer <- menu_first(
    c(
      "Keep current configuration.",
      sprintf("Use %s for all files.", main),
      "Change the settings for some files."
    ),
    title = "\nHow should `checklist` spell check the files above?"
  )
  if (answer <= 2) {
    other <- ifelse(answer == 1, list(other), list(list()))[[1]]
    ignore <- ifelse(answer == 1, list(ignore), list(character(0)))[[1]]
    return(invisible(list(other = other, ignore = ignore)))
  }
  x <- x[order(x$path, method = "radix"), ]
  result <- change_language_interactive2(
    x,
    main = main,
    other_lang = names(other),
    base_path = "."
  )
  return(invisible(list(other = result$other, ignore = result$ignore)))
}

#' @importFrom fs path path_norm path_split
#' @importFrom stats setNames
change_language_interactive2 <- function(x, main, other_lang, base_path = ".") {
  first_path <- vapply(
    path_split(x$path),
    FUN = `[`,
    FUN.VALUE = character(1),
    x = 1
  )
  x$path <- path_norm(path(base_path, x$path))
  other <- list()
  ignore <- character(0)
  for (i in unique(first_path)) {
    current <- which(first_path == i)
    print(c_sort(x$path[current]))
    answer <- menu_first(
      c(
        paste("ignore", "all files"[length(current) > 1]),
        paste(
          "use",
          c(sprintf("%s (default)", main), other_lang),
          "for all files"[length(current) > 1]
        ),
        "change the settings for some files"[length(current) > 1],
        "use an additional language"
      ),
      title = "\nHow should `checklist` spell check the files above?"
    )
    if (answer == 1) {
      ignore <- c_sort(c(ignore, path_norm(path(base_path, i))))
      next
    }
    if (answer == 2) {
      next
    }
    if (length(current) > 1 && answer == length(other_lang) + 3) {
      x2 <- x[current, ]
      x2$path <- path_rel(x2$path, start = path(base_path, i))
      x2 <- change_language_interactive2(
        x = x2,
        main = main,
        other_lang = other_lang,
        base_path = path(base_path, i)
      )
      other_lang <- unique(c(other_lang, x2$other_lang))
      ignore <- c_sort(c(ignore, x2$ignore))
      for (j in names(x2$other)) {
        other[[j]] <- c_sort(c(other[[j]], x2$other[[j]]))
      }
      next
    }
    if (answer == length(other_lang) + 3 + (length(current) > 1)) {
      language <- validate_language(readline("Which language? "))
      other_lang <- c_sort(c(other_lang, language))
      other <- c(other, setNames(list(x$path[current]), language))
      next
    }
    other[[other_lang[answer - 2]]] <- c_sort(
      c(other[[other_lang[answer - 2]]], x$path[current])
    )
  }
  return(list(ignore = ignore, other = other, other_lang = other_lang))
}

#' @export
#' @importFrom assertthat assert_that is.flag noNA
print.checklist_language <- function(x, ..., hide_ignore = FALSE) {
  assert_that(is.flag(hide_ignore), noNA(hide_ignore))

  cat("Default language:", attr(x, "checklist_default"), "\n\n")
  if (any(x$language == attr(x, "checklist_default"))) {
    print(
      c_sort(x$path[x$language == attr(x, "checklist_default")])
    )
  }
  x <- x[!x$language %in% c(attr(x, "checklist_default"), "ignore"), ]
  while (length(unique(x$language))) {
    current <- head(unique(x$language), 1)
    cat("\nAdditional language:", current, "\n\n")
    print(c_sort(x$path[x$language == current]))
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

yaml_extract_filename <- function(yaml) {
  if (inherits(yaml, "list")) {
    if (has_name(yaml, "file")) {
      return(list(yaml$file))
    }
    return(list(vapply(yaml, yaml_extract_filename, list(1))))
  }
  if (!is.character(yaml)) {
    return(list(NULL))
  }
  list(yaml[grepl(".q?md$", yaml)])
}
