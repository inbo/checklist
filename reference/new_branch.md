# Create a new branch after cleaning the repo

This functions first runs
[`clean_git()`](https://inbo.github.io/checklist/reference/clean_git.md).
Then it creates the new branch from the (updated) main branch.

## Usage

``` r
new_branch(branch, verbose = TRUE, checkout = TRUE, repo = ".")
```

## Arguments

- branch:

  name of branch to check out

- verbose:

  display some progress info while downloading

- checkout:

  move HEAD to the newly created branch

- repo:

  The path to the git repository. If the directory is not a repository,
  parent directories are considered (see
  [git_find](https://docs.ropensci.org/gert/reference/git_repo.html)).
  To disable this search, provide the filepath protected with
  [`I()`](https://rdrr.io/r/base/AsIs.html). When using this parameter,
  always explicitly call by name (i.e. `repo = `) because future
  versions of gert may have additional parameters.

## See also

Other git:
[`clean_git()`](https://inbo.github.io/checklist/reference/clean_git.md),
[`create_draft_pr()`](https://inbo.github.io/checklist/reference/create_draft_pr.md),
[`get_branches_tags()`](https://inbo.github.io/checklist/reference/get_branches_tags.md),
[`is_repository()`](https://inbo.github.io/checklist/reference/is_repository.md),
[`is_workdir_clean()`](https://inbo.github.io/checklist/reference/is_workdir_clean.md),
[`set_tag()`](https://inbo.github.io/checklist/reference/set_tag.md)
