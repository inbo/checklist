#' A function that asks a yes or no question to the user
#' @author Hadley Wickham <Hadley@Rstudio.com>
#' Largely based on `devtools:::yesno()`.
#' The user gets three options in an random order: 2 for "no", 1 for "yes".
#' The wording for "yes" and "no" is random as well.
#' This forces the user to carefully read the question.
#' @param ... Currently ignored
#' @return A logical where `TRUE` implies a "yes" answer from the user.
#' @export
#' @importFrom utils menu
#' @family utils
yesno <- function(...) {
  stopifnot(interactive())
  yeses <- c(
    "Yes",
    "Definitely",
    "For sure",
    "Yup",
    "Yeah",
    "Of course",
    "Absolutely"
  )
  nos <- c("No way", "Not yet", "I forget", "No", "Nope", "Uhhhh... Maybe?")

  cat(paste0(..., collapse = ""))
  qs <- c(sample(yeses, 1), sample(nos, 2))
  rand <- sample(length(qs))

  menu(qs[rand]) == which(rand == 1)
}

#' Check if the current working directory of a repo is clean
#'
#' A clean working directory has no staged, unstaged or untracked files.
#' @inheritParams gert::git_status
#' @return `TRUE` when there are no staged, unstaged or untracked files.
#' Otherwise `FALSE`
#' @export
#' @importFrom gert git_status
#' @family git
is_workdir_clean <- function(repo) {
  status <- git_status(repo = repo)
  status <- status[!(status$status == "new" & !status$staged), ]
  status <- as.data.frame(status)
  identical(
    status,
    data.frame(file = character(0), status = character(0), staged = logical(0))
  )
}

#' @importFrom assertthat on_failure<-
on_failure(is_workdir_clean) <- function(call, env) {
  "Working directory is not clean. Please commit or stash changes first."
}

#' Check if a vector contains valid email
#'
#' It only checks the format of the text, not if the email address exists.
#' @param email A vector with email addresses.
#' @return A logical vector.
#' @export
#' @importFrom assertthat assert_that
#' @family utils
validate_email <- function(email) {
  assert_that(is.character(email))
  # expression taken from https://emailregex.com/
  grepl(
    paste0(
      "(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"",
      "(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|",
      "\\[\x01-\x09\x0b\x0c\x0e-\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*",
      "[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|",
      "2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9]",
      "[0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a",
      "\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\\])"
    ),
    tolower(email)
  )
}

checklist_extract <- function(x, name = "value", prefix = rep("", length(x))) {
  paste0(prefix, vapply(x, `[[`, character(1), name))
}

checklist_format_error <- function(errors) {
  error_length <- lengths(errors)
  vapply(
    names(errors)[error_length > 0],
    function(x) {
      sprintf(
        "%s: %i error%s%s",
        x,
        length(errors[[x]]),
        ifelse(length(errors[[x]]) > 1, "s", ""),
        paste(rules("-"), errors[[x]], collapse = "")
      )
    },
    character(1)
  )
}

checklist_format_output <- function(
  input,
  output,
  motivation = rep("", length = length(input)),
  type,
  variable,
  negate = FALSE
) {
  ok <- xor(input %in% output, negate)
  if (all(ok)) {
    return(character(0))
  }
  sprintf(
    "%i %s %s%s\n%s",
    sum(!ok),
    type,
    variable,
    ifelse(sum(!ok) > 1, "s", ""),
    paste(rules("-"), input[!ok], motivation[!ok], collapse = "")
  )
}

