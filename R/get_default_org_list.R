#' Get the default organization list
#'
#' This function retrieves the default organisation list from the
#' `organisation.yml` file in the organisations `checklist` repository.
#' The `origin` of the repository is used to determine the root URL of the
#' organisation.
#' @param x The path to the repository.
#' Defaults to the current working directory.
#' @return An `org_list` object containing the organisation list.
#' The function also stores the information in the user's R configuration.
#' @export
#' @family utils
#' @importFrom gert git_remote_list
get_default_org_list <- function(x = ".") {
  stopifnot(is_repository(x))
  remotes <- git_remote_list(repo = x)
  stopifnot("no git remote `origin` found" = any(remotes$name == "origin"))
  url <- ssh_http(remotes$url[remotes$name == "origin"])
  cache_org(url, config_folder = R_user_dir("checklist", "config"))
}

#' @importFrom fs dir_create path
#' @importFrom httr HEAD
#' @importFrom tools R_user_dir
cache_org <- function(url, config_folder) {
  paste0(url, "/checklist") |>
    HEAD() -> url_head
  if (url_head$status_code != 200) {
    warning(
      sprintf("no public `checklist` repo found at %s", url),
      immediate. = TRUE,
      call. = FALSE
    )
    return(invisible(NULL))
  }
  target <- tempfile("checklist-organisation")
  c(
    "clone",
    "--single-branch",
    "--branch=main",
    "--depth=1",
    paste0(url, "/checklist"),
    target
  ) |>
    system2(command = "git", stderr = FALSE, stdout = FALSE)
  org <- org_list$new()$read(target)
  gsub("https://", "", url) |>
    tolower() -> config_name
  config_path <- path(config_folder, config_name)
  dir_create(config_path, recurse = TRUE)
  org$write(config_path, license = TRUE)
  return(org)
}

org_list_from_url <- function(git) {
  ssh_http(git) |>
    gsub(pattern = "https://", replacement = "") |>
    tolower() -> config_name
  config_folder <- R_user_dir("checklist", "config")
  path(config_folder, config_name) -> config_path
  if (file_test("-d", config_path)) {
    return(org_list$new()$read(config_path))
  }
  org <- cache_org(url = ssh_http(git), config_folder = config_folder)
  if (!is.null(org) || !interactive()) {
    return(org)
  }
  return(new_org_list(git = git))
}
