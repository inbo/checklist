# Make hexagonal logo for package

This function makes a hexagonal logo in INBO style for the provided
package name.

## Usage

``` r
create_hexsticker(
  package_name,
  filename = path("man", "figures", "logo.svg"),
  icon,
  x = 0,
  y = 0,
  scale = 1
)
```

## Arguments

- package_name:

  package name that should be mentioned on the hexagonal sticker.

- filename:

  filename to save the sticker.

- icon:

  optional filename to an `.svg` file with an icon.

- x:

  number of pixels to move the icon to the right. Use negative numbers
  to move the icon to the left.

- y:

  number of pixels to move the icon to the bottom. Use negative numbers
  to move the icon to the top.

- scale:

  Scales the `icon`.

## Value

A figure is saved in the working directory or provided path.

## See also

Other utils:
[`ask_rightsholder_funder()`](https://inbo.github.io/checklist/reference/ask_rightsholder_funder.md),
[`ask_yes_no()`](https://inbo.github.io/checklist/reference/ask_yes_no.md),
[`author2df()`](https://inbo.github.io/checklist/reference/author2df.md),
[`bookdown_zenodo()`](https://inbo.github.io/checklist/reference/bookdown_zenodo.md),
[`c_sort()`](https://inbo.github.io/checklist/reference/c_sort.md),
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

## Examples

``` r
if (FALSE) { # \dontrun{
# make tempfile to save logo (or just use (path and) filename)
#' output <- tempfile(pattern = "hexsticker", fileext = ".svg")
create_hexsticker("checklist", filename = output)
} # }
```
