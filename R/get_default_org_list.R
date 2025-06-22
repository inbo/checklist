#' Get the default organization list
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
#' @importFrom fs dir_create path
#' @importFrom gert git_remote_list
#' @importFrom tools R_user_dir
get_default_org_list <- function(x = ".") {
  stopifnot(is_repository(x))
  remotes <- git_remote_list(repo = x)
  stopifnot("no git remote `origin` found" = any(remotes$name == "origin"))
  url <- remotes$url[remotes$name == "origin"]
  if (!grepl("^https:\\/\\/", url)) {
    url <- gsub("^git@(.*):", "https://\\1/", url, perl = TRUE)
  }
  url <- gsub("oauth2:.*?@", "", url)
  stopifnot("no online origin" = grepl("^https://", url, perl = TRUE))
  url <- gsub("(https:\\/\\/.+?\\/.+?)\\/.*", "\\1", url, perl = TRUE)
  target <- tempfile("checklist-organisation")
  sprintf(
    "git clone --single-branch --branch=main --depth=1 %s/checklist %s",
    url,
    target
  ) |>
    system()
  org <- org_list$new()$read(target)
  gsub("https://", "", url) |>
    tolower() -> config_name
  R_user_dir("checklist", "config") |>
    path(config_name) -> config_path
  dir_create(config_path, recurse = TRUE)
  org$write(config_path)
  return(org)
}
