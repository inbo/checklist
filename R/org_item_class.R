#' @title The `org_item`  R6 class
#' @description A class containing a single organisation
#' @export
#' @importFrom assertthat has_name is.string noNA
#' @importFrom R6 R6Class
#' @family class
org_item <- R6Class(
  "org_item",
  public = list(
    #' @description Initialize a new `org_item` object.
    #' @param ... The organisation information.
    #' See the details.
    #' @param orcid Whether the organisation requires an ORCID for every person
    #'   that uses this organisation as affiliation.
    #' @param rightsholder The required copyright holder status for the
    #' organisation.
    #' `"optional"` means that the organisation is not required as the copyright
    #' holder.
    #' `"single"` means that the organisation must be the only copyright holder.
    #' `"shared"` means that the organisation must be one of the copyright
    #' holders.
    #' `"no other"` means that if no other copyright holder is specified,
    #' the organisation must be the copyright holder.
    #' @param funder The required funder status for the organisation.
    #' The categories are the same as for `rightsholder`.
    #' @details
    #' - `name`: A named vector with the organisation names in one or more
    #'   languages.
    #'   The first item in the vector is the default language.
    #'   The names of the vector must match the language code.
    #' - `domain`: The email domain of the organisation.
    #'   Used to match users to the organisation.
    #' - `email`: An optional email address for the organisation.
    #'   Used to contact the organisation.
    #' - `git`: The optional root URL to the organisations git repositories.
    #'   The organisation with matching URL in the git remote will be used as
    #'   the primary organisation.
    #' - `ror`: The optional ROR ID of the organisation.
    #' - `zenodo`: The optional Zenodo community ID of the organisation.
    initialize = function(
      ...,
      orcid = FALSE,
      rightsholder = c("optional", "single", "shared", "when no other"),
      funder = c("optional", "single", "shared", "when no other")
    ) {
      dots <- list(...)
      private$rightsholder <- match.arg(rightsholder)
      private$funder <- match.arg(funder)
      stopifnot(
        "no `name` argument found" = has_name(dots, "name"),
        "`domain` must be a string" = is.string(dots$domain),
        "`domain` cannot be NA" = noNA(dots$domain),
        "`domain` cannot be empty" = dots$domain != ""
      )
      if (dots$domain == "inbo.be") {
        private$name <- c(
          `nl-BE` = "Instituut voor Natuur- en Bosonderzoek (INBO)",
          `fr-FR` = "Institut de Recherche sur la Nature et les Forêts (INBO)",
          `en-GB` = "Research Institute for Nature and Forest (INBO)",
          `de-DE` = "Institut für Natur- und Waldforschung (INBO)"
        )
        private$domain <- dots$domain
        private$orcid <- TRUE
        private$ror <- "https://ror.org/00j54wy13"
        private$zenodo <- "inbo"
        private$git <- "https://github.com/inbo"
        return(self)
      }
      dots$name <- unlist(dots$name)
      stopifnot(
        "`name` is not character" = is.character(dots$name),
        "`name` must contain at least one value" = length(dots$name) > 0,
        "`name` must have the language as name" = !is.null(names(dots$name)),
        "`name` cannot have empty names" = all(names(dots$name) != ""),
        "`name` cannot have empty values" = noNA(dots$name),
        "`orcid` must be `TRUE` or `FALSE`" = is.flag(private$orcid),
        "`orcid` must be `TRUE` or `FALSE`" = noNA(private$orcid)
      )
      private$name <- dots$name
      private$domain <- dots$domain
      private$orcid <- orcid
      if (has_name(dots, "email")) {
        stopifnot(
          "`email` must be a string" = is.string(dots$email),
          "`email` cannot be NA" = noNA(dots$email),
          "`email` cannot be empty" = dots$email != ""
        )
        private$email <- dots$email
      }
      if (has_name(dots, "git")) {
        stopifnot(
          "`git` must be a string" = is.string(dots$git),
          "`git` cannot be NA" = noNA(dots$git),
          "`git` must be in https://server/org format" = grepl(
            "^https:\\/\\/[\\w\\.]+\\/\\w+$",
            dots$git,
            perl = TRUE
          )
        )
        private$git <- dots$git
      }
      if (has_name(dots, "ror")) {
        stopifnot(
          "`ror` must be a string" = is.string(dots$git),
          "`ror` cannot be NA" = noNA(dots$git),
          "`ror` must be in https://ror.org/id format" = grepl(
            "^https:\\/\\/ror\\.org\\/0[a-hj-km-np-tv-z|0-9]{6}[0-9]{2}$",
            dots$ror,
            perl = TRUE
          )
        )
        private$ror <- dots$ror
      }
      if (has_name(dots, "zenodo")) {
        stopifnot(
          "`zenodo` must be a string" = is.string(dots$zenodo),
          "`zenodo` cannot be NA" = noNA(dots$zenodo),
          "`zenodo` cannot be empty" = dots$zenodo != ""
        )
        private$zenodo <- dots$zenodo
      }
      return(self)
    },
    #' @description Print the `org_item` object.
    print = function() {
      c(
        "name",
        sprintf("- %s: %s", names(private$name), private$name),
        sprintf("domain: %s", private$domain),
        sprintf("email: %s", private$email),
        sprintf("ROR: %s", private$ror),
        sprintf("git organisation: %s", private$git),
        "ORCID is required"[private$orcid],
        sprintf("zenodo community: %s", private$zenodo),
        sprintf("copyright holder: %s", private$rightsholder),
        sprintf("funder: %s", private$funder)
      ) |>
        cat(sep = "\n")
      return(invisible(NULL))
    }
  ),
  active = list(
    #' @field as_list The organisation as a list.
    as_list = function() {
      organisation <- list(
        domain = private$domain,
        name = as.list(private$name),
        email = private$email,
        ror = private$ror,
        git = private$git,
        orcid = private$orcid,
        zenodo = private$zenodo,
        rightsholder = private$rightsholder,
        funder = private$funder
      )
      relevant <- vapply(organisation, length, FUN.VALUE = integer(1)) > 0
      organisation[relevant]
    },
    #' @field get_community The organisation Zenodo community.
    get_community = function() {
      private$community
    },
    #' @field get_domain The organisation email.
    get_domain = function() {
      private$domain
    },
    #' @field get_email The organisation email.
    get_email = function() {
      private$email
    },
    #' @field get_funder The funder rules.
    get_funder = function() {
      private$funder
    },
    #' @field get_name The organisation name.
    get_name = function() {
      private$name
    },
    #' @field get_orcid The ORCID rules.
    get_orcid = function() {
      private$orcid
    },
    #' @field get_git The organisational root git URL.
    get_git = function() {
      private$git
    },
    #' @field get_rightsholder The rightsholder rules.
    get_rightsholder = function() {
      private$rightsholder
    }
  ),
  private = list(
    email = character(0),
    domain = character(0),
    git = character(0),
    name = character(0),
    orcid = FALSE,
    ror = character(0),
    zenodo = character(0),
    rightsholder = "single",
    funder = "single"
  )
)
