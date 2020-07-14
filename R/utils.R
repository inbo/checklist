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
#' @param repo Either a `git2r::repository()` or path to the repository.
#' @return `TRUE` when there are no staged, unstaged or untracked files.
#' Otherwise `FALSE`
#' @export
#' @importFrom git2r status
is_workdir_clean <- function(repo) {
  current_status <- status(repo)
  all(vapply(current_status, length, integer(1)) == 0)
}

#' Check if a vector contains valid email
#' @param email A vector with email addresses.
#' @return A logical vector.
#' @export
#' @importFrom assertthat assert_that
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
    email
  )
}

#' Convert an ORCID to a `person` object.
#' @param orcid The ORCID of the person.
#' @param email An optional email of the person.
#' Require when the ORCID record does not contain a public email.
#' @param role The role of the person.
#' See `utils::person` for all possible values.
#' @export
#' @importFrom assertthat assert_that is.string
#' @importFrom rorcid as.orcid
#' @importFrom utils person
orcid2person <- function(orcid, email, role = c("aut", "cre")) {
  assert_that(is.string(orcid))
  assert_that(
    nchar(orcid) == 19,
    msg = "Please provide `orcid` in the `0000-0000-0000-0000` format."
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
  person(
    given = details[[1]]$name$`given-names`$value,
    family = details[[1]]$name$`family-name`$value,
    email = tolower(email),
    role = role,
    comment = c(ORCID = orcid)
  )
}
