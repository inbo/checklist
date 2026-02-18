
## Breaking changes

* Many citation-related functions have been moved to the new
  [`citeme`](https://github.com/inbo/citeme) package (>= 0.1.1).
  The following functions are no longer part of `checklist`:
  `citation_meta()`, `default_organisation()`, `get_available_organisations()`,
  `get_default_org_list()`, `new_org_list()`, `org_item`, `org_list`,
  `organisation`, `read_organisation()`, `store_authors()`,
  `upload_zenodo()`, `use_author()`, `write_citation_cff()`,
  `write_organisation()`, and `write_zenodo_json()`.
* `bookdown_zenodo()` is removed.
* `add_badges()` is renamed to `add_checklist_badges()`.
* `check_codemeta()` is removed because it provided not much extra information.
  This also allows us to remove a dependency.
* `create_draft_pr()` and `get_branches_tags()` are removed to remove the
  dependency on `gh`.
  Note that we now have a GitHub template for pull requests.

## New functions

* `add_agents()` installs AI agent configuration files (`.github/agents/`) in
  a package repository.
  `create_package()` and `setup_package()` now call this function automatically.
* `add_issue_templates()` adds GitHub issue and pull request templates to a
  package repository.
  `create_package()` and `setup_package()` now call this function automatically.
* `fix_duplicate_git_config()` removes duplicate entries from the local git
  config, fixing issues that could prevent `clean_git()` from working (#191).

## Other changes

* `check_package()` gains a `timeout` argument to control the maximum time
  allowed for the CRAN checks.
* `check_cran()` now displays the full output of all failing tests.
* `check_filename()` allows `Makevars`, `Cargo.toml`, `Cargo.lock`, and
  `*.agent.md` file names.
* `check_lintr()` ignores the `tests/testthat/_problems` folder.
* `check_spelling()` improves the handling of Markdown URLs (#190) and world
  clock time-out errors.
* Submodule directories are ignored when running `check_lintr()`,
  `check_filename()`, `check_folder()`, and `check_spelling()` (#142).
* Updated compatibility with `roxygen2` >= 8.0.0.
* Add the [`CRANhaven`](https://www.cranhaven.org/) repository to reduce the
  impact of recently archived CRAN packages.
* `clean_git()` handles duplicate entries in `git config`.
* Reduce the number of layers in the Docker image.
