# The checklist R6 class

A class which contains all checklist results.

## See also

Other class:
[`spelling`](https://inbo.github.io/checklist/reference/spelling.md)

## Super class

[`spelling`](https://inbo.github.io/checklist/reference/spelling.md) -\>
`checklist`

## Public fields

- `package`:

  A logical indicating whether the source code refers to a package.

## Active bindings

- `get_checked`:

  A vector with checked topics.

- `get_gha_install`:

  A vector with bash commands for GitHub Actions.

- `get_path`:

  The path to the package.

- `get_pak`:

  Packages to install with
  [`pak::pkg_install()`](https://pak.r-lib.org/reference/pkg_install.html).

- `get_required`:

  A vector with the names of the required checks.

- `get_spelling`:

  Return the issues found by
  [`check_spelling()`](https://inbo.github.io/checklist/reference/check_spelling.md)

- `fail`:

  A logical indicating if any required check fails.

- `template`:

  A list for a check list template.

## Methods

### Public methods

- [`checklist$add_error()`](#method-checklist-add_error)

- [`checklist$add_linter()`](#method-checklist-add_linter)

- [`checklist$add_motivation()`](#method-checklist-add_motivation)

- [`checklist$add_notes()`](#method-checklist-add_notes)

- [`checklist$add_rcmdcheck()`](#method-checklist-add_rcmdcheck)

- [`checklist$add_spelling()`](#method-checklist-add_spelling)

- [`checklist$add_warnings()`](#method-checklist-add_warnings)

- [`checklist$allowed()`](#method-checklist-allowed)

- [`checklist$confirm_motivation()`](#method-checklist-confirm_motivation)

- [`checklist$new()`](#method-checklist-initialize)

- [`checklist$print()`](#method-checklist-print)

- [`checklist$set_pak()`](#method-checklist-set_pak)

- [`checklist$set_gha_install()`](#method-checklist-set_gha_install)

- [`checklist$set_required()`](#method-checklist-set_required)

- [`checklist$clone()`](#method-checklist-clone)

Inherited methods

- [`spelling$set_default()`](https://inbo.github.io/checklist/reference/spelling.html#method-set_default)
- [`spelling$set_exceptions()`](https://inbo.github.io/checklist/reference/spelling.html#method-set_exceptions)
- [`spelling$set_ignore()`](https://inbo.github.io/checklist/reference/spelling.html#method-set_ignore)
- [`spelling$set_other()`](https://inbo.github.io/checklist/reference/spelling.html#method-set_other)

------------------------------------------------------------------------

### `checklist$add_error()`

Add errors

#### Usage

    checklist$add_error(errors, item, keep = TRUE)

#### Arguments

- `errors`:

  A vector with errors.

- `item`:

  The item on which to store the errors.

- `keep`:

  Keep old results

------------------------------------------------------------------------

### `checklist$add_linter()`

Add results from
[`lintr::lint_package()`](https://lintr.r-lib.org/reference/lint.html)

#### Usage

    checklist$add_linter(linter, error = FALSE)

#### Arguments

- `linter`:

  A vector with linter errors.

- `error`:

  A logical indicating if the linter should be considered an error.

------------------------------------------------------------------------

### `checklist$add_motivation()`

Add motivation for allowed issues.

#### Usage

    checklist$add_motivation(which = c("warnings", "notes"))

#### Arguments

- `which`:

  Which kind of issue to add.

------------------------------------------------------------------------

### `checklist$add_notes()`

Add notes

#### Usage

    checklist$add_notes(notes, item)

#### Arguments

- `notes`:

  A vector with notes.

- `item`:

  The item on which to store the notes.

------------------------------------------------------------------------

### `checklist$add_rcmdcheck()`

Add results from
[`rcmdcheck::rcmdcheck`](http://r-lib.github.io/rcmdcheck/reference/rcmdcheck.md)

#### Usage

    checklist$add_rcmdcheck(errors, warnings, notes)

#### Arguments

- `errors`:

  A vector with errors.

- `warnings`:

  A vector with warning messages.

- `notes`:

  A vector with notes.

------------------------------------------------------------------------

### `checklist$add_spelling()`

Add results from
[`check_spelling()`](https://inbo.github.io/checklist/reference/check_spelling.md)

#### Usage

    checklist$add_spelling(issues)

#### Arguments

- `issues`:

  A `data.frame` with spell checking issues.

------------------------------------------------------------------------

### `checklist$add_warnings()`

Add warnings

#### Usage

    checklist$add_warnings(warnings, item)

#### Arguments

- `warnings`:

  A vector with warnings.

- `item`:

  The item on which to store the warnings.

------------------------------------------------------------------------

### `checklist$allowed()`

Add allowed warnings and notes

#### Usage

    checklist$allowed(
      warnings = vector(mode = "list", length = 0),
      notes = vector(mode = "list", length = 0)
    )

#### Arguments

- `warnings`:

  A vector with allowed warning messages. Defaults to an empty list.

- `notes`:

  A vector with allowed notes. Defaults to an empty list.

- `package`:

  Does the check list refers to a package. Defaults to `TRUE`.

------------------------------------------------------------------------

### `checklist$confirm_motivation()`

Confirm the current motivation for allowed issues.

#### Usage

    checklist$confirm_motivation(which = c("warnings", "notes"))

#### Arguments

- `which`:

  Which kind of issue to confirm.

------------------------------------------------------------------------

### `checklist$new()`

Initialize a new `checklist` object.

#### Usage

    checklist$new(x = ".", language, package = TRUE)

#### Arguments

- `x`:

  The path to the root of the project.

- `language`:

  The default language for spell checking.

- `package`:

  Is this a package or a project?

------------------------------------------------------------------------

### `checklist$print()`

Print the `checklist` object. Add `quiet = TRUE` to suppress printing.

#### Usage

    checklist$print(...)

#### Arguments

- `...`:

  See description.

------------------------------------------------------------------------

### `checklist$set_pak()`

Set packages to install with
[`pak::pkg_install()`](https://pak.r-lib.org/reference/pkg_install.html).

#### Usage

    checklist$set_pak(pkg = character(0))

#### Arguments

- `pkg`:

  A vector of packages to install with
  [`pak::pkg_install()`](https://pak.r-lib.org/reference/pkg_install.html).

------------------------------------------------------------------------

### `checklist$set_gha_install()`

Set optional install commands for GitHub Actions

#### Usage

    checklist$set_gha_install(commands)

#### Arguments

- `commands`:

  A vector with commands.

------------------------------------------------------------------------

### `checklist$set_required()`

set required checks

#### Usage

    checklist$set_required(checks = character(0))

#### Arguments

- `checks`:

  a vector of required checks

------------------------------------------------------------------------

### `checklist$clone()`

The objects of this class are cloneable with this method.

#### Usage

    checklist$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
