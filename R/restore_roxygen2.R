restore_roxygen2 <- function(x = ".", quiet = TRUE) {
  requireNamespace("pak")
  x <- read_checklist(x)
  path_(x$get_path, "DESCRIPTION") |>
    readLines() -> desc
  note <- grep("Config/roxygen2/version:", desc)
  stopifnot(
    "Multiple `roxygen2:` entries found in DESCRIPTION" = length(note) <= 1
  )
  if (length(note) == 1) {
    roxygen_version <- gsub(
      ".*?Config/roxygen2/version: ([0-9\\.]+).*?",
      "roxygen2@\\1",
      desc[note]
    )
  } else {
    note <- grep("RoxygenNote:", desc)
    stopifnot(
      "Multiple `RoxygenNote:` entries found in DESCRIPTION" = length(note) <= 1
    )
    if (length(note) == 0) {
      quiet_cat("No RoxygenNote entry found in DESCRIPTION", quiet = quiet)
      return(invisible(NULL))
    }
    roxygen_version <- gsub(
      ".*?RoxygenNote: ([0-9\\.]+).*?",
      "roxygen2@\\1",
      desc[note]
    )
  }
  pak::pkg_install(roxygen_version)
  return(invisible(NULL))
}
