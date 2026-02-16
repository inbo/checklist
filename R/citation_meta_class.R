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
      } else if (is_file(path(path, "_quarto.yml"))) {
        private$type <- "quarto"
        meta <- citation_quarto(self)
      } else {
        assert_that(
          is_file(path(path, "checklist.yml")),
          msg = "no `checklist.yml` found. See ?write_checklist "
        )
        read_checklist(x = path) |>
          citation_rbuildignore() -> x
        private$type <- ifelse(x$package, "package", "project")
        meta <- switch(
          private$type,
          package = citation_description(self),
          citation_readme(
            self,
            org = org_list$new()$read(x$get_path),
            lang = x$default
          )
        )
        meta$meta$language <- x$default
      }
      private$person <- meta$person
      private$meta <- meta$meta
      private$errors <- meta$errors
      private$notes <- meta$notes
      private$warnings <- meta$warnings
      if (length(private$errors) == 0) {
        private$errors <- c(private$errors, validate_citation(self))
      }
      if (length(private$errors) > 0) {
        warning(
          "Errors found parsing citation meta data. ",
          "Citation files not updated.",
          call. = FALSE,
          immediate. = TRUE,
          noBreaks. = TRUE
        )
        return(invisible(self))
      }
      private$errors <- c(
        private$errors,
        citation_r(self),
        citation_zenodo(self),
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
        errors = private$errors,
        meta = private$meta,
        notes = private$notes,
        path = private$path,
        person = private$person,
        warnings = private$warnings
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

    #' @field get_person Return the authors and organisations as a list of
    #' `person` objects.
    get_person = function() {
      private$person
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
    errors = character(0),
    notes = character(0),
    meta = list(),
    path = character(0),
    person = person(),
    type = character(0),
    warnings = list()
  )
)

citation_print <- function(errors, meta, notes, path, person, warnings) {
  cat(rules())
  cat("\ncitation meta data for", path, "\n")
  cat(rules())
  cat("\ntitle:", meta$title)
  cat("\ncontributors:\n")
  format(
    person,
    braces = list(
      given = c("- given: ", "\n"),
      family = c("  family: ", "\n"),
      email = c("  email: ", "\n"),
      comment = c("  comment: ", "\n"),
      role = c("  role: ", "\n")
    )
  ) |>
    cat()
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
  org <- org_list$new()$read(meta$get_path)
  persons <- meta$get_person
  rightsholder <- persons[vapply(
    persons$role,
    FUN = function(x) {
      "cph" %in% x
    },
    FUN.VALUE = logical(1)
  )]
  funder <- persons[vapply(
    persons$role,
    FUN = function(x) {
      "fnd" %in% x
    },
    FUN.VALUE = logical(1)
  )]
  contact <- any("cre" %in% unlist(persons$role))
  c(rightsholder$email, funder$email) |>
    unlist() |>
    unique() |>
    org$get_zenodo_by_email() -> required_communities
  org$validate_person(persons, lang = meta$get_meta$language) |>
    attr("errors") |>
    c(
      org$validate_rules(rightsholder = rightsholder, funder = funder),
      sprintf(
        "missing required Zenodo community `%s`",
        paste(required_communities, collapse = ", ")
      )[
        length(required_communities) > 0 &&
          !all(required_communities %in% meta$get_meta$community)
      ],
      "no author with `corresponding: true` or role `cre`"[!contact]
    )
}

