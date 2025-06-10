#' @title The `org_list`  R6 class
#' @description A class containing a list of organisations
#' @export
#' @importFrom assertthat has_name is.string noNA
#' @importFrom R6 R6Class
#' @family class
org_list <- R6Class(
  "org_list",
  public = list(
    #' @description Return the organisation with matching email as a `person()`.
    #' @param email The email address of the organisation.
    #' @param role The role of the person to return.
    get_person = function(email, role = c("cph", "fnd")) {
      if (!email %in% self$get_email) {
        return(person(email = email, role = role))
      }
      relevant <- which(self$get_email == email)
      private$items[[relevant]]$as_person(role = role)
    },
    #' @description Return a vector of Zenodo communities associated with the
    #' organisations with matching email.
    #' @param email The email addresses to match against.
    #' @return A character vector with the communities.
    get_zenodo_by_email = function(email) {
      relevant <- private$items[unique(email)]
      vapply(
        relevant,
        FUN.VALUE = vector(mode = "list", length = 1),
        FUN = function(x) {
          list(x$get_zenodo)
        }
      ) |>
        unlist() |>
        unique()
    },
    #' @description Return the organisation with a matching name.
    #' @param name The name of the organisation to match.
    #' @return A list with the organisation name, email and match ratio.
    get_match = function(name) {
      matches <- vapply(
        private$items,
        FUN.VALUE = vector(mode = "list", length = 1),
        FUN = function(x) {
          list(x$compare_by_name(name))
        }
      )
      ratios <- vapply(matches, attr, FUN.VALUE = numeric(1), which = "match")
      assert_that(
        sum(ratios == max(ratios)) == 1,
        msg = unlist(matches)[ratios == max(ratios)] |>
          paste(collapse = "\n") |>
          sprintf(fmt = "multiples matches for `%2$s`:\n%1$s", name)
      )
      best_match <- matches[ratios == max(ratios)]
      return(
        list(
          name = unname(unlist(best_match)),
          email = names(best_match),
          match = attr(best_match[[1]], "match")
        )
      )
    },
    #' @description Return the organisation names with a matching email domain.
    #' @param email The email address to match the domain against.
    #' @param lang The language to return the organisation name in.
    #' @return A character vector with the organisation names.
    #' @details
    #' The function extracts the domain from the email address and
    #' matches it against the organisation email addresses.
    #' If multiple organisations have the same domain,
    #' the function returns all matching names.
    #' If the language is not available for a specific organisation,
    #' it will return the first available name.
    get_name_by_domain = function(email, lang) {
      org_domain <- gsub(".*@(.*)", "\\1", names(private$items))
      email_domain <- gsub(".*@(.*)", "\\1", email)
      relevant <- private$items[org_domain %in% email_domain]
      vapply(
        relevant,
        lang = lang,
        FUN.VALUE = character(1),
        FUN = function(x, lang) {
          x$get_name[[
            first_valid(
              choices = names(x$get_name),
              x = lang
            )
          ]]
        }
      ) |>
        unlist() -> aff_names
      vapply(
        relevant,
        FUN.VALUE = logical(1),
        FUN = function(x) {
          x$get_orcid
        }
      ) -> orcid
      names(orcid) <- aff_names
      return(orcid)
    },
    #' @description Initialize a new `org_list` object.
    #' @param ... One or more `org_item` objects.
    initialize = function(...) {
      dots <- list(...)
      vapply(dots, inherits, logical(1), what = "org_item") |>
        as.list() -> ok
      names(ok) <- sprintf("element %i is not an `org_item`", seq_along(dots))
      do.call(stopifnot, ok)
      vapply(dots, FUN.VALUE = character(1), FUN = function(x) {
        x$get_rightsholder
      }) |>
        compatible_rules()
      vapply(dots, FUN.VALUE = character(1), FUN = function(x) {
        x$get_funder
      }) |>
        compatible_rules()
      vapply(
        dots,
        FUN.VALUE = vector(mode = "list", length = 1),
        FUN = function(x) {
          list(x$get_name)
        }
      ) |>
        unlist() -> names
      ok <- list(anyDuplicated(names) == 0)
      names(ok) <- sprintf(
        "duplicated organisation name: `%s`",
        names[anyDuplicated(names)]
      )
      do.call(stopifnot, ok)
      private$items <- dots
      names(private$items) <- self$get_email
      return(self)
    },
    #' @description Print the `org_list` object.
    print = function() {
      vapply(
        seq_along(private$items),
        FUN.VALUE = logical(1),
        x = private$items,
        FUN = function(i, x) {
          rules() |>
            c(sprintf("organisation %i", i), rules(".")) |>
            cat()
          print(x[[i]])
          return(invisible(TRUE))
        }
      )
      cat(rules())
      return(invisible(self))
    },
    #' @description  Read the `org_list` object from an `organisation.yml` file.
    #' @param x The path to the directory where the `organisation.yml` file
    #' is stored.
    #' @importFrom fs is_dir path
    #' @importFrom yaml read_yaml write_yaml
    read = function(x = ".") {
      checklist <- try(read_checklist(x = x), silent = TRUE)
      if (inherits(checklist, "checklist")) {
        x <- checklist$get_path
      } else {
        stopifnot("`x` is not an existing directory" = is_dir(x))
      }
      if (!file_exists(path(x, "organisation.yml"))) {
        self <- org_list$new(org_item$new(email = "info@inbo.be"))
        return(self)
      }
      path(x, "organisation.yml") |>
        read_yaml() -> yaml
      stopifnot(
        "old style `organisation.yml` detected" = has_name(
          yaml,
          "checklist version"
        )
      )
      yaml[names(yaml) != "checklist version"] |>
        lapply(function(z) {
          do.call(org_item$new, z)
        }) |>
        do.call(what = org_list$new) -> self
      return(self)
    },
    #' @description Validate a `person` object given the `org_list` object.
    #' @param person The `person` object to validate.
    #' @param lang The language to use for affiliation.
    validate_person = function(person, lang) {
      ol_validate_persons(person, lang, items = private$items)
    },
    #' @description Validate the rules for the rightsholder and funder.
    #' @param rightsholder The rightsholders as a `person` object.
    #' @param funder The funders as a `person` object.
    validate_rules = function(rightsholder = person(), funder = person()) {
      ol_validate_rules(
        person = rightsholder,
        which_person = self$which_rightsholder,
        type = "rightsholder",
        items = private$items
      ) |>
        c(
          ol_validate_rules(
            person = funder,
            which_person = self$which_funder,
            type = "funder",
            items = private$items
          )
        )
    },
    #' @description  Write the `org_list` object to an `organisation.yml` file.
    #' @param x The path to the directory where the `organisation.yml` file
    #' should be written.
    #' @importFrom fs path
    #' @importFrom sessioninfo session_info
    #' @importFrom yaml write_yaml
    write = function(x = ".") {
      checklist <- try(read_checklist(x = x), silent = TRUE)
      if (inherits(checklist, "checklist")) {
        x <- checklist$get_path
      }
      vapply(
        private$items,
        FUN.VALUE = vector(mode = "list", length = 1),
        FUN = function(x) {
          list(x$as_list)
        }
      ) -> yaml
      names(yaml) <- self$get_default_name
      si <- session_info(pkgs = "checklist")
      yaml <- c(
        `checklist version` = si$packages$loadedversion[
          si$packages$package == "checklist"
        ],
        yaml
      )
      write_yaml(yaml, file = path(x, "organisation.yml"))
      return(path(x, "organisation.yml"))
    }
  ),
  active = list(
    #' @field get_default_name The organisations default name.
    get_default_name = function() {
      vapply(private$items, FUN.VALUE = character(1), FUN = function(x) {
        x$get_default_name
      })
    },
    #' @field get_email The organisations email.
    get_email = function() {
      vapply(private$items, FUN.VALUE = character(1), FUN = function(x) {
        x$get_email
      })
    },
    #' @field get_languages The different languages of the organisations.
    get_languages = function() {
      vapply(
        private$items,
        FUN.VALUE = vector(mode = "list", length = 1),
        FUN = function(x) {
          names(private$items[[1]]$get_name) |>
            list()
        }
      ) |>
        unlist() |>
        unique()
    },
    #' @field which_funder The required rightsholders.
    which_funder = function() {
      type <- vapply(
        private$items,
        FUN.VALUE = character(1),
        FUN = function(x) {
          x$get_funder
        }
      )
      list(
        required = names(type)[type %in% c("single", "shared")],
        alternative = names(type)[type == "when no other"]
      )
    },
    #' @field which_rightsholder The required rightsholders.
    which_rightsholder = function() {
      type <- vapply(
        private$items,
        FUN.VALUE = character(1),
        FUN = function(x) {
          x$get_rightsholder
        }
      )
      list(
        required = names(type)[
          type %in% c("single", "shared", "when no other")
        ],
        alternative = names(type)[type == "when no other"]
      )
    }
  ),
  private = list(items = list())
)

