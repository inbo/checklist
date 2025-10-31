project_maintainer <- function(org, lang) {
  message("Please select the corresponding author")
  use_author(lang = lang) |>
    author2badge(role = c("aut", "cre")) -> author
  while (isTRUE(ask_yes_no("add another author?", default = FALSE))) {
    use_author(lang = lang) |>
      author2badge() -> extra
    attr(author, "footnote") |>
      c(attr(extra, "footnote")) -> footnote
    c(author, extra) |>
      `attr<-`(which = "footnote", value = footnote) -> author
  }

  available <- org$get_default_name
  funder <- character(0)
  while (
    length(available) > 0 &&
      isTRUE(ask_yes_no("Add a funder?", default = FALSE))
  ) {
    c("default funder", available) |>
      menu_first(title = "Select a funder:") -> selected
    if (selected > 1) {
      funder <- c(funder, names(available)[selected + 1])
    } else {
      funder <- org$get_default_funder
    }
  }
  if (length(funder) == 0) {
    funder <- org$get_default_funder
  }
  rightsholder <- org$get_default_rightsholder
  c(
    vapply(
      rightsholder[rightsholder %in% funder],
      FUN = function(x) {
        list(org$get_person(x, role = c("cph", "fnd"), lang = lang))
      },
      FUN.VALUE = vector("list", 1)
    ),
    vapply(
      rightsholder[!rightsholder %in% funder],
      FUN = function(x) {
        list(org$get_person(x, role = "cph", lang = lang))
      },
      FUN.VALUE = vector("list", 1)
    ),
    vapply(
      funder[!funder %in% rightsholder],
      FUN = function(x) {
        list(org$get_person(x, role = "fnd", lang = lang))
      },
      FUN.VALUE = vector("list", 1)
    )
  ) |>
    do.call(what = c) |>
    vapply(
      FUN.VALUE = vector("list", 1),
      FUN = function(x) {
        data.frame(
          given = x$given,
          family = "",
          orcid = "",
          affiliation = "",
          email = x$email
        ) |>
          author2badge(role = x$role) |>
          list()
      }
    ) -> extra
  vapply(extra, FUN.VALUE = vector(mode = "list", 1), FUN = function(x) {
    list(attr(x, "footnote"))
  }) |>
    unlist() |>
    c(attr(author, "footnote")) |>
    unique() |>
    sort() -> footnote
  c(author, unlist(extra)) |>
    `attr<-`(which = "footnote", value = footnote) |>
    `attr<-`(
      which = "zenodo",
      value = c(rightsholder, funder) |>
        org$get_zenodo_by_email() |>
        paste(collapse = "; ")
    )
}
