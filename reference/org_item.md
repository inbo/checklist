# The `org_item` R6 class

A class containing a single organisation

## See also

Other class:
[`checklist`](https://inbo.github.io/checklist/reference/checklist.md),
[`citation_meta`](https://inbo.github.io/checklist/reference/citation_meta.md),
[`org_list`](https://inbo.github.io/checklist/reference/org_list.md),
[`organisation`](https://inbo.github.io/checklist/reference/organisation.md),
[`spelling`](https://inbo.github.io/checklist/reference/spelling.md)

## Active bindings

- `as_list`:

  The organisation as a list.

- `get_zenodo`:

  The organisation Zenodo community.

- `get_default_name`:

  The organisation default name.

- `get_email`:

  The organisation email.

- `get_funder`:

  The funder rules.

- `get_name`:

  The organisation names.

- `get_orcid`:

  The ORCID rules.

- `get_rightsholder`:

  The rightsholder rules.

## Methods

### Public methods

- [`org_item$new()`](#method-org_item-new)

- [`org_item$as_person()`](#method-org_item-as_person)

- [`org_item$compare_by_name()`](#method-org_item-compare_by_name)

- [`org_item$get_license()`](#method-org_item-get_license)

- [`org_item$get_pkgdown()`](#method-org_item-get_pkgdown)

- [`org_item$print()`](#method-org_item-print)

- [`org_item$clone()`](#method-org_item-clone)

------------------------------------------------------------------------

### Method `new()`

Initialize a new `org_item` object.

#### Usage

    org_item$new(
      name,
      email,
      orcid = FALSE,
      rightsholder = c("optional", "single", "shared", "when no other"),
      funder = c("optional", "single", "shared", "when no other"),
      license = list(package = c(`GPL-3.0` =
        paste("https://raw.githubusercontent.com/inbo/checklist/refs/heads/main",
        "inst/generic_template/gplv3.md", sep = "/"), MIT =
        paste("https://raw.githubusercontent.com/inbo/checklist/refs/heads/main",
        "inst/generic_template/mit.md", sep = "/")), project = c(`CC BY 4.0` =
        paste("https://raw.githubusercontent.com/inbo/checklist/refs/heads/main",
        "inst/generic_template/cc_by_4_0.md", sep = "/")), data = c(CC0 =
        paste("https://raw.githubusercontent.com/inbo/checklist",
        "131fe5829907079795533bfea767bf7df50c3cfd/inst/generic_template",
         "cc0.md", sep
        = "/"))),
      ror = "",
      zenodo = "",
      website = "",
      logo = ""
    )

#### Arguments

- `name`:

  A named vector with the organisation names in one or more languages.
  The first item in the vector is the default language. The names of the
  vector must match the language code.

- `email`:

  An email address for the organisation. Used to contact the
  organisation. And used to detect if a person is affiliated with the
  organisation.

- `orcid`:

  Whether the organisation requires an ORCID for every person that uses
  this organisation as affiliation.

- `rightsholder`:

  The required copyright holder status for the organisation.
  `"optional"` means that the organisation is not required as the
  copyright holder. `"single"` means that the organisation must be the
  only copyright holder. `"shared"` means that the organisation must be
  one of the copyright holders. `"when no other"` means that if no other
  copyright holder is specified, the organisation must be the copyright
  holder.

- `funder`:

  The required funder status for the organisation. The categories are
  the same as for `rightsholder`.

- `license`:

  A list with the allowed licenses by the organisation. The list may
  contain the following items: `package`, `project`, and `data`. Every
  item must be a named character vector with the allowed licenses. The
  names must match the license name. The values must either match the
  path to a license template in the `checklist` package or an absolute
  URL to publicly available markdown file with the license text. Use
  `character(0)` to indicate that the organisation does not require a
  specific license for that item. `package` defaults to
  `c("GPL-3.0", "MIT")`. `project` defaults to `"CC BY 4.0"`. `data`
  defaults to `"CC0 1.0"`.

- `ror`:

  The optional ROR ID of the organisation.

- `zenodo`:

  The optional Zenodo community ID of the organisation.

- `website`:

  The optional website URL of the organisation.

- `logo`:

  The optional logo URL of the organisation.

------------------------------------------------------------------------

### Method `as_person()`

as_person The organisation as a person.

#### Usage

    org_item$as_person(lang = names(private$name)[1], role = c("cph", "fnd"))

#### Arguments

- `lang`:

  The language to use for the organisation name. Defaults to the first
  language in the `name` vector.

- `role`:

  The role of the person in the organisation.

------------------------------------------------------------------------

### Method `compare_by_name()`

Compares the number of matching words with the organisation name. Either
`Inf` when there is a perfect match. Otherwise a number between 0 and 1
indicating the ratio of the matching words with the total number of
words in `name`. A value of 1 means that all words in `name` are present
in one of the organisation names but in a different order.

#### Usage

    org_item$compare_by_name(name)

#### Arguments

- `name`:

  The name to match.

------------------------------------------------------------------------

### Method `get_license()`

Get the organisation license.

#### Usage

    org_item$get_license(type = c("package", "project", "data", "all"))

#### Arguments

- `type`:

  The type of license to get. Can be one of `"package"`, `"project"`, or
  `"data"`. Defaults to `"package"`.

#### Returns

A named character vector with the allowed licenses.

------------------------------------------------------------------------

### Method `get_pkgdown()`

The pkgdown author field.

#### Usage

    org_item$get_pkgdown(lang)

#### Arguments

- `lang`:

  The language to use for the organisation name.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print the `org_item` object.

#### Usage

    org_item$print()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    org_item$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
