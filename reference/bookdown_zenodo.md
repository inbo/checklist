# Render a `bookdown` and upload to Zenodo

First clears all the existing files in the `output_dir` set in
`_bookdown_.yml`. Then renders all required output formats and uploads
them to Zenodo. `bookdown_zenodo()` creates a draft record when you
don't specify a community in the yaml. Otherwise it creates a review
request for the first community.

## Usage

``` r
bookdown_zenodo(
  path,
  zip_format = c("bookdown::gitbook", "INBOmd::gitbook"),
  single_format = c("bookdown::pdf_book", "bookdown::epub_book", "INBOmd::pdf_report",
    "INBOmd::epub_book"),
  token,
  sandbox = TRUE,
  logger = "INFO"
)
```

## Arguments

- path:

  The root folder of the report

- zip_format:

  A vector with output formats that generate multiple files. The
  function will bundle all the files in a zip file for every format.

- single_format:

  A vector with output formats that generate a single output file. The
  output will remain as is.

- token:

  the user token for Zenodo. By default an attempt will be made to
  retrieve token using `zenodo_pat()`.

- sandbox:

  When `TRUE`, upload a test version to https://sandbox.zenodo.org. When
  `FALSE`, upload the final version to https://zenodo.org.

- logger:

  Type of logger for Zenodo upload. Defaults to `"INFO"` which provides
  minimal logs. Use `NULL` to hide the logs. `"DEBUG"` provides the full
  log.

## See also

Other utils:
[`ask_rightsholder_funder()`](https://inbo.github.io/checklist/reference/ask_rightsholder_funder.md),
[`ask_yes_no()`](https://inbo.github.io/checklist/reference/ask_yes_no.md),
[`author2df()`](https://inbo.github.io/checklist/reference/author2df.md),
[`c_sort()`](https://inbo.github.io/checklist/reference/c_sort.md),
[`create_hexsticker()`](https://inbo.github.io/checklist/reference/create_hexsticker.md),
[`execshell()`](https://inbo.github.io/checklist/reference/execshell.md),
[`get_default_org_list()`](https://inbo.github.io/checklist/reference/get_default_org_list.md),
[`inbo_org_list()`](https://inbo.github.io/checklist/reference/inbo_org_list.md),
[`install_pak()`](https://inbo.github.io/checklist/reference/install_pak.md),
[`menu_first()`](https://inbo.github.io/checklist/reference/menu_first.md),
[`store_authors()`](https://inbo.github.io/checklist/reference/store_authors.md),
[`use_author()`](https://inbo.github.io/checklist/reference/use_author.md),
[`validate_email()`](https://inbo.github.io/checklist/reference/validate_email.md),
[`validate_orcid()`](https://inbo.github.io/checklist/reference/validate_orcid.md),
[`yesno()`](https://inbo.github.io/checklist/reference/yesno.md)
