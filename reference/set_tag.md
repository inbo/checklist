# Set a New Tag

This function is a part of the GitHub Action. Therefore it only works
when run in a GitHub Action on the main or master branch. Otherwise it
will only return a message. It sets a new tag at the current commit
using the related entry from `NEWS.md` as message. This tag will turn
into a release.

## Usage

``` r
set_tag(x = ".")
```

## Arguments

- x:

  Either a `checklist` object or a path to the source code. Defaults to
  `.`.

## See also

Other git:
[`clean_git()`](https://inbo.github.io/checklist/reference/clean_git.md),
[`create_draft_pr()`](https://inbo.github.io/checklist/reference/create_draft_pr.md),
[`get_branches_tags()`](https://inbo.github.io/checklist/reference/get_branches_tags.md),
[`is_repository()`](https://inbo.github.io/checklist/reference/is_repository.md),
[`is_workdir_clean()`](https://inbo.github.io/checklist/reference/is_workdir_clean.md),
[`new_branch()`](https://inbo.github.io/checklist/reference/new_branch.md)
