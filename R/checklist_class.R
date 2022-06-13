#' @title The checklist R6 class
#' @description A class which contains all checklist results.
#' @export
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom R6 R6Class
#' @family class
checklist <- R6Class(

  "checklist",

  inherit = spelling,
  public = list(

    #' @description Add errors
    #' @param errors A vector with errors.
    #' @param item The item on which to store the errors.
    add_error = function(errors, item) {
      assert_that(is.character(errors), noNA(errors))
      assert_that(is.string(item), noNA(item))
      private$errors[[item]] <- errors
      private$checked <- sort(unique(c(private$checked, item)))
      invisible(self)
    },

    #' @description Add results from `lintr::lint_package()`
    #' @param linter A vector with linter errors.
    add_linter = function(linter) {
      assert_that(inherits(linter, "lints"))
      private$linter <- linter
      private$checked <- sort(unique(c(private$checked, "lintr")))
      invisible(self)
    },

    #' @description Add motivation for allowed issues.
    #' @param which Which kind of issue to add.
    add_motivation = function(which = c("warnings", "notes")) {
      which <- match.arg(which)
      allowed <- get(paste0("allowed_", which), envir = private)
      value <- checklist_extract(allowed)
      motivation <- checklist_extract(allowed, "motivation")
      current <- get(which, envir = private)
      keep <- current %in% value
      new_motivation <- vapply(
        seq_along(current)[!keep],
        function(i) {
          message(current[i])
          ifelse(
            yesno("Motivated why to allow this ", which, "?"),
            readline(prompt = "Motivation: "),
            ""
          )
        },
        character(1)
      )
      extra <- new_motivation != ""
      new_motivation <- c(motivation, new_motivation[extra])
      new_allowed <- c(value, current[!keep][extra])
      new_allowed <- lapply(
        order(new_allowed),
        function(i) {
          list(motivation = new_motivation[i], value = new_allowed[i])
        }
      )
      assign(paste0("allowed_", which), new_allowed, envir = private)
      invisible(self)
    },

    #' @description Add notes
    #' @param notes A vector with notes.
    add_notes = function(notes) {
      assert_that(is.character(notes), noNA(notes))
      private$notes <- unique(c(private$notes, remove_fancy_quotes(notes)))
      invisible(self)
    },

    #' @description Add results from `rcmdcheck::rcmdcheck`
    #' @param errors A vector with errors.
    #' @param warnings A vector with warning messages.
    #' @param notes A vector with notes.
    add_rcmdcheck = function(errors, warnings, notes) {
      self$add_error(errors, "R CMD check")
      self$add_warnings(remove_fancy_quotes(warnings))
      self$add_notes(remove_fancy_quotes(notes))
      invisible(self)
    },

    #' @description Add warnings
    #' @param warnings A vector with warnings.
    add_warnings = function(warnings) {
      assert_that(is.character(warnings), noNA(warnings))
      private$warnings <- unique(
        c(private$warnings, remove_fancy_quotes(warnings))
      )
      invisible(self)
    },

    #' @description Add allowed warnings and notes
    #' @param warnings A vector with allowed warning messages.
    #' Defaults to an empty list.
    #' @param notes A vector with allowed notes.
    #' Defaults to an empty list.
    #' @param package Does the check list refers to a package.
    #' Defaults to `TRUE`.
    allowed = function(
      warnings = vector(mode = "list", length = 0),
      notes = vector(mode = "list", length = 0)
    ) {
      assert_that(inherits(warnings, "list"))
      assert_that(inherits(notes, "list"))
      private$allowed_warnings <- remove_fancy_quotes(warnings)
      private$allowed_notes <- remove_fancy_quotes(notes)
      private$checked <- sort(unique(c(private$checked, "checklist")))
      invisible(self)
    },

    #' @description Confirm the current motivation for allowed issues.
    #' @param which Which kind of issue to confirm.
    confirm_motivation = function(which = c("warnings", "notes")) {
      which <- match.arg(which)
      current <- get(paste0("allowed_", which), envir = private)
      selection <- vapply(
        seq_along(current),
        function(i) {
          message(current[[i]]$value, "\nMotivation: ", current[[i]]$motivation)
          yesno("Keep this motivation?")
        },
        logical(1)
      )
      assign(paste0("allowed_", which), current[selection], envir = private)
      invisible(self)
    },

    #' @description Initialize a new `checklist` object.
    #' @param x The path to the root of the project.
    #' @param language The default language for spell checking.
    #' @importFrom fs is_dir path_real
    initialize = function(x = ".", language) {
      assert_that(is.string(x), noNA(x))
      x <- path_real(x)
      assert_that(is_dir(x))
      private$path <- x
      super$initialize(language = language, base_path = private$path)
      invisible(self)
    },

    #' @field package A logical indicating whether the source code refers to a
    #' package.
    package = TRUE,

    #' @description Print the `checklist` object.
    #' @param ... currently ignored.
    print = function(...) {
      dots <- list(...)
      if (!is.null(dots$quiet) && dots$quiet) {
        return(invisible(NULL))
      }
      cat("Spell checking settings\n\n")
      super$print(...)
      cat("\n\n")
      checklist_print(
        path = private$path,
        warnings = private$warnings,
        allowed_warnings = private$allowed_warnings,
        notes = private$notes,
        allowed_notes = private$allowed_notes,
        linter = private$linter,
        errors = private$errors
      )
    },

    #' @description set roles
    #' @param roles A vector with roles.
    set_roles = function(roles) {
      assert_that(is.character(roles), noNA(roles))
      private$roles <- sort(unique(roles))
      invisible(self)
    },

    #' @description Update the keywords.
    #' @param keywords a character vector with the new keywords.
    #' The default empty vector (`character(0)`) will erase the keywords.
    update_keywords = function(keywords = character(0)) {
      assert_that(inherits(keywords, "character"))
      private$keywords <- sort(keywords)
      invisible(self)
    }
  ),

  active = list(

    #' @field get_checked A vector with checked topics.
    get_checked = function() {
      return(private$checked)
    },

    #' @field get_keywords A vector with keywords.
    get_keywords = function() {
      return(private$keywords)
    },

    #' @field get_path The path to the package.
    get_path = function() {
      return(private$path)
    },

    #' @field get_roles The roles to select contributors for the CITATION.
    get_roles = function() {
      return(private$roles)
    },

    #' @field fail A logical indicating if all checks passed.
    fail = function() {
      required_checks <- list(
        always = c("checklist", "filename conventions", "lintr"),
        package = c(
          "CITATION", "DESCRIPTION", "documentation", "R CMD check", "codemeta",
          "license", "CITATION.cff", ".zenodo.json", "repository secret"
        )
      )
      required_checks <- unlist(required_checks[c(TRUE, self$package)])
      assert_that(
        all(private$checked %in% required_checks),
        msg = "Something went wrong while checking your package.
Please contact the maintainer of the `checklist` package."
      )
      errors <- vapply(private$errors, length, integer(1))
      any(!required_checks %in% private$checked) ||
        any(errors > 0) ||
        length(private$linter) ||
        any(
          !private$warnings %in% checklist_extract(private$allowed_warnings)
        ) ||
        any(!private$notes %in% checklist_extract(private$allowed_notes))
    },

    #' @field template A list for a check list template.
    template = function() {
      checklist_template(
        package = self$package, warnings = private$allowed_warnings,
        notes = private$allowed_notes, citation_roles = private$roles,
        keywords = private$keywords, spelling = super$settings
      )
    }
  ),

  private = list(
    allowed_notes = list(),
    allowed_warnings = list(),
    checked = character(0),
    errors = list(),
    keywords = character(0),
    linter = structure(list(), class = "lints", path = "."),
    notes = character(0),
    path = character(0),
    roles = c("aut", "cre"),
    warnings = character(0)
  )
)

remove_fancy_quotes <- function(x) {
  single_quotation <- "(\u2018|\u2019)"
  if (inherits(x, "character")) {
    return(gsub(single_quotation, "'", x))
  }
  for (i in seq_along(x)) {
    x[[i]][["value"]] <- gsub(single_quotation, "'", x[[i]][["value"]])
  }
  return(x)
}
