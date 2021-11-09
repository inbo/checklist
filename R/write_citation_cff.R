#' Write a CITATION.cff file
#'
#' This file format contains the citation information.
#' It is supported by GitHub, Zenodo and Zotero.
#' @inheritParams read_checklist
#' @inheritParams update_citation
#' @export
#' @importFrom assertthat assert_that
#' @family package
write_citation_cff <- function(x = ".", roles) {
  x <- read_checklist(x = x)
  assert_that(
    x$package,
    msg = "`write_citation_cff()` currently only handles packages.
  `checklist.yml` indicates this is not a package."
  )
  if (!missing(roles)) {
    x$set_roles(roles = roles)
  }

  this_desc <- description$new(
    file = file.path(x$get_path, "DESCRIPTION")
  )

  authors <- eval(parse(text = this_desc$get_field("Authors@R")))
  maintainer <- authors[vapply(
    authors, FUN.VALUE = logical(1), FUN = function(z) {
      any(z$role %in% "cre")
    }
  )]
  contact <- list(list(
    email = maintainer$email, `family-names` = maintainer$family,
    `given-names` = maintainer$given
  ))
  copyright <- authors[vapply(
    authors, FUN.VALUE = logical(1), FUN = function(z) {
      any(z$role %in% "cph")
    }
  )]
  if (length(copyright) == 1) {
    if (is.null(copyright$family)) {
      contact <- c(contact,
        list(list(email = copyright$email, name = copyright$given))
      )
    }  else {
      contact <- c(contact,
        list(list(
          email = copyright$email, `family-names` = copyright$family,
          `given-names` = copyright$given
        ))
      )
    }
  }
  relevant <- vapply(
    authors, FUN.VALUE = logical(1), FUN = function(z) {
      any(z$role %in% x$get_roles)
    }
  )
  authors <- authors[relevant]
  authors <- vapply(
    authors, FUN.VALUE = vector("list", 1),
    FUN = function(i) {
      z <- list(list(`family-names` = i$family, `given-names` = i$given))
      if (!is.null(i$comment["ORCID"])) {
        z[[1]]$orcid <- sprintf(
          "https://orcid.org/%s", unname(i$comment["ORCID"])
        )
      }
      return(z)
    }
  )
  description <- gsub(" +", " ", gsub("\n", " ", this_desc$get("Description")))

  license <- this_desc$get_field("License")
  license <- ifelse(license == "GPL-3", "GPL-3.0", license)
  citation <- list(
    `cff-version` = "1.2.0",
    message = "If you use this software, please cite it as below.",
    authors = authors, contact = contact,
    title = sprintf("%s: %s", this_desc$get("Package"), this_desc$get("Title")),
    version = as.character(this_desc$get_version()), abstract = description,
    license = license, type = "software"
  )

  url <- this_desc$get_field("URL")
  url <- strsplit(url, ", ")[[1]]
  if (any(grepl("https:\\/\\/doi.org/", url))) {
    doi <- url[grepl("https:\\/\\/doi.org/", url)]
    url <- url[!grepl("https:\\/\\/doi.org/", url)]
    citation$doi <- gsub("https:\\/\\/doi.org/(.*)", "\\1", doi)
  }
  if (any(grepl("https:\\/\\/github.com/", url))) {
    citation[["repository-code"]] <- url[grepl("https:\\/\\/github.com/", url)]
    url <- url[!grepl("https:\\/\\/github.com/", url)]
  }
  citation$identifiers <- vapply(
    url, FUN.VALUE = vector("list", 1), USE.NAMES = FALSE, FUN = function(i) {
      list(list(type = "url", value = i))
    }
  )

  write_yaml(
    x = citation, file = file.path(x$get_path, "CITATION.cff"),
    fileEncoding = "UTF-8"
  )

  if (!file_test("-f", file.path(x$get_path, ".Rbuildignore"))) {
    file.copy(
      system.file(
        file.path("package_template", "rbuildignore"), package = "checklist"
      ),
      file.path(x$get_path, ".Rbuildignore")
    )
  } else {
    current <- readLines(file.path(x$get_path, ".Rbuildignore"))
    new <- "^CITATION\\.cff$"
    writeLines(
      sort(unique(c(new, current))), file.path(x$get_path, ".Rbuildignore")
    )
  }

  repo <- x$get_path
  x$add_error(
    paste(
      "CITATION.cff file needs an update.",
      "Run `update_citation()` or `check_package()` locally.",
      "Then\ncommit `CITATION.cff`."
    )[
      !is_tracked_not_modified(file = "CITATION.cff", repo = repo)
    ],
    "CITATION"
  )

  return(invisible(NULL))
}
