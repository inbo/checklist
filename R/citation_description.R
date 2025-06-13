#' @importFrom assertthat assert_that
#' @importFrom desc description
#' @importFrom fs path
citation_description <- function(meta) {
  assert_that(inherits(meta, "citation_meta"))
  assert_that(meta$get_type == "package")
  path(meta$get_path, "DESCRIPTION") |>
    description$new() -> descript
  org <- org_list$new()$read(meta$get_path)
  descript$get_field("Config/checklist/keywords", default = character(0)) |>
    description_keywords() -> keywords
  description_communities(descript = descript, org = org) -> communities
  urls <- description_url(descript$get_urls())
  lang <- descript$get_field("Language", default = "")
  descript$get_authors() |>
    org$validate_person(lang = lang) -> authors
  descript$get_field("License") |>
    gsub(pattern = " \\+ file LICENSE", replacement = "") |>
    gsub(pattern = "^GPL-3$", replacement = "GPL-3.0") -> license
  descript$get_field("Description") |>
    gsub(pattern = "<((\\w|:|\\.|-|\\/)*?)>", replacement = "\\1") -> abstract
  list(
    title = sprintf(
      "%s: %s",
      descript$get_field("Package"),
      descript$get_field("Title")
    ),
    version = descript$get_version(),
    license = license,
    upload_type = "software",
    description = abstract
  ) |>
    c(
      keywords$meta,
      communities$meta,
      urls$meta,
      access_right = "open"
    ) -> cit_meta
  if (lang != "") {
    cit_meta$language <- lang
  }
  if (is_repository(meta$get_path)) {
    remotes <- git_remote_list(meta$get_path)
    remotes$url[remotes$name == "origin"] |>
      gsub(pattern = "git@(.*?):(.*)", replacement = "https://\\1/\\2") |>
      gsub(pattern = "https://.*?@", replacement = "https://") |>
      gsub(pattern = "\\.git$", replacement = "") |>
      paste0("/") -> cit_meta$source
  }
  list(
    meta = cit_meta,
    person = authors,
    errors = c(attr(authors, "errors"), urls$errors, keywords$errors),
    warnings = communities$warnings,
    notes = character(0)
  )
}

description_url <- function(urls) {
  urls <- urls[!grepl("https://github.com/", urls)]
  doi_regexp <- "https://doi.org/(.*)"
  doi_line <- grep(doi_regexp, urls)
  if (length(doi_line) == 1) {
    return(
      list(
        meta = list(
          doi = gsub(doi_regexp, "\\1", urls[doi_line]),
          url = urls[-doi_line]
        ),
        errors = character(0)
      )
    )
  }
  list(
    meta = list(url = urls),
    errors = "Multiple DOI found in DESCRIPTION"[length(doi_line) > 1]
  )
}

description_keywords <- function(keywords) {
  if (length(keywords) == 0) {
    return(
      list(
        meta = list(),
        errors = paste(
          "no keywords found in `DESCRIPTION`.",
          "Please add them with `Config/checklist/keywords: keyword; second`"
        )
      )
    )
  }
  list(
    meta = list(keywords = strsplit(keywords, "; ")[[1]]),
    errors = character(0)
  )
}

#' @importFrom assertthat assert_that
description_communities <- function(descript, org) {
  assert_that(inherits(descript, "description"), inherits(org, "org_list"))
  communities <- descript$get_field(
    "Config/checklist/communities",
    default = character(0)
  )
  descript$get_author("cph")$email |>
    c(descript$get_author("fnd")$email) |>
    unlist() |>
    org$get_zenodo_by_email() -> required_communities
  if (length(communities) == 0 && length(required_communities) > 0) {
    return(
      list(
        meta = list(),
        warnings = paste(
          "missing communities found in `DESCRIPTION`.",
          "Please make sure to add `Config/checklist/communities:",
          paste(required_communities, collapse = "; ")
        )
      )
    )
  }
  list(
    meta = list(community = split_community(communities)),
    warnings = paste(
      "missing communities found in `DESCRIPTION`.",
      "Please make sure to add `Config/checklist/communities:",
      paste(required_communities, collapse = "; ")
    )[
      !all(required_communities %in% communities)
    ]
  )
}