#' @importFrom sessioninfo session_info
checklist_print <- function(
  path,
  warnings,
  allowed_warnings,
  notes,
  allowed_notes,
  linter,
  errors,
  spelling,
  package,
  failed
) {
  print(session_info())
  output <- c(
    sprintf(
      "%sChecklist summary for the package located at:\n%s",
      rules(),
      path
    ),
    checklist_format_output(
      input = warnings,
      output = checklist_extract(allowed_warnings),
      motivation = checklist_extract(
        allowed_warnings,
        "motivation",
        "\nmotivation: "
      ),
      type = "allowed",
      variable = "warning",
      negate = TRUE
    ),
    checklist_format_output(
      input = warnings,
      output = checklist_extract(allowed_warnings),
      type = "new",
      variable = "warning"
    ),
    checklist_format_output(
      input = checklist_extract(allowed_warnings),
      output = warnings,
      motivation = checklist_extract(
        allowed_warnings,
        "motivation",
        "\nmotivation: "
      ),
      type = "missing",
      variable = "warning"
    ),
    checklist_format_output(
      input = notes,
      output = checklist_extract(allowed_notes),
      motivation = checklist_extract(
        allowed_notes,
        "motivation",
        "\nmotivation: "
      ),
      type = "allowed",
      variable = "note",
      negate = TRUE
    ),
    checklist_format_output(
      input = notes,
      output = checklist_extract(allowed_notes),
      type = "new",
      variable = "note"
    ),
    checklist_format_output(
      input = checklist_extract(allowed_notes),
      output = notes,
      motivation = checklist_extract(
        allowed_notes,
        "motivation",
        "\nmotivation: "
      ),
      type = "missing",
      variable = "note"
    ),
    checklist_diff(path),
    checklist_summarise_linter(linter),
    checklist_summarise_spelling(spelling),
    checklist_format_error(errors)
  )
  cat(output, sep = rules())
  cat(rules())
  if (failed) {
    c(
      "",
      sprintf(
        paste(
          "You can allow certain warnings and notes via",
          "`write_checklist(check_%s())`"
        ),
        ifelse(package, "package", "project")
      ),
      "You need to run this too in case of missing warnings or notes.",
      "Because a missing warning or note is considered an error."
    ) |>
      cat(sep = "\n")
    cat(rules())
  }
}

checklist_summarise_linter <- function(linter) {
  if (length(linter) == 0) {
    return(character(0))
  }
  linter_message <- vapply(linter, `[[`, character(1), "message")
  messages <- c_sort(table(linter_message), decreasing = TRUE)
  messages <- sprintf("%i times \"%s\"", messages, names(messages))
  sprintf(
    "%i linter%s found.
`styler::style_file()` can fix some problems automatically. \n%s%s",
    length(linter),
    ifelse(length(linter) > 1, "s", ""),
    rules("-"),
    paste(messages, collapse = "\n")
  )
}

checklist_summarise_spelling <- function(spelling) {
  if (nrow(spelling) == 0) {
    return(character(0))
  }

  messages <- vapply(
    unique(spelling$language),
    FUN.VALUE = character(1),
    spelling = spelling,
    FUN = function(i, spelling) {
      sprintf(
        "Potential spelling errors for `%s`\nWords:\n%s\nFiles:\n%s",
        i,
        paste(
          c_sort(
            as.character(unique(spelling$message[spelling$language == i]))
          ),
          collapse = ", "
        ),
        paste(
          c_sort(as.character(unique(spelling$file[spelling$language == i]))),
          collapse = "\n"
        )
      )
    }
  )
  paste(messages, collapse = rules("-"))
}

checklist_template <- function(package, warnings, notes, spelling, required) {
  template <- list(
    description = "Configuration file for checklist::check_pkg()",
    package = package,
    allowed = list(warnings = warnings, notes = notes),
    required = required
  )
  spelling$root <- NULL
  if (length(spelling$ignore) == 0) {
    spelling$ignore <- NULL
  }
  if (length(spelling$other) == 0) {
    spelling$other <- NULL
  }
  template$spelling <- spelling
  return(template)
}

rules <- function(x = "#", nl = "\n") {
  assert_that(is.string(nl), noNA(nl))
  paste(c(nl, rep(x, getOption("width", 80)), nl), collapse = "")
}

