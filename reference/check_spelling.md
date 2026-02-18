# Spell check a package or project

This function checks by default any markdown (`.md`) or Rmarkdown
(`.Rmd`) file found within the project. It also checks any R help file
(`.Rd`) in the `man` folder. Use the `set_exceptions()` method of the
`checklist` object to exclude files or use a different language. Have a
look at
[`vignette("spelling", package = "checklist")`](https://inbo.github.io/checklist/articles/spelling.md)
for more details.

## Usage

``` r
check_spelling(x = ".", quiet = FALSE)
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

- quiet:

  Whether to print check output during checking.

## See also

Other both:
[`add_agents()`](https://inbo.github.io/checklist/reference/add_agents.md),
[`add_issue_templates()`](https://inbo.github.io/checklist/reference/add_issue_templates.md),
[`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md),
[`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md),
[`custom_dictionary()`](https://inbo.github.io/checklist/reference/custom_dictionary.md),
[`print.checklist_spelling()`](https://inbo.github.io/checklist/reference/print.checklist_spelling.md),
[`read_checklist()`](https://inbo.github.io/checklist/reference/read_checklist.md),
[`update_citation()`](https://inbo.github.io/checklist/reference/update_citation.md),
[`write_checklist()`](https://inbo.github.io/checklist/reference/write_checklist.md)
