#' @importFrom assertthat assert_that
#' @importFrom desc description
#' @importFrom fs path
citation_description <- function(meta) {
  assert_that(inherits(meta, "citation_meta"))
  assert_that(meta$get_type == "package")
  path(meta$get_path, "DESCRIPTION") |>
    description$new() -> descript
  descript$get_field("Config/checklist/keywords", default = character(0)) |>
    description_keywords() -> keywords
  descript$get_field("Config/checklist/communities", default = character(0)) |>
    description_communities() -> communities
  urls <- description_url(descript$get_urls())
  authors <- description_author(descript$get_authors())
  list(
    title = sprintf(
      "%s: %s", descript$get_field("Package"), descript$get_field("Title")
    ),
    version = descript$get_version(), license = descript$get_field("License"),
    upload_type = "software", description = descript$get_field("Description")
  ) |>
    c(authors$meta, keywords$meta, communities$meta, urls$meta) -> cit_meta
  lang <- descript$get_field("Language", default = "")
  if (lang != "") {
    cit_meta$language <- lang
  }
  remotes <- git_remote_list()
  remotes$url[remotes$name == "origin"] |>
    gsub(pattern = "git@(.*?):(.*)", replacement = "https://\\1/\\2") |>
    gsub(pattern = "\\.git$", replacement = "") -> cit_meta$source
  list(
    meta = cit_meta,
    errors = c(urls$errors, keywords$errors, communities$errors),
    warnings = character(0), notes = c(authors$notes, communities$notes)
  )
}

description_author <- function(authors) {
  vapply(
    seq_along(authors), FUN = description_author_format, x = authors,
    FUN.VALUE = vector("list", 1)
  ) |>
    do.call(what = "rbind") -> roles
  data.frame(
    id = seq_along(authors), given = format(authors, include = "given"),
    family = format(authors, include = "family")
  ) |>
    merge(
      unique(roles[, c("contributor", "orcid", "affiliation")]), by.x = "id",
      by.y = "contributor"
    ) -> contributors
  contributors[
    contributors$given == "Research Institute for Nature and Forest",
  ] |>
    merge(
      roles[, c("contributor", "role")], by.x = "id", by.y = "contributor"
    ) -> inbo_roles
  notes <- c(
    paste(
      "`Research Institute for Nature and Forest` not listed as copyright",
      "holder in `DESCRIPTION`."
    )[!"copyright holder" %in% inbo_roles$role],
    paste(
      "`Research Institute for Nature and Forest` not listed as funder",
      "in `DESCRIPTION`."
    )[!"funder" %in% inbo_roles$role]
  )
  list(
    meta = list(
      authors = contributors, roles = roles[, c("contributor", "role")]
    ),
    notes = notes
  )
}

description_author_format <- function(i, x) {
  formatted <- data.frame(
    contributor = i,
    role = c(
      aut = "author", cre = "contact person", ctb = "contributor",
      cph = "copyright holder", fnd = "funder"
    )[x[[i]]$role]
  )
  if (is.null(x[[i]]$comment)) {
    formatted$orcid <- ""
    formatted$affiliation <- ""
    return(list(formatted))
  }
  formatted$orcid <- ifelse(
    is.na(x[[i]]$comment["ORCID"]), "", x[[i]]$comment["ORCID"]
  )
  formatted$affiliation <- ifelse(
    is.na(x[[i]]$comment["affiliation"]), "", x[[i]]$comment["affiliation"]
  )
  return(list(formatted))
}

description_url <- function(urls) {
  urls <- urls[!grepl("https://github.com/", urls)]
  doi_regexp <- "https://doi.org/(.*)"
  doi_line <- grep(doi_regexp, urls)
  if (length(doi_line) == 1) {
    return(
      list(
        meta = list(
          doi = gsub(doi_regexp, "\\1", urls[doi_line]), url = urls[-doi_line]
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
    meta = list(keywords = strsplit(keywords, "; ")[[1]]), errors = character(0)
  )
}

description_communities <- function(communities) {
  if (length(communities) == 0) {
    return(
      list(
        meta = list(), notes = character(0),
        errors = paste(
          "no communities found in `DESCRIPTION`.",
          "Please add them with `Config/checklist/communities: inbo; second`"
        )
      )
    )
  }
  communities <- strsplit(communities, "; ")[[1]]
  notes <-
    "inbo not listed as community in `DESCRIPTION`"[!"inbo" %in% communities]
  list(
    meta = list(community = communities), errors = character(0), notes = notes
  )
}
