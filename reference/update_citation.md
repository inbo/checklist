# Create or update the citation files

The function extracts citation meta data from the project. Then it
checks the required meta data. Upon success, it writes several files.

## Usage

``` r
update_citation(x = ".", quiet = FALSE)
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

- quiet:

  Whether to print check output during checking.

## Value

An invisible `checklist` object.

## Details

- `.zenodo.json` contains the citation information in the format that
  [Zenodo](https://zenodo.org) requires.

- `CITATION.cff` provides the citation information in the format that
  [GitHub](https://github.com) requires.

- `inst/CITATION` provides the citation information in the format that R
  packages require. It is only relevant for packages.

## Note

Source of the citation meta data:

- package: `DESCRIPTION`

- project: `README.md`

Should you want to add more information to the `inst/CITATION` file, add
it to that file outside `# begin checklist entry` and
`# end checklist entry`.

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
[`write_checklist()`](https://inbo.github.io/checklist/reference/write_checklist.md),
[`write_citation_cff()`](https://inbo.github.io/checklist/reference/write_citation_cff.md),
[`write_organisation()`](https://inbo.github.io/checklist/reference/write_organisation.md),
[`write_zenodo_json()`](https://inbo.github.io/checklist/reference/write_zenodo_json.md)
