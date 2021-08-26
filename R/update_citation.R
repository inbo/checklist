#' Create or update the CITATION file
#'
#' The function creates the file `inst/CITATION` is case is doesn't exist.
#' Otherwise it will update the citation information indicated between
#' `# begin checklist entry` and `# end checklist entry`.
#' The remained of the file is left untouched.
#'
#' The content of `DESCRIPTION` determines the citation information.
#'
#' When you don't want the update, then remove both `# begin checklist entry`
#' and `# end checklist entry`.
#' Note that this will result in a warning, which you can allow via
#' `write_checklist()`.
#'
#' @inheritParams read_checklist
#' @param roles Roles to select the persons for the `DESCRIPTION`.
#' Defaults to `c("aut", "cre")`.
#' @export
#' @importFrom assertthat assert_that
#' @importFrom desc description
#' @importFrom utils file_test
#' @family package
update_citation <- function(x = ".", roles = c("aut", "cre")) {
  x <- read_checklist(x = x)
  assert_that(
    x$package,
    msg = "`check_description()` is only relevant for packages.
  `checklist.yml` indicates this is not a package."
  )

  this_desc <- description$new(
    file = file.path(x$get_path, "DESCRIPTION")
  )
  if (file_test("-f", file.path(x$get_path, "inst", "CITATION"))) {
    cit <- readLines(file.path(x$get_path, "inst", "CITATION"))
  } else {
    cit <- sprintf(
      "citHeader(\"To cite `%s` in publications please use:\")
# begin checklist entry
# end checklist entry",
      this_desc$get_field("Package")
    )
  }
  start <- grep("^# begin checklist entry", cit)
  end <- grep("^# end checklist entry", cit)
  problems <- c(
    "No `# begin checklist entry` found in `inst/CITATION`"[length(start) == 0],
    "No `# end checklist entry` found in `inst/CITATION`"[length(end) == 0]
  )
  if (length(problems)) {
    x$add_warnings(problems)
    return(x)
  }
  problems <- c(
    "Multiple `# begin checklist entry` found in `inst/CITATION`"[
      length(start) > 1
    ],
    "Multiple `# end checklist entry` found in `inst/CITATION`"[
      length(end) > 1
    ],
  "`# end checklist entry` gefore `# begin checklist entry` in `inst/CITATION`"[
      start >= end
    ]
  )
  if (length(problems)) {
    x$add_error(problems, "CITATION")
    return(x)
  }
  authors <- eval(parse(text = this_desc$get_field("Authors@R")))
  relevant <- vapply(
    authors,
    function(x) {
      any(x$role %in% roles)
    },
    logical(1)
  )
  authors <- authors[relevant]
  authors_plain <- format(
    authors, include = c("family", "given"),
    braces = list(family = c("", ","))
  )
  authors_bibtex <- format(
    authors, include = c("given", "family"),
    braces = list(family = c("{", "}"))
  )
  authors_bibtex <- paste0("\"", authors_bibtex, "\"", collapse = ", ")
  package_citation <- c(
    entry = "\"Manual\"",
    title = sprintf(
      "\"%s: %s. Version %s\"", this_desc$get_field("Package"),
      this_desc$get_field("Title"), this_desc$get_field("Version")
    ),
    author = sprintf("c(%s)", authors_bibtex),
    year = gsub("-.*", "", Sys.Date()),
    url = paste0("\"", gsub(",.*", "", this_desc$get_field("URL")), "\""),
    doi = paste0(
      "\"",
      gsub(".*https://doi.org/(.*) ?,?.*", "\\1", this_desc$get_field("URL")),
      "\""
    ),
    abstract = paste0("\"", this_desc$get_field("Description"), "\""),
    textVersion = sprintf(
      "\"%s (%s) %s: %s. Version %s. %s\"",
      paste(authors_plain, collapse = "; "), gsub("-.*", "", Sys.Date()),
      this_desc$get_field("Package"), this_desc$get_field("Title"),
      this_desc$get_field("Version"), this_desc$get_field("URL")
    )
  )
  package_citation <- gsub("\n", " ", package_citation)
  package_citation <- gsub("[ ]{2, }", " ", package_citation)
  package_citation <- sprintf(
    "  %s = %s,", names(package_citation), package_citation
  )
  writeLines(
    c(head(cit, start), "citEntry(", package_citation, ")", tail(cit, 1 - end)),
    file.path(x$get_path, "inst", "CITATION")
  )
  return(x)
}
