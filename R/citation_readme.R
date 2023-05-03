#' @importFrom assertthat assert_that
#' @importFrom fs path
citation_readme <- function(meta) {
  assert_that(inherits(meta, "citation_meta"))
  assert_that(meta$get_type == "project")
  readme_file <- path(meta$get_path, "README.md")
  if (!is_file(readme_file)) {
    return(
      list(
        errors = paste(readme_file, "not found"), warnings = character(0),
        notes = character(0)
      )
    )
  }
  readme_file |>
    readLines() |>
    readme_badges() |>
    readme_title() |>
    readme_author() |>
    readme_version() |>
    readme_community() |>
    readme_description() |>
    readme_keywords() -> cit_meta
  if (is_repository(meta$get_path)) {
    remotes <- git_remote_list(meta$get_path)
    remotes$url[remotes$name == "origin"] |>
      gsub(pattern = "git@(.*?):(.*)", replacement = "https://\\1/\\2") |>
      gsub(pattern = "https://.*?@", replacement = "https://") |>
      gsub(pattern = "\\.git$", replacement = "/") -> cit_meta$meta$source
  }
  cit_meta$meta$upload_type <- "software"
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
  return(cit_meta)
}

#' @importFrom utils head
readme_badges <- function(text) {
  badges_start <- grep("<!-- badges: start -->", text)
  badges_end <- grep("<!-- badges: end -->", text)
  errors <- c(
    "Multiple `<!-- badges: start -->`README.md"[length(badges_start) > 1],
    "Multiple `<!-- badges: end -->`README.md"[length(badges_end) > 1],
    paste(
      "Mismatch between `<!-- badges: start -->` and",
      "`<!-- badges: end -->` README.md"
    )[
      length(badges_start) != length(badges_end)
    ],
    "`<!-- badges: end -->` before `<!-- badges: start -->` README.md"[
      any(
        head(badges_end, length(badges_start)) <=
          head(badges_start, length(badges_end))
      )
    ]
  )
  if (length(errors) > 0 || length(badges_start) == 0) {
    return(
      list(
        errors = errors, notes = character(0), text = text,
        warnings = character(0))
    )
  }
  badges <- text[seq(badges_start + 1, badges_end - 1)]
  badge_regexp <- "^\\[?!\\[.*?\\]\\(.*?\\)(\\]\\(.*?\\))?"
  errors <- c(
    errors,
    "badges section in README.md should only contain images"[
      !all(grepl(badge_regexp, badges, perl = TRUE))
    ],
    "every line in the badges section README.md should hold only on image"[
      !all(grepl("^\\s*$", gsub(badge_regexp, "", badges, perl = TRUE)))
    ]
  )

  paste0(
    "\\[!\\[DOI\\]\\(https://zenodo.org/badge/DOI/(.*?)\\.svg\\)\\]",
    "\\(https://doi\\.org/(.*)\\)"
  ) -> doi_regexp
  doi_line <- grep(doi_regexp, badges)
  errors <- c(
    errors,
    "multiple DOI badges found in README.md"[length(doi_line) > 1]
  )
  notes <- "no DOI badge found in README.md"[length(doi_line) == 0]
  if (length(doi_line) != 1) {
    meta <- list()
  } else {
    doi <- gsub(doi_regexp, "\\1", badges[doi_line])
    errors <- c(
      errors,
      "DOI badge in README refers to different DOI"[
        doi != gsub(doi_regexp, "\\2", badges[doi_line])
      ]
    )
    meta <- list(doi = doi)
  }

  paste0(
    "\\[!\\[website\\]\\(https://img.shields.io/badge/website-(.*?)-c04384\\)",
    "\\]\\((.*)\\)"
  ) -> website_regexp
  website_line <- grep(website_regexp, badges)
  errors <- c(
    errors,
    "multiple website badges found in README.md"[length(website_line) > 1]
  )
  notes <- c(
    notes, "no website badge found in README.md"[length(website_line) == 0]
  )
  if (length(website_line) == 1) {
    meta$url <- gsub(website_regexp, "\\2", badges[website_line])
  }
  meta$access_right <- "open"
  list(
    errors = errors, notes = notes, meta = meta,
    text = text[-badges_start:-badges_end], warnings = character(0)
  )
}

remove_empty_line <- function(text, top = TRUE) {
  empty_line <- grep("^\\s*$", text)
  if (top) {
    empty_line <- empty_line[empty_line == seq_along(empty_line)]
  }
  if (length(empty_line)) {
    return(text[-empty_line])
  }
  return(text)
}

