# A function that asks a yes or no question to the user

A function that asks a yes or no question to the user

## Usage

``` r
yesno(...)
```

## Arguments

- ...:

  Currently ignored

## Value

A logical where `TRUE` implies a "yes" answer from the user.

## See also

Other utils:
[`ask_rightsholder_funder()`](https://inbo.github.io/checklist/reference/ask_rightsholder_funder.md),
[`ask_yes_no()`](https://inbo.github.io/checklist/reference/ask_yes_no.md),
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
[`validate_orcid()`](https://inbo.github.io/checklist/reference/validate_orcid.md)

## Author

Hadley Wickham <Hadley@Rstudio.com> Largely based on
`devtools:::yesno()`. The user gets three options in an random order: 2
for "no", 1 for "yes". The wording for "yes" and "no" is random as well.
This forces the user to carefully read the question.
