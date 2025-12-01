# Write a check list with allowed issues in the source code

checklist stores it configuration as a `checklist.yml` file.
[`create_package()`](https://inbo.github.io/checklist/reference/create_package.md),
[`setup_package()`](https://inbo.github.io/checklist/reference/setup_package.md)
and
[`setup_source()`](https://inbo.github.io/checklist/reference/setup_source.md)
generate a default file. If you need to allow some warnings or notes,
you need to update the configuration.

## Usage

``` r
write_checklist(x = ".")
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

## Details

First run `x <- checklist::check_package()` or
`x <- checklist::check_source()`. These commands run the checks and
store the `checklist` object in the variable `x`. Next you can store the
configuration with `checklist::write_checklist(x)`. This will first list
any existing allowed warnings or notes. For every one of them, choose
whether you want to keep it or not. Next, the function presents every
new warning or note which you may allow or not. If you choose to allow a
warning or note, you must provide a motivation. Please provide a
sensible motivation. Keep in mind that `checklist.yml` stores these
motivations in plain text, so they are visible for other users. We use
the [`yesno()`](https://inbo.github.io/checklist/reference/yesno.md)
function to make sure you carefully read the questions.

## Caveat

When you allow a warning or note, this warning or note must appear.
Otherwise you get a "missing warning" or "missing note" error. So if you
fix an allowed warning or note, you need to rerun
`checklist::write_checklist(x)` and remove the old version.

If you can solve a warning or note, then solve it rather than to allow
it. Only allow a warning or note in case of a generic "problem" that you
can't solve. The best example is the
`checking CRAN incoming feasibility ... NOTE New submission` which
appears when checking a package not on
[CRAN](https://cran.r-project.org/). That is should an allowed note as
long as the package is not on CRAN. Or permanently when your package is
not intended for CRAN.

Do not allow a warning or note to fix an issue specific to your machine.
That will result in an error when checking the package on an other
machine (e.g. GitHub actions).

## See also

Other both:
[`add_badges()`](https://inbo.github.io/checklist/reference/add_badges.md),
[`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md),
[`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md),
[`check_spelling()`](https://inbo.github.io/checklist/reference/check_spelling.md),
[`custom_dictionary()`](https://inbo.github.io/checklist/reference/custom_dictionary.md),
[`default_organisation()`](https://inbo.github.io/checklist/reference/default_organisation.md),
[`print.checklist_spelling()`](https://inbo.github.io/checklist/reference/print.checklist_spelling.md),
[`read_checklist()`](https://inbo.github.io/checklist/reference/read_checklist.md),
[`read_organisation()`](https://inbo.github.io/checklist/reference/read_organisation.md),
[`update_citation()`](https://inbo.github.io/checklist/reference/update_citation.md),
[`write_citation_cff()`](https://inbo.github.io/checklist/reference/write_citation_cff.md),
[`write_organisation()`](https://inbo.github.io/checklist/reference/write_organisation.md),
[`write_zenodo_json()`](https://inbo.github.io/checklist/reference/write_zenodo_json.md)
