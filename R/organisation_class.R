#' @title The organisation R6 class
#' @description A class with the organisation defaults
#' @export
#' @importFrom R6 R6Class
#' @family class
organisation <- R6Class(
  "organisation",
  public = list(
    #' @description Initialize a new `organisation` object.
    #' @param ... The organisation settings.
    #' See the details.
    #' @details
    #' - `github`: the name of the github organisation.
    #'   Set to `NA_character_` in case you don't want a mandatory github
    #'   organisation.
    #' - `community`: the mandatory Zenodo community.
    #'   Defaults to `"inbo"`.
    #'   Set to `NA_character_` in case you don't want a mandatory community.
    #' - `email`: the e-mail of the organisation.
    #'   Defaults to `"info@inbo.be"`.
    #'   Set to `NA_character_` in case you don't want an organisation e-mail.
    #' - `funder`: the funder.
    #'   Defaults to `"Research Institute for Nature and Forest (INBO)"`.
    #'   Set to `NA_character_` in case you don't want to set a funder.
    #' - `rightsholder`: the rightsholder.
    #'   Defaults to `"Research Institute for Nature and Forest (INBO)"`.
    #'   Set to `NA_character_` in case you don't want to set a rightsholder.
    #' - `organisation`: a named list with one or more organisation default
    #'   rules.
    #'   The names of the element must match the e-mail domain name of the
    #'   organisation.
    #'   Every element should be a named list containing `affiliation` and
    #'   `orcid`.
    #'   `affiliation` is a character vector with the approved organisation
    #'   names in one or more languages.
    #'   `orcid = TRUE` indicated a mandatory ORCiD for every member.
    #'   Use an empty list in case you don't want to set this.
    #' @importFrom assertthat assert_that is.string is.flag
    initialize = function(...) {
      dots <- list(...)
      private$community <- use_first_non_null(dots$community, "inbo")
      stopifnot("`community` must be a string" = is.string(private$community))
      private$email <- use_first_non_null(dots$email, "info@inbo.be")
      stopifnot("`email` must be a string" = is.string(private$email))
      private$github <- use_first_non_null(dots$github, "inbo")
      stopifnot("`github` must be a string" = is.string(private$github))
      private$funder <- use_first_non_null(
        dots$funder,
        "Research Institute for Nature and Forest (INBO)"
      )
      stopifnot("`funder` must be a string" = is.string(private$funder))
      private$rightsholder <- use_first_non_null(
        dots$rightsholder,
        "Research Institute for Nature and Forest (INBO)"
      )
      stopifnot(
        "`rightsholder` must be a string" = is.string(private$rightsholder)
      )
      assert_that(
        is.null(dots$organisation) || is.list(dots$organisation),
        msg = "`organisation` must be a list"
      )
      private$organisation <- dots$organisation
      private$organisation[["inbo.be"]] <- list(
        affiliation = c(
          en = "Research Institute for Nature and Forest (INBO)",
          nl = "Instituut voor Natuur- en Bosonderzoek (INBO)",
          fr = "Institut de Recherche sur la Nature et les For\u00eats (INBO)",
          de = "Institut f\u00fcr Natur- und Waldforschung (INBO)"
        ),
        orcid = TRUE
      )
      stopifnot(
        "`organisation` must be a named list or NULL" = !is.null(names(
          private$organisation
        )) &&
          all(names(private$organisation) != "")
      )
      vapply(
        names(private$organisation),
        FUN.VALUE = logical(1),
        FUN = function(x) {
          assert_that(
            is.list(private$organisation[[x]]),
            msg = sprintf("`organisation[[\"%s\"]]` is not a list", x)
          )
          assert_that(
            all(
              c("affiliation", "orcid") %in% names(private$organisation[[x]])
            ),
            msg = sprintf(
              "`organisation[[\"%s\"]]` must contain `affiliation` and `orcid`",
              x
            )
          )
          assert_that(
            is.character(private$organisation[[x]][["affiliation"]]),
            msg = paste(
              "`organisation[[\"%s\"]][[\"affiliation\"]]`",
              "is not a character vector"
            ) |>
              sprintf(x)
          )
          assert_that(
            noNA(private$organisation[[x]][["affiliation"]]),
            msg = sprintf(
              "`organisation[[\"%s\"]][[\"affiliation\"]]` may not contain NA",
              x
            )
          )
          assert_that(
            length(private$organisation[[x]][["affiliation"]]) > 0,
            msg = sprintf(
              "`organisation[[\"%s\"]][[\"affiliation\"]]` may not be empty",
              x
            )
          )
          assert_that(
            is.flag(private$organisation[[x]][["orcid"]]),
            noNA(private$organisation[[x]][["orcid"]]),
            msg = paste(
              "`organisation[[\"%s\"]][[\"orcid\"]]` is not a flag",
              "(a length one logical vector)"
            ) |>
              sprintf(x)
          )
        }
      )
      invisible(self)
    },
    #' @description Print the `organisation` object.
    #' @param ... currently ignored.
    print = function(...) {
      dots <- list(...)
      c(
        "rightsholder:  %s",
        "funder:        %s",
        "organisation email:  %s",
        "GitHub organisation: %s",
        "Zenodo community:    %s",
        "email domain settings"
      ) |>
        paste(collapse = "\n") |>
        sprintf(
          self$get_rightsholder,
          self$get_funder,
          self$get_email,
          self$get_github,
          self$get_community
        ) |>
        cat()
      org <- self$get_organisation
      for (domain in names(org)) {
        cat(
          "\n-",
          domain,
          "\n  mandatory ORCID iD"[org[[domain]]$orcid],
          "\n  affiliations",
          sprintf(
            "\n    %s: %s",
            names(org[[domain]]$affiliation),
            org[[domain]]$affiliation
          )
        )
      }
      return(invisible(NULL))
    }
  ),
  active = list(
    #' @field as_person The default organisation funder and rightsholder.
    #' @importFrom utils person
    as_person = function() {
      person(
        given = private$rightsholder,
        email = private$email,
        role = c("cph", "fnd")
      )
    },
    #' @field get_community The default organisation Zenodo communities.
    get_community = function() {
      private$community
    },
    #' @field get_email The default organisation email.
    get_email = function() {
      private$email
    },
    #' @field get_funder The default funder.
    get_funder = function() {
      private$funder
    },
    #' @field get_github The default GitHub organisation domain.
    get_github = function() {
      private$github
    },
    #' @field get_organisation The organisation requirements.
    get_organisation = function() {
      private$organisation
    },
    #' @field get_rightsholder The default rightsholder.
    get_rightsholder = function() {
      private$rightsholder
    },
    #' @field template A list for a check list template.
    template = function() {
      list(
        community = private$community,
        email = private$email,
        github = private$github,
        funder = private$funder,
        rightsholder = private$rightsholder,
        organisation = private$organisation
      )
    }
  ),
  private = list(
    community = "inbo",
    email = "info@inbo.be",
    funder = "Research Institute for Nature and Forest (INBO)",
    github = "inbo",
    organisation = list(
      "inbo.be" = list(
        affiliation = c(
          en = "Research Institute for Nature and Forest (INBO)",
          nl = "Instituut voor Natuur- en Bosonderzoek (INBO)",
          fr = "Institut de Recherche sur la Nature et les For\u00eats (INBO)",
          de = "Institut f\u00fcr Natur- und Waldforschung (INBO)"
        ),
        orcid = TRUE
      )
    ),
    rightsholder = "Research Institute for Nature and Forest (INBO)"
  )
)

use_first_non_null <- function(...) {
  dots <- list(...)
  vapply(dots, is.null, logical(1)) |>
    xor(TRUE) |>
    which() |>
    head(1) -> selected
  stopifnot(
    "please provide at least one non-NULL element" = length(selected) == 1
  )
  dots[[selected]]
}
