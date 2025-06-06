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
    #' @param name A named vector with the organisation names in one or more
    #'   languages.
    #'   The first item in the vector is the default language.
    #'   The names of the vector must match the language code.
    #' @param email An optional email address for the organisation.
    #'   Used to contact the organisation.
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
    #' @param git The optional root URL to the organisations git repositories.
    #'   The organisation with matching URL in the git remote will be used as
    #'   the primary organisation.
    #' @param ror The optional ROR ID of the organisation.
    #' @param zenodo The optional Zenodo community ID of the organisation.
    initialize = function(
      name,
      email,
      orcid = FALSE,
      rightsholder = c("optional", "single", "shared", "when no other"),
      funder = c("optional", "single", "shared", "when no other"),
      git,
      ror,
      zenodo
    ) {
      private$rightsholder <- match.arg(rightsholder)
      private$funder <- match.arg(funder)
      stopifnot(
        "`email` must be a string" = is.string(email),
        "`email` cannot be NA" = noNA(email),
        "`email` cannot be empty" = email != "",
        "invalid email" = validate_email(email)
      )
      if (grepl("@inbo\\.be$", email)) {
        private$name <- c(
          `nl-BE` = "Instituut voor Natuur- en Bosonderzoek (INBO)",
          `fr-FR` = "Institut de Recherche sur la Nature et les Forêts (INBO)",
          `en-GB` = "Research Institute for Nature and Forest (INBO)",
          `de-DE` = "Institut für Natur- und Waldforschung (INBO)"
        )
        private$email <- "info@inbo.be"
        private$orcid <- TRUE
        private$ror <- "https://ror.org/00j54wy13"
        private$zenodo <- "inbo"
        private$git <- "https://github.com/inbo"
        return(self)
      }
      name <- unlist(name)
      stopifnot(
        "`name` is not character" = is.character(name),
        "`name` must contain at least one value" = length(name) > 0,
        "`name` must have the language as name" = !is.null(names(name)),
        "`name` cannot have empty names" = all(names(name) != ""),
        "`name` cannot have empty values" = noNA(name),
        "`orcid` must be `TRUE` or `FALSE`" = is.flag(orcid),
        "`orcid` must be `TRUE` or `FALSE`" = noNA(orcid)
      )
      private$name <- name
      private$orcid <- orcid
      private$email <- email
      if (!missing(git)) {
        stopifnot(
          "`git` must be a string" = is.string(git),
          "`git` cannot be NA" = noNA(git),
          "`git` must be in https://server/org format" = grepl(
            "^https:\\/\\/[\\w\\.]+\\/\\w+$",
            git,
            perl = TRUE
          )
        )
        private$git <- git
      }
      if (!missing(ror)) {
        stopifnot(
          "`ror` must be a string" = is.string(ror),
          "`ror` cannot be NA" = noNA(ror),
          "`ror` must be in https://ror.org/id format" = grepl(
            "^https:\\/\\/ror\\.org\\/0[a-hj-km-np-tv-z|0-9]{6}[0-9]{2}$",
            ror,
            perl = TRUE
          )
        )
        private$ror <- ror
      }
      if (!missing(zenodo)) {
        stopifnot(
          "`zenodo` must be a string" = is.string(zenodo),
          "`zenodo` cannot be NA" = noNA(zenodo),
          "`zenodo` cannot be empty" = zenodo != ""
        )
        private$zenodo <- zenodo
      }
      return(self)
    },
    #' @description as_person The organisation as a person.
    #' @param lang The language to use for the organisation name.
    #' Defaults to the first language in the `name` vector.
    #' @param role The role of the person in the organisation.
    as_person = function(
      lang = names(private$name)[1],
      role = c("cph", "fnd")
    ) {
      if (!lang %in% names(private$name)) {
        lang <- names(private$name)[1]
      }
      role <- match.arg(role, several.ok = TRUE)
      person(
        given = unname(private$name[lang]),
        family = "",
        email = private$email,
        comment = c(ROR = private$ror)[length(private$ror) > 0],
        role = role
      )
    },
    #' @description Compares the number of matching words with the organisation
    #' name.
    #' Either `Inf` when there is a perfect match.
    #' Otherwise a number between 0 and 1 indicating the ratio of the matching
    #' words with the total number of words in `name`.
    #' A value of 1 means that all words in `name` are present in one of the
    #' organisation names but in a different order.
    #' @param name The name to match.
    compare_by_name = function(name) {
      assert_that(is.string(name), noNA(name))
      if (any(name %in% private$name)) {
        best_match <- unname(private$name[private$name == name])
        attr(best_match, "match") <- Inf
        return(best_match)
      }
      gsub("  ", " ", name) |>
        gsub(pattern = "[-\\(\\)]", replacement = "") |>
        strsplit(split = " ") -> name_split
      gsub("  ", " ", private$name) |>
        gsub(pattern = "[-\\(\\)]", replacement = "") |>
        strsplit(split = " ") -> target_name_split
      vapply(
        target_name_split,
        name_split = name_split[[1]],
        FUN = function(x, name_split) {
          mean(name_split %in% x)
        },
        FUN.VALUE = numeric(1)
      ) -> ratios
      best_match <- unname(private$name[which.max(ratios)])
      attr(best_match, "match") <- max(ratios)
      return(best_match)
    },
    #' @description Print the `org_item` object.
    print = function() {
      c(
        "name",
        sprintf("- %s: %s", names(private$name), private$name),
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
    #' @field get_zenodo The organisation Zenodo community.
    get_zenodo = function() {
      private$zenodo
    },
    #' @field get_default_name The organisation default name.
    get_default_name = function() {
      private$name[1]
    },
    #' @field get_email The organisation email.
    get_email = function() {
      private$email
    },
    #' @field get_funder The funder rules.
    get_funder = function() {
      private$funder
    },
    #' @field get_git The organisational root git URL.
    get_git = function() {
      private$git
    },
    #' @field get_name The organisation names.
    get_name = function() {
      private$name
    },
    #' @field get_orcid The ORCID rules.
    get_orcid = function() {
      private$orcid
    },
    #' @field get_rightsholder The rightsholder rules.
    get_rightsholder = function() {
      private$rightsholder
    }
  ),
  private = list(
    email = character(0),
    git = character(0),
    name = character(0),
    orcid = FALSE,
    ror = character(0),
    zenodo = character(0),
    rightsholder = "single",
    funder = "single"
  )
)
