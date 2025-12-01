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
    #' @param email An email address for the organisation.
    #'   Used to contact the organisation.
    #'   And used to detect if a person is affiliated with the organisation.
    #' @param orcid Whether the organisation requires an ORCID for every person
    #'   that uses this organisation as affiliation.
    #' @param rightsholder The required copyright holder status for the
    #' organisation.
    #' `"optional"` means that the organisation is not required as the copyright
    #' holder.
    #' `"single"` means that the organisation must be the only copyright holder.
    #' `"shared"` means that the organisation must be one of the copyright
    #' holders.
    #' `"when no other"` means that if no other copyright holder is specified,
    #' the organisation must be the copyright holder.
    #' @param funder The required funder status for the organisation.
    #' The categories are the same as for `rightsholder`.
    #' @param ror The optional ROR ID of the organisation.
    #' @param license A list with the allowed licenses by the organisation.
    #' The list may contain the following items:
    #' `package`, `project`, and `data`.
    #' Every item must be a named character vector with the allowed licenses.
    #' The names must match the license name.
    #' The values must either match the path to a license template in the
    #' `checklist` package or an absolute URL to publicly available markdown
    #' file with the license text.
    #' Use `character(0)` to indicate that the organisation does not
    #' require a specific license for that item.
    #' `package` defaults to `c("GPL-3.0", "MIT")`.
    #' `project` defaults to `"CC BY 4.0"`.
    #' `data` defaults to `"CC0 1.0"`.
    #' @param zenodo The optional Zenodo community ID of the organisation.
    #' @param website The optional website URL of the organisation.
    #' @param logo The optional logo URL of the organisation.
    initialize = function(
      name,
      email,
      orcid = FALSE,
      rightsholder = c("optional", "single", "shared", "when no other"),
      funder = c("optional", "single", "shared", "when no other"),
      license = list(
        package = c(
          `GPL-3.0` = paste(
            "https://raw.githubusercontent.com/inbo/checklist/refs/heads/main",
            "inst/generic_template/gplv3.md",
            sep = "/"
          ),
          MIT = paste(
            "https://raw.githubusercontent.com/inbo/checklist/refs/heads/main",
            "inst/generic_template/mit.md",
            sep = "/"
          )
        ),
        project = c(
          `CC BY 4.0` = paste(
            "https://raw.githubusercontent.com/inbo/checklist/refs/heads/main",
            "inst/generic_template/cc_by_4_0.md",
            sep = "/"
          )
        ),
        data = c(
          `CC0` = paste(
            "https://raw.githubusercontent.com/inbo/checklist",
            "131fe5829907079795533bfea767bf7df50c3cfd/inst/generic_template",
            "cc0.md",
            sep = "/"
          )
        )
      ),
      ror = "",
      zenodo = "",
      website = "",
      logo = ""
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
          # fmt: skip
          `fr-FR` =
            "Institut de Recherche sur la Nature et les For\u00eats (INBO)",
          `en-GB` = "Research Institute for Nature and Forest (INBO)",
          `de-DE` = "Institut f\u00fcr Natur- und Waldforschung (INBO)"
        )
        private$email <- "info@inbo.be"
        private$orcid <- TRUE
        private$ror <- "https://ror.org/00j54wy13"
        private$zenodo <- "inbo"
        private$license <- list(
          package = c(
            `GPL-3` = paste(
              "https://raw.githubusercontent.com/inbo/checklist/refs/heads",
              "main/inst/generic_template/gplv3.md",
              sep = "/"
            ),
            MIT = paste(
              "https://raw.githubusercontent.com/inbo/checklist/refs/heads",
              "main/inst/generic_template/mit.md",
              sep = "/"
            )
          ),
          project = c(
            `CC BY 4.0` = paste(
              "https://raw.githubusercontent.com/inbo/checklist/refs/heads",
              "main/inst/generic_template/cc_by_4_0.md",
              sep = "/"
            )
          ),
          data = c(
            `CC0` = paste(
              "https://raw.githubusercontent.com/inbo/checklist",
              "131fe5829907079795533bfea767bf7df50c3cfd/inst/generic_template",
              "cc0.md",
              sep = "/"
            )
          )
        )
        private$website <- "https://www.vlaanderen.be/inbo/en-gb"
        private$logo <- paste0(
          "https://inbo.github.io/checklist/reference/figures/logo-en.png"
        )
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
        "`orcid` cannot be `NA`" = noNA(orcid)
      )
      validate_license(license)
      private$name <- name
      private$orcid <- orcid
      private$email <- email
      private$license <- license
      if (zenodo != "") {
        stopifnot(
          "`zenodo` must be a string" = is.string(zenodo),
          "`zenodo` cannot be NA" = noNA(zenodo)
        )
        private$zenodo <- zenodo
      }
      private$ror <- set_non_empty(
        ror,
        validate_ror,
        "`ror` must be in https://ror.org/id format"
      )
      private$website <- set_non_empty(
        website,
        validate_url,
        "Please enter a valid website URL."
      )
      private$logo <- set_non_empty(
        logo,
        validate_url,
        "Please enter a valid logo URL."
      )
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
        comment = c(ROR = private$ror)[nchar(private$ror) > 0],
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
    #' @description Get the organisation license.
    #' @param type The type of license to get.
    #' Can be one of `"package"`, `"project"`, or `"data"`.
    #' Defaults to `"package"`.
    #' @return A named character vector with the allowed licenses.
    get_license = function(type = c("package", "project", "data", "all")) {
      type <- match.arg(type)
      if (type == "all") {
        available <- unlist(unname(private$license))
        return(available[unique(names(available))])
      }
      private$license[[type]]
    },
    #' @description The pkgdown author field.
    #' @param lang The language to use for the organisation name.
    get_pkgdown = function(lang) {
      if (private$website == "" && private$logo == "") {
        return(NULL)
      }
      lang <- ifelse(
        lang %in% names(private$name),
        lang,
        names(private$name)[1]
      )
      org_name <- private$name[lang]
      sprintf("  %s:", org_name) |>
        c(
          sprintf("    href: \"%s\"", private$website)[private$website != ""],
          sprintf(
            "    html: \"<img src='%s' height=24 alt='%s'>\"",
            private$logo,
            org_name
          )[private$logo != ""]
        ) |>
        paste(collapse = "\n")
    },
    #' @description Print the `org_item` object.
    print = function() {
      c(
        "name",
        sprintf("- %s: %s", names(private$name), private$name),
        sprintf("email: %s", private$email),
        sprintf("ROR: %s", private$ror)[nchar(private$ror) > 0],
        "ORCID is required"[private$orcid],
        sprintf("zenodo community: %s", private$zenodo)[
          nchar(private$zenodo) > 0
        ],
        sprintf("website: %s", private$website)[nchar(private$website) > 0],
        sprintf("logo: %s", private$logo)[nchar(private$logo) > 0],
        sprintf("copyright holder: %s", private$rightsholder),
        sprintf("funder: %s", private$funder),
        "allowed licenses:",
        vapply(
          names(private$license),
          FUN.VALUE = character(1),
          license = private$license,
          FUN = function(x, license) {
            if (length(license[[x]]) == 0) {
              return(sprintf("- %s: no requirements", x))
            }
            names(license[[x]]) |>
              paste(collapse = " or ") |>
              sprintf(fmt = "- %2$s: %1$s", x)
          }
        )
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
        website = private$website[nchar(private$website) > 0],
        logo = private$logo[nchar(private$logo) > 0],
        ror = private$ror[nchar(private$ror) > 0],
        orcid = private$orcid,
        zenodo = private$zenodo,
        rightsholder = private$rightsholder,
        funder = private$funder,
        license = lapply(private$license, as.list)
      )
      relevant <- lengths(organisation) > 0
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
    license = list(),
    name = character(0),
    orcid = FALSE,
    ror = character(0),
    zenodo = character(0),
    rightsholder = "single",
    funder = "single",
    website = "",
    logo = ""
  )
)

validate_license <- function(license) {
  stopifnot(
    "`license` must be a list" = inherits(license, "list"),
    # fmt:skip
    "`license` must contain `package`, `project`, and `data`" =
      all(c("package", "project", "data") %in% names(license)),
    "`license` must contain character vectors" = all(
      vapply(license, is.character, FUN.VALUE = logical(1))
    ),
    "`license` must contain named vectors" = all(
      vapply(
        license,
        function(x) {
          length(x) == 0 || (!is.null(names(x)) && all(names(x) != ""))
        },
        FUN.VALUE = logical(1)
      )
    ),
    "`license` must contain uniquely named vectors" = all(
      vapply(
        license,
        function(x) {
          length(x) == 0 || anyDuplicated(names(x)) == 0
        },
        FUN.VALUE = logical(1)
      )
    ),
    "`license` must contain vectors with unique licenses" = all(
      vapply(
        license,
        function(x) {
          length(x) == 0 || anyDuplicated(x) == 0
        },
        FUN.VALUE = logical(1)
      )
    )
  )
}

set_non_empty <- function(x, fun, prompt) {
  if (x == "") {
    return(x)
  }
  fun(x) |>
    setNames(prompt) |>
    stopifnot()
  return(x)
}
