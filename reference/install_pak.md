# Install extra packages defined in `checklist.yml`

Install extra packages defined in `checklist.yml`

## Usage

``` r
install_pak(x = ".", ...)
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

- ...:

  Additional arguments passed to
  [`pak::pkg_install()`](https://pak.r-lib.org/reference/pkg_install.html)

## See also

Other utils:
[`ask_rightsholder_funder()`](https://inbo.github.io/checklist/reference/ask_rightsholder_funder.md),
[`c_sort()`](https://inbo.github.io/checklist/reference/c_sort.md),
[`create_hexsticker()`](https://inbo.github.io/checklist/reference/create_hexsticker.md),
[`execshell()`](https://inbo.github.io/checklist/reference/execshell.md),
[`yesno()`](https://inbo.github.io/checklist/reference/yesno.md)
