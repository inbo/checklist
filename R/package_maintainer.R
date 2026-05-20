#' @importFrom citeme individual2person
package_maintainer <- function(org, lang) {
  message("Please select the maintainer")
  maintainer <- individual2person(role = c("aut", "cre"), lang = lang)
  while (isTRUE(ask_yes_no("Add another author?", default = FALSE))) {
    maintainer <- c(maintainer, individual2person(role = "aut", lang = lang))
  }
  info <- ask_rightsholder_funder(org = org, type = "rightsholder")
  rightsholder <- info$selection
  info <- ask_rightsholder_funder(org = info$org, type = "funder")
  funder <- info$selection
  org <- info$org
  list(
    authors = c(
      maintainer,
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
        do.call(what = c)
    ),
    org = org
  )
}
