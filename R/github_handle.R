#' Create a `curl` handle for the GitHub API
#'
#' Internal helper to avoid repeating the same set of headers for every
#' GitHub API call.
#' @param token the GitHub token as returned by `citeme::get_token()`.
#' @param method the HTTP method to use.
#' @param body an optional JSON string to send as the request body.
#' @return A `curl` handle.
#' @noRd
github_handle <- function(token, method = "GET", body = NULL) {
  curl::new_handle() |>
    curl::handle_setopt(customrequest = method) -> h
  if (!is.null(body)) {
    curl::handle_setopt(h, postfields = charToRaw(body)) -> h
  }
  curl::handle_setheaders(
    h,
    "Authorization" = paste("Bearer", token$password),
    "Accept" = "application/vnd.github+json",
    "X-GitHub-Api-Version" = "2022-11-28",
    "Content-Type" = "application/json"
  )
}
