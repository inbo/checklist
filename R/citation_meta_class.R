#' @title The `citation_meta` R6 class
#' @description A class which contains citation information.
#' @export
#' @importFrom R6 R6Class
#' @family class
citation_meta <- R6Class(

  "citation_meta",

  public = list(

    #' @description Initialize a new `citation_meta` object.
    #' @param path The path to the root of the project.
    #' @importFrom assertthat assert_that is.flag is.string noNA
    #' @importFrom fs is_dir is_file path_real
    initialize = function(path = ".") {
      assert_that(is.string(path), noNA(path))
      path <- path_real(path)
      stopifnot(
        "path is not an existing directory" = is_dir(path),
        "no `checklist.yml` found. See ?write_checklist " = is_file(
          path(path, "checklist.yml")
        )
      )
      x <- read_checklist(x = path)
      private$path <- path
      private$type <- ifelse(x$package, "package", "project")
      meta <- switch(
        private$type, package = citation_description(self),
        citation_readme(self)
      )
      meta$meta$language <- x$default
      private$meta <- meta$meta
      private$errors <- meta$errors
      private$notes <- meta$notes
      private$warnings <- meta$warnings
      if (length(private$errors) > 0) {
        warning(
          "Errors found parsing citation meta data. ",
          "Citation files not updated."
        )
        return(invisible(self))
      }
      private$errors <- c(
        private$errors, citation_r(self), citation_zenodo(self),
        citation_cff(self)
      )
      return(invisible(self))
    },

    #' @description Print the `citation_meta` object.
    #' @param ... currently ignored.
    print = function(...) {
      dots <- list(...)
      if (!is.null(dots$quiet) && dots$quiet) {
        return(invisible(NULL))
      }
      citation_print(
        path = private$path, warnings = private$warnings, notes = private$notes,
        errors = private$errors, meta = private$meta
      )
    }

  ),

  active = list(

    #' @field get_errors Return the errors
    get_errors = function() {
      return(private$erros)
    },

    #' @field get_meta Return the meta data as a list
    get_meta = function() {
      return(private$meta)
    },

    #' @field get_notes Return the notes
    get_notes = function() {
      return(private$notes)
    },

    #' @field get_type A string indicating the type of source.
    get_type = function() {
      return(private$type)
    },

    #' @field get_path The path to the project.
    get_path = function() {
      return(private$path)
    },

    #' @field get_warnings Return the warnings
    get_warnings = function() {
      return(private$warnings)
    }

  ),

  private = list(
    errors = character(0), notes = character(0), meta = list(),
    path = character(0), type = character(0), warnings = list()
  )
)

citation_print <- function(errors, meta, notes, path, warnings) {
  cat(rules())
  cat("\ncitation meta data for", path, "\n")
  cat(rules())
  cat("\ntitle:", meta$title)
  cat("\ncontributors:")
  for (i in seq_along(meta$authors$id)) {
    cat("\n- given:", meta$authors$given[i])
    cat("\n  family:", meta$authors$family[i])
    cat("\n  affiliation:", meta$authors$affiliation[i])
    cat("\n  orcid:", meta$authors$orcid[i])
    cat(
      "\n  roles: ",
      paste(
        meta$roles$role[meta$roles$contributor == meta$authors$id[i]],
        collapse = "; "
      )
    )
  }
  cat("\nversion:", as.character(meta$version))
  cat("\nlicense:", meta$license)
  cat("\nlanguage:", meta$language)
  cat("\nupload type:", meta$upload_type)
  cat("\nkeywords:", paste(meta$keywords, collapse = "; "))
  cat("\ncommunities:", paste(meta$community, collapse = "; "))
  cat("\ndoi:", meta$doi)
  cat("\nsource URL:", meta$source)
  cat("\nwebsite URL:", meta$url)
  cat("\ndescription:\n\n")
  cat(meta$description, sep = "\n")
  cat(rules())
  if (length(errors) > 0) {
    cat("\nErrors found while parsing citation meta data\n")
    cat(rules("-"))
    cat(errors, sep = "\n")
    cat(rules())
  }
  if (length(warnings) > 0) {
    cat("\nWarnings found while parsing citation meta data\n")
    cat(rules("-"))
    cat(warnings, sep = "\n")
    cat(rules())
  }
  if (length(notes) > 0) {
    cat("\nNotes found while parsing citation meta data\n")
    cat(rules("-"))
    cat(notes, sep = "\n")
    cat(rules())
  }
}

