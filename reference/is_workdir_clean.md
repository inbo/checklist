# Check if the current working directory of a repo is clean

A clean working directory has no staged, unstaged or untracked files.

## Usage

``` r
is_workdir_clean(repo)
```

## Arguments

- repo:

  The path to the git repository. If the directory is not a repository,
  parent directories are considered (see
  [git_find](https://docs.ropensci.org/gert/reference/git_repo.html)).
  To disable this search, provide the filepath protected with
  [`I()`](https://rdrr.io/r/base/AsIs.html). When using this parameter,
  always explicitly call by name (i.e. `repo = `) because future
  versions of gert may have additional parameters.

## Value

`TRUE` when there are no staged, unstaged or untracked files. Otherwise
`FALSE`

## See also

Other git:
[`clean_git()`](https://inbo.github.io/checklist/reference/clean_git.md),
[`create_draft_pr()`](https://inbo.github.io/checklist/reference/create_draft_pr.md),
[`get_branches_tags()`](https://inbo.github.io/checklist/reference/get_branches_tags.md),
[`is_repository()`](https://inbo.github.io/checklist/reference/is_repository.md),
[`new_branch()`](https://inbo.github.io/checklist/reference/new_branch.md),
[`set_tag()`](https://inbo.github.io/checklist/reference/set_tag.md)
