#' @importFrom fs file_exists path
create_readme <- function(
  path,
  org,
  lang,
  authors,
  title,
  description,
  keywords,
  license,
  type = c("package", "project", "data")
) {
  if (file_exists(path(path, "README.md"))) {
    warning(
      "README.md already exists in ",
      path,
      ". No changes made.",
      call. = FALSE,
      immediate. = TRUE
    )
    return(character(0))
  }
  if (missing(authors)) {
    info <- project_maintainer(org = org, lang = lang)
    authors <- info$authors
    org <- info$org
    org$write(x = path)
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
  if (missing(license)) {
    license <- ask_license(org = org, type = type)
  }
  paste0(
    "[![Project Status: Concept - Minimal or no implementation has been done ",
    "yet, or the repository is only intended to be a limited example, demo, ",
    "or proof-of-concept.]",
    "(https://www.repostatus.org/badges/latest/concept.svg)]",
    "(https://www.repostatus.org/#concept)"
  ) |>
    c(
      paste0(
        "[![Lifecycle: experimental](https://img.shields.io/badge/",
        "lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/",
        "articles/stages.html#experimental)"
      ),
      sprintf(
        "[![%s](https://img.shields.io/badge/License-%s-brightgreen)](%s)",
        license,
        gsub(" ", "_", license),
        license_local_remote(org$get_listed_licenses[license])$remote_file
      )
    ) -> badges
  if (is_repository(path)) {
    remotes <- git_remote_list(repo = path)
    repo_url <- remotes$url[remotes$name == "origin"]
    repo_org <- gsub("https://.*?/", "", ssh_http(repo_url))
    repo_name <- gsub(".*/(.*?)\\.git", "\\1", repo_url)
    c(
      badges,
      sprintf(
        fmt = paste0(
          "[![Release](https://img.shields.io/github/release/%1$s.svg)]",
          "(https://github.com/%1$s/releases)\n",
          "![GitHub Workflow Status](https://img.shields.io/github/actions/",
          "workflow/status/%1$s/check-%2$s)\n",
          "![GitHub repo size](https://img.shields.io/github/repo-size/%1$s)\n",
          "![GitHub code size in bytes](https://img.shields.io/github/",
          "languages/code-size/%1$s.svg)"
        ),
        paste(repo_org, repo_name, sep = "/"),
        type
      )[grepl("github.com", repo_url)],
      sprintf(
        paste0(
          "![r-universe name](https://%1$s.r-universe.dev/badges/:name?",
          "color=c04384)\n![r-universe package](https://%1$s.r-universe.dev/",
          "badges/%2$s)\n",
          "[![Codecov test coverage](https://codecov.io/gh/%1$s/%2$s/branch/",
          "main/graph/badge.svg)](https://app.codecov.io/gh/%1$s/%2$s?",
          "branch=main)"
        ),
        repo_org,
        repo_name
      )[type == "package"]
    ) -> badges
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
  ) -> content
  if (type != "package") {
    writeLines(content, path(path, "README.md"))
    return(invisible(NULL))
  }
  c(
    "---",
    "output: github_document",
    "---",
    "",
    "<!-- README.md is generated from README.Rmd. Please edit that file -->",
    "",
    "```{r, include = FALSE}",
    "knitr::opts_chunk$set(",
    "  collapse = TRUE,",
    "  comment = \"#>\",",
    "  fig.path = file.path(\"man\", \"figures\", \"README-\"),",
    "  out.width = \"100%\"",
    ")",
    "```",
    "",
    content,
    "",
    "## Installation",
    "",
    "You can install the development version from",
    "[GitHub](https://github.com/) with:",
    "",
    "``` r",
    "# install.packages(\"remotes\")",
    sprintf("remotes::install_git(\"%s/%s\")", ssh_http(repo_url), repo_name),
    "```",
    "",
    "## Example",
    "",
    "This is a basic example which shows you how to solve a common problem:",
    "",
    "```{r example}",
    sprintf("library(%s)", repo_name),
    "## basic example code",
    "```"
  ) |>
    writeLines(path(path, "README.Rmd"))
  return(invisible(NULL))
}
