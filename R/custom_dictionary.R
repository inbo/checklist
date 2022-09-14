#' Add words to custom dictionaries
#' @param issues The output of `check_spelling()`.
#' @export
#' @importFrom fs path
#' @family both
custom_dictionary <- function(issues) {
  assert_that(inherits(issues, "checklist"))
  issues <- issues$get_spelling
  assert_that(
    !is.null(attr(issues, "checklist_path")),
    msg = "Something went wrong. Please rerun `check_spelling().`"
  )

  vapply(
    unique(issues$language), FUN.VALUE = logical(1),
    FUN = function(lang) {
      dict_file <- tolower(gsub("-", "_", lang))
      dict_file <- path(attr(issues, "checklist_path"), "inst", dict_file)
      unique(issues$message[issues$language == lang]) |>
        add_words(dictionary = dict_file)
      return(TRUE)
    }
  )
  return(invisible(NULL))
}

#' @importFrom fs dir_create file_exists path path_dir path_ext_remove
add_words <- function(words, dictionary) {
  dictionary <- path(path_ext_remove(dictionary), ext = "dic")
  if (file_exists(dictionary)) {
    words <- c(words, readLines(dictionary))
  }
  dir_create(path_dir(dictionary), recurse = TRUE)
  writeLines(c_sort(unique(words)), dictionary)
  return(invisible(NULL))
}