#' @importFrom utils head tail
readme_title <- function(text) {
  text$text <- remove_empty_line(text$text, top = TRUE)
  title <- head(text$text, 1)
  text$errors <- c(
    text$errors,
    paste(
    "Title line must be just below the (optional) badges section in README.md",
      "The title in README.md must start with `# `"
    )[!grepl("^ *# +", title)]
  )
  gsub(pattern = "^ *?# +", replacement = "", title) |>
    strip_markdown() -> text$meta$title
  text$text <- tail(text$text, -1)
  return(text)
}

strip_markdown <- function(text) {
  gsub("\\*\\*(.*?)\\*\\*", "\\1", text) |>
    gsub(pattern = "__(.*?)__", replacement = "\\1") |>
    gsub(pattern = "\\*(.*?)\\*", replacement = "\\1") |>
    gsub(pattern = "_(.*?)_", replacement = "\\1") |>
    gsub(pattern = "<.*?>", replacement = "") |>
    gsub(pattern = " +", replacement = " ") |>
    gsub(pattern = " $", replacement = "")
}

#' @importFrom stats setNames
readme_author <- function(text) {
  text$text <- remove_empty_line(text$text, top = TRUE)
  if (length(text$text) == 0) {
    text$errors <- c(text$errors, "No author information in README.md")
    return(text)
  }
  grep("^\\s*$", text$text) |>
    head(1) -> empty_line
  text$text[seq_len(empty_line - 1)] |>
    gsub(pattern = ";\\s*$", replacement = "") -> authors
  authors_aff <- authors
  authors_aff[!grepl("\\[\\^.*\\]", authors_aff)] <- ""
  gsub(".*?\\[\\^(.*?)\\]", "\\1;", authors_aff) |>
    gsub(pattern = "(aut|cph|cre|ctb|fnd|rev);", replacement = "") |>
    gsub(pattern = ";$", replacement = "") |>
    strsplit(split = ";") -> authors_aff
  data.frame(
    contributor = grep("\\[\\^aut\\]", authors),
    role = rep("author", , sum(grepl("\\[\\^aut\\]", authors)))
  ) |>
    rbind(
      data.frame(
        contributor = grep("\\[\\^cph\\]", authors),
        role = rep("copyright holder", sum(grepl("\\[\\^cph\\]", authors)))
      ),
      data.frame(
        contributor = grep("\\[\\^cre\\]", authors),
        role = rep("contact person", sum(grepl("\\[\\^cre\\]", authors)))
      ),
      data.frame(
        contributor = grep("\\[\\^ctb\\]", authors),
        role = rep("contributor", sum(grepl("\\[\\^ctb\\]", authors)))
      ),
      data.frame(
        contributor = grep("\\[\\^fnd\\]", authors),
        role = rep("funder", sum(grepl("\\[\\^fnd\\]", authors)))
      ),
      data.frame(
        contributor = grep("\\[\\^rev\\]", authors),
        role = rep("reviewer", sum(grepl("\\[\\^rev\\]", authors)))
      )
    ) -> text$meta$roles
  authors <- gsub("\\[\\^.*\\]", "", authors)
  c(
    "^\\[(.*?)!\\[ORCID logo\\]",
  "\\(https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png\\)\\]",
    "\\(https://orcid.org/(.+)\\)$"
  ) |>
    paste(collapse = "") -> orcid_grep
  ifelse(grepl(orcid_grep, authors), authors, "") |>
    gsub(pattern = orcid_grep, replacement = "\\2") -> authors_orcid
  authors <- gsub(orcid_grep, "\\1", authors)

  if (empty_line > 0) {
    tail(text$text, -empty_line) |>
      remove_empty_line(top = TRUE) -> text$text
  }
  affiliations <- text$text[grepl("\\[\\^.*?\\]:", text$text)]
  aff_code <- gsub(".*\\[\\^(.*?)\\]:.*", "\\1", affiliations)
  aff_code_check <- vapply(
    authors_aff, FUN.VALUE = logical(1), aff_code = aff_code,
    FUN = function(z, aff_code) {
      all(z %in% aff_code)
    }
  )
  gsub("\\[\\^(.*?)\\]:\\s*(.*)", "\\2", affiliations) |>
    setNames(aff_code) -> affiliations
  authors_aff <- vapply(
    authors_aff, FUN.VALUE = character(1), z = affiliations,
    FUN = function(y, z) {
      paste(z[y], collapse = "; ")
    }
  )
  text$errors <- c(
    text$errors,
    "No authors found or no empty line after author in README.md"[
      length(authors) == 0
    ],
    "Nobody marked as author in README.md. Add `[^aut]` behind the name"[
      sum(text$meta$roles$role == "author") == 0
    ],
    "No contact person found in README.md. Add `[^cre]` behind the name"[
      sum(text$meta$roles$role == "contact person") == 0
    ],
    "Multiple contact persons found in README.md."[
      sum(text$meta$roles$role == "contact person") > 1
    ],
    "No copyright holder found in README.md. Add `[^cph]` behind the name"[
      sum(text$meta$roles$role == "copyright holder") == 0
    ],
    "No `[^aut]:` found in README.md."[!has_name(affiliations, "aut")],
    "No `[^cph]:` found in README.md."[!has_name(affiliations, "cph")],
    "No `[^cre]:` found in README.md."[!has_name(affiliations, "cre")],
    "Duplicate affiliations found in README.md."[anyDuplicated(aff_code) > 0],
    "Affiliation of some authors not defined with `[^*]:` in README.md"[
      !all(aff_code_check)
    ],
    "Persons or insitutions without defined role in README.md."[
      !all(seq_along(authors) %in% unique(text$meta$roles$contributor))
    ]
  )

  text$text <- text$text[!grepl("\\[\\^.*?\\]:", text$text)]
  text$meta$authors <- data.frame(
    id = seq_along(authors), given = gsub(".*,\\s*(.*)", "\\1", authors),
    family = ifelse(grepl(",", authors), gsub("(.*),.*", "\\1", authors), ""),
    affiliation = authors_aff, orcid = authors_orcid
  )
  return(text)
}

