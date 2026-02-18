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
[`c_sort()`](https://inbo.github.io/checklist/reference/c_sort.md),
[`create_hexsticker()`](https://inbo.github.io/checklist/reference/create_hexsticker.md),
[`install_pak()`](https://inbo.github.io/checklist/reference/install_pak.md),
[`yesno()`](https://inbo.github.io/checklist/reference/yesno.md)
