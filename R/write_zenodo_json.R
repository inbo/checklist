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
#' @family package
write_zenodo_json <- function(x = ".") {
  x <- read_checklist(x = x)
  assert_that(
    x$package,
    msg = "`write_zenodo_josn()` currently only handles packages.
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
  zenodo <- list(
    title = sprintf("%s: %s", this_desc$get("Package"), this_desc$get("Title")),
    version = as.character(this_desc$get_version()), description = description,
    creators = creators, contributors = contributors, upload_type = "software",
    access_rights = "open", license = this_desc$get("License"),
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

  writeLines(toJSON(zenodo, pretty = TRUE), ".zenodo.json")

  repo <- repository(x$get_path)
  current <- unlist(status(repo, ignored = TRUE))
  x$add_error(
    paste(
      ".zenodo.json file needs an update.",
      "Run `write_zenodo_json()` or `check_package()` locally.",
      "Then\ncommit `.zenodo.json`."
    )[
      ".zenodo.json" %in% current
    ],
    "CITATION"
  )

  return(invisible(NULL))
}
