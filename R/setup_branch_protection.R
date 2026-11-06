#' Protect the default branch on GitHub
#'
#' @param git the url of the repo.
#' @param package logical, whether the repo is a package or not.
#' If `TRUE`, the default branch protection ruleset will be set for packages,
#' otherwise for projects.
#' When the ruleset already exists, it is updated instead of created.
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
    "`curl` package is not installed" = requireNamespace(
      "curl",
      quietly = TRUE
    ),
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

  # The name must match the one used when looking up an existing ruleset.
  "Default Branch Protection Ruleset" -> ruleset_name

  c(
    "{",
    sprintf("  \"name\": \"%s\",", ruleset_name),
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

  sprintf(
    "https://api.github.com/repos/%s/%s/rulesets",
    ssh_http(git) |>
      basename(),
    basename(git) |>
      gsub(pattern = "\\.git$", replacement = "")
  ) -> api_url

  # Look up an existing ruleset first.
  # Creating a ruleset with an existing name fails with a 422 status.
  github_handle(token) |>
    curl::curl_fetch_memory(url = api_url) -> listed
  if (!listed$status_code %in% c(200, 201)) {
    paste(
      "Failed to list the existing rulesets.",
      "API request failed with status: %s",
      "Error details:",
      "%s",
      sep = "\n"
    ) |>
      sprintf(listed$status_code, rawToChar(listed$content)) |>
      stop()
  }
  rawToChar(listed$content) |>
    ruleset_id(name = ruleset_name) -> id

  if (is.null(id)) {
    "POST" -> method
    api_url -> target_url
    "Success! Ruleset activated." -> success_message
  } else {
    "PUT" -> method
    paste(api_url, id, sep = "/") -> target_url
    "Success! Ruleset updated." -> success_message
  }

  github_handle(token, method = method, body = json_body) |>
    curl::curl_fetch_memory(url = target_url) -> response

  if (response$status_code %in% c(200, 201)) {
    message(success_message)
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
