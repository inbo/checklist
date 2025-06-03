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
      relevant <- private$items[org_domain == email_domain]
      vapply(
        relevant,
        lang = lang,
        FUN.VALUE = character(1),
        FUN = function(x, lang) {
          org_names <- x$get_name
          if (lang %in% names(org_names)) {
            return(org_names[[lang]])
          } else {
            return(org_names[[1]])
          }
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
    #' @description Validate the rules for the rightsholder and funder.
    #' @param rightsholder The rightsholders as a `person` object.
    #' @param funder The funders as a `person` object.
    validate_rules = function(rightsholder = person(), funder = person()) {
      problem <- c(
        "`rightsholder` is not a `person` object"[
          !inherits(rightsholder, "person")
        ],
        "`funder` is not a `person` object"[!inherits(funder, "person")]
      )
      if (length(problem) > 0) {
        return(problem)
      }
      c(
        "`rightsholder` with multiple email"[
          !all(
            vapply(rightsholder$email, length, integer(1)) == 1
          )
        ],
        "`funder` with multiple email"[
          !all(
            vapply(funder$email, length, integer(1)) == 1
          )
        ],
        "`rightsholder` without matching email in `organisation.yml`"[
          !all(
            unlist(rightsholder$email) %in% self$get_email
          )
        ],
        "`funder` without matching email in `organisation.yml`"[
          !all(
            unlist(funder$email) %in% self$get_email
          )
        ],
        sprintf(
          "missing required rightsholder:\n - %s",
          paste(unlist(self$which_rightsholder), collapse = "\n -")
        )[
          !((length(self$which_rightsholder[["alternative"]]) > 0 &&
            all(
              self$which_rightsholder[["required"]] %in% rightsholder$email
            )) ||
            (length(self$which_rightsholder[["alternative"]]) > 0 &&
              self$which_rightsholder[["alternative"]] %in% rightsholder$email))
        ],
        sprintf(
          "missing required funder:\n - %s",
          paste(unlist(self$which_funder), collapse = "\n -")
        )[
          !((length(self$which_rightsfunder[["alternative"]]) > 0 &&
            all(
              self$which_funder[["required"]] %in% funder$email
            )) ||
            (length(self$which_funder[["alternative"]]) > 0 &&
              self$which_funder[["alternative"]] %in% funder$email))
        ],
        "incompatible rules for rightholder"[
          length(rightsholder) > 0 &&
            !(private$items[[unlist(
              rightsholder$email
            )]]$get_rightsholder |>
              valid_rules())
        ],
        "incompatible rules for funder"[
          length(funder) > 0 &&
            !(private$items[[unlist(
              funder$email
            )]]$get_funder |>
              valid_rules())
        ]
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
  stopifnot(
    "more than one organisation with `single`" = sum(rules == "single") <= 1,
    "`single` is not compatible with `shared`" = !(any(rules == "single") &&
      any(rules == "shared")),
    "`single` is not compatible with `when no other`" = !(any(
      rules == "single"
    ) &&
      any(rules == "when no other")),
    "more than one organisation with `when no other`" = sum(
      rules == "when no other"
    ) <=
      1
  )
}

valid_rules <- function(rules) {
  assert_that(is.character(rules), noNA(rules))
  if (length(rules) <= 1) {
    return(TRUE)
  }
  all(rules %in% c("shared", "optional"))
}
