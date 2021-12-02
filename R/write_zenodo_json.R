#' Write a .zenodo.json file
#'
#' Zenodo uses the .zenodo.json file to define the citation information.
#' See
#' https://developers.zenodo.org/#add-metadata-to-your-github-repository-release
#' for more information.
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
    ".*orcid.org/(([0-9]{4}-){3}[0-9]{4}).*", "https://orcid.org/\\1", # nolint
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
  relevant <- vapply(
    authors, FUN.VALUE = logical(1),
    FUN = function(z) {
      any(z$role %in% "ctb")
    }
  )
  contributors <- vapply(
    which(relevant), FUN.VALUE = vector("list", 1),
    FUN = function(i) {
      if (authors_orcid[[i]] == "") {
        list(list(name = authors_plain[[i]]))
      } else {
        list(list(name = authors_plain[[i]], orcid = authors_orcid[[i]]))
      }
    }
  )

  description <- gsub(" +", " ", gsub("\n", " ", this_desc$get("Description")))
  license <- this_desc$get("License")
  license <- ifelse(license == "GPL-3", "GPL-3.0", license)
  zenodo <- list(
    title = sprintf("%s: %s", this_desc$get("Package"), this_desc$get("Title")),
    version = as.character(this_desc$get_version()), description = description,
    creators = creators, contributors = contributors, upload_type = "software",
    access_rights = "open", license = license,
    communities = list(identifier = "inbo")
  )
  if (!is.na(this_desc$get("Language"))) {
    zenodo$language <- gsub("(-.*)", "", this_desc$get("Language"))
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
    new <- "^\\.zenodo\\.json$"
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
    paste(
      ".zenodo.json file needs an update.",
      "Run `update_citation()` or `check_package()` locally.",
      "Then\ncommit `.zenodo.json`."
    )[
      !is_tracked_not_modified(file = ".zenodo.json", repo = repo)
    ],
    "CITATION"
  )

  return(invisible(NULL))
}
