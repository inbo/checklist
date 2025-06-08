#' @importFrom assertthat assert_that is.string
#' @importFrom fs path
#' @importFrom rmarkdown yaml_front_matter
citation_bookdown <- function(meta) {
  assert_that(inherits(meta, "citation_meta"))
  assert_that(meta$get_type == "bookdown")
  index_file <- path(meta$get_path, "index.Rmd")
  if (!is_file(index_file)) {
    return(
      list(
        errors = paste(index_file, "not found"),
        warnings = character(0),
        notes = character(0)
      )
    )
  }
  yaml <- yaml_front_matter(index_file)
  cit_meta <- yaml_author(yaml = yaml)
  description <- bookdown_description(meta$get_path)
  cit_meta$meta$description <- description$description
  cit_meta$errors <- c(cit_meta$errors, description$errors)
  cit_meta$meta$title <- paste0(
    yaml$title,
    ifelse(has_name(yaml, "subtitle"), paste0(". ", yaml$subtitle, "."), ".")
  )
  if (has_name(yaml, "shorttitle")) {
    cit_meta$meta$shorttitle <- yaml$shorttitle
  }
  cit_meta$meta$upload_type <- "publication"
  if (has_name(yaml, "publication_date")) {
    cit_meta$meta$publication_date <- string2date(yaml$publication_date) |>
      format("%Y-%m-%d")
  }
  if (has_name(yaml, "embargo")) {
    cit_meta$meta$embargo_date <- string2date(yaml$embargo) |>
      format("%Y-%m-%d")
    cit_meta$meta$access_right <- "embargoed"
    if (!has_name(yaml, "publication_date")) {
      cit_meta$meta$publication_date <- cit_meta$meta$embargo_date
    }
  } else {
    cit_meta$meta$access_right <- "open"
  }
  license_file <- path(meta$get_path, "LICENSE.md")
  if (!is_file(license_file)) {
    cit_meta$errors <- c(cit_meta$errors, "No LICENSE.md file found")
  } else {
    license <- readLines(license_file)
    path("generic_template", "cc_by_4_0.md") |>
      system.file(package = "checklist") |>
      readLines() |>
      identical(license) -> license_ok
    if (license_ok) {
      cit_meta$meta$license <- "CC-BY-4.0"
    } else {
      cit_meta$errors <- c(
        cit_meta$errors,
        "LICENSE.md doesn't match with CC-BY-4.0 license"
      )
    }
  }
  if (has_name(yaml, "lang")) {
    cit_meta$meta$language <- yaml$lang
  }
  extra <- c(
    "community",
    "doi",
    "keywords",
    "publication_type",
    "publisher"
  )
  extra <- extra[extra %in% names(yaml)]
  cit_meta$meta <- c(cit_meta$meta, yaml[extra])
  publication_type <- c(
    "publication",
    "publication-annotationcollection",
    "publication-article",
    "publication-book",
    "publication-conferencepaper",
    "publication-conferenceproceeding",
    "publication-datamanagementplan",
    "publication-datapaper",
    "publication-deliverable",
    "publication-dissertation",
    "publication-journal",
    "publication-milestone",
    "publication-other",
    "publication-patent",
    "publication-peerreview",
    "publication-preprint",
    "publication-proposal",
    "publication-report",
    "publication-section",
    "publication-softwaredocumentation",
    "publication-standard",
    "publication-taxonomictreatment",
    "publication-technicalnote",
    "publication-thesis",
    "publication-workingpaper"
  )
  c(
    "No `keywords` element found"[!has_name(yaml, "keywords")],
    "No `publisher` element found"[!has_name(yaml, "publisher")],
    paste(
      "`publication_type` must be one of following:",
      paste(publication_type, collapse = ", "),
      sep = "\n"
    )[
      has_name(yaml, "publication_type") &&
        is.string(yaml$publication_type) &&
        !yaml$publication_type %in% publication_type
    ]
  ) |>
    c(cit_meta$errors) -> cit_meta$errors
  c(
    "No `community` element found"[!has_name(yaml, "community")],
    "No `publication_type` element found"[!has_name(yaml, "publication_type")]
  ) |>
    c(cit_meta$notes) -> cit_meta$notes
  cit_meta$meta$community <- split_community(cit_meta$meta$community)
  return(cit_meta)
}

