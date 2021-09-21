#' A function that asks a yes or no question to the user
#' @author Hadley Wickham <hadley@rstudio.com>
#' Largely based on devtools:::yesno().
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
    "Yes", "Definitely", "For sure", "Yup", "Yeah", "Of course", "Absolutely"
  )
  nos <- c("No way", "Not yet", "I forget", "No", "Nope", "Uhhhh... Maybe?")

  cat(paste0(..., collapse = ""))
  qs <- c(sample(yeses, 1), sample(nos, 2))
  rand <- sample(length(qs))

  menu(qs[rand]) == which(rand == 1)
}

#' Check if the current workdir of a repo is clean
#'
#' A clean working directory has no staged, unstaged or untracked files.
#' @inheritParams gert::git_status
#' @return `TRUE` when there are no staged, unstaged or untracked files.
#' Otherwise `FALSE`
#' @export
#' @importFrom gert git_status
#' @family utils
is_workdir_clean <- function(repo) {
  status <- git_status(repo = repo)
  status <- status[!(status$status == "new" & !status$staged), ]
  status <- as.data.frame(status)
  identical(
    status,
    data.frame(file = character(0),
               status = character(0),
               staged = logical(0))
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
      "2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9]", #nolint
      "[0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a",
      "\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\\])"
    ),
    tolower(email)
  )
}

#' Convert an ORCID to a `person` object.
#'
#' This function requires that your `ORCID_TOKEN` is set as an environment
#' variable.
#' First run `rorcid::orcid_auth()`.
#' A browser window should open where you can log into `ORCID`.
#' Run `rorcid::orcid_auth()`, which should return something like
#' `"Bearer dc0a6b6b-b4d4-4276-bc89-78c1e9ede56e"`.
#' Copy this (not the `Bearer` part) and append it to your `.Renviron` as
#' follows: `ORCID_TOKEN=dc0a6b6b-b4d4-4276-bc89-78c1e9ede56e`.
#' Don't forget to append your UUID instead of the example given here.
#' @param orcid The ORCID of the person.
#' @param email An optional email of the person.
#' Require when the ORCID record does not contain a public email.
#' @param role The role of the person.
#' See `utils::person` for all possible values.
#' @export
#' @importFrom assertthat assert_that is.string
#' @importFrom rorcid as.orcid
#' @importFrom utils person
#' @family utils
orcid2person <- function(orcid, email, role = c("aut", "cre")) {
  assert_that(is.string(orcid))
  assert_that(
    nchar(orcid) == 19,
    msg = "Please provide `orcid` in the `0000-0000-0000-0000` format."
  )
  assert_that(
    Sys.getenv("ORCID_TOKEN") != "",
    msg = "Please set ORCID_TOKEN. See ?orcid2person for instructions."
  )
  details <- as.orcid(orcid)
  if (missing(email)) {
    email <- details[[1]]$emails$email
    assert_that(
      length(email) > 0,
      msg = "No public email found at ORCID. Please provide `email`."
    )
    email <- head(email$email, 1)
  }
  assert_that(is.string(email))
  assert_that(validate_email(email))

  person(
    given = details[[1]]$name$`given-names`$value,
    family = details[[1]]$name$`family-name`$value,
    email = tolower(email),
    role = role,
    comment = c(ORCID = orcid)
  )
}

checklist_extract <- function(x, name = "value", prefix = rep("", length(x))) {
  paste0(prefix, vapply(x, `[[`, character(1), name))
}

checklist_format_error <- function(errors) {
  error_length <- vapply(errors, length, integer(1))
  vapply(
    names(errors)[error_length > 0],
    function(x) {
      sprintf(
        "%s: %i error%s%s",
        x, length(errors[[x]]),
        ifelse(length(errors[[x]]) > 1, "s", ""),
        paste(rules("-"), errors[[x]], collapse = "")
      )
    },
    character(1)
  )
}

checklist_format_output <- function(
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
    paste(rules("-"), input[!ok], motivation[!ok], collapse = "")
  )
}

#' @importFrom sessioninfo session_info
checklist_print <- function(
  path, warnings, allowed_warnings, notes, allowed_notes, linter, errors
) {
  print(session_info())
  output <- c(
    sprintf(
      "%sChecklist summary for the package located at:\n%s",
      rules(), path
    ),
    checklist_format_output(
      input = warnings,
      output = checklist_extract(allowed_warnings),
      motivation = checklist_extract(
        allowed_warnings, "motivation", "\nmotivation: "
      ),
      type = "allowed", variable = "warning", negate = TRUE
    ),
    checklist_format_output(
      input = warnings,
      output = checklist_extract(allowed_warnings),
      type = "new", variable = "warning"
    ),
    checklist_format_output(
      input = checklist_extract(allowed_warnings),
      output = warnings,
      motivation = checklist_extract(
        allowed_warnings, "motivation", "\nmotivation: "
      ),
      type = "missing", variable = "warning"
    ),
    checklist_format_output(
      input = notes,
      output = checklist_extract(allowed_notes),
      motivation = checklist_extract(
        allowed_notes, "motivation", "\nmotivation: "
      ),
      type = "allowed", variable = "note", negate = TRUE
    ),
    checklist_format_output(
      input = notes,
      output = checklist_extract(allowed_notes),
      type = "new", variable = "note"
    ),
    checklist_format_output(
      input = checklist_extract(allowed_notes),
      output = notes,
      motivation = checklist_extract(
        allowed_notes, "motivation", "\nmotivation: "
      ),
      type = "missing", variable = "note"
    ),
    checklist_summarise_linter(linter),
    checklist_format_error(errors)
  )
  cat(output, sep = rules())
  cat(rules())
}

checklist_summarise_linter <- function(linter) {
  if (length(linter) == 0) {
    return(character(0))
  }
  linter_message <- vapply(linter, `[[`, character(1), "message")
  messages <- sort(table(linter_message), decreasing = TRUE)
  messages <- sprintf("%i times \"%s\"", messages, names(messages))
  sprintf(
    "%i linter%s found.
`styler::style_file()` can fix some problems automatically. \n%s%s",
    length(linter), ifelse(length(linter) > 1, "s", ""),
    rules("-"),
    paste(messages, collapse = "\n")
  )
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
is_repository <- function(path = ".") {
  out <- tryCatch(git_find(path = path), error = function(e) e)
  !any(class(out) == "error")
}


#' Pass command lines to a shell
#'
#' Cross-platform function to pass a command to the shell, using either
#' \code{\link[base]{system}} or
#' (Windows-only) \code{\link[base]{shell}}, depending on the operating system.
#'
#' @param commandstring
#' The system command to be invoked, as a string.
#' Multiple commands can be combined in this single string, e.g. with a
#' multiline string.
#' @param path The path from where the commandstring needs to be executed
#' @param ... Other arguments passed to \code{\link[base]{system}} or
#' \code{\link[base]{shell}}.
#'
#' @inheritParams base::system
#'
#' @keywords internal
#'
execshell <- function(commandstring, intern = FALSE, path = ".", ...) {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(path)

  if (.Platform$OS.type == "windows") {
    res <- shell(commandstring, intern = TRUE, ...)# nolint
  } else {
    res <- system(commandstring, intern = TRUE, ...)
  }
  if (!intern) {
    if (length(res) > 0) cat(res, sep = "\n") else return(invisible())
  } else return(res)
}
