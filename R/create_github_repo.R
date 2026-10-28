create_github_repo <- function(git) {
  stopifnot(
    "`git` must be a character" = is.character(git),
    "`git` must be of length 1" = length(git) == 1,
    "`git` must not be `NA`" = !is.na(git),
    "`curl` package is not installed" = requireNamespace("curl")
  )
  grepv(pattern = "github.com", git) |>
    head(1) -> url
  if (length(url) == 0) {
    message("Not a GitHub repository")
    return(TRUE)
  }
  ssh_http(git) |>
    get_token() -> token
  if (is.null(token)) {
    message("No GitHub token provided, skipping branch protection setup")
    return(TRUE)
  }

  paste0(
    "{",
    "\"name\":\"%s\",",
    "\"private\":false,",
    "\"has_issues\":true,",
    "\"has_projects\":false,",
    "\"has_wiki\":false,",
    "\"allow_squash_merge\":false,",
    "\"allow_merge_commit\":true,",
    "\"allow_rebase_merge\":false,",
    "\"delete_branch_on_merge\":true,",
    "\"allow_auto_merge\":false",
    "}"
  ) |>
    sprintf(
      basename(git) |>
        gsub(pattern = "\\.git$", replacement = "")
    ) -> json_body
  curl::new_handle() |>
    curl::handle_setopt(customrequest = "POST") |>
    curl::handle_setopt(postfields = charToRaw(json_body)) |>
    curl::handle_setheaders(
      "Authorization" = paste("Bearer", token$password),
      "Accept" = "application/vnd.github+json",
      "X-GitHub-Api-Version" = "2022-11-28",
      "Content-Type" = "application/json"
    ) -> h
  ssh_http(git) |>
    basename() |>
    sprintf(fmt = "https://api.github.com/orgs/%s/repos") |>
    curl::curl_fetch_memory(handle = h) -> response
  if (response$status_code %in% c(200, 201)) {
    message("Success! Repository created.")
    return(invisible(NULL))
  }
  paste(
    "Failed to create the repository.",
    "API request failed with status: %s",
    "Error details:",
    "%s",
    sep = "\n"
  ) |>
    sprintf(response$status_code, rawToChar(response$content)) |>
    stop()
}
