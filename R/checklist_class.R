#' @title The checklist R6 class
#' @description A class which contains all checklist results.
#' @export
#' @importFrom R6 R6Class
checklist <- R6Class(
  "Checklist",
  public = list(
    #' @description Add errors
    #' @param errors A vector with errors.
    #' @param item The item on which to store the errors.
    add_error = function(errors, item) {
      private$errors[[item]] <- errors
      private$checked <- sort(unique(c(private$checked, item)))
      invisible(self)
    },
    #' @description Add results from `lintr::lint_package()`
    #' @param linter A vector with linter errors.
    add_linter = function(linter) {
      private$linter <- linter
      private$checked <- sort(unique(c(private$checked, "lintr")))
      invisible(self)
    },
    #' @description Add motivation for allowed issues.
    #' @param which Which kind of issue to add.
    add_motivation = function(which = c("warnings", "notes")) {
      which <- match.arg(which)
      allowed <- get(paste0("allowed_", which), envir = private)
      value <- private$extract(allowed)
      motivation <- private$extract(allowed, "motivation")
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
    #' @description Add results from `rcmdcheck::rcmdcheck`
    #' @param errors A vector with errors.
    #' @param warnings A vector with warning messages.
    #' @param notes A vector with notes.
    add_rcmdcheck = function(errors, warnings, notes) {
      self$add_error(errors, "R CMD check")
      private$warnings <- warnings
      private$notes <- notes
      private$checked <- sort(unique(c(private$checked, "R CMD check")))
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
      private$allowed_warnings <- warnings
      private$allowed_notes <- notes
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
    #' @description Initialize a new Checklist object.
    #' @param x The path to the root of the package.
    initialize = function(x) {
      private$path <- normalizePath(x, winslash = "/", mustWork = TRUE)
      invisible(self)
    },
    #' @field package A logical indicating whether the source code refers to a
    #' package.
    package = TRUE,
    #' @description Print the Checklist object.
    #' @param ... currently ignored.
    print = function(...) {
      output <- c(
        sprintf(
          "%sChecklist summary for the package located at:\n%s",
          private$rules(), private$path
        ),
        private$format_output(
          input = private$warnings,
          output = private$extract(private$allowed_warnings),
          motivation = private$extract(
            private$allowed_warnings, "motivation", "\nmotivation: "
          ),
          type = "allowed", variable = "warning", negate = TRUE
        ),
        private$format_output(
          input = private$warnings,
          output = private$extract(private$allowed_warnings),
          type = "new", variable = "warning"
        ),
        private$format_output(
          input = private$extract(private$allowed_warnings),
          output = private$warnings,
          motivation = private$extract(
            private$allowed_warnings, "motivation", "\nmotivation: "
          ),
          type = "missing", variable = "warning"
        ),
        private$format_output(
          input = private$notes,
          output = private$extract(private$allowed_notes),
          motivation = private$extract(
            private$allowed_notes, "motivation", "\nmotivation: "
          ),
          type = "allowed", variable = "note", negate = TRUE
        ),
        private$format_output(
          input = private$notes,
          output = private$extract(private$allowed_notes),
          type = "new", variable = "note"
        ),
        private$format_output(
          input = private$extract(private$allowed_notes),
          output = private$notes,
          motivation = private$extract(
            private$allowed_notes, "motivation", "\nmotivation: "
          ),
          type = "missing", variable = "note"
        ),
        private$summarise_linter(),
        private$format_error()
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
      required_checks <- list(
        always = c("checklist", "filename conventions", "lintr"),
        package = c("DESCRIPTION", "documentation", "R CMD check")
      )
      required_checks <- unlist(required_checks[c(TRUE, self$package)])
      stopifnot(all(private$checked %in% required_checks))
      errors <- vapply(private$errors, length, integer(1))
      any(!required_checks %in% private$checked) ||
        any(errors > 0) ||
        length(private$linter) ||
        any(!private$warnings %in% private$extract(private$allowed_warnings)) ||
        any(!private$notes %in% private$extract(private$allowed_notes))
    },
    #' @field template A list for a check list template.
    template = function() {
      list(
        description = "Configuration file for checklist::check_pkg()",
        package = self$package,
        allowed = list(
          warnings = private$allowed_warnings,
          notes = private$allowed_notes
        )
      )
    }
  ),
  private = list(
    path = character(0),
    checked = character(0),
    errors = list(),
    allowed_warnings = list(),
    warnings = character(0),
    allowed_notes = list(),
    notes = character(0),
    linter = list(),
    extract = function(x, name = "value", prefix = rep("", length(x))) {
      paste0(prefix, vapply(x, `[[`, character(1), name))
    },
    rules = function(x = "#") {
      nl <- switch(x, "#" = "\n\n", "\n")
      paste(c(nl, rep(x, getOption("width", 80)), nl), collapse = "")
    },
    format_output = function(
      input, output, motivation = rep("", length = length(input)), type,
      variable, negate = FALSE
    ) {
      ok <- xor(input %in% output, negate)
      if (all(ok)) {
        return(character(0))
      }
      sprintf(
        "%i %s %s%s\n%s",
        sum(!ok), type, variable, ifelse(sum(!ok) > 1, "s", ""),
        paste(private$rules("-"), input[!ok], motivation[!ok], collapse = "")
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
        "%i linter%s found.
`styler::style_file()` can fix some problems automatically. \n%s%s",
        length(private$linter), ifelse(length(private$linter) > 1, "s", ""),
        private$rules("-"),
        paste(messages, collapse = "\n")
      )
    },
    format_error = function() {
      error_length <- vapply(private$errors, length, integer(1))
      vapply(
        names(private$errors)[error_length > 0],
        function(x) {
          sprintf(
            "%s: %i error%s%s",
            x, length(private$errors[[x]]),
            ifelse(length(private$errors[[x]]) > 1, "s", ""),
            paste(private$rules("-"), private$errors[[x]], collapse = "")
          )
        },
        character(1)
      )
    }
  )
)
