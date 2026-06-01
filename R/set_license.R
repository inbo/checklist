#' Set the proper license
#' @inheritParams read_checklist
#' @param license the license to set.
#' If missing, the user will be prompted to choose a license.
#' @param org An `organisation` object.
#' If missing, the organisation will be read from the project.
#' @return Invisible `NULL`.
#' @family setup
#' @export
#' @importFrom assertthat assert_that
#' @importFrom citeme license_local_remote org_list select_license
#' @importFrom desc description
set_license <- function(x = ".", license, org) {
  x <- read_checklist(x = x)
  license_file <- file.path(x$get_path, "LICENSE.md")
  if (file_test("-f", license_file)) {
    return(invisible(NULL))
  }
  if (missing(org)) {
    org <- org_list$new()$read(x$get_path)
  }
  if (x$package) {
    assert_that(
      file_test("-f", file.path(x$get_path, "DESCRIPTION")),
      msg = sprintf("No `DESCRIPTION` file found at %s", x$get_path)
    )
    this_desc <- description$new(file = file.path(x$get_path, "DESCRIPTION"))
    assert_that(
      this_desc$has_fields("License"),
      msg = "`DESCRIPTION` has no `License`field."
    )
    license <- this_desc$get_field("License")
  } else if (missing(license)) {
    license <- select_license(org, type = "project")
  }
  get_official_license_location(license = license, org = org) |>
    readLines() |>
    writeLines(license_file)
  if (!grepl("^MIT", license)) {
    return(invisible(NULL))
  }
  rightsholder <- org$which_rightsholder
  if (length(rightsholder$required) > 0) {
    rightsholder <- rightsholder$required
  } else {
    rightsholder <- rightsholder$alternative
  }
  org$get_name_by_domain(
    rightsholder,
    lang = this_desc$get_field("Language")
  ) |>
    names() |>
    paste(collapse = ", ") -> cph
  paste0("YEAR: ", format(Sys.Date(), "%Y")) |>
    c(sprintf("COPYRIGHT HOLDER: %s", cph)) |>
    writeLines(file.path(x$get_path, "LICENSE"))
  mit <- readLines(license_file)
  mit[3] <- gsub("<YEAR>", format(Sys.Date(), "%Y"), mit[3])
  mit[3] <- gsub("<COPYRIGHT HOLDER>", cph, mit[3])
  writeLines(mit, license_file)
  return(invisible(NULL))
}

#' @importFrom citeme ssh_http
get_official_license_location <- function(license, org) {
  switch(
    license,
    "CC BY 4.0" = file.path("generic_template", "cc_by_4_0.md"),
    "CC BY-SA 4.0" = file.path("generic_template", "cc_by_sa_4_0.md"),
    "CC0" = file.path("generic_template", "cc0.md"),
    "GPL-3" = file.path("generic_template", "gplv3.md"),
    "MIT" = file.path("generic_template", "mit.md"),
    "MIT + file LICENSE" = file.path("generic_template", "mit.md"),
    NA
  ) |>
    system.file(package = "checklist") -> license_location
  if (license_location != "") {
    return(license_location)
  }
  org_licenses <- org$get_listed_licenses
  stopifnot(
    "license not available in organisation" = license %in% names(org_licenses)
  )
  license_location <- license_local_remote(org_licenses[license])
  url <- ssh_http(org$get_git)
  if (!grepl("^http", url)) {
    return(license_location$remote_file)
  }
  R_user_dir("citeme", "config") |>
    file.path(
      tolower(url) |> gsub(pattern = "https://", replacement = ""),
      license_location$local_file
    )
}
