# The spelling R6 class

A class with the configuration for spell checking

## See also

Other class:
[`checklist`](https://inbo.github.io/checklist/reference/checklist.md)

## Active bindings

- `default`:

  The default language of the project.

- `get_md`:

  The markdown files within the project.

- `get_r`:

  The R files within the project.

- `get_rd`:

  The Rd files within the project.

- `settings`:

  A list with current spell checking settings.

## Methods

### Public methods

- [`spelling$new()`](#method-spelling-initialize)

- [`spelling$print()`](#method-spelling-print)

- [`spelling$set_default()`](#method-spelling-set_default)

- [`spelling$set_exceptions()`](#method-spelling-set_exceptions)

- [`spelling$set_ignore()`](#method-spelling-set_ignore)

- [`spelling$set_other()`](#method-spelling-set_other)

- [`spelling$clone()`](#method-spelling-clone)

------------------------------------------------------------------------

### `spelling$new()`

Initialize a new `spelling` object.

#### Usage

    spelling$new(language, base_path = ".")

#### Arguments

- `language`:

  the default language.

- `base_path`:

  the base path of the project

------------------------------------------------------------------------

### `spelling$print()`

Print the `spelling` object.

#### Usage

    spelling$print(...)

#### Arguments

- `...`:

  currently ignored.

------------------------------------------------------------------------

### `spelling$set_default()`

Define which files to ignore or to spell check in a different language.

#### Usage

    spelling$set_default(language)

#### Arguments

- `language`:

  The language.

------------------------------------------------------------------------

### `spelling$set_exceptions()`

Define which files to ignore or to spell check in a different language.

#### Usage

    spelling$set_exceptions()

------------------------------------------------------------------------

### `spelling$set_ignore()`

Manually set the ignore vector. Only use this if you known what you are
doing.

#### Usage

    spelling$set_ignore(ignore)

#### Arguments

- `ignore`:

  The character vector with ignore file patterns.

------------------------------------------------------------------------

### `spelling$set_other()`

Manually set the other list. Only use this if you known what you are
doing.

#### Usage

    spelling$set_other(other)

#### Arguments

- `other`:

  a list with file patterns per additional language.

------------------------------------------------------------------------

### `spelling$clone()`

The objects of this class are cloneable with this method.

#### Usage

    spelling$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