readme_version <- function(text) {
  version_regexp <- "<!-- version: (.*?) -->"
  version_line <- grep(version_regexp, text$text)
  text$notes <- c(
    text$notes,
    "No version information found in README.md"[length(version_line) == 0]
  )
  text$errors <- c(
    text$errors,
    "Multiple version information found in README.md"[length(version_line) > 1]
  )
  if (length(version_line) == 1) {
    gsub(version_regexp, "\\1", text$text[version_line]) |>
      package_version() -> text$meta$version
    text$text <- text$text[-version_line]
  }
  return(text)
}

readme_community <- function(text) {
  community_regexp <- "<!-- community: (.*?) -->"
  community_line <- grep(community_regexp, text$text)
  text$warnings <- c(
    text$warnings,
    "No community information found in README.md"[length(community_line) == 0]
  )
  if (length(community_line) > 0) {
    text$meta$community <- gsub(
      community_regexp, "\\1", text$text[community_line]
    )
    text$notes <- c(
      text$notes,
      "`inbo` not listed as a community"[
        !"inbo" %in% text$meta$community
      ]
    )
    text$text <- text$text[-community_line]
  }
  return(text)
}


#' @importFrom utils head
readme_description <- function(text) {
  description_start <- grep("<!-- description: start -->", text$text)
  description_end <- grep("<!-- description: end -->", text$text)
  errors <- c(
    "Multiple `<!-- description: start -->`"[length(description_start) > 1],
    "Multiple `<!-- description: end -->`"[length(description_end) > 1],
    paste(
      "Mismatch between `<!-- description: start -->` and",
      "`<!-- description: end -->`"
    )[length(description_start) != length(description_end)],
    "`<!-- description: end -->` before `<!-- description: start -->`"[
      any(
        head(description_end, length(description_start)) <=
          head(description_start, length(description_end))
      )
    ]
  )
  if (length(errors) > 0 || length(description_start) == 0) {
    text$errors <- c(text$errors, errors)
    return(text)
  }
  text$meta$description <- text$text[
    seq(description_start + 1, description_end - 1)
  ]
  text$text <- text$text[-description_start:-description_end]
  return(text)
}

readme_keywords <- function(text) {
  keyword_regexp <- "\\*\\*keywords\\*\\*: *(.*)"
  keyword_line <- grep(keyword_regexp, text$text)
  text$errors <- c(
    text$errors,
    paste(
      "No keywords found in README.md.",
      "Add them on a line starting with `**keywords**:`",
      "Separate keywords with `; `"
    )[length(keyword_line) == 0],
    "Multiple lines with keywords found in README.md"[length(keyword_line) > 1]
  )
  if (length(keyword_line) != 1) {
    return(text)
  }
  text$warnings <- c(
    text$warnings,
    paste(
      "keywords found in README.md separated by ','.",
      "Please use `; ` instead."
    )[grepl(",", text$text[keyword_line])],
    paste(
      "keywords found in README.md only separated by ';'.",
      "Please use `; ` instead."
    )[grepl(";\\w", text$text[keyword_line])]
  )
  gsub(keyword_regexp, "\\1", text$text[keyword_line]) |>
    gsub(pattern = " +", replacement = " ") |>
    strsplit("; ") |>
    unlist() -> text$meta$keywords
  text$text <- text$text[-keyword_line]
  return(text)
}
