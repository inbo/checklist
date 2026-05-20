display_message <- function(x, verbose, type = c("cat", "message", "warning")) {
  if (isFALSE(verbose)) {
    return(invisible(NULL))
  }
  type <- match.arg(type)
  stopifnot(is.character(x))
  switch(
    type,
    cat = cat(x, "\n"),
    message = message(x),
    warning = warning(x, call. = FALSE, immediate. = TRUE)
  )
  return(invisible(NULL))
}
