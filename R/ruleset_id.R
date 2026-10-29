#' Find the id of a repository ruleset by name
#'
#' Extracts the id from the JSON returned by the GitHub rulesets endpoint
#' without requiring a JSON parser.
#' The response is a JSON array in which every ruleset object starts with its
#' `id`, directly followed by its `name`.
#' Splitting the string on `"id":` therefore yields one element per ruleset,
#' each containing the id and the name of that ruleset.
#' Note that `"node_id":` does not match `"id":` because of the leading quote,
#' so nested identifiers are ignored.
#' @param json the raw JSON string with the list of rulesets.
#' @param name the name of the ruleset to look for.
#' @return The id as a character string, or `NULL` when the ruleset is absent.
#' @noRd
ruleset_id <- function(json, name) {
  gsub("^\\[", "", json) |>
    gsub(pattern = "\\]$", replacement = "") |>
    strsplit(split = "},{", fixed = TRUE) |>
    unlist() -> rulesets
  if (length(rulesets) == 0) {
    return(NULL)
  }
  sprintf("\"name\":\"%s\"", name) |>
    grepl(x = rulesets, fixed = TRUE) |>
    which() |>
    head(1) -> relevant
  if (length(relevant) == 0) {
    return(NULL)
  }
  gsub(".*?\\\"id\\\":([0-9]+).*$", "\\1", rulesets[relevant])
}
