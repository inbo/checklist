# Determine if a directory is in a git repository

The path arguments specifies the directory at which to start the search
for a git repository. If it is not a git repository itself, then its
parent directory is consulted, then the parent's parent, and so on.

## Usage

``` r
is_repository(path = ".")
```

## Arguments

- path:

  the location of the git repository, see details.

## Value

TRUE if directory is in a git repository else FALSE

## See also

Other git:
[`clean_git()`](https://inbo.github.io/checklist/reference/clean_git.md),
[`create_draft_pr()`](https://inbo.github.io/checklist/reference/create_draft_pr.md),
[`get_branches_tags()`](https://inbo.github.io/checklist/reference/get_branches_tags.md),
[`is_workdir_clean()`](https://inbo.github.io/checklist/reference/is_workdir_clean.md),
[`new_branch()`](https://inbo.github.io/checklist/reference/new_branch.md),
[`set_tag()`](https://inbo.github.io/checklist/reference/set_tag.md)
