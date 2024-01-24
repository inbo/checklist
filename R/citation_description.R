#' @importFrom assertthat assert_that
#' @importFrom desc description
#' @importFrom fs path
citation_description <- function(meta) {
  assert_that(inherits(meta, "citation_meta"))
  assert_that(meta$get_type == "package")
  path(meta$get_path, "DESCRIPTION") |>
    description$new() -> descript
  org <- read_organisation(meta$get_path)
  descript$get_field("Config/checklist/keywords", default = character(0)) |>
    description_keywords() -> keywords
  descript$get_field("Config/checklist/communities", default = character(0)) |>
    description_communities(org = org) -> communities
  urls <- description_url(descript$get_urls())
  authors <- description_author(
    descript$get_authors(), org = org$get_organisation
  )
  descript$get_field("License") |>
    gsub(pattern = " \\+ file LICENSE", replacement = "") |>
    gsub(pattern = "^GPL-3$", replacement = "GPL-3.0") -> license
  descript$get_field("Description") |>
    gsub(pattern = "<((\\w|:|\\.|-|\\/)*?)>", replacement = "\\1") -> abstract
  list(
    title = sprintf(
      "%s: %s", descript$get_field("Package"), descript$get_field("Title")
    ),
    version = descript$get_version(), license = license,
    upload_type = "software", description = abstract
  ) |>
    c(
      authors, keywords$meta, communities$meta, urls$meta,
      access_right = "open"
    ) -> cit_meta
  lang <- descript$get_field("Language", default = "")
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
    errors = c(urls$errors, keywords$errors), warnings = communities$warnings,
    notes = character(0)
  )
}

description_author <- function(authors, org) {
  vapply(
    seq_along(authors), FUN = description_author_format, x = authors,
    org = org, FUN.VALUE = vector("list", 1)
  ) |>
    do.call(what = "rbind") -> roles
  data.frame(
    id = seq_along(authors), given = format(authors, include = "given"),
    family = format(authors, include = "family")
  ) |>
    merge(
      unique(roles[, c("contributor", "orcid", "affiliation", "organisation")]),
      by.x = "id", by.y = "contributor"
    ) -> contributors
  list(authors = contributors, roles = roles[, c("contributor", "role")])
}

description_author_format <- function(i, x, org) {
  formatted <- data.frame(
    contributor = i,
    role = c(
      aut = "author", cre = "contact person", ctb = "contributor",
      cph = "copyright holder", fnd = "funder", rev = "reviewer"
    )[x[[i]]$role]
  )
  formatted$organisation <- ifelse(
    is.null(x[[i]]$email), "", gsub(".*@", "", x[[i]]$email)
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
  if (formatted$organisation[1] == "" && formatted$affiliation[1] != "") {
    formatted$organisation <- known_affiliation(
      formatted$affiliation[1], org = org
    )
  }
  return(list(formatted))
}

#' @importFrom assertthat assert_that
known_affiliation <- function(target, org) {
  assert_that(inherits(org, "organisation"))
  target <- gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", target)
  vapply(
    names(org), FUN.VALUE = logical(1), target = target,
    org = org$get_organisation,
    FUN = function(x, org, target) {
      grepl(target, org[[x]]$affiliation) |>
        any()
    }
  ) -> org
  assert_that(
    sum(org) < 2,
    msg = paste(
      "multiple matching organisations:",
      paste(names(org)[org], collapse = "; ")
    )
  )
  c(names(org)[org], "") |>
    head(1)
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

#' @importFrom assertthat assert_that
description_communities <- function(communities, org) {
  assert_that(inherits(org, "organisation"))
  if (length(communities) == 0 && any(!is.na(org$get_community))) {
    return(
      list(
        meta = list(),
        warnings = paste(
          "no communities found in `DESCRIPTION`.",
          "Please add them with `Config/checklist/communities:",
          paste(org$get_community, collapse = "; ")
        )
      )
    )
  }
  list(
    meta = list(community = communities), warnings = character(0)
  )
}
