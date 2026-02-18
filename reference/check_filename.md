# Check the style of file and folder names

A consistent naming schema avoids problems when working together,
especially when working with different OS. Some OS (e.g. Windows) are
case-insensitive whereas others (e.g. Linux) are case-sensitive. Note
that the `checklist` GitHub Actions will test your code on Linux,
Windows and MacOS.

## Usage

``` r
check_filename(x = ".")
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

## Details

The sections below describe the default rules. We allow several
exceptions when the community standard is different. E.g. a package
stores the function scripts in the `R` folder, while our standard
enforces lower case folder names. Use the community standard, even if it
does not conform with the `checklist` rules. Most likely `checklist`
will have an exception for the name. If not, you can file an
[issue](https://github.com/inbo/checklist/issues) and motivate why you
think we should add an exception.

## Rules for folder names

- Folder names should only contain lower case letters, numbers, dashes
  (`-`) and underscores (`_`).

- They can start with a single dot (`.`).

## Default rules for file names

- Base names should only contain lower case letters, numbers, dashes
  (`-`) and underscores (`_`).

- File extensions should only contain lower case letters and numbers.
  Exceptions: file extensions related to `R` must have an upper case `R`
  ( `.R`, `.Rd`, `.Rda`, `.Rnw`, `.Rmd`, `.Rproj`). Exception to these
  exceptions: `R/sysdata.rda`.

## Exceptions for some file formats

Underscores (`_`) causes problems for graphical files when using LaTeX
to create pdf output. This is how we generate pdf output from rmarkdown.
Therefore you need to use a dash (`-`) as separator instead of an
underscores (`_`). Applies to files with extensions `csl`, `eps`, `gif`,
`jpg`, `jpeg`, `pdf`, `png`, `ps`, `svg`, `tiff`, `tif`, `wmf` and
`.cls`.

We ignore files with `.otf` or `.ttf` extensions. These are fonts files
which often require their own file name scheme.

## See also

Other both:
[`add_badges()`](https://inbo.github.io/checklist/reference/add_badges.md),
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
