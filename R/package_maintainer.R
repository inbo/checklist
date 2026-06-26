#' @importFrom citeme individual2person
package_maintainer <- function(org, lang) {
  message("Please select the maintainer")
  maintainer <- individual2person(
    role = c("aut", "cre"),
    lang = lang,
    org = org
  )
  while (isTRUE(ask_yes_no("Add another author?", default = FALSE))) {
    maintainer <- c(
      maintainer,
      individual2person(role = "aut", lang = lang, org = org)
    )
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
  list(
    authors = c(
      maintainer,
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
        do.call(what = c)
    ),
    org = org
  )
}
