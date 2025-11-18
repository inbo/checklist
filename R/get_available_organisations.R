get_available_organisations <- function() {
  config_folder <- R_user_dir("checklist", which = "config")
  list.files(
    config_folder,
    pattern = "organisation.yml",
    recursive = TRUE,
    full.names = TRUE
  ) |>
    dirname() |>
    vapply(
      FUN = function(x) {
        list(org_list$new()$read(x)$as_list)
      },
      FUN.VALUE = vector(mode = "list", length = 1)
    ) |>
    unname() |>
    unlist(recursive = FALSE) -> all_orgs
  all_orgs <- all_orgs[sort(unique(names(all_orgs)[names(all_orgs) != "git"]))]
  orgnames <- lapply(all_orgs, "[[", "name")
  orcid <- vapply(all_orgs, "[[", "orcid", FUN.VALUE = logical(1))
  zenodo <- vapply(
    all_orgs,
    function(x) {
      ifelse(is.null(x$zenodo), "", x$zenodo)
    },
    character(1)
  )
  ror <- vapply(
    all_orgs,
    function(x) {
      ifelse(is.null(x$ror), "", x$ror)
    },
    character(1)
  )
  lapply(all_orgs, "[[", "license") |>
    unname() |>
    unlist(recursive = FALSE) |>
    unname() |>
    unlist() -> licenses
  unname(orgnames) |>
    unlist() |>
    names() |>
    unique() |>
    sort() -> languages
  return(list(
    names = orgnames,
    languages = languages,
    licenses = licenses[sort(unique(names(licenses)))],
    orcid = orcid,
    zenodo = zenodo,
    ror = ror
  ))
}
