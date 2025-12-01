# Check the packages for linters

This functions does [static code
analysis](https://en.wikipedia.org/wiki/Static_program_analysis). It
relies on
[`lintr::lint_package()`](https://lintr.r-lib.org/reference/lint.html).
We recommend that you activate all code diagnostics in RStudio to help
meeting the requirements. You can find this in the menu *Tools* \>
*Global options* \> *Code* \> *Diagnostics*. Please have a look at
[`vignette("philosophy")`](https://inbo.github.io/checklist/articles/philosophy.md)
for more details on the rules.

## Usage

``` r
check_lintr(x = ".", quiet = FALSE)
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

- quiet:

  Whether to print check output during checking.

## Details

When `check_lintr()` runs on a git repository, it checks whether the
organisation has a custom `.lintr` file in their `checklist` repository.
If so, it uses this file. Otherwise it looks for a local `.lintr` file
in the project directory. If this file is not present, it uses the
default `.lintr` file provided with the `checklist` package.

## See also

Other both:
[`add_badges()`](https://inbo.github.io/checklist/reference/add_badges.md),
[`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md),
[`check_spelling()`](https://inbo.github.io/checklist/reference/check_spelling.md),
[`custom_dictionary()`](https://inbo.github.io/checklist/reference/custom_dictionary.md),
[`default_organisation()`](https://inbo.github.io/checklist/reference/default_organisation.md),
[`print.checklist_spelling()`](https://inbo.github.io/checklist/reference/print.checklist_spelling.md),
[`read_checklist()`](https://inbo.github.io/checklist/reference/read_checklist.md),
[`read_organisation()`](https://inbo.github.io/checklist/reference/read_organisation.md),
[`update_citation()`](https://inbo.github.io/checklist/reference/update_citation.md),
[`write_checklist()`](https://inbo.github.io/checklist/reference/write_checklist.md),
[`write_citation_cff()`](https://inbo.github.io/checklist/reference/write_citation_cff.md),
[`write_organisation()`](https://inbo.github.io/checklist/reference/write_organisation.md),
[`write_zenodo_json()`](https://inbo.github.io/checklist/reference/write_zenodo_json.md)
