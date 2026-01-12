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

  info <- ask_rightsholder_funder(org = org, type = "rightsholder")
  rightsholder <- info$selection
  info <- ask_rightsholder_funder(org = info$org, type = "funder")
  funder <- info$selection
  org <- info$org
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
  list(
    authors = c(author, unlist(extra)) |>
      paste(collapse = ";\n") |>
      `attr<-`(which = "footnote", value = footnote) |>
      `attr<-`(
        which = "zenodo",
        value = c(rightsholder, funder) |>
          org$get_zenodo_by_email() |>
          paste(collapse = "; ")
      ),
    org = org
  )
}

#' @title Ask for rights holder or funder
#' @param org Organisation object
#' @param type Character, either "rightsholder" or "funder"
#' @return A list with the selected names and the updated organisation object
#' @export
#' @family utils
ask_rightsholder_funder <- function(org, type = c("rightsholder", "funder")) {
  type <- match.arg(type)
  available <- org$get_default_name
  selection <- character(0)
  while (
    length(available) > 0 &&
      isTRUE(ask_yes_no(sprintf("Add a %s?", type), default = FALSE))
  ) {
    c(paste("default", type), available, paste("other", type)) |>
      menu_first(title = sprintf("Select a %s:", type)) -> selected
    if (selected > 1) {
      if (selected > length(available) + 1) {
        current <- get_available_organisations()
        org <- org$add_item(
          new_org_item(
            languages = current$languages,
            licenses = current$licenses
          )
        )
        available <- org$get_default_name
      }
      selection <- c(selection, names(available)[selected - 1])
    } else {
      selection <- ifelse(
        type == "rightsholder",
        org$get_default_rightsholder,
        org$get_default_funder
      )
    }
  }
  if (length(selection) == 0) {
    selection <- ifelse(
      type == "rightsholder",
      org$get_default_rightsholder,
      org$get_default_funder
    )
  }
  return(list(selection = selection, org = org))
}
