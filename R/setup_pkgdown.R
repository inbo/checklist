setup_pkgdown <- function(x = ".", org, lang) {
  x <- read_checklist(x = x)

  authors <- org$get_pkgdown(lang = lang)
  path("package_template", "_pkgdown.yml") |>
    system.file(package = "checklist") |>
    readLines() |>
    c("authors:"[nchar(authors) > 0], authors) |>
    writeLines(path(x$get_path, "_pkgdown.yml"))
  git_add("_pkgdown.yml", repo = x$get_path)

  gsub(pattern = "https://", replacement = "", org$get_git) |>
    tolower() -> config_name
  config_folder <- R_user_dir("checklist", "config")

  css_source <- path(config_folder, config_name, "pkgdown.css")
  if (file_test("-f", css_source)) {
    target <- path(x$get_path, "pkgdown")
    dir_create(target)
    file.copy(css_source, to = path(target, "extra.css"), overwrite = TRUE)
    git_add("pkgdown/extra.css", repo = x$get_path)
  }
  path(config_folder, config_name, "pkgdown") -> config_path
  if (!file_test("-d", config_path)) {
    return(invisible(NULL))
  }

  target <- path(x$get_path, "man", "figures")
  dir_create(target)
  to_do <- list.files(config_path, full.names = TRUE)
  file.copy(to_do, to = path(target, basename(to_do)), overwrite = TRUE)
  path("man", "figures") |>
    git_add(repo = x$get_path)
  return(invisible(NULL))
}
