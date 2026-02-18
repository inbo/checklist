# Which author to use

Reuse existing author information or add a new author. Allows to update
existing author information.

## Usage

``` r
use_author(email, lang)
```

## Arguments

- email:

  An optional email address. When given and it matches with a single
  person, the function immediately returns the information of that
  person.

- lang:

  The language to use for the affiliation. Defaults to the first
  language in the `name` vector of the `org_list` object. When the
  affiliation is not available in that language, it will use the first
  available language.

## Value

A data.frame with author information.

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
[`validate_email()`](https://inbo.github.io/checklist/reference/validate_email.md),
[`validate_orcid()`](https://inbo.github.io/checklist/reference/validate_orcid.md),
[`yesno()`](https://inbo.github.io/checklist/reference/yesno.md)
