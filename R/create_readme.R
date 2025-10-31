#' @importFrom fs file_exists path
create_readme <- function(
  path,
  org,
  authors,
  title,
  description,
  keywords,
  lang
) {
  if (file_exists(path(path, "README.md"))) {
    return(character(0))
  }
  if (missing(authors)) {
    authors <- project_maintainer(org = org, lang = lang)
  }
  if (missing(title)) {
    title <- readline(prompt = "Enter the title: ")
  }
  if (missing(description)) {
    description <- readline(prompt = "Enter the description: ")
  }
  if (missing(keywords)) {
    keywords <- ask_keywords()
  }

  paste0(
    "[![Project Status: Concept - Minimal or no implementation has been done ",
    "yet, or the repository is only intended to be a limited example, demo, ",
    "or proof-of-concept.]",
    "(https://www.repostatus.org/badges/latest/concept.svg)]",
    "(https://www.repostatus.org/#concept)"
  ) -> badges
  if (is_repository(path)) {
    remotes <- git_remote_list(repo = path)
    remotes$url[remotes$name == "origin"] |>
      gsub(pattern = "git@(.*?):(.*)", replacement = "https://\\1/\\2") |>
      gsub(pattern = "https://.*?@", replacement = "https://") |>
      gsub(pattern = "\\.git$", replacement = "") -> repo_url
    if (length(repo_url) > 0 && grepl("github.com", repo_url)) {
      gsub("https://github.com/", "", repo_url) |>
        sprintf(
          fmt = paste0(
            "![GitHub](https://img.shields.io/github/license/%1$s)\n",
            "![GitHub Workflow Status](https://img.shields.io/github/actions/",
            "workflow/status/%1$s/check-project)\n",
            "![GitHub repo size](https://img.shields.io/github/repo-size/%1$s)"
          )
        ) -> badges
    }
  }
  c(
    "<!-- badges: start -->",
    badges,
    "<!-- badges: end -->",
    "",
    paste("#", title),
    "",
    authors,
    "",
    attr(authors, "footnote"),
    "",
    paste("**keywords**: ", paste(keywords, collapse = "; ")),
    "",
    sprintf("<!-- community: %s -->", attr(authors, "zenodo")),
    "",
    "<!-- description: start -->",
    description,
    "<!-- description: end -->"
  ) |>
    writeLines(path(path, "README.md"))
  return("README.md")
}
