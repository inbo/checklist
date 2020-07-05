#' @title The checklist R6 class
#' @description A class which contains all checklist results.
#' @export
#' @importFrom R6 R6Class
checklist <- R6Class(
  "Checklist",
  public = list(
    #' @description Add results from `lintr::lint_package()`
    #' @param linter A vector with linter errors.
    add_linter = function(linter) {
      private$linter <- linter
      private$checked <- sort(unique(c(private$checked, "lintr")))
      invisible(self)
    },
    #' @description Add results from `rcmdcheck::rcmdcheck`
    #' @param errors A vector with errors.
    #' @param warnings A vector with warning messages.
    #' @param notes A vector with notes.
    add_rcmdcheck = function(errors, warnings, notes) {
      private$errors <- errors
      private$warnings <- warnings
      private$notes <- notes
      private$checked <- sort(unique(c(private$checked, "rcmd")))
      invisible(self)
    },
    #' @description Add allowed warnings and notes
    #' @param warnings A vector with allowed warning messages.
    #' Defaults to `character(0)`.
    #' @param notes A vector with allowed notes.
    #' Defaults to `character(0)`
    allowed = function(warnings = character(0), notes = character(0)) {
      private$allowed_warnings <- warnings
      private$allowed_notes <- notes
      private$checked <- sort(unique(c(private$checked, "checklist")))
      invisible(self)
    },
    #' @description Initialize a new Checklist object.
    #' @param x The path to the root of the package.
    initialize = function(x) {
      private$path <- normalizePath(x, winslash = "/", mustWork = TRUE)
      invisible(self)
    },
    #' @description Print the Checklist object.
    #' @param ... currently ignored.
    print = function(...) {
      output <- c(
        sprintf(
          "%sChecklist summary for the package located at:\n%s",
          private$rules(), private$path
        ),
        private$format_output(
          input = private$warnings, output = private$allowed_warnings,
          type = "allowed", variable = "warning", negate = TRUE
        ),
        private$format_output(
          input = private$warnings, output = private$allowed_warnings,
          type = "new", variable = "warning"
        ),
        private$format_output(
          input = private$allowed_warnings, output = private$warnings,
          type = "missing", variable = "warning"
        ),
        private$format_output(
          input = private$notes, output = private$allowed_notes,
          type = "allowed", variable = "note", negate = TRUE
        ),
        private$format_output(
          input = private$notes, output = private$allowed_notes,
          type = "new", variable = "note"
        ),
        private$format_output(
          input = private$allowed_notes, output = private$notes,
          type = "missing", variable = "note"
        ),
        private$summarise_linter()
      )
      cat(output, sep = private$rules())
      cat(private$rules())
    }
  ),
  active = list(
    #' @field get_checked A vector with checked topics.
    get_checked = function() {
      return(private$checked)
    },
    #' @field get_path The path to the package.
    get_path = function() {
      return(private$path)
    },
    #' @field fail A logical indicating if all checks passed.
    fail = function() {
      required_checks <- c("checklist", "lintr", "rcmd")
      stopifnot(all(private$checked %in% required_checks))
      any(!required_checks %in% private$checked) ||
        length(private$errors) ||
        length(private$linter) ||
        any(!private$warnings %in% private$allowed_warnings) ||
        any(!private$notes %in% private$allowed_notes)
    },
    #' @field template A list for a check list template.
    template = function() {
      key_value <- function(x) {
        list(motivation = "", value = x)
      }
      list(
        description = "Configuration file for checklist::check_pkg()",
        allowed = list(
          warnings = lapply(private$warnings, key_value),
          notes = lapply(private$notes, key_value)
        )
      )
    }
  ),
  private = list(
    path = character(0),
    checked = character(0),
    errors = character(0),
    allowed_warnings = character(0),
    warnings = character(0),
    allowed_notes = character(0),
    notes = character(0),
    linter = list(),
    rules = function(x = "#") {
      nl <- switch(x, "#" = "\n\n", "\n")
      paste(c(nl, rep(x, getOption("width", 80)), nl), collapse = "")
    },
    format_output = function(input, output, type, variable, negate = FALSE) {
      ok <- xor(input %in% output, negate)
      if (all(ok)) {
        return(character(0))
      }
      sprintf(
        "%i %s %s%s\n%s",
        sum(!ok), type, variable, ifelse(sum(!ok) > 1, "s", ""),
        paste(private$rules("-"), input[!ok], collapse = "")
      )
    },
    summarise_linter = function() {
      if (length(private$linter) == 0) {
        return(character(0))
      }
      linter_message <- vapply(private$linter, `[[`, character(1), "message")
      messages <- sort(table(linter_message), decreasing = TRUE)
      messages <- sprintf("%i times \"%s\"", messages, names(messages))
      sprintf(
        "%i linter%s found\n%s%s",
        length(private$linter), ifelse(length(private$linter) > 1, "s", ""),
        private$rules("-"),
        paste(messages, collapse = "\n")
      )
    }
  )
)
