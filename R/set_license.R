#' Set the proper license
#' @inheritParams read_checklist
#' @family setup
#' @export
#' @importFrom assertthat assert_that
#' @importFrom desc description
#' @importFrom fs file_copy file_exists path
set_license <- function(x = ".") {
  x <- read_checklist(x = x)
  license_file <- path(x$get_path, "LICENSE.md")
  if (x$package) {
    assert_that(
      file_exists(path(x$get_path, "DESCRIPTION")),
      msg = sprintf("No `DESCRIPTION` file found at %s", x$get_path)
    )
    this_desc <- description$new(file = path(x$get_path, "DESCRIPTION"))
    assert_that(
      this_desc$has_fields("License"),
      msg = "`DESCRIPTION` has no `License`field."
    )
    switch(
      this_desc$get_field("License"),
      "GPL-3" = path("generic_template", "gplv3.md"),
      "MIT" = path("generic_template", "mit.md"),
      "MIT + file LICENSE" = path("generic_template", "mit.md"),
      stop(
        sprintf("`%s` license is not available", this_desc$get_field("License"))
      )
    ) |>
      system.file(package = "checklist") |>
      file_copy(license_file, overwrite = TRUE)
    if (!grepl("^MIT", this_desc$get_field("License"))) {
      return(invisible(NULL))
    }
    this_desc$get_author(role = "cph") |>
      format(include = c("given", "family")) |>
      paste(collapse = ", ") -> cph
    paste0("YEAR: ", format(Sys.Date(), "%Y")) |>
      c(sprintf("COPYRIGHT HOLDER: %s", cph)) |>
      writeLines(path(x$get_path, "LICENSE"))
    mit <- readLines(license_file)
    mit[3] <- gsub("<YEAR>", format(Sys.Date(), "%Y"), mit[3])
    mit[3] <- gsub("<COPYRIGHT HOLDER>", cph, mit[3])
    writeLines(mit, license_file)
    return(invisible(NULL))
  }
  path("generic_template", "cc_by_4_0.md") |>
    system.file(package = "checklist") |>
    file_copy(license_file, overwrite = TRUE)
  return(invisible(NULL))
}
