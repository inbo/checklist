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
