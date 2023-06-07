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
      assert_that(is_dir(path), msg = "path is not an existing directory")
      private$path <- path
      if (is_file(path(path, "_bookdown.yml"))) {
        private$type <- "bookdown"
        meta <- citation_bookdown(self)
      } else {
        assert_that(
          is_file(path(path, "checklist.yml")),
          msg = "no `checklist.yml` found. See ?write_checklist "
        )
        read_checklist(x = path) |>
          citation_rbuildignore() -> x
        private$type <- ifelse(x$package, "package", "project")
        meta <- switch(
          private$type, package = citation_description(self),
          citation_readme(self)
        )
        meta$meta$language <- x$default
      }
      private$meta <- meta$meta
      private$errors <- meta$errors
      private$notes <- meta$notes
      private$warnings <- meta$warnings
      if (length(private$errors) == 0) {
        validated <- validate_citation(self)
        private$errors <- c(private$errors, validated$errors)
        private$notes <- c(private$notes, validated$notes)
      }
      if (length(private$errors) > 0) {
        warning(
          "Errors found parsing citation meta data. ",
          "Citation files not updated.", call. = FALSE, noBreaks. = TRUE
        )
        return(invisible(self))
      }
      private$errors <- c(
        private$errors, citation_r(self), citation_zenodo(self),
        citation_cff(self)
      )
      return(self)
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
      return(private$errors)
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
      "\n  roles:",
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

#' @importFrom assertthat assert_that
validate_citation <- function(meta) {
  assert_that(inherits(meta, "citation_meta"))
  org <- organisation$new()
  roles <- meta$get_meta$roles
  authors <- meta$get_meta$authors
  rightsholder_id <- roles$contributor[roles$role == "copyright holder"]
  funder_id <- roles$contributor[roles$role == "funder"]
  notes <- c(
    sprintf("rightsholder differs from `%s`", org$get_rightsholder)[
      authors$given[authors$id == rightsholder_id] != org$get_rightsholder
    ],
    sprintf("funder differs from `%s`", org$get_funder)[
      authors$given[authors$id == funder_id] != org$get_funder
    ]
  )
  errors <- c(
    sprintf("invalid ORCID for %s %s", authors$given, authors$family)[
      !validate_orcid(authors$orcid)
    ],
    sprintf("missing required Zenodo community `%s`", org$get_community)[
      !org$get_community %in% meta$get_meta$community
    ]
  )
  authors <- authors[authors$given != org$get_rightsholder, ]
  authors <- authors[authors$given != org$get_funder, ]
  authors <- authors[authors$organisation %in% names(org$get_organisation), ]
  vapply(
    seq_along(authors$organisation),
    FUN.VALUE = vector(mode = "list", length = 1), org = org$get_organisation,
    FUN = function(i, org) {
      paste(
        "Non standard affiliation for %s %s as member of `%s`. ",
        "Please use any of the following", collapse = ""
      ) |>
        sprintf(
          authors$given[i], authors$family[i], authors$organisation[i]
        ) -> error
      error <- error[
        !authors$affiliation[i] %in% org[[authors$organisation[i]]]$affiliation
      ]
      if (org[[authors$organisation[i]]]$orcid) {
        error <- c(
          error,
          sprintf(
            "No ORCID for %s %s. This is required for `%s`", authors$given[i],
            authors$family[i], authors$organisation[i]
          )[is.na(authors$orcid[i]) || authors$orcid[i] == ""]
        )
      }
      return(list(error))
    }
  ) |>
    unlist() |>
    c(errors) -> errors
  list(notes = notes, errors = errors)
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
      "author", "contact person", "contributor", "copyright holder", "funder",
      "reviewer"
    ),
    labels = c(
      "author", "ContactPerson", "ProjectMember", "RightsHolder", "Funder",
      "Other"
    )
  )
  relevant <- zenodo$roles$role %in% c(
    "ContactPerson", "ProjectMember", "RightsHolder", "Other"
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
    "Run `checklist::update_citation()` locally."[!interactive()],
    "Please commit changes."
  )[
    !is_tracked_not_modified(
      path_rel(citation_file, meta$get_path), meta$get_path
    )
  ]
  return(errors)
}

format_zenodo <- function(x, i) {
  formatted <- list(
    name = ifelse(
      x$family[i] == "", x$given[i],
      ifelse(
        x$given[i] == "", x$family[i],
        paste(x$family[i], x$given[i], sep = ", ")
      )
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
  if (!meta$get_type %in% c("package", "project")) {
    return(character(0))
  }
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
    "Run `checklist::update_citation()` locally."[!interactive()],
    "Please commit changes."
  )[
    !is_tracked_not_modified(
      path_rel(citation_file, meta$get_path), meta$get_path
    )
  ]
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
  errors <- c(
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
  if (length(errors) > 0) {
    return(errors = errors)
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
    bibtype = "\"Manual\"",
    title = sprintf(
      "\"%s. Version %s\"", cit_meta$title, cit_meta$version
    ),
    author = sprintf("c(%s)", authors_bibtex),
    year = format(Sys.Date(), "%Y"),
    url = c(cit_meta$url, cit_meta$source) |>
      head(1) |>
      sprintf(fmt = "\"%s\""),
    abstract = paste0("\"", cit_meta$description, "\""),
    textVersion = sprintf(
      "\"%s (%s) %s. Version %s. %s\"",
      paste(authors_plain, collapse = "; "), format(Sys.Date(), "%Y"),
      cit_meta$title, cit_meta$version,
      paste0(paste(c(cit_meta$source, cit_meta$url), collapse = "; "), "")
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
  c(head(cit, start), "bibentry(", package_citation, ")", tail(cit, 1 - end)) |>
    writeLines(citation_file)
  errors <- paste(
    citation_file, "is modified.",
    "Run `checklist::update_citation()` locally."[!interactive()],
    "Please commit changes."
  )[
    !is_tracked_not_modified(
      path_rel(citation_file, meta$get_path), meta$get_path
    )
  ]
  return(errors = errors)
}

#' @importFrom fs file_copy is_file path
citation_rbuildignore <- function(x = ".") {
  x <- read_checklist(x = x)
  if (!x$package) {
    return(invisible(x))
  }
  rbuildignore_file <- path(x$get_path, ".Rbuildignore")
  if (!is_file(rbuildignore_file)) {
    file_copy(
      system.file(
        path("package_template", "rbuildignore"), package = "checklist"
      ),
      rbuildignore_file
    )
    return(invisible(x))
  }
  current <- readLines(rbuildignore_file)
  c("^\\.zenodo\\.json$", "^CITATION\\.cff$", current) |>
    unique() |>
    c_sort() |>
    writeLines(rbuildignore_file)
  return(invisible(x))
}
