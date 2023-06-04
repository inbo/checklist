#' @title The organisation R6 class
#' @description A class with the organisation defaults
#' @export
#' @importFrom R6 R6Class
#' @family class
organisation <- R6Class(
  "organisation",
  public = list(
    #' @description Initialize a new `organisation` object.
    initialize = function() {
      invisible(self)
    },
    #' @description Print the `organisation` object.
    #' @param ... currently ignored.
    print = function(...) {
      dots <- list(...)
      c(
        "rightsholder:  %s", "funder:        %s", "organisation email:  %s",
        "GitHub organisation: %s", "email domain settings"
      ) |>
        paste(collapse = "\n") |>
        sprintf(
          self$get_rightsholder, self$get_funder, self$get_email,
          self$get_github
        ) |>
        cat()
      org <- self$get_organisation
      for (domain in names(org)) {
        cat(
          "\n-", domain, "\n  mandatory ORCID iD"[org[[domain]]$orcid],
          "\n  affiliations",
          sprintf(
            "\n    %s: %s", names(org[[domain]]$affiliation),
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
        given = private$rightsholder, email = private$email,
        role = c("cph", "fnd")
      )
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
    }
  ),
  private = list(
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
