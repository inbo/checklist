#' Store author details for later usage
#' @inheritParams read_checklist
#' @export
#' @importFrom desc description
#' @importFrom fs path
#' @importFrom tools R_user_dir
#' @importFrom utils write.table
#' @family utils
store_authors <- function(x = ".") {
  root <- R_user_dir("checklist", which = "data")
  current <- stored_authors(root)
  if (file_exists(path(x, "DESCRIPTION"))) {
    this_desc <- description$new(file = path(x, "DESCRIPTION"))
    author <- this_desc$get_authors()
    vapply(author, author2df, vector(mode = "list", 1)) |>
      c(list(current)) |>
      do.call(what = rbind) -> new_author_df
  } else {
    citation_meta$new(x)$get_meta$authors |>
      cbind(usage = 1, email = "") -> cit_meta
    cit_meta <- cit_meta[
      , c("given", "family", "email", "orcid", "affiliation", "usage")
    ]
    new_author_df <- rbind(current, cit_meta)
  }
  aggregate(
    usage ~ given + family + email + orcid + affiliation, FUN = sum,
    data = new_author_df
  ) |>
    write.table(
      file = path(root, "author.txt"), sep = "\t", row.names = FALSE,
      fileEncoding = "UTF8"
    )
  return(invisible(NULL))
}

#' @importFrom assertthat assert_that has_name
author2df <- function(z) {
  assert_that(inherits(z, "person"))
  if (all(z$role %in% c("cph", "fnd"))) {
    return(list(data.frame(
      given = character(0), family = character(0), email = character(0),
      orcid = character(0), affiliation = character(0), usage = integer(0)
    )))
  }

  list(data.frame(
    given = z$given, family = z$family, email = coalesce(z$email, ""),
    orcid = ifelse(
      has_name(z$comment, "ORCID"), unname(z$comment["ORCID"]), ""
    ),
    affiliation = ifelse(
      has_name(z$comment, "ORCID"), unname(z$comment["affiliation"]), ""
    ),
    usage = 1
  ))
}

coalesce <- function(...) {
  dots <- list(...)
  i <- 1
  while (i <= length(dots)) {
    if (!is.null(dots[[i]])) {
      return(dots[[i]])
    }
    i <- i + 1
  }
  return(NULL)
}

#' @importFrom assertthat assert_that is.string noNA
#' @importFrom fs dir_create is_dir is_file path
#' @importFrom utils read.table
stored_authors <- function(root) {
  assert_that(is.string(root), noNA(root))
  if (!is_dir(root)) {
    dir_create(root)
    return(
      data.frame(
        given = character(0), family = character(0), email = character(0),
        orcid = character(0), affiliation = character(0), usage = integer(0)
      )
    )
  }
  if (is_file(path(root, "author.txt"))) {
    path(root, "author.txt") |>
      read.table(
        header = TRUE, sep = "\t",
        colClasses = c(rep("character", 5), "integer")
      ) -> current
    return(current)
  }
  return(
    data.frame(
      given = character(0), family = character(0), email = character(0),
      orcid = character(0), affiliation = character(0), usage = integer(0)
    )
  )
}
