#' Write a `.zenodo.json` file
#'
#' Zenodo uses the `.zenodo.json` file to define the citation information.
#' See the [Zenodo developers website](
#'https://developers.zenodo.org/#add-metadata-to-your-github-repository-release)
#' for more information.
#'
#' @return An invisible `checklist` object.
#' @inheritParams read_checklist
#' @export
#' @importFrom assertthat assert_that
#' @importFrom desc description
#' @importFrom jsonlite toJSON
#' @importFrom gert git_status
#' @family package
write_zenodo_json <- function(x = ".") {
  x <- read_checklist(x = x)
  assert_that(
    x$package,
    msg = "`write_zenodo_json()` currently only handles packages.
  `checklist.yml` indicates this is not a package."
  )
  this_desc <- description$new(
    file = file.path(x$get_path, "DESCRIPTION")
  )

  authors <- eval(parse(text = this_desc$get_field("Authors@R")))
  authors_plain <- format(
    authors, include = c("family", "given"),
    braces = list(family = c("", ","))
  )
  authors_orcid <- format(
    authors, include = "comment", braces = list(comment = c("", ""))
  )
  authors_orcid[!grepl("orcid.org", authors_orcid)] <- ""
  authors_orcid <- gsub(
    ".*orcid.org/(([0-9]{4}-){3}[0-9]{3}[0-9X]).*", "https://orcid.org/\\1", # nolint: nonportable_path_linter, line_length_linter.
    authors_orcid
  )

  relevant <- vapply(
    authors, FUN.VALUE = logical(1),
    FUN = function(z) {
      any(z$role %in% c("aut", "cre"))
    }
  )
  creators <- vapply(
    which(relevant), FUN.VALUE = vector("list", 1),
    FUN = function(i) {
      if (authors_orcid[[i]] == "") {
        list(list(name = authors_plain[[i]]))
      } else {
        list(list(name = authors_plain[[i]], orcid = authors_orcid[[i]]))
      }
    }
  )
  # add contributors
  relevant <- vapply(
    authors, FUN.VALUE = logical(1),
    FUN = function(z) {
      any(z$role %in% "ctb")
    }
  )
  contributors <- vapply(
    which(relevant), FUN.VALUE = vector("list", 1),
    FUN = function(i) {
      z <- list(list(name = authors_plain[[i]], type = "ProjectMember"))
      if (authors_orcid[[i]] != "") {
        z[[1]][["orcid"]] <-  authors_orcid[[i]]
      }
      return(z)
    }
  )
  # add copyright holder
  relevant <- vapply(
    authors, FUN.VALUE = logical(1),
    FUN = function(z) {
      any(z$role %in% "cph")
    }
  )
  contributors <- c(contributors, vapply(
    which(relevant), FUN.VALUE = vector("list", 1),
    FUN = function(i) {
      z <- list(list(name = authors_plain[[i]], type = "RightsHolder"))
      if (authors_orcid[[i]] != "") {
        z[[1]][["orcid"]] <-  authors_orcid[[i]]
      }
      return(z)
    }
  ))
  # add contact person
  relevant <- vapply(
    authors, FUN.VALUE = logical(1),
    FUN = function(z) {
      any(z$role %in% "cre")
    }
  )
  contributors <- c(contributors, vapply(
    which(relevant), FUN.VALUE = vector("list", 1),
    FUN = function(i) {
      z <- list(list(name = authors_plain[[i]], type = "ContactPerson"))
      if (authors_orcid[[i]] != "") {
        z[[1]][["orcid"]] <-  authors_orcid[[i]]
      }
      return(z)
    }
  ))

  cit_desc <- gsub(" +", " ", gsub("\n", " ", this_desc$get("Description")))
  license <- this_desc$get("License")
  license <- ifelse(license == "GPL-3", "GPL-3.0", license)
  zenodo <- list(
    title = sprintf("%s: %s", this_desc$get("Package"), this_desc$get("Title")),
    version = as.character(this_desc$get_version()), description = cit_desc,
    creators = creators, upload_type = "software",
    access_right = "open", license = license,
    communities = list(list(identifier = "inbo"))
  )
  if (length(contributors) > 0) {
    zenodo$contributors <- contributors
  }
  lang <- lang_2_iso_639_3(this_desc$get("Language"))
  if (!is.na(lang)) {
    zenodo$language <- lang
  }
  if (length(x$get_keywords) > 0) {
    zenodo$keywords <- as.list(x$get_keywords)
  }

  if (!file_test("-f", file.path(x$get_path, ".Rbuildignore"))) {
    file.copy(
      system.file(
        file.path("package_template", "rbuildignore"), package = "checklist"
      ),
      file.path(x$get_path, ".Rbuildignore")
    )
  } else {
    current <- readLines(file.path(x$get_path, ".Rbuildignore"))
    new <- "^\\.zenodo\\.json$" # nolint: nonportable_path_linter.
    writeLines(
      sort(unique(c(new, current))), file.path(x$get_path, ".Rbuildignore")
    )
  }

  writeLines(
    toJSON(zenodo, pretty = TRUE, auto_unbox = TRUE),
    file.path(x$get_path, ".zenodo.json")
  )

  # check if file is tracked and not modified
  repo <- x$get_path
  x$add_error(
    c(
      paste(
        ".zenodo.json file needs an update.",
        "Run `update_citation()` or `check_package()` locally.",
        "Then\ncommit `.zenodo.json`."
      )[
        !is_tracked_not_modified(file = ".zenodo.json", repo = repo)
      ],
      attr(lang, "problem")
    ),
    ".zenodo.json"
  )

  return(x)
}

lang_2_iso_639_3 <- function(lang) {
  if (lang %in% iso_639_3$alpha_3) {
    return(lang)
  }
  short <- gsub("-.*", "", lang)
  if (short %in% iso_639_3$alpha_2) {
    return(iso_639_3$alpha_3[iso_639_3$alpha_2 == short])
  }
  attr(lang, "problem") <-
    "Language field in DESCRIPTION must be a valid language.
E.g. en-GB or eng for (British) English and nl-BE or nld for (Flemish) Dutch."
  return(lang)
}
