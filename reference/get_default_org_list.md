# Get the default organization list

This function retrieves the default organisation list from the
`organisation.yml` file in the organisations `checklist` repository. The
`origin` of the repository is used to determine the root URL of the
organisation.

## Usage

``` r
get_default_org_list(x = ".")
```

## Arguments

- x:

  The path to the repository. Defaults to the current working directory.

## Value

An `org_list` object containing the organisation list. The function also
stores the information in the user's R configuration.

## See also

Other utils:
[`ask_rightsholder_funder()`](https://inbo.github.io/checklist/reference/ask_rightsholder_funder.md),
[`ask_yes_no()`](https://inbo.github.io/checklist/reference/ask_yes_no.md),
[`author2df()`](https://inbo.github.io/checklist/reference/author2df.md),
[`bookdown_zenodo()`](https://inbo.github.io/checklist/reference/bookdown_zenodo.md),
[`c_sort()`](https://inbo.github.io/checklist/reference/c_sort.md),
[`create_hexsticker()`](https://inbo.github.io/checklist/reference/create_hexsticker.md),
[`execshell()`](https://inbo.github.io/checklist/reference/execshell.md),
[`inbo_org_list()`](https://inbo.github.io/checklist/reference/inbo_org_list.md),
[`install_pak()`](https://inbo.github.io/checklist/reference/install_pak.md),
[`menu_first()`](https://inbo.github.io/checklist/reference/menu_first.md),
[`store_authors()`](https://inbo.github.io/checklist/reference/store_authors.md),
[`use_author()`](https://inbo.github.io/checklist/reference/use_author.md),
[`validate_email()`](https://inbo.github.io/checklist/reference/validate_email.md),
[`validate_orcid()`](https://inbo.github.io/checklist/reference/validate_orcid.md),
[`yesno()`](https://inbo.github.io/checklist/reference/yesno.md)
