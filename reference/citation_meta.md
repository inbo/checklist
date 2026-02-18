# The `citation_meta` R6 class

A class which contains citation information.

## See also

Other class:
[`checklist`](https://inbo.github.io/checklist/reference/checklist.md),
[`org_item`](https://inbo.github.io/checklist/reference/org_item.md),
[`org_list`](https://inbo.github.io/checklist/reference/org_list.md),
[`organisation`](https://inbo.github.io/checklist/reference/organisation.md),
[`spelling`](https://inbo.github.io/checklist/reference/spelling.md)

## Active bindings

- `get_errors`:

  Return the errors

- `get_meta`:

  Return the meta data as a list

- `get_notes`:

  Return the notes

- `get_person`:

  Return the authors and organisations as a list of `person` objects.

- `get_type`:

  A string indicating the type of source.

- `get_path`:

  The path to the project.

- `get_warnings`:

  Return the warnings

## Methods

### Public methods

- [`citation_meta$new()`](#method-citation_meta-new)

- [`citation_meta$print()`](#method-citation_meta-print)

- [`citation_meta$clone()`](#method-citation_meta-clone)

------------------------------------------------------------------------

### Method `new()`

Initialize a new `citation_meta` object.

#### Usage

    citation_meta$new(path = ".")

#### Arguments

- `path`:

  The path to the root of the project.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print the `citation_meta` object.

#### Usage

    citation_meta$print(...)

#### Arguments

- `...`:

  currently ignored.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    citation_meta$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