compatible_rules <- function(rules) {
  if (length(rules) < 2) {
    return(TRUE)
  }
  # fmt: skip
  stopifnot(
    "more than one organisation with `single`" = sum(rules == "single") <= 1,
    "`single` is not compatible with `shared`" =
      !(any(rules == "single") && any(rules == "shared")),
    "`single` is not compatible with `when no other`" =
      !(any(rules == "single") && any(rules == "when no other")),
    "more than one organisation with `when no other`" =
      sum(rules == "when no other") <= 1
  )
}

ol_valid_rules <- function(rules) {
  assert_that(is.character(rules), noNA(rules))
  if (length(rules) <= 1) {
    return(TRUE)
  }
  all(rules %in% c("shared", "optional"))
}

ol_validate_rules <- function(
  person = person(),
  which_person,
  items,
  type = c("rightsholder", "funder")
) {
  type <- match.arg(type)
  if (!inherits(person, "person")) {
    return(sprintf("`%s` is not a `person` object", type))
  }
  if (is.null(person$email)) {
    return(sprintf("all `%s` without email", type))
  }
  c(
    sprintf("`%s` without matching email in `organisation.yml`", type)[
      !all(unlist(person$email) %in% names(items))
    ],
    # fmt:skip
    sprintf(
      "missing required `%s`:\n - %s",
      type,
      paste(unlist(which_person), collapse = "\n -")
    )[
      !(
        (
          length(which_person[["required"]]) == 0 &&
            length(which_person[["alternative"]]) == 0
        ) ||
          (
            length(which_person[["required"]]) > 0 &&
              all(which_person[["required"]] %in% person$email)
          ) ||
          (
            length(which_person[["alternative"]]) > 0 &&
              which_person[["alternative"]] %in% person$email
          )
      )
    ],
    # fmt:skip
    sprintf("incompatible rules for `%s`", type)[
      length(person) > 0 &&
        !(items[[unlist(person$email)]]$get_rightsholder |>
            ol_valid_rules())
    ]
  )
}

