# Clean the git repository

- update local branches that are behind their counterpart on origin.

- list local branches that have diverged from their counterpart the
  origin.

- list local branches without counterpart on origin that have diverged
  from the main branch.

- remove local branches without counterpart on origin and fully merged
  into the main branch.

- remove local copies of origin branches deleted at the origin.

## Usage

``` r
clean_git(repo = ".", verbose = TRUE)
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

- verbose:

  display some progress info while downloading

## See also

Other git:
[`create_draft_pr()`](https://inbo.github.io/checklist/reference/create_draft_pr.md),
[`get_branches_tags()`](https://inbo.github.io/checklist/reference/get_branches_tags.md),
[`is_repository()`](https://inbo.github.io/checklist/reference/is_repository.md),
[`is_workdir_clean()`](https://inbo.github.io/checklist/reference/is_workdir_clean.md),
[`new_branch()`](https://inbo.github.io/checklist/reference/new_branch.md),
[`set_tag()`](https://inbo.github.io/checklist/reference/set_tag.md)
