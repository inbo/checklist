# The organisation R6 class

A class with the organisation defaults

## See also

Other class:
[`checklist`](https://inbo.github.io/checklist/reference/checklist.md),
[`citation_meta`](https://inbo.github.io/checklist/reference/citation_meta.md),
[`org_item`](https://inbo.github.io/checklist/reference/org_item.md),
[`org_list`](https://inbo.github.io/checklist/reference/org_list.md),
[`spelling`](https://inbo.github.io/checklist/reference/spelling.md)

## Active bindings

- `as_person`:

  The default organisation funder and rightsholder.

- `get_community`:

  The default organisation Zenodo communities.

- `get_email`:

  The default organisation email.

- `get_funder`:

  The default funder.

- `get_github`:

  The default GitHub organisation domain.

- `get_organisation`:

  The organisation requirements.

- `get_rightsholder`:

  The default rightsholder.

- `template`:

  A list for a check list template.

## Methods

### Public methods

- [`organisation$new()`](#method-organisation-new)

- [`organisation$print()`](#method-organisation-print)

- [`organisation$clone()`](#method-organisation-clone)

------------------------------------------------------------------------

### Method `new()`

Initialize a new `organisation` object.

#### Usage

    organisation$new(...)

#### Arguments

- `...`:

  The organisation settings. See the details.

#### Details

- `github`: the name of the github organisation. Set to `NA_character_`
  in case you don't want a mandatory github organisation.

- `community`: the mandatory Zenodo community. Defaults to `"inbo"`. Set
  to `NA_character_` in case you don't want a mandatory community.

- `email`: the e-mail of the organisation. Defaults to `"info@inbo.be"`.
  Set to `NA_character_` in case you don't want an organisation e-mail.

- `funder`: the funder. Defaults to
  `"Research Institute for Nature and Forest (INBO)"`. Set to
  `NA_character_` in case you don't want to set a funder.

- `rightsholder`: the rightsholder. Defaults to
  `"Research Institute for Nature and Forest (INBO)"`. Set to
  `NA_character_` in case you don't want to set a rightsholder.

- `organisation`: a named list with one or more organisation default
  rules. The names of the element must match the e-mail domain name of
  the organisation. Every element should be a named list containing
  `affiliation` and `orcid`. `affiliation` is a character vector with
  the approved organisation names in one or more languages.
  `orcid = TRUE` indicated a mandatory ORCiD for every member. Use an
  empty list in case you don't want to set this.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print the `organisation` object.

#### Usage

    organisation$print(...)

#### Arguments

- `...`:

  currently ignored.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    organisation$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