#' @importFrom assertthat assert_that has_name
#' @importFrom fs path
#' @importFrom jsonlite toJSON
#' @importFrom knitr pandoc
#' @importFrom gert git_find
citation_zenodo <- function(meta) {
  # Validate input
  assert_that(inherits(meta, "citation_meta"))
  assert_that(length(meta$get_errors) == 0)

  # Extract base metadata
  zenodo <- meta$get_meta

  # Read and validate person entries from DESCRIPTION
  person <- org_list$new()$read(meta$get_path)$validate_person(
    meta$get_person,
    lang = "en-GB"
  )

  # Extract package version
  if (has_name(zenodo, "version")) {
    zenodo$version <- as.character(zenodo$version)
  }

  # Extract package contributors
  person[vapply(
    person$role,
    FUN = function(x) {
      any(c("ctb", "cph", "cre", "rev") %in% x)
    },
    FUN.VALUE = logical(1)
  )] |>
    vapply(
      FUN = format_zenodo,
      FUN.VALUE = vector("list", 1)
    ) -> zenodo$contributors

  # Extract package creators (authors)
  person[vapply(
    person$role,
    FUN = function(x) {
      "aut" %in% x
    },
    FUN.VALUE = logical(1)
  )] |>
    vapply(
      FUN = format_zenodo,
      type = FALSE,
      FUN.VALUE = vector("list", 1)
    ) -> zenodo$creators

  # Extract package keywords
  zenodo$keywords <- as.list(zenodo$keywords)

  # Extract Zenodo communities
  if (has_name(zenodo, "community")) {
    zenodo$communities <- vapply(
      zenodo$community,
      FUN.VALUE = vector("list", 1),
      USE.NAMES = FALSE,
      FUN = function(x) {
        list(list(identifier = x))
      }
    )
    zenodo$community <- NULL
  }

  # Extract language (ISO 639-3)
  if (has_name(zenodo, "language")) {
    zenodo$language <- lang_2_iso_639_3(zenodo$language)
  }

  # Extract publisher
  publishers <- Filter(function(x) "pbl" %in% x$role, person)

  if (length(publishers) > 0) {
    stopifnot("Only single publisher possible" = length(publishers) == 1)
    zenodo$publisher <- publishers$given
  }

  # Remove Zenodo DOI (self-reference)
  if (has_name(zenodo, "doi") && grepl("zenodo", zenodo$doi)) {
    zenodo$doi <- NULL
  }

  # Remove unsupported fields
  zenodo$url <- NULL
  zenodo$source <- NULL

  # Extract grant ID from funder (role = "fnd")
  funders <- Filter(function(x) "fnd" %in% x$role, person)

  grant_id <- vapply(
    funders,
    function(x) {
      if (!is.null(x$comment) && "id" %in% names(x$comment)) {
        x$comment[["id"]]
      } else {
        NA_character_
      }
    },
    character(1)
  )
  grant_id <- grant_id[!is.na(grant_id)]

  if (length(grant_id) > 0) {
    stopifnot("Only single grant ID possible" = length(grant_id) == 1)
    zenodo$grants <- list(list(id = grant_id))
  }

  # Extract description (convert Markdown to HTML)
  desc <- tempfile(fileext = ".md")
  writeLines(zenodo$description, desc)
  suppressMessages(pandoc(desc, format = "html"))
  gsub("\\.md", ".html", desc) |>
    readLines() |>
    paste(collapse = " ") |>
    gsub(pattern = " +", replacement = " ") -> zenodo$description

  # Write .zenodo.json file
  citation_file <- path(meta$get_path, ".zenodo.json")
  toJSON(zenodo, pretty = TRUE, auto_unbox = TRUE) |>
    writeLines(citation_file)

  # Check repository status
  errors <- paste(
    citation_file,
    "is modified.",
    "Run `checklist::update_citation()` locally."[!interactive()],
    "Please commit changes."
  )[
    is_repository(meta$get_path) &&
      !is_tracked_not_modified(
        path_rel(citation_file, git_find(meta$get_path)),
        meta$get_path
      )
  ]
  return(errors)
}

format_zenodo <- function(x, type = TRUE) {
  list(
    name = format(
      x,
      include = c("family", "given"),
      braces = list(family = c("", ","))
    ),
    affiliation = unname(x$comment["affiliation"]),
    orcid = unname(x$comment["ORCID"]),
    type = zenodo_role(x$role)
  )[c(
    TRUE,
    "affiliation" %in% names(x$comment),
    "ORCID" %in% names(x$comment),
    type
  )] |>
    list()
}

zenodo_role <- function(z) {
  if ("cre" %in% z) {
    return("contactperson")
  } else if ("cph" %in% z) {
    return("rightsholder")
  } else if ("rev" %in% z) {
    return("other")
  } else {
    return("projectmember")
  }
}

format_cff <- function(x) {
  list(
    `given-names` = unname(x$given),
    `family-names` = unname(x$family),
    affiliation = unname(x$comment["affiliation"]),
    orcid = unname(x$comment["ORCID"])
  )[c(
    !is.na(x$given),
    !is.na(x$family),
    !is.na(x$comment["affiliation"]),
    !is.na(x$comment["ORCID"])
  )] |>
    list()
}

