#' @importFrom assertthat is.flag is.string noNA
#' @importFrom fs is_dir is_file path
#' @importFrom yaml read_yaml
upload_zenodo <- function(path, token, sandbox = TRUE, logger = NULL) {
  assert_that(requireNamespace("zen4R", quietly = TRUE))
  assert_that(is.string(path), noNA(path), is.flag(sandbox), noNA(sandbox))
  assert_that(is_dir(path), msg = "`path` is not an existing directory")
  assert_that(is_file(path(path, ".zenodo.json")))

  path(path, ".zenodo.json") |>
    read_yaml() -> cit_meta

  zen_rec <- zen4R::ZenodoRecord$new()
  zen_rec$setTitle(cit_meta$title)
  zen_rec$setDescription(cit_meta$description)
  zen_rec$setUploadType(cit_meta$upload_type)
  if (
    has_name(cit_meta, "embargo_date") &&
      as.Date(cit_meta$embargo_date) > Sys.Date()
  ) {
    zen_rec$setEmbargoDate(as.Date(cit_meta$embargo_date))
  }
  zen_rec$setAccessRight(cit_meta$access_right)
  zen_rec$setLicense(cit_meta$license)
  zen_rec$setLanguage(cit_meta$language)
  for (x in cit_meta$creators) {
    zen_rec$addCreator(
      name = x$name, affiliation = x$affiliation, orcid = x$orcid
    )
  }
  for (x in cit_meta$contributors) {
    zen_rec$addContributor(
      firstname = character(0), lastname = x$name, affiliation = x$affiliation,
      orcid = x$orcid, type = x$type
    )
  }
  for (x in cit_meta$communities) {
    zen_rec$addCommunity(x$identifier)
  }
  zen_rec$setKeywords(cit_meta$keywords)
  zen_rec$setPublicationType(cit_meta$publication_type)
  if (has_name(cit_meta, "doi")) {
    zen_rec$setDOI(cit_meta$doi)
  }
  if (has_name(cit_meta, "version")) {
    zen_rec$setVersion(cit_meta$version)
  }

  url <- ifelse(
    sandbox, "https://sandbox.zenodo.org/api", "https://zenodo.org/api"
  )
  zenodo <- zen4R::ZenodoManager$new(url = url, token = token, logger = logger)
  zen_rec <- zenodo$depositRecord(zen_rec, publish = FALSE)
  to_upload <- dir_ls(path, recurse = TRUE, all = TRUE)
  for (filename in to_upload) {
    zenodo$uploadFile(filename, record = zen_rec)
  }

  gsub("api", "deposit/", url) |>
    paste0(zen_rec$record_id) -> deposit_url
  message(
    "Draft uploaded to Zenodo. Please visit ", deposit_url, " to publish."
  )
  if (interactive()) {
    browseURL(deposit_url)
  }
  return(invisible(NULL))
}
