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
        errors = paste(index_file, "not found"), warnings = character(0),
        notes = character(0)
      )
    )
  }
  yaml <- yaml_front_matter(index_file)
  read_organisation(meta$get_path) |>
    yaml_author(yaml = yaml) -> cit_meta
  description <- bookdown_description(meta$get_path)
  cit_meta$meta$description <- description$description
  cit_meta$errors <- c(cit_meta$errors, description$errors)
  cit_meta$meta$title <- paste0(
    yaml$title,
    ifelse(has_name(yaml, "subtitle"), paste0(". ", yaml$subtitle, "."), ".")
  )
  cit_meta$meta$upload_type <- "publication"
  if (has_name(yaml, "embargo")) {
    cit_meta$meta$embargo_date <- string2date(yaml$embargo) |>
      format("%Y-%m-%d")
    cit_meta$meta$access_right <- "embargoed"
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
        cit_meta$errors, "LICENSE.md doesn't match with CC-BY-4.0 license"
      )
    }
  }
  if (has_name(yaml, "lang")) {
    cit_meta$meta$language <- yaml$lang
  }
  extra <- c(
    "community", "doi", "keywords", "publication_type"
  )
  extra <- extra[extra %in% names(yaml)]
  cit_meta$meta <- c(cit_meta$meta, yaml[extra])
  publication_type <- c(
    "annotationcollection", "book", "section", "conferencepaper",
    "datamanagementplan", "article", "patent", "preprint", "deliverable",
    "milestone", "proposal", "report", "softwaredocumentation",
    "taxonomictreatment", "technicalnote", "thesis", "workingpaper", "other"
  )
  c(
    "no `keywords` element found"[!has_name(yaml, "keywords")],
    paste(
      "`publication_type` must be one of following:",
      paste(publication_type, collapse = ", "),
      sep = "\n"
    )[
      has_name(yaml, "publication_type") && is.string(yaml$publication_type) &&
        !yaml$publication_type %in% publication_type
    ]
  ) |>
    c(cit_meta$errors) -> cit_meta$errors
  c(
    "no `community` element found"[!has_name(yaml, "community")],
    "no `publication_type` element found"[!has_name(yaml, "publication_type")]
  ) |>
    c(cit_meta$notes) -> cit_meta$notes
  return(cit_meta)
}

#' @importFrom assertthat has_name
yaml_author <- function(yaml, org) {
  author <- vapply(
    X = yaml$author, FUN = yaml_author_format,
    FUN.VALUE = vector(mode = "list", 1), org = org
  )
  yaml$reviewer |>
    vapply(yaml_author_format, vector(mode = "list", 1), org = org) -> reviewer
  c(author, reviewer) |>
    vapply(attr, vector(mode = "list", 1), which = "errors") |>
    unlist() |>
    unique() -> errors
  c(author, reviewer) |>
    vapply(attr, vector(mode = "list", 1), which = "notes") |>
    unlist() |>
    unique() |>
    c(
      "no `funder` element found"[!has_name(yaml, "funder")],
      "no `rightsholder` element found"[!has_name(yaml, "rightsholder")]
    ) -> notes
  author <- do.call(rbind, author)
  author$id <- seq_along(author$family)
  c(
    "no author with `corresponding: true`"[sum(author$contact) == 0],
    "multiple authors with `corresponding: true`"[sum(author$contact) > 1],
    errors
  ) -> errors
  reviewer <- do.call(rbind, reviewer)
  reviewer$id <- seq_along(reviewer$family) + nrow(author)

  data.frame(
    contributor = c(author$id, author$id[author$contact], reviewer$id),
    role = c(
      rep("author", nrow(author)), rep("contact person", sum(author$contact)),
      rep("reviewer", nrow(reviewer))
    )
  ) -> roles
  author <- rbind(author, reviewer)
  author$contact <- NULL
  if (has_name(yaml, "funder")) {
    data.frame(contributor = nrow(author) + 1, role = "funder") |>
      rbind(roles) -> roles
    data.frame(
      id = nrow(author) + 1, given = yaml$funder, family = "", orcid = "",
      affiliation = "", organisation = known_affiliation(yaml$funder, org = org)
    ) |>
      rbind(author) -> author
  }
  if (has_name(yaml, "rightsholder")) {
    data.frame(contributor = nrow(author) + 1, role = "copyright holder") |>
      rbind(roles) -> roles
    data.frame(
      id = nrow(author) + 1, given = yaml$rightsholder, family = "",
      orcid = "", affiliation = "",
      organisation = known_affiliation(yaml$rightsholder, org = org)
    ) |>
      rbind(author) -> author
  }
  list(
    meta = list(authors = author, roles = roles), errors = errors, notes = notes
  )
}

#' @importFrom assertthat has_name is.flag
yaml_author_format <- function(person, org) {
  person_df <- data.frame(
    given = character(0), family = character(0), orcid = character(0),
    affiliation = character(0), contact = logical(0),
    organisation = character(0)
  )
  if (!is.list(person)) {
    attr(person_df, "errors") <- list("person must be a list")
    attr(person_df, "notes") <- list(character(0))
    return(list(person_df))
  }
  if (!has_name(person, "name") || !is.list(person$name)) {
    c(
      "person has no `name` element"[
        !has_name(person, "name")
      ],
      "person `name` element is not a list"[
        has_name(person, "name") && !is.list(person$name)
      ]
    ) |>
      list() -> attr(person_df, "errors")
    attr(person_df, "notes") <- list(character(0))
    return(list(person_df))
  }
  person_df <- data.frame(
    given = paste0(person$name$given, ""),
    family = paste0(person$name$family, ""), orcid = paste0(person$orcid, ""),
    affiliation = paste0(person$affiliation, ""),
    contact = ifelse(
      is.null(person$corresponding), FALSE, person$corresponding
    ),
    organisation = known_affiliation(paste0(person$affiliation, ""), org = org)
  )
  c(
    "person `name` element is missing a `given` element"[
      !has_name(person$name, "given")
    ],
    "person `name` element is missing a `family` element"[
      !has_name(person$name, "family")
    ],
    "person `corresponding` element must be true, false or missing"[
      has_name(person, "corresponding") && !is.flag(person$corresponding)
    ]
  ) |>
    list() -> attr(person_df, "errors")
  c(
    "person has no `orcid` element"[!has_name(person, "orcid")],
    "person has no `affiliation` element"[!has_name(person, "affiliation")]
  ) |>
    list() -> attr(person_df, "notes")
  return(list(person_df))
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
        description = description$meta$description, errors = description$errors
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
      description = description$meta$description, errors = description$errors
    )
  )
}
