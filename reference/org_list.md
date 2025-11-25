# The `org_list` R6 class

A class containing a list of organisations

## See also

Other class:
[`checklist`](https://inbo.github.io/checklist/reference/checklist.md),
[`citation_meta`](https://inbo.github.io/checklist/reference/citation_meta.md),
[`org_item`](https://inbo.github.io/checklist/reference/org_item.md),
[`organisation`](https://inbo.github.io/checklist/reference/organisation.md),
[`spelling`](https://inbo.github.io/checklist/reference/spelling.md)

## Active bindings

- `as_list`:

  The list of `org_item` objects.

- `get_default_name`:

  The organisations default name.

- `get_default_funder`:

  The default funder.

- `get_default_rightsholder`:

  The default rightsholder.

- `get_email`:

  The organisations email.

- `get_git`:

  The git organisation URL.

- `get_listed_licenses`:

  Return the available licenses.

- `get_languages`:

  The different languages of the organisations.

- `which_funder`:

  The required rightsholders.

- `which_rightsholder`:

  The required rightsholders.

## Methods

### Public methods

- [`org_list$add_item()`](#method-org_list-add_item)

- [`org_list$check()`](#method-org_list-check)

- [`org_list$get_allowed_licenses()`](#method-org_list-get_allowed_licenses)

- [`org_list$get_person()`](#method-org_list-get_person)

- [`org_list$get_zenodo_by_email()`](#method-org_list-get_zenodo_by_email)

- [`org_list$get_match()`](#method-org_list-get_match)

- [`org_list$get_name_by_domain()`](#method-org_list-get_name_by_domain)

- [`org_list$get_pkgdown()`](#method-org_list-get_pkgdown)

- [`org_list$new()`](#method-org_list-new)

- [`org_list$print()`](#method-org_list-print)

- [`org_list$read()`](#method-org_list-read)

- [`org_list$validate_person()`](#method-org_list-validate_person)

- [`org_list$validate_rules()`](#method-org_list-validate_rules)

- [`org_list$write()`](#method-org_list-write)

- [`org_list$clone()`](#method-org_list-clone)

------------------------------------------------------------------------

### Method `add_item()`

Add one or more `org_item` objects to the list.

#### Usage

    org_list$add_item(...)

#### Arguments

- `...`:

  One or more `org_item` objects.

------------------------------------------------------------------------

### Method `check()`

Check if the organisation list is compatible with the default as set in
the organisations git repository.

#### Usage

    org_list$check(x = ".")

#### Arguments

- `x`:

  The path to the project directory

------------------------------------------------------------------------

### Method `get_allowed_licenses()`

Return the allowed licenses.

#### Usage

    org_list$get_allowed_licenses(
      email = character(0),
      type = c("package", "project", "data", "all")
    )

#### Arguments

- `email`:

  The email addresses of the organisations. Returns all available
  licenses if missing.

- `type`:

  The type of license to return. Can be one of `"package"`, `"project"`,
  `"data"` or `"all"`.

------------------------------------------------------------------------

### Method `get_person()`

Return the organisation with matching email as a
[`person()`](https://rdrr.io/r/utils/person.html).

#### Usage

    org_list$get_person(email, role = c("cph", "fnd"), lang)

#### Arguments

- `email`:

  The email address of the organisation.

- `role`:

  The role of the person to return.

- `lang`:

  The language to return the organisation name in.

------------------------------------------------------------------------

### Method `get_zenodo_by_email()`

Return a vector of Zenodo communities associated with the organisations
with matching email.

#### Usage

    org_list$get_zenodo_by_email(email)

#### Arguments

- `email`:

  The email addresses to match against.

#### Returns

A character vector with the communities.

------------------------------------------------------------------------

### Method `get_match()`

Return the organisation with a matching name.

#### Usage

    org_list$get_match(name)

#### Arguments

- `name`:

  The name of the organisation to match.

#### Returns

A list with the organisation name, email and match ratio.

------------------------------------------------------------------------

### Method `get_name_by_domain()`

Return the organisation names with a matching email domain.

#### Usage

    org_list$get_name_by_domain(email, lang)

#### Arguments

- `email`:

  The email address to match the domain against.

- `lang`:

  The language to return the organisation name in.

#### Details

The function extracts the domain from the email address and matches it
against the organisation email addresses. If multiple organisations have
the same domain, the function returns all matching names. If the
language is not available for a specific organisation, it will return
the first available name.

#### Returns

A character vector with the organisation names.

------------------------------------------------------------------------

### Method `get_pkgdown()`

get_pkgdown The pkgdown author field

#### Usage

    org_list$get_pkgdown(lang)

#### Arguments

- `lang`:

  The language to use for affiliation.

------------------------------------------------------------------------

### Method `new()`

Initialize a new `org_list` object.

#### Usage

    org_list$new(..., git = character(0))

#### Arguments

- `...`:

  One or more `org_item` objects.

- `git`:

  An optional string with the absolute path to a git organisation. E.g.
  `"https://github.com/inbo"`

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print the `org_list` object.

#### Usage

    org_list$print()

------------------------------------------------------------------------

### Method `read()`

Read the `org_list` object from an `organisation.yml` file.

#### Usage

    org_list$read(x = ".")

#### Arguments

- `x`:

  The path to the directory where the `organisation.yml` file is stored.

------------------------------------------------------------------------

### Method `validate_person()`

Validate a `person` object given the `org_list` object.

#### Usage

    org_list$validate_person(person, lang)

#### Arguments

- `person`:

  The `person` object to validate.

- `lang`:

  The language to use for affiliation.

------------------------------------------------------------------------

### Method `validate_rules()`

Validate the rules for the rightsholder and funder.

#### Usage

    org_list$validate_rules(rightsholder = person(), funder = person())

#### Arguments

- `rightsholder`:

  The rightsholders as a `person` object.

- `funder`:

  The funders as a `person` object.

------------------------------------------------------------------------

### Method [`write()`](https://rdrr.io/r/base/write.html)

Write the `org_list` object to an `organisation.yml` file.

#### Usage

    org_list$write(x = ".", license = FALSE)

#### Arguments

- `x`:

  The path to the directory where the `organisation.yml` file should be
  written.

- `license`:

  Whether to include license information.

#### Returns

The path to the written `organisation.yml` file.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    org_list$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