ol_validate_persons <- function(person, lang, items) {
  assert_that(inherits(person, "person"))
  vapply(
    person,
    lang = lang,
    FUN = function(x, lang) {
      list(ol_validate_person(person = x, lang = lang, items = items))
    },
    FUN.VALUE = vector(mode = "list", length = 1)
  ) -> updated_person
  vapply(
    updated_person,
    function(x) {
      list(attr(x, "errors"))
    },
    FUN.VALUE = vector("list", 1)
  ) |>
    unlist() -> problems
  updated_person <- do.call(c, updated_person)
  attr(updated_person, "errors") <- problems
  return(updated_person)
}

first_valid <- function(choices, x) {
  assert_that(
    is.string(x),
    noNA(x),
    is.character(choices),
    noNA(choices),
    length(choices) > 0
  )
  if (length(choices) == 1) {
    return(choices)
  }
  if (missing(x) || !x %in% choices) {
    return(choices[1])
  }
  return(x)
}

ol_validate_org <- function(person, this_org, lang) {
  person_name <- format(person, c("given", "family"))
  lang <- first_valid(choices = names(this_org$name), x = lang)
  problems <- c(
    sprintf(
      "`%s`: `given` does not match `%s`",
      person_name,
      this_org$name[lang]
    )[
      person$given != this_org$name[lang]
    ],
    sprintf("`%s`: `family` must be empty", person_name)[
      !is.null(person$family) && person$family != ""
    ],
    # fmt: skip
    sprintf(
      "`%s`: `comment` must contain `ROR = \"%s\"`",
      person_name,
      this_org$ror
    )[
      has_name(this_org, "ror") &&
        (
          is.null(person$comment) ||
            is.null(person$comment["ROR"]) ||
            this_org$ror != person$comment["ROR"]
        )
    ],
    sprintf(
      "`%s`: `ORCID` is not relevant for organisations",
      person_name
    )[
      has_name(person, "comment") && has_name(person$comment, "ORCID")
    ]
  )
  comment <- first_non_null(person$comment, c(ROR = this_org$ror))
  comment["ROR"] <- this_org$ror
  updated_person <- person(
    given = this_org$name[lang],
    email = this_org$email,
    role = person$role,
    comment = comment
  )
  attr(updated_person, "errors") <- problems
  return(updated_person)
}

