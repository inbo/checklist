# Pass command lines to a shell

Cross-platform function to pass a command to the shell, using either
[`base::system()`](https://rdrr.io/r/base/system.html) or (Windows-only)
[`base::shell()`](https://rdrr.io/r/base/system.html), depending on the
operating system.

## Usage

``` r
execshell(commandstring, intern = FALSE, path = ".", ...)
```

## Arguments

- commandstring:

  The system command to be invoked, as a string. Multiple commands can
  be combined in this single string, e.g. with a multiline string.

- intern:

  a logical (not `NA`) which indicates whether to capture the output of
  the command as an R character vector.

- path:

  The path from where the command string needs to be executed

- ...:

  Other arguments passed to
  [`base::system()`](https://rdrr.io/r/base/system.html) or
  [`base::shell()`](https://rdrr.io/r/base/system.html).

## See also

Other utils:
[`ask_rightsholder_funder()`](https://inbo.github.io/checklist/reference/ask_rightsholder_funder.md),
[`ask_yes_no()`](https://inbo.github.io/checklist/reference/ask_yes_no.md),
[`author2df()`](https://inbo.github.io/checklist/reference/author2df.md),
[`bookdown_zenodo()`](https://inbo.github.io/checklist/reference/bookdown_zenodo.md),
[`c_sort()`](https://inbo.github.io/checklist/reference/c_sort.md),
[`create_hexsticker()`](https://inbo.github.io/checklist/reference/create_hexsticker.md),
[`get_default_org_list()`](https://inbo.github.io/checklist/reference/get_default_org_list.md),
[`inbo_org_list()`](https://inbo.github.io/checklist/reference/inbo_org_list.md),
[`install_pak()`](https://inbo.github.io/checklist/reference/install_pak.md),
[`menu_first()`](https://inbo.github.io/checklist/reference/menu_first.md),
[`store_authors()`](https://inbo.github.io/checklist/reference/store_authors.md),
[`use_author()`](https://inbo.github.io/checklist/reference/use_author.md),
[`validate_email()`](https://inbo.github.io/checklist/reference/validate_email.md),
[`validate_orcid()`](https://inbo.github.io/checklist/reference/validate_orcid.md),
[`yesno()`](https://inbo.github.io/checklist/reference/yesno.md)