citation_cff <- function(meta) {
  assert_that(inherits(meta, "citation_meta"))
  if (!meta$get_type %in% c("package", "project")) {
    return(character(0))
  }
  assert_that(length(meta$get_errors) == 0)
  person <- meta$get_person
  person[vapply(
    person$role,
    FUN = function(x) {
      "aut" %in% x
    },
    FUN.VALUE = logical(1)
  )] |>
    vapply(
      FUN = format_cff,
      FUN.VALUE = vector(mode = "list", 1)
    ) -> authors
  person[vapply(
    person$role,
    FUN = function(x) {
      "cre" %in% x
    },
    FUN.VALUE = logical(1)
  )] |>
    vapply(
      FUN = format_cff,
      FUN.VALUE = vector(mode = "list", 1)
    ) -> contact
  input <- meta$get_meta
  if (has_name(input, "doi")) {
    identifiers <- list(list(type = "doi", value = input$doi))
  } else {
    identifiers <- list()
  }
  if (has_name(input, "url") && length(input$url) > 0) {
    identifiers <- c(identifiers, list(list(type = "url", value = input$url)))
  }
  cff <- list(
    `cff-version` = "1.2.0",
    message = "If you use this software, please cite it using these metadata.",
    title = input$title,
    authors = authors,
    keywords = as.list(input$keywords),
    contact = contact,
    doi = input$doi,
    license = input$license,
    `repository-code` = input$source,
    type = input$upload_type,
    abstract = strip_markdown(input$description) |>
      paste(collapse = "\n")
  )
  attr(cff$title, "quoted") <- TRUE
  attr(cff$abstract, "quoted") <- TRUE
  if (length(identifiers) > 0) {
    cff$identifiers <- identifiers
  }
  if (has_name(input, "version")) {
    cff$version <- as.character(input$version)
  }
  citation_file <- path(meta$get_path, "CITATION.cff")
  write_yaml(x = cff, file = citation_file, fileEncoding = "UTF-8")
  errors <- paste(
    citation_file,
    "is modified.",
    "Run `checklist::update_citation()` locally."[!interactive()],
    "Please commit changes."
  )[
    !is_tracked_not_modified(
      path_rel(citation_file, meta$get_path),
      meta$get_path
    )
  ]
  return(errors)
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
      "# begin checklist entry",
      "# end checklist entry"
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
    paste(
      "`# end checklist entry` before `# begin checklist entry` in",
      "`inst/CITATION`"
    )[
      head(start, length(end)) >= head(end, length(start))
    ]
  )
  if (length(errors) > 0) {
    return(errors = errors)
  }
  authors <- meta$get_person[vapply(
    meta$get_person,
    FUN.VALUE = logical(1),
    FUN = function(x) {
      "aut" %in% x$role
    }
  )]
  format(
    authors,
    include = c("given", "family"),
    braces = list(
      given = c("person(given = \"", "\","),
      family = c("family = \"", "\")")
    )
  ) |>
    paste(collapse = ", ") -> authors_bibtex
  authors_plain <- format(
    authors,
    include = c("family", "given"),
    braces = list(family = c("", ","))
  )
  cit_meta$description <- gsub("\"", "\\\\\"", cit_meta$description)
  package_citation <- c(
    bibtype = "\"Manual\"",
    title = sprintf(
      "\"%s. Version %s\"",
      cit_meta$title,
      cit_meta$version
    ),
    author = sprintf("c(%s)", authors_bibtex),
    year = format(Sys.Date(), "%Y"),
    url = c(cit_meta$url, cit_meta$source) |>
      head(1) |>
      sprintf(fmt = "\"%s\""),
    abstract = paste0("\"", cit_meta$description, "\""),
    textVersion = sprintf(
      "\"%s (%s) %s. Version %s. %s\"",
      paste(authors_plain, collapse = "; "),
      format(Sys.Date(), "%Y"),
      cit_meta$title,
      cit_meta$version,
      ifelse(
        length(cit_meta$url),
        paste(cit_meta$url, collapse = "; "),
        cit_meta$source
      )
    ),
    keywords = paste0("\"", paste(cit_meta$keywords, collapse = "; "), "\"")
  )
  if (length(cit_meta$doi)) {
    package_citation <- c(
      package_citation,
      doi = paste0("\"", cit_meta$doi, "\"")
    )
  }
  package_citation <- gsub("\n", " ", package_citation)
  package_citation <- gsub("[ ]{2, }", " ", package_citation)
  package_citation <- sprintf(
    "  %s = %s,",
    names(package_citation),
    package_citation
  )
  c(head(cit, start), "bibentry(", package_citation, ")", tail(cit, 1 - end)) |>
    writeLines(citation_file)
  errors <- paste(
    citation_file,
    "is modified.",
    "Run `checklist::update_citation()` locally."[!interactive()],
    "Please commit changes."
  )[
    !is_tracked_not_modified(
      path_rel(citation_file, meta$get_path),
      meta$get_path
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
        path("package_template", "rbuildignore"),
        package = "checklist"
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
