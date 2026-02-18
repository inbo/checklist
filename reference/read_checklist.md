# Read the check list file from a package

The checklist package stores configuration information in the
`checklist.yml` file in the root of a project. This function reads this
configuration. It is mainly used by the other functions inside the
package. If no `checklist.yml` file is found at the path, the function
walks upwards through the directory structure until it finds such file.
The function returns an error when it reaches the root of the disk
without finding a `checklist.yml` file.

## Usage

``` r
read_checklist(x = ".")
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

## Value

A `checklist` object.

## See also

Other both:
[`add_badges()`](https://inbo.github.io/checklist/reference/add_badges.md),
[`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md),
[`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md),
[`check_spelling()`](https://inbo.github.io/checklist/reference/check_spelling.md),
[`custom_dictionary()`](https://inbo.github.io/checklist/reference/custom_dictionary.md),
[`default_organisation()`](https://inbo.github.io/checklist/reference/default_organisation.md),
[`print.checklist_spelling()`](https://inbo.github.io/checklist/reference/print.checklist_spelling.md),
[`read_organisation()`](https://inbo.github.io/checklist/reference/read_organisation.md),
[`update_citation()`](https://inbo.github.io/checklist/reference/update_citation.md),
[`write_checklist()`](https://inbo.github.io/checklist/reference/write_checklist.md),
[`write_citation_cff()`](https://inbo.github.io/checklist/reference/write_citation_cff.md),
[`write_organisation()`](https://inbo.github.io/checklist/reference/write_organisation.md),
[`write_zenodo_json()`](https://inbo.github.io/checklist/reference/write_zenodo_json.md)