#' @importFrom assertthat assert_that has_name
#' @importFrom fs path
#' @importFrom jsonlite toJSON
#' @importFrom knitr pandoc
citation_zenodo <- function(meta) {
  assert_that(inherits(meta, "citation_meta"))
  assert_that(length(meta$get_errors) == 0)
  zenodo <- meta$get_meta
  if (has_name(zenodo, "version")) {
    zenodo$version <- as.character(zenodo$version)
  }
  zenodo$roles$role <- factor(
    zenodo$roles$role,
    levels = c(
      "author", "contact person", "contributor", "copyright holder", "funder"
    ),
    labels = c(
      "author", "ContactPerson", "ProjectMember", "RightsHolder", "Funder"
    )
  )
  relevant <- zenodo$roles$role %in% c(
    "ContactPerson", "ProjectMember", "RightsHolder"
  )
  zenodo$contributors <- merge(
    zenodo$authors, zenodo$roles[relevant, ], by.x = "id", by.y = "contributor"
  )
  zenodo$contributors <- vapply(
    seq_len(nrow(zenodo$contributors)), FUN = format_zenodo,
    FUN.VALUE = vector("list", 1), x = zenodo$contributors
  )
  relevant <- zenodo$roles$role == "author"
  zenodo$creators <- merge(
    zenodo$authors, zenodo$roles[relevant, ], by.x = "id", by.y = "contributor"
  )
  zenodo$creators <- vapply(
    seq_len(nrow(zenodo$creators)), FUN = format_zenodo,
    FUN.VALUE = vector("list", 1), x = zenodo$creators
  )
  zenodo$roles <- NULL
  zenodo$authors <- NULL
  zenodo$access_right <- "open"
  zenodo$keywords <- as.list(zenodo$keywords)
  if (has_name(zenodo, "community")) {
    zenodo$communities <- vapply(
      zenodo$community, FUN.VALUE = vector("list", 1), USE.NAMES = FALSE,
      FUN = function(x) {
        list(list(identifier = x))
      }
    )
    zenodo$community <- NULL
  }
  if (has_name(zenodo, "language")) {
    zenodo$language <- lang_2_iso_639_3(zenodo$language)
  }
  if (has_name(zenodo, "doi") && grepl("zenodo", zenodo$doi)) {
    zenodo$doi <- NULL
  }
  zenodo$url <- NULL
  zenodo$source <- NULL
  desc <- tempfile(fileext = ".md")
  writeLines(zenodo$description, desc)
  suppressMessages(pandoc(desc, format = "html"))
  gsub("\\.md", ".html", desc) |>
    readLines() |>
    paste(collapse = "\n") -> zenodo$description
  citation_file <- path(meta$get_path, ".zenodo.json")
  toJSON(zenodo, pretty = TRUE, auto_unbox = TRUE) |>
    writeLines(citation_file)
  errors <- paste(
    citation_file, "is modified.",
    "Run `checklist::citation_meta$new()` locally."[!interactive()],
    "Please commit changes."
  )[!is_tracked_not_modified(citation_file, meta$get_path)]
  return(errors)
}

format_zenodo <- function(x, i) {
  formatted <- list(
    name = ifelse(
      x$family[i] == "", x$given[i], paste(x$family[i], x$given[i], sep = ", ")
    )
  )
  if (x$affiliation[i] != "") {
    formatted$affiliation <- x$affiliation[i]
  }
  if (x$orcid[i] != "") {
    formatted$orcid <- x$orcid[i]
  }
  if (x$role[i] != "author") {
    formatted$type <- as.character(x$role[i])
  }
  return(list(formatted))
}

citation_cff <- function(meta) {
  assert_that(inherits(meta, "citation_meta"))
  assert_that(length(meta$get_errors) == 0)
  input <- meta$get_meta
  relevant <- input$roles$role == "author"
  authors <- merge(
    input$authors, input$roles[relevant, ], by.x = "id", by.y = "contributor"
  )
  authors <- vapply(
    seq_len(nrow(authors)), FUN = format_cff, FUN.VALUE = vector("list", 1),
    x = authors
  )
  relevant <- input$roles$role == "contact person"
  contact <- merge(
    input$authors, input$roles[relevant, ], by.x = "id", by.y = "contributor"
  )
  contact <- vapply(
    seq_len(nrow(contact)), FUN = format_cff, FUN.VALUE = vector("list", 1),
    x = contact
  )
  if (has_name(input, "doi")) {
    identifiers <- list(list(type = "doi", value = input$doi))
  } else {
    identifiers <- list()
  }
  if (has_name(input, "url")) {
    identifiers <- c(identifiers, list(list(type = "url", value = input$url)))
  }
  cff <- list(
    `cff-version` = "1.2.0",
    message = "If you use this software, please cite it using these metadata.",
    title = input$title, authors = authors, keywords = as.list(input$keywords),
    contact = contact, doi = input$doi, license = input$license,
    `repository-code` = input$source, type = input$upload_type,
    abstract = strip_markdown(input$description) |>
      paste(collapse = "\n")
  )
  if (length(identifiers) > 0) {
    cff$identifiers <- identifiers
  }
  if (has_name(input, "version")) {
    cff$version <- as.character(input$version)
  }
  citation_file <- path(meta$get_path, "CITATION.cff")
  write_yaml(x = cff, file = citation_file, fileEncoding = "UTF-8")
  errors <- paste(
    citation_file, "is modified.",
    "Run `checklist::citation_meta$new()` locally."[!interactive()],
    "Please commit changes."
  )[!is_tracked_not_modified(citation_file, meta$get_path)]
  return(errors)
}

