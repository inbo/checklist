#' @importFrom assertthat has_name is.flag is.string noNA
#' @importFrom fs is_dir is_file path
#' @importFrom yaml read_yaml
upload_zenodo <- function(path, token, sandbox = TRUE, logger = NULL) {
  assert_that(requireNamespace("zen4R", quietly = TRUE))
  assert_that(is.string(path), noNA(path), is.flag(sandbox), noNA(sandbox))
  assert_that(is_dir(path), msg = "`path` is not an existing directory")
  assert_that(is_file(path(path, ".zenodo.json")))

  path(path, ".zenodo.json") |>
    read_yaml() -> cit_meta

  zenodo <- zen4R::ZenodoManager$new(
    sandbox = sandbox, token = token, logger = logger
  )
  zen_rec <- zen4R::ZenodoRecord$new()
  zen_rec$setTitle(cit_meta$title)
  zen_rec$setDescription(cit_meta$description)
  zen_rec$setResourceType(cit_meta$upload_type)
  if (
    has_name(cit_meta, "embargo_date") &&
      as.Date(cit_meta$embargo_date) > Sys.Date()
  ) {
    zen_rec$setAccessPolicyEmbargo(TRUE, as.Date(cit_meta$embargo_date))
  }
  zen_rec$setLicense(tolower(cit_meta$license), sandbox = sandbox)
  zen_rec$addLanguage(cit_meta$language)
  zen_creator(zen_rec, cit_meta$creator) |>
    zen_contributor(cit_meta$contributors) -> zen_rec
  zen_rec$setSubjects(cit_meta$keywords)
  zen_rec$setResourceType(cit_meta$publication_type)
  if (has_name(cit_meta, "doi")) {
    zen_rec$setDOI(cit_meta$doi)
  }
  if (has_name(cit_meta, "version")) {
    zen_rec$setVersion(cit_meta$version)
  }

  zen_rec <- zen_upload(zenodo, zen_rec, path)
  return(invisible(zen_rec))
}

zen_creator <- function(zen_rec, creators) {
  for (x in creators) {
    zen_rec$addCreator(
      name = x$name, affiliation = x$affiliation, orcid = x$orcid
    )
  }
  return(zen_rec)
}

zen_contributor <- function(zen_rec, contributors) {
  for (x in contributors) {
    zen_rec$addContributor(
      firstname = character(0), lastname = x$name, affiliation = x$affiliation,
      orcid = x$orcid, role = x$type
    )
  }
  return(zen_rec)
}

#' @importFrom assertthat assert_that has_name
#' @importFrom cli cli_alert_info cli_alert_warning
#' @importFrom fs dir_ls
#' @importFrom utils browseURL
zen_upload <- function(zenodo, zen_rec, path) {
  zen_rec <- zenodo$depositRecord(zen_rec, publish = FALSE)
  assert_that(
    has_name(zen_rec, "status"),
    msg = "Unexpected error uploading to Zenodo. Please contact the maintainer."
  )
  assert_that(
    zen_rec$status == "draft",
    msg = ifelse(
      zen_rec$status == "400",
      "Problem authenticating to Zenodo. Check the Zenodo token.",
      first_non_null(
        zen_rec$message, "Error uploading to Zenodo without error message."
      )
    )
  )

  to_upload <- dir_ls(path, recurse = TRUE, all = TRUE)
  for (filename in to_upload) {
    zenodo$uploadFile(filename, record = zen_rec)
  }
  c(
    "Draft uploaded to Zenodo.",
    "Please visit {zen_rec$links$self_html} to publish."
  ) |>
    paste(collapse = " ") |>
    cli_alert_info()
  cli_alert_warning(
    "Remember to add the publication to the relevant communities."
  )
  if (interactive()) {
    browseURL(zen_rec$links$self_html)
  }
  return(zen_rec)
}

first_non_null <- function(...) {
  dots <- list(...)
  if (length(dots) == 0) {
    return(NULL)
  }
  if (!is.null(dots[[1]])) {
    return(dots[[1]])
  }
  do.call(first_non_null, tail(dots, -1))
}
