# Function to ask a simple yes no question Provides a simple wrapper around `utils::askYesNo()`. This function is used to ask questions in an interactive way. It repeats the question until a valid answer is given.

Function to ask a simple yes no question Provides a simple wrapper
around [`utils::askYesNo()`](https://rdrr.io/r/utils/askYesNo.html).
This function is used to ask questions in an interactive way. It repeats
the question until a valid answer is given.

## Usage

``` r
ask_yes_no(msg, default = TRUE, prompts = c("Yes", "No", "Cancel"), ...)
```

## Arguments

- msg:

  The prompt message for the user.

- default:

  The default response.

- prompts:

  Any of: a character vector containing 3 prompts corresponding to
  return values of `TRUE`, `FALSE`, or `NA`, or a single character value
  containing the prompts separated by `/` characters, or a function to
  call.

- ...:

  Additional parameters, ignored by the default function.

## See also

Other utils:
[`ask_rightsholder_funder()`](https://inbo.github.io/checklist/reference/ask_rightsholder_funder.md),
[`author2df()`](https://inbo.github.io/checklist/reference/author2df.md),
[`bookdown_zenodo()`](https://inbo.github.io/checklist/reference/bookdown_zenodo.md),
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