format_cff <- function(x, i) {
  formatted <- list(`given-names` = x$given[i])
  if (x$family[i] != "") {
    formatted$`family-names` <- x$family[i]
  }
  if (x$affiliation[i] != "") {
    formatted$affiliation <- x$affiliation[i]
  }
  if (x$orcid[i] != "") {
    formatted$orcid <- x$orcid[i]
  }
  return(list(formatted))
}

#' @importFrom assertthat assert_that
#' @importFrom fs dir_create is_file path
#' @importFrom utils head tail
citation_r <- function(meta) {
  assert_that(inherits(meta, "citation_meta"))
  if (meta$get_type != "package") {
    return(character(0))
  }
  assert_that(length(meta$get_errors) == 0)
  cit_meta <- meta$get_meta
  citation_file <- path(meta$get_path, "inst", "CITATION")
  if (is_file(citation_file)) {
    cit <- readLines(citation_file)
  } else {
    dirname(citation_file) |>
      dir_create()
    cit <- c(
      sprintf(
        "citHeader(\"To cite `%s` in publications please use:\")",
        gsub("^(.*?):.*", "\\1", cit_meta$title)
      ),
      "# begin checklist entry", "# end checklist entry"
    )
  }
  start <- grep("^# begin checklist entry", cit)
  end <- grep("^# end checklist entry", cit)
  problems <- c(
    "No `# begin checklist entry` found in `inst/CITATION`"[length(start) == 0],
    "No `# end checklist entry` found in `inst/CITATION`"[length(end) == 0],
    "Multiple `# begin checklist entry` found in `inst/CITATION`"[
      length(start) > 1
    ],
    "Multiple `# end checklist entry` found in `inst/CITATION`"[
      length(end) > 1
    ],
  "`# end checklist entry` before `# begin checklist entry` in `inst/CITATION`"[
      head(start, length(end)) >= head(end, length(start))
    ]
  )
  if (length(problems) > 0) {
    return(problems)
  }
  authors <- cit_meta$roles$contributor[cit_meta$roles$role == "author"]
  authors <- cit_meta$authors[cit_meta$authors$id %in% authors, ]
  authors$fam <- ifelse(
    authors$family == "", "", sprintf(", family = \"%s\"", authors$family)
  )
  authors$fam2 <- ifelse(
    authors$family == "", "", sprintf("%s, ", authors$family)
  )
  sprintf("person(given = \"%s\"%s)", authors$given, authors$fam) |>
    paste(collapse = ", ") |>
    sprintf(fmt = "  author = c(%s)") -> authors_bibtex
  sprintf("%s%s", authors$fam2, authors$given) -> authors_plain
  package_citation <- c(
    entry = "\"Manual\"",
    title = sprintf(
      "\"%s. Version %s\"", cit_meta$title, cit_meta$version
    ),
    author = sprintf("c(%s)", authors_bibtex),
    year = format(Sys.Date(), "%Y"),
    url = paste0("\"", cit_meta$url, "\""),
    abstract = paste0("\"", cit_meta$description, "\""),
    textVersion = sprintf(
      "\"%s (%s) %s. Version %s. %s\"",
      paste(authors_plain, collapse = "; "), format(Sys.Date(), "%Y"),
      cit_meta$title, cit_meta$version, cit_meta$url
    ),
    keywords = paste0("\"", paste(cit_meta$keywords, collapse = "; "), "\"")
  )
  if (length(cit_meta$doi)) {
    package_citation <- c(
      package_citation, doi = paste0("\"", cit_meta$doi, "\"")
    )
  }
  package_citation <- gsub("\n", " ", package_citation)
  package_citation <- gsub("[ ]{2, }", " ", package_citation)
  package_citation <- sprintf(
    "  %s = %s,", names(package_citation), package_citation
  )
  c(head(cit, start), "citEntry(", package_citation, ")", tail(cit, 1 - end)) |>
    writeLines(citation_file)
  errors <- paste(
    citation_file, "is modified.",
    "Run `checklist::citation_meta$new()` locally."[!interactive()],
    "Please commit changes."
  )[!is_tracked_not_modified(citation_file, meta$get_path)]
  return(errors)
}