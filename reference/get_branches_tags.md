# Get branches and tags of a GitHub repository

Get branches and tags of a GitHub repository

## Usage

``` r
get_branches_tags(owner, repo)
```

## Arguments

- owner:

  Repository owner

- repo:

  Repository name

## Value

A sorted character vector of branch and tag names, excluding the
`gh-pages` branch.

## See also

Other git:
[`clean_git()`](https://inbo.github.io/checklist/reference/clean_git.md),
[`create_draft_pr()`](https://inbo.github.io/checklist/reference/create_draft_pr.md),
[`is_repository()`](https://inbo.github.io/checklist/reference/is_repository.md),
[`is_workdir_clean()`](https://inbo.github.io/checklist/reference/is_workdir_clean.md),
[`new_branch()`](https://inbo.github.io/checklist/reference/new_branch.md),
[`set_tag()`](https://inbo.github.io/checklist/reference/set_tag.md)
