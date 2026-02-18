# add badges to a README

- `check_package`: add a package check badge

- `check_project`: add a project check badge

- `doi`: add a DOI badge

- `url`: add a website badge

- `version`: add a version badge

## Usage

``` r
add_badges(x = ".", ...)
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

- ...:

  Additional arguments

## See also

Other both:
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
[`write_organisation()`](https://inbo.github.io/checklist/reference/write_organisation.md),
[`write_zenodo_json()`](https://inbo.github.io/checklist/reference/write_zenodo_json.md)

## Examples

``` r
if (FALSE) { # \dontrun{
  add_badges(url = "https://www.inbo.be")
  add_badges(doi = "10.5281/zenodo.8063503")
  add_badges(check_project = "inbo/checklist")
  add_badges(check_package = "inbo/checklist")
  add_badges(version = "v0.1.2")
  add_badges(url = "https://www.inbo.be", doi = "10.5281/zenodo.8063503")
} # }
```
