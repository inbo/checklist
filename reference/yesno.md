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
[`c_sort()`](https://inbo.github.io/checklist/reference/c_sort.md),
[`create_hexsticker()`](https://inbo.github.io/checklist/reference/create_hexsticker.md),
[`execshell()`](https://inbo.github.io/checklist/reference/execshell.md),
[`install_pak()`](https://inbo.github.io/checklist/reference/install_pak.md)

## Author

Hadley Wickham <Hadley@Rstudio.com> Largely based on
`devtools:::yesno()`. The user gets three options in an random order: 2
for "no", 1 for "yes". The wording for "yes" and "no" is random as well.
This forces the user to carefully read the question.
