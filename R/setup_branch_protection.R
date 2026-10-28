#' Protect the default branch on GitHub
#'
#' @param git the url of the repo.
#' @param package logical, whether the repo is a package or not.
#' If `TRUE`, the default branch protection ruleset will be set for packages,
#' otherwise for projects.
#' @return `TRUE` in case not a GitHub repository, or if the ruleset was
#' successfully activated.
#' @export
#' @family setup
#' @importFrom citeme get_token
setup_branch_protection <- function(git, package = TRUE) {
  stopifnot(
    "`git` must be a character" = is.character(git),
    "`git` must be of length 1" = length(git) == 1,
    "`git` must not be `NA`" = !is.na(git),
    "`curl` package is not installed" = requireNamespace("curl"),
    "`package` must be a logical" = is.logical(package),
    "`package` must be of length 1" = length(package) == 1,
    "`package` must not be `NA`" = !is.na(package)
  )
  grepv(pattern = "github.com", git) |>
    head(1) -> url
  if (length(url) == 0) {
    message("Not a GitHub repository, skipping branch protection setup")
    return(TRUE)
  }
  ssh_http(git) |>
    get_token() -> token
  if (is.null(token)) {
    message("No GitHub token provided, skipping branch protection setup")
    return(TRUE)
  }

  c(
    "{",
    "  \"name\": \"Default Branch Protection Ruleset\",",
    "  \"target\": \"branch\",",
    " \"enforcement\": \"active\",",
    "  \"conditions\": {",
    "    \"ref_name\": {",
    "      \"include\": [\"~DEFAULT_BRANCH\"],",
    "      \"exclude\": []",
    "    }",
    "  },",
    "  \"rules\": [",
    "    { \"type\": \"deletion\" },",
    "    { \"type\": \"non_fast_forward\" },",
    "    {",
    "      \"type\": \"pull_request\",",
    "      \"parameters\": {",
    "        \"dismiss_stale_reviews_on_push\": false,",
    "        \"require_code_owner_review\": true,",
    "        \"require_last_push_approval\": true,",
    "        \"required_approving_review_count\": 1,",
    "        \"required_review_thread_resolution\": false",
    "      }",
    "    },",
    "    {",
    "      \"type\": \"required_status_checks\",",
    "      \"parameters\": {",
    "        \"strict_required_status_checks_policy\": true,",
    "        \"do_not_enforce_on_create\": true,",
    "        \"required_status_checks\": [",
    "          { \"context\": \"check-project\" },"[!package],
    "          { \"context\": \"check-package\" },"[package],
    "          { \"context\": \"codecov/patch\" },"[package],
    "          { \"context\": \"codecov/project\" },"[package],
    "          { \"context\": \"R release on Windows\" },"[package],
    "          { \"context\": \"R release on macOS\" },"[package],
    "          { \"context\": \"R devel on Ubuntu\" },"[package],
    "          { \"context\": \"R oldrel on Ubuntu\" }"[package],
    "        ]",
    "      }",
    "    }",
    "  ]",
    "}"
  ) |>
    paste(collapse = "\n") -> json_body

  curl::new_handle() |>
    curl::handle_setopt(customrequest = "POST") |>
    curl::handle_setopt(postfields = charToRaw(json_body)) |>
    curl::handle_setheaders(
      "Authorization" = paste("Bearer", token$password),
      "Accept" = "application/vnd.github+json",
      "X-GitHub-Api-Version" = "2022-11-28",
      "Content-Type" = "application/json"
    ) -> h

  sprintf(
    "https://api.github.com/repos/%s/%s/rulesets",
    ssh_http(git) |>
      basename(),
    basename(git) |>
      gsub(pattern = "\\.git$", replacement = "")
  ) |>
    curl::curl_fetch_memory(handle = h) -> response

  if (response$status_code %in% c(200, 201)) {
    message("Success! Ruleset activated.")
    return(TRUE)
  }

  paste(
    "Failed to set the branch protection.",
    "API request failed with status: %s",
    "Error details:",
    "%s",
    sep = "\n"
  ) |>
    sprintf(response$status_code, rawToChar(response$content)) |>
    stop()
}