quiet_cat <- function(x, quiet = FALSE, ...) {
  if (!quiet) {
    cat(x, ...)
  }
}

#' Determine if a directory is in a git repository
#'
#' The path arguments specifies the directory at which to start the search for
#' a git repository.
#' If it is not a git repository itself, then its parent directory is consulted,
#' then the parent's parent, and so on.
#' @inheritParams gert::git_find
#' @importFrom gert git_find
#' @return TRUE if directory is in a git repository else FALSE
#' @export
#' @family git
is_repository <- function(path = ".") {
  out <- tryCatch(git_find(path = path), error = function(e) e)
  !any(class(out) == "error")
}


#' Pass command lines to a shell
#'
#' Cross-platform function to pass a command to the shell, using either
#' [base::system()] or (Windows-only) `base::shell()`, depending on the
#' operating system.
#'
#' @param commandstring
#' The system command to be invoked, as a string.
#' Multiple commands can be combined in this single string, e.g. with a
#' multiline string.
#' @param path The path from where the command string needs to be executed
#' @param ... Other arguments passed to [base::system()] or
#' `base::shell()`.
#'
#' @inheritParams base::system
#' @family utils
#' @importFrom withr defer
#' @export
execshell <- function(commandstring, intern = FALSE, path = ".", ...) {
  old_wd <- setwd(path)
  defer(setwd(old_wd))

  if (.Platform$OS.type == "windows") {
    res <- shell(commandstring, intern = TRUE, ...) # nolint
  } else {
    res <- system(commandstring, intern = TRUE, ...)
  }
  if (!intern) {
    if (length(res) > 0) {
      cat(res, sep = "\n")
    } else {
      return(invisible())
    }
  } else {
    return(res)
  }
}


#' Check if a file is tracked and not modified
#'
#' @param file path relative to the git root directory.
#' @param repo path to the repository
#'
#' @importFrom gert git_status git_ls
#' @importFrom assertthat assert_that is.string
#'
#' @noRd
is_tracked_not_modified <- function(file, repo = ".") {
  assert_that(is.string(file))
  tracked <- try(git_ls(repo = repo), silent = TRUE)
  if (inherits(tracked, "try-error")) {
    if (grepl("could not find repository", tracked)) {
      return(TRUE)
    }
    stop(tracked)
  }
  is_tracked <- file %in% tracked$path
  status <- git_status(repo = repo)
  is_not_modified <- !file %in% status$file[status$status == "modified"]
  return(is_tracked && is_not_modified)
}

#' @importFrom gert git_branch_list git_diff git_info
#' @importFrom cli cli_h1 cli_text col_green col_red
checklist_diff <- function(root) {
  if (inherits(try(git_info(repo = root), silent = TRUE), "try-error")) {
    return(invisible(NULL))
  }
  changes <- git_diff(repo = root)
  if (length(changes) == 0) {
    return(invisible(NULL))
  }
  cli_h1("unstaged changes")
  changes$patch |>
    gsub(pattern = "^.*?index.*?\n.*?\n", replacement = "") |>
    strsplit(split = "\n") |>
    unlist() -> changes
  changes <- changes[grepl("^[\\+-]", changes)]
  display_col <- character(length(changes))
  files <- grepl("^\\+\\+\\+ b/", changes)
  display_col[!files & grepl("^\\+", changes)] <- "green"
  display_col[grepl("^\\-", changes)] <- "red"
  vapply(
    seq_along(display_col),
    FUN.VALUE = logical(1),
    display_col = display_col,
    changes = changes,
    FUN = function(i, display_col, changes) {
      switch(
        display_col[i],
        "red" = col_red(changes[i]),
        "green" = col_green(changes[i]),
        cli_text(changes[i])
      ) |>
        cat(sep = "\n")
      return(TRUE)
    }
  )
  return(invisible(NULL))
}
