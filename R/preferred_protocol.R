#' @importFrom assertthat assert_that
#' @importFrom citeme ask_url cache_org menu_first ssh_http
#' @importFrom tools R_user_dir
#' @importFrom utils menu
#' @importFrom yaml read_yaml write_yaml
preferred_protocol <- function() {
  config <- list()
  config_folder <- R_user_dir("citeme", which = "config")
  config_file <- path_(config_folder, "config.yml")
  if (file_test("-f", config_file)) {
    config <- read_yaml(config_file)
  }
  if (!has_name(config, "git") || !has_name(config$git, "protocol")) {
    c("https (easy)", "ssh (more secure)") |>
      menu_first(title = "Which protocol do you prefer?") -> protocol
    config[["git"]][["protocol"]] <- c("https", "ssh")[protocol]
    dirname(config_file) |> dir.create(recursive = TRUE, showWarnings = FALSE)
    write_yaml(x = config, file = config_file, fileEncoding = "UTF-8")
  }
  c(config[["git"]][["organisation"]], "new git organisation") |>
    menu_first(title = "Which git organisation?") -> org_choice
  if (org_choice > length(config[["git"]][["organisation"]])) {
    paste(
      "Enter the URL of the git organisation?",
      "E.g. `https://github.com/inbo`: "
    ) |>
      ask_url() -> org_url
    c(config[["git"]][["organisation"]], org_url) |>
      sort() |>
      unique() -> config[["git"]][["organisation"]]
    write_yaml(x = config, file = config_file, fileEncoding = "UTF-8")
    ssh_http(org_url) |> cache_org(config_folder = config_folder)
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

#' @importFrom citeme ask_yes_no
renv_activate <- function(path, use_renv) {
  if (file_test("-f", path_(path, "renv.lock"))) {
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
  c("if (!utils::file_test(\"-f\", \"renv.lock\")) {", "  renv::init()", "}") |>
    writeLines(path_(path, ".Rprofile"))
}