#' @importFrom assertthat assert_that
split_community <- function(community) {
  if (is.null(community)) {
    return(NULL)
  }
  assert_that(is.character(community))
  strsplit(community, split = "\\s*;\\s*") |>
    unlist() |>
    unique()
}

#' @importFrom assertthat has_name
yaml_author <- function(yaml) {
  author <- vapply(
    X = yaml$author,
    role = "aut",
    FUN = yaml_author_format,
    FUN.VALUE = vector(mode = "list", 1)
  )
  reviewer <- vapply(
    X = yaml$reviewer,
    FUN = yaml_author_format,
    role = "rev",
    FUN.VALUE = vector(mode = "list", 1)
  )
  funder <- vapply(
    X = yaml$funder,
    FUN = yaml_author_format,
    role = "fnd",
    FUN.VALUE = vector(mode = "list", 1)
  )
  rightsholder <- vapply(
    X = yaml$rightsholder,
    FUN = yaml_author_format,
    role = "cph",
    FUN.VALUE = vector(mode = "list", 1)
  )
  list(
    person = c(
      author$person,
      reviewer$person,
      funder$person,
      rightsholder$person
    ) |>
      do.call(what = "c"),
    errors = c(
      author$error,
      reviewer$error,
      funder$error,
      rightsholder$error
    ) |>
      do.call(what = "c")
  )
}

#' @importFrom assertthat has_name is.flag
yaml_author_format <- function(person, role) {
  if (!inherits(person, "list")) {
    return(list(
      person = NULL,
      error = sprintf(
        "`%s` is not in the required person format. Please update the YAML",
        person
      )
    ))
  }
  comment <- person[c("orcid", "affiliation", "ror")]
  names(comment)[names(comment) == "orcid"] <- "ORCID"
  names(comment)[names(comment) == "ror"] <- "ROR"
  comment <- comment[comment != ""]
  person <- person(
    given = paste0(person$name[["given"]], ""),
    family = paste0(person$name[["family"]], ""),
    email = paste0(person$email, ""),
    comment = unlist(comment),
    role = c(role, "cre"[isTRUE(person$corresponding)])
  )
  list(person = person, error = NULL)
}

#' @family utils
#' @importFrom assertthat is.string noNA
string2date <- function(date) {
  if (!is.string(date)) {
    date <- Sys.Date()
    attr(date, "error") <- "`date` not a single date in `YYYY-MM-DD` format"
    return(date)
  }
  date <- as.Date(date, format = "%Y-%m-%d")
  attr(date, "error") <- "date not in `YYYY-MM-DD` format"[!noNA(date)]
  return(date)
}

bookdown_description <- function(path) {
  path(path, "index.Rmd") |>
    readLines() |>
    list() |>
    setNames("text") |>
    readme_description() -> description
  if (has_name(description, "meta") || length(description$errors) > 0) {
    return(
      list(
        description = description$meta$description,
        errors = description$errors
      )
    )
  }
  for (i in dir_ls(path, regexp = "\\.R?md$")) {
    readLines(i) |>
      list() |>
      setNames("text") |>
      readme_description() -> description
    if (has_name(description, "meta") || length(description$errors) > 0) {
      break
    }
  }
  if (!has_name(description, "meta")) {
    description$errors <- c(
      description$errors,
      paste(
        "No description found.",
        "Use `<!-- description: start -->` and `<!-- description: end -->`.",
        "Place these tags around the abstract."
      )
    )
  }
  return(
    list(
      description = description$meta$description,
      errors = description$errors
    )
  )
}
