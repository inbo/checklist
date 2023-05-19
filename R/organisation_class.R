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
      c("rightsholder: %s", "funder:       %s", "email domain settings") |>
        paste(collapse = "\n") |>
        sprintf(self$get_rightsholder, self$get_funder) |>
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
    #' @field get_funder The default funder.
    get_funder = function() {
      private$funder
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
    funder = "Research Institute for Nature and Forest (INBO)",
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
