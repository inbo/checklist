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
