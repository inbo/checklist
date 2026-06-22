#' @importFrom citeme ask_yes_no individual2badge select_individual
project_maintainer <- function(org, lang) {
  message("Please select the corresponding author")
  select_individual(lang = lang) |>
    individual2badge(role = c("aut", "cre")) -> author
  while (isTRUE(ask_yes_no("add another author?", default = FALSE))) {
    select_individual(lang = lang) |>
      individual2badge(role = "aut") -> extra
    attr(author, "footnote") |>
      c(attr(extra, "footnote")) -> footnote
    c(author, extra) |>
      `attr<-`(which = "footnote", value = footnote) -> author
  }

  info <- ask_rightsholder_funder(org = org, type = "rightsholder")
  selected_org <- info$selection
  list("cph") |>
    rep(length(selected_org)) -> selected_role
  info <- ask_rightsholder_funder(org = info$org, type = "funder")
  matched <- selected_org == info$selection
  for (i in which(matched)) {
    selected_role[[i]] <- c(selected_role[[i]], "fnd")
  }
  extra <- info$selection[!info$selection %in% selected_org]
  selected_org <- c(selected_org, extra)
  selected_role <- c(selected_role, rep(list("fnd"), length(extra)))
  info <- ask_rightsholder_funder(org = info$org, type = "publisher")
  matched <- selected_org == info$selection
  for (i in which(matched)) {
    selected_role[[i]] <- c(selected_role[[i]], "pbl")
  }
  extra <- info$selection[!info$selection %in% selected_org]
  selected_org <- c(selected_org, extra)
  selected_role <- c(selected_role, rep(list("pbl"), length(extra)))
  org <- info$org
  vapply(
    which(!is.na(selected_org)),
    FUN = function(x) {
      list(org$get_person(
        selected_org[x],
        role = selected_role[[x]],
        lang = lang
      ))
    },
    FUN.VALUE = vector("list", 1)
  ) |>
    do.call(what = c) |>
    vapply(FUN.VALUE = vector("list", 1), FUN = function(x) {
      data.frame(
        given = x$given,
        family = "",
        orcid = "",
        affiliation = "",
        email = x$email
      ) |>
        individual2badge(role = x$role) |>
        list()
    }) -> extra
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
        value = org$get_zenodo_by_email(selected_org) |>
          paste(collapse = "; ")
      ),
    org = org
  )
}

#' @title Ask for rights holder or funder
#' @param org Organisation object
#' @param type Character, either `"rightsholder"`, `"funder"` or `"publisher"`
#' @return A list with the selected names and the updated organisation object
#' @importFrom citeme get_available_organisations new_org_item menu_first
#' @export
#' @family utils
ask_rightsholder_funder <- function(
  org,
  type = c("rightsholder", "funder", "publisher")
) {
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
        org <- org$add_item(new_org_item(
          languages = current$languages,
          licenses = current$licenses
        ))
        available <- org$get_default_name
      }
      selection <- c(selection, names(available)[selected - 1])
    } else {
      selection <- ifelse(
        type == "rightsholder",
        org$get_default_rightsholder,
        ifelse(
          type == "funder",
          org$get_default_funder,
          org$get_default_publisher
        )
      )
    }
  }
  if (length(selection) == 0) {
    selection <- ifelse(
      type == "rightsholder",
      org$get_default_rightsholder,
      ifelse(
        type == "funder",
        org$get_default_funder,
        org$get_default_publisher
      )
    )
  }
  return(list(selection = selection, org = org))
}
