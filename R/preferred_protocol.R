#' @importFrom assertthat assert_that
#' @importFrom fs dir_create path
#' @importFrom tools R_user_dir
#' @importFrom utils menu
#' @importFrom yaml read_yaml write_yaml
preferred_protocol <- function() {
  config <- list()
  config_folder <- R_user_dir("checklist", which = "config")
  config_file <- path(config_folder, "config.yml")
  if (file_exists(config_file)) {
    config <- read_yaml(config_file)
  }
  if (!has_name(config, "git") || !has_name(config$git, "protocol")) {
    c("https (easy)", "ssh (more secure)") |>
      menu_first(title = "Which protocol do you prefer?") -> protocol
    config[["git"]][["protocol"]] <- c("https", "ssh")[protocol]
    dirname(config_file) |>
      dir_create()
    write_yaml(x = config, file = config_file, fileEncoding = "UTF-8")
  }
  c(config[["git"]][["organisation"]], "new git organisation") |>
    menu_first(title = "Which git organisation?") -> org_choice
  if (org_choice > length(config[["git"]][["organisation"]])) {
    while (TRUE) {
      paste(
        "Enter the URL of the git organisation?",
        "E.g. `https://github.com/inbo`: "
      ) |>
        readline() -> org_url
      if (grepl("^https:\\/\\/[\\w\\.]+?\\/\\w+$", org_url, perl = TRUE)) {
        break
      }
      message("Please enter a valid URL.")
    }
    c(
      config[["git"]][["organisation"]],
      org_url
    ) |>
      sort() |>
      unique() -> config[["git"]][["organisation"]]
    write_yaml(x = config, file = config_file, fileEncoding = "UTF-8")
    ssh_http(org_url) |>
      cache_org(config_folder = config_folder)
  } else {
    org_url <- config[["git"]][["organisation"]][org_choice]
  }
  if (config[["git"]][["protocol"]] == "https") {
    return(paste0(org_url, "/%s.git"))
  }
  gsub(
    "^https:\\/\\/([\\w\\.]+?)\\/(\\w+)$",
    "git@\\1:\\2/%s.git",
    org_url,
    perl = TRUE
  )
}

#' Function to ask a simple yes no question
#' Provides a simple wrapper around `utils::askYesNo()`.
#' This function is used to ask questions in an interactive way.
#' It repeats the question until a valid answer is given.
#' @inheritParams utils::askYesNo
#' @importFrom utils askYesNo
#' @export
#' @family utils
ask_yes_no <- function(
  msg,
  default = TRUE,
  prompts = c("Yes", "No", "Cancel"),
  ...
) {
  if (!interactive()) {
    return(default)
  }
  assert_that(is.string(msg), noNA(msg))
  answer <- try(askYesNo(msg = msg, default = default, prompts = prompts))
  while (inherits(answer, "try-error") || is.null(answer)) {
    sprintf("`%s`", prompts) |>
      paste(collapse = ", ") |>
      sprintf(fmt = "Please answer with %s.") |>
      warning(immediate. = TRUE, call. = FALSE)
    answer <- try(askYesNo(msg = msg, default = default, prompts = prompts))
  }
  return(answer)
}

#' @importFrom fs file_exists path
renv_activate <- function(path, use_renv) {
  if (file_exists(path(path, "renv.lock"))) {
    return(invisible(NULL))
  }
  if (missing(use_renv)) {
    use_renv <- ask_yes_no(
      "Use `renv` to lock package versions with the project?",
      default = FALSE
    )
  }
  if (!use_renv) {
    return(invisible(NULL))
  }
  c(
    "if (!utils::file_test(\"-f\", \"renv.lock\")) {",
    "  renv::init()",
    "}"
  ) |>
    writeLines(path(path, ".Rprofile"))
}
