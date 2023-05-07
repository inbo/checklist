#' Render a `bookdown` and upload to Zenodo
#'
#' First clears all the existing files in the `output_dir` set in
#' `_bookdown_.yml`.
#' Then renders all required output formats and uploads them to Zenodo.
#' @param path The root folder of the report
#' @param zip_format A vector with output formats that generate multiple files.
#' The function will bundle all the files in a zip file for every format.
#' @param single_format A vector with output formats that generate a single
#' output file.
#' The output will remain as is.
#' @param token the user token for Zenodo.
#' By default an attempt will be made to retrieve token using `zenodo_pat()`.
#' @param sandbox When `TRUE`, upload a test version to
#' https://sandbox.zenodo.org.
#' When `FALSE`, upload the final version to https://zenodo.org.
#' @param logger Type of logger for Zenodo upload.
#' Defaults to `"INFO"` which provides minimal logs.
#' Use `NULL` to hide the logs.
#' `"DEBUG"` provides the full log.
#' @family utils
#' @export
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom fs dir_create dir_delete dir_ls file_delete is_dir is_file
#' path_abs path_ext_remove path_rel
#' @importFrom rmarkdown clean_site render_site yaml_front_matter
#' @importFrom utils zip
#' @importFrom withr defer
bookdown_zenodo <- function(
  path, zip_format = c("bookdown::gitbook", "INBOmd::gitbook"),
  single_format = c(
    "bookdown::pdf_book", "bookdown::epub_book", "INBOmd::pdf_report",
    "INBOmd::epub_book"
  ), token, sandbox = TRUE, logger = "INFO"
) {
  assert_that(
    is.string(path), noNA(path), inherits(zip_format, "character"),
    noNA(zip_format), inherits(single_format, "character"), noNA(single_format),
    assert_that(requireNamespace("bookdown", quietly = TRUE))
  )
  assert_that(is_dir(path), msg = "`path` is not an existing directory")
  assert_that(
    is_file(path(path, "index.Rmd")), msg = "index.Rmd not found in `path`"
  )
  assert_that(
    is_file(path(path, "_bookdown.yml")),
    msg = "_bookdown.yml not found in `path`"
  )

  path(path, "_bookdown.yml") |>
    file(encoding = "UTF-8") -> con
  bookdown_yml <- readLines(con)
  close(con)
  bookname <- bookdown_yml[grepl("book_filename", bookdown_yml)]
  gsub("book_filename:\\s*\"(.*)\"", "\\1", bookname) |>
    path_ext_remove() -> bookname
  bookdown_yml[grepl("output_dir:", bookdown_yml)] |>
    gsub(pattern = "output_dir: \"(.*)\"", replacement = "\\1") -> output_dir
  stopifnot(
    "no `output_dir:` found in `_bookdown.yml`" = length(output_dir) > 0,
    "multiple `output_dir:` found in `_bookdown.yml`" = length(output_dir) < 2
  )

  yml <- yaml_front_matter(path(path, "index.Rmd"))
  formats <- names(yml[["output"]])
  assert_that(
    any(formats %in% c(zip_format, single_format)), msg = "No formats to render"
  )
  zip_format <- zip_format[zip_format %in% formats]
  single_format <- single_format[single_format %in% formats]

  cit <- citation_meta$new(path)
  if (length(cit$get_errors) > 0) {
    return(cit)
  }
  if (!is.null(logger)) {
    cit$print()
  }

  file_scope <- getOption("bookdown.render.file_scope")
  options(bookdown.render.file_scope = FALSE)
  defer(options(bookdown.render.file_scope = file_scope))
  old_wd <- getwd()
  defer(setwd(old_wd))

  path(path, output_dir) |>
    path_abs(output_dir) -> output_dir
  dir_create(output_dir)

  setwd(path)
  testing <- identical(Sys.getenv("TESTTHAT"), "true")
  clean_site(path, preview = !testing, quiet = testing)

  for (zip_i in seq_along(zip_format)) {
    # render report
    render_site(
      output_format = zip_format[zip_i], encoding = "UTF-8",
      quiet = is.null(logger)
    )
    # pack report into a zip archive
    dir_ls(output_dir, recurse = TRUE, regexp = "\\.zip", invert = TRUE) |>
      path_rel(output_dir) -> files
    setwd(output_dir)
    path(
      output_dir, paste(c(bookname, letters[zip_i - 1]), collapse = "_"),
      ext = "zip"
    ) |>
      zip(files = files, flags = "-r9XqT")
    # remove output except zip archive
    dir_ls(output_dir, type = "dir") |>
      dir_delete()
    dir_ls(output_dir, type = "file", regexp = "\\.zip", invert = TRUE) |>
      file_delete()
    setwd(path)
  }
  for (output_format in single_format) {
    render_site(
      output_format = output_format, encoding = "UTF-8", quiet = is.null(logger)
    )
  }
  dir_ls(output_dir, regexp = "reference-keys.txt") |>
    file_delete()

  path(path, ".zenodo.json") |>
    file_copy(output_dir, overwrite = TRUE)

  upload_zenodo(
    path = output_dir, token = token, sandbox = sandbox, logger = logger
  )
}
