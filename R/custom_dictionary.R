#' Add words to custom dictionaries
#' @param issues The output of `check_spelling()`.
#' @export
#' @family both
custom_dictionary <- function(issues) {
  assert_that(inherits(issues, "checklist"))
  issues <- issues$get_spelling
  assert_that(
    !is.null(attr(issues, "checklist_path")),
    msg = "Something went wrong. Please rerun `check_spelling().`"
  )

  vapply(unique(issues$language), FUN.VALUE = logical(1), FUN = function(lang) {
    dict_file <- tolower(gsub("-", "_", lang))
    dict_file <- file.path(attr(issues, "checklist_path"), "inst", dict_file)
    unique(issues$message[issues$language == lang]) |>
      add_words(dictionary = dict_file)
    return(TRUE)
  })
  return(invisible(NULL))
}

add_words <- function(words, dictionary) {
  dictionary <- paste0(tools::file_path_sans_ext(dictionary), ".dic")
  if (file_test("-f", dictionary)) {
    words <- c(words, readLines(dictionary))
  }
  dir.create(dirname(dictionary), recursive = TRUE, showWarnings = FALSE)
  writeLines(c_sort(unique(words)), dictionary)
  return(invisible(NULL))
}
