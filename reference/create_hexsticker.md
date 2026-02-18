# Make hexagonal logo for package

This function makes a hexagonal logo in INBO style for the provided
package name.

## Usage

``` r
create_hexsticker(
  package_name,
  filename = file.path("man", "figures", "logo.svg"),
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
[`c_sort()`](https://inbo.github.io/checklist/reference/c_sort.md),
[`execshell()`](https://inbo.github.io/checklist/reference/execshell.md),
[`install_pak()`](https://inbo.github.io/checklist/reference/install_pak.md),
[`yesno()`](https://inbo.github.io/checklist/reference/yesno.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# make tempfile to save logo (or just use (path and) filename)
#' output <- tempfile(pattern = "hexsticker", fileext = ".svg")
create_hexsticker("checklist", filename = output)
} # }
```
