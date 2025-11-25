# Write organisation settings

Store the organisation rules into `organisation.yml` file. First run
`org <- organisation$new()` with the appropriate argument. Next you can
store the configuration with `write_organisation(org)`.

## Usage

``` r
write_organisation(org, x = ".")
```

## Arguments

- org:

  An `organisation` object. Create it with `organisation$new()`.

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

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
[`write_checklist()`](https://inbo.github.io/checklist/reference/write_checklist.md),
[`write_citation_cff()`](https://inbo.github.io/checklist/reference/write_citation_cff.md),
[`write_zenodo_json()`](https://inbo.github.io/checklist/reference/write_zenodo_json.md)
