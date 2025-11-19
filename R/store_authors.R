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
    this_desc$get_authors() |>
      author2df() |>
      cbind(usage = 1) |>
      rbind(cbind(current, role = "")) -> new_author_df
  } else {
    citation_meta$new(x)$get_person |>
      author2df() |>
      cbind(usage = 1, email = "") -> cit_meta
    cit_meta <- cit_meta[
      cit_meta$family != "",
      c("given", "family", "email", "orcid", "affiliation", "usage")
    ]
    new_author_df <- rbind(current, cit_meta)
  }
  aggregate(
    usage ~ given + family + email + orcid + affiliation,
    FUN = sum,
    data = new_author_df
  ) |>
    write.table(
      file = path(root, "author.txt"),
      sep = "\t",
      row.names = FALSE,
      fileEncoding = "UTF8"
    )
  return(invisible(NULL))
}

#' Convert person object in a data.frame.
#'
#' Results in a data.frame with the given name, family name, e-mail, ORCID,
#' affiliation and role.
#' Missing elements result in an empty string (`""`).
#' Persons with multiple roles will have the roles as a comma separated string.
#' @param person The person object or a list of person objects, `NA` or `NULL`.
#' Any `"character"` is converted to a person object using `as.person()` with a
#' warning.
#' @family utils
#' @export
author2df <- function(person) {
  UseMethod("author2df", person)
}

#' @export
author2df.default <- function(person) {
  stop("`author2df()` is not implemented for ", class(person))
}

#' @export
author2df.logical <- function(person) {
  stopifnot(
    "`author2df()` is not implemented for `TRUE` or `FALSE`" = is.na(person)
  )
  data.frame(
    given = character(0),
    family = character(0),
    email = character(0),
    orcid = character(0),
    affiliation = character(0),
    role = character(0)
  )
}

#' @export
author2df.NULL <- function(person) {
  data.frame(
    given = character(0),
    family = character(0),
    email = character(0),
    orcid = character(0),
    affiliation = character(0),
    role = character(0)
  )
}

#' @export
#' @importFrom utils as.person
author2df.character <- function(person) {
  warning(
    "`author2df()` converted a character to a person using `as.person()`",
    immediate. = TRUE,
    call. = FALSE
  )
  author2df(as.person(person))
}

#' @export
author2df.list <- function(person) {
  vapply(
    person,
    function(x) {
      list(author2df(x))
    },
    vector(mode = "list", 1)
  ) |>
    do.call(what = rbind)
}

#' @export
#' @importFrom assertthat assert_that has_name
author2df.person <- function(person) {
  assert_that(inherits(person, "person"))
  if (length(person) > 1) {
    return(
      vapply(
        person,
        function(x) {
          list(author2df(x))
        },
        vector(mode = "list", 1)
      ) |>
        do.call(what = rbind)
    )
  }

  data.frame(
    given = coalesce(person$given, ""),
    family = coalesce(person$family, ""),
    email = coalesce(person$email, ""),
    orcid = ifelse(
      has_name(person$comment, "ORCID"),
      unname(person$comment["ORCID"]),
      ""
    ),
    affiliation = ifelse(
      has_name(person$comment, "affiliation"),
      unname(person$comment["affiliation"]),
      ""
    ),
    role = paste(person$role, collapse = ", ")
  )
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
        given = character(0),
        family = character(0),
        email = character(0),
        orcid = character(0),
        affiliation = character(0),
        usage = integer(0)
      )
    )
  }
  if (is_file(path(root, "author.txt"))) {
    path(root, "author.txt") |>
      read.table(
        header = TRUE,
        sep = "\t",
        colClasses = c(rep("character", 5), "integer")
      ) -> current
    return(current)
  }
  return(
    data.frame(
      given = character(0),
      family = character(0),
      email = character(0),
      orcid = character(0),
      affiliation = character(0),
      usage = integer(0)
    )
  )
}