ol_validate_person <- function(person, lang, items) {
  if (is.null(person$email)) {
    updated_person <- person
    attr(updated_person, "errors") <- character(0)
    return(updated_person)
  }
  if (person$email %in% names(items)) {
    return(ol_validate_org(
      person = person,
      this_org = items[[person$email]]$as_list,
      lang = lang
    ))
  }
  person_name <- format(person, c("given", "family"))
  org_domain <- gsub(".*@(.*)", "\\1", names(items))
  email_domain <- gsub(".*@(.*)", "\\1", person$email)
  items[org_domain %in% email_domain] |>
    vapply(
      FUN = function(x) {
        list(x$as_list)
      },
      FUN.VALUE = vector(mode = "list", length = 1)
    ) |>
    ol_select_relevant_org(
      person = person,
      person_name = person_name,
      email_domain = email_domain
    ) -> relevant
  if (length(relevant) == 0) {
    updated_person <- person
    attr(updated_person, "errors") <- character(0)
    return(updated_person)
  }
  lang <- first_valid(
    choices = names(relevant[[1]]$name),
    x = lang
  )
  problems <- c(
    sprintf("`%s`: `given` is empty", person_name)[
      is.null(person$given) || person$given == ""
    ],
    sprintf("`%s`: `family` is empty", person_name)[
      is.null(person$family) || person$family == ""
    ],
    sprintf(
      "`%s`: `affiliation` must contain `%s`",
      person_name,
      relevant[[1]]$name[lang]
    )[
      is.null(person$comment) ||
        !has_name(person$comment, "affiliation") ||
        !relevant[[1]]$name[lang] %in% person$comment["affiliation"]
    ],
    sprintf(
      "`%s`: `ORCID` required for `%s`",
      person_name,
      relevant[[1]]$name[lang]
    )[
      is.null(person$comment) || !has_name(person$comment, "ORCID")
    ],
    sprintf(
      "`%s`: `ROR` is only relevant for organisations",
      person_name
    )[
      is.null(person$comment) || has_name(person$comment, "ROR")
    ]
  )
  comment <- first_non_null(
    person$comment,
    c(affiliation = relevant[[1]]$name[lang])
  )
  c(
    relevant[[1]]$name[[lang]],
    comment[["affiliation"]][
      !comment[["affiliation"]] %in% relevant[[1]]$name
    ]
  ) |>
    head(1) -> comment[["affiliation"]]
  updated_person <- person(
    given = person$given,
    family = person$family,
    email = person$email,
    role = person$role,
    comment = comment
  )
  attr(updated_person, "errors") <- problems
  return(updated_person)
}

ol_select_relevant_org <- function(
  relevant,
  person,
  person_name,
  email_domain
) {
  if (length(relevant) <= 1) {
    return(relevant)
  }
  vapply(
    relevant,
    FUN = function(x) {
      person$comment["affiliation"] %in% x$name
    },
    FUN.VALUE = logical(1)
  ) |>
    which() -> which_aff
  if (length(which_aff) == 0) {
    updated_person <- person
    attr(updated_person, "errors") <- sprintf(
      "`%s`: matching `affiliation` required for `%s`",
      person_name,
      email_domain
    )
    return(updated_person)
  }
  relevant <- relevant[which_aff]
}
