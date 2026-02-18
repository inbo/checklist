# Changelog

## checklist 0.5.3

- Add publisher to `.zenodo.json`
  ([\#180](https://github.com/inbo/checklist/issues/180)).
- Add grant ID for EU-funded Zenodo communities
  ([\#182](https://github.com/inbo/checklist/issues/182)).
- Correctly handle ROR
  ([\#184](https://github.com/inbo/checklist/issues/184))
- Fix Zenodo DOI badge in README.

## checklist 0.5.2

- Only create the contributing guidelines or code of conduct file when
  the user answers “yes” on the related questions.

## checklist 0.5.1

- bugfix in
  [`check_license()`](https://inbo.github.io/checklist/reference/check_license.md)
  which failed when no correct license information is available in
  `README.md` ([\#166](https://github.com/inbo/checklist/issues/166)).
- The `check_project` GitHub Action now restores the R environment using
  `renv` when a `renv.lock` file is present. It also gains an `APTGET`
  argument to install system dependencies via `apt-get`.

## checklist 0.5.0

### Breaking changes

- The `organisation` class is superseded by the `org_list` and
  `org_item` classes.
- Updated the
  [`vignette("organisation", package = "checklist")`](https://inbo.github.io/checklist/articles/organisation.md)
  to reflect the changes in the `organisation` class.
- `organisation` class and its related function like
  [`default_organisation()`](https://inbo.github.io/checklist/reference/default_organisation.md),
  [`read_organisation()`](https://inbo.github.io/checklist/reference/read_organisation.md)
  and
  [`write_organisation()`](https://inbo.github.io/checklist/reference/write_organisation.md)
  are deprecated.
- The new `org_list` enforces the use of the INBO ROR
  ([\#153](https://github.com/inbo/checklist/issues/153)).

### New functions

- [`get_default_org_list()`](https://inbo.github.io/checklist/reference/get_default_org_list.md)
  returns the default organisation list depending on the git remote
  `origin`.
- [`new_org_list()`](https://inbo.github.io/checklist/reference/new_org_list.md)
  creates a new `org_list` object based on interactive questions.
- [`create_draft_pr()`](https://inbo.github.io/checklist/reference/create_draft_pr.md)
  creates a draft pull request on GitHub.

### Other changes

- [`create_package()`](https://inbo.github.io/checklist/reference/create_package.md)
  and
  [`create_project()`](https://inbo.github.io/checklist/reference/create_project.md)
  now fully work based on interactive questions.
- Updated the formatting of the code with
  [`air`](https://posit-dev.github.io/air/).
- The GitHub Actions now install missing packages on the fly
  ([\#152](https://github.com/inbo/checklist/issues/152)).
- Improved output on missing warning and notes
  ([\#155](https://github.com/inbo/checklist/issues/155)).
- `check_folders()` now handles nested folders
  ([\#156](https://github.com/inbo/checklist/issues/156)).
- [`check_project()`](https://inbo.github.io/checklist/reference/check_project.md)
  now works on GitHub Actions with projects using `renv`
  ([\#158](https://github.com/inbo/checklist/issues/158)).
- [`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md)
  turns missing dependencies into an error.
- [`check_source()`](https://inbo.github.io/checklist/reference/check_source.md)
  is now defunct.
- Removed the defunct `orcid2person()`.
- Reworked the
  [`vignette("philosophy", package = "checklist")`](https://inbo.github.io/checklist/articles/philosophy.md)
  and
  [`vignette("getting_started", package = "checklist")`](https://inbo.github.io/checklist/articles/getting_started.md)

## checklist 0.4.2

- [`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md)
  checks for missing dependencies.
- Checking projects on GitHub Actions try to install the missing
  dependencies.
- [`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md)
  includes
  [`lintr::indentation_linter()`](https://lintr.r-lib.org/reference/indentation_linter.html).
- Increase the time-out in
  [`check_cran()`](https://inbo.github.io/checklist/reference/check_cran.md).
- Docker image installs the latest version of `TeXLive`.
- Docker image installs missing packages on the fly.
- [`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md)
  ignores symbolic links.
- When the path is a git repository,
  [`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md)
  and
  [`check_folder()`](https://inbo.github.io/checklist/reference/check_folder.md)
  only check the files and directories under version control.
- [`check_folder()`](https://inbo.github.io/checklist/reference/check_folder.md)
  allows quarto specific `_extensions` and `_files` folders.
- [`citation_meta()`](https://inbo.github.io/checklist/reference/citation_meta.md)
  now supports `quarto` documents.
- Improved support for `quarto` documents in
  [`check_spelling()`](https://inbo.github.io/checklist/reference/check_spelling.md).
- [`add_badges()`](https://inbo.github.io/checklist/reference/add_badges.md)
  can create a version badge.
- [`create_draft_pr()`](https://inbo.github.io/checklist/reference/create_draft_pr.md)
  returns the URL of the draft pull request.
- Fix bug in
  [`use_author()`](https://inbo.github.io/checklist/reference/use_author.md)
  ([\#149](https://github.com/inbo/checklist/issues/149)).

## checklist 0.4.1

- Add new function
  [`create_draft_pr()`](https://inbo.github.io/checklist/reference/create_draft_pr.md).
- Escape quotes in the `CITATION` file.
- Install packages in `Dockerfile` using `pak`.
- [`check_description()`](https://inbo.github.io/checklist/reference/check_description.md)
  doesn’t require a funder when not set in the organisation.
- `check_document()` handles unexported functions in the documentation.
- [`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md)
  requires the `cyclocomp` package.
- Improved extraction of citation information.
- Fix false positive from
  [`check_spelling()`](https://inbo.github.io/checklist/reference/check_spelling.md)
  as requested in [\#147](https://github.com/inbo/checklist/issues/147).
- Improve
  [`author2df()`](https://inbo.github.io/checklist/reference/author2df.md).

## checklist 0.4.0

- Updated `README.md`.
- Improved support for `organisation`.
- Add
  [`set_license()`](https://inbo.github.io/checklist/reference/set_license.md).
- [`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md)
  allows a `CODEOWNERS` file.
- The checklist summary displays the unstaged git changes.
- The GitHub Action on packages installs the `roxygen2` version listed
  in the `DESCRIPTION` of the package it checks.

## checklist 0.3.6

- Add an `organisation` class to store organisation rules different from
  those of the Research Institute for Nature and Forest (INBO). See
  [`vignette("organisation", package = "checklist")`](https://inbo.github.io/checklist/articles/organisation.md)
  for more information.
- The output of the check shows the git diff
  ([\#77](https://github.com/inbo/checklist/issues/77)).
- [`add_badges()`](https://inbo.github.io/checklist/reference/add_badges.md)
  helps to add badges to the `README`.
- Put double quotes around the title and abstract fields of
  `CITATION.cff`.
- [`check_documentation()`](https://inbo.github.io/checklist/reference/check_documentation.md)
  handles assignment functions and re-exported functions correctly.
- [`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md)
  ignores `renv` subdirectories
  ([\#118](https://github.com/inbo/checklist/issues/118)).
- Update to [`zen4R`](https://github.com/eblondel/zen4R/wiki) version
  0.10 to reflect the Zenodo API changes
  ([\#125](https://github.com/inbo/checklist/issues/125)).
- [`update_citation()`](https://inbo.github.io/checklist/reference/update_citation.md)
  no longer introduces new lines
  ([\#124](https://github.com/inbo/checklist/issues/124)) and handles
  single quotes in titles
  ([\#115](https://github.com/inbo/checklist/issues/115)).
- You can add multiple affiliations per author
  ([\#123](https://github.com/inbo/checklist/issues/123)). Separate them
  by a semi-colon (;) in a `DESCRIPTION` or the yaml of a bookdown. Use
  multiple footnotes is a `README.md`.
- [`check_spelling()`](https://inbo.github.io/checklist/reference/check_spelling.md)
  handles leading or trailing backwards slashes
  ([\#107](https://github.com/inbo/checklist/issues/107)).
- [`check_cran()`](https://inbo.github.io/checklist/reference/check_cran.md)
  ignores irrelevant CRAN notes.

## checklist 0.3.5

- Fix release GitHub Action.
- Bugfix in
  [`update_citation()`](https://inbo.github.io/checklist/reference/update_citation.md)
  on a `DESCRIPTION`.
- [`check_spelling()`](https://inbo.github.io/checklist/reference/check_spelling.md)
  handles Roxygen2 tags `@aliases`, `@importMethodsFrom`, `@include`,
  `@keywords`, `@method`, `@name`, `@slot`

## checklist 0.3.4

- [`check_spelling()`](https://inbo.github.io/checklist/reference/check_spelling.md)
  ignores numbers.
- Ask which GitHub organisation to use when create a new project.
  Default equals the organisation’s default.
- GitHub Action for project allow to install package prior to checking
  the project. Use this in case
  [`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md)
  returns an error about global variables in a function and you did
  [`require()`](https://rdrr.io/r/base/library.html) the package.
- Fix release GitHub Action.

## checklist 0.3.3

- New
  [`organisation()`](https://inbo.github.io/checklist/reference/organisation.md)
  class to hold the requirements of the organisation. For the time being
  this is hard-coded to the Research Institute for Nature and Forest
  (INBO).
- Author affiliations must match one of the affiliations set in
  [`organisation()`](https://inbo.github.io/checklist/reference/organisation.md).
  The membership of an author is determined by their e-mail or their
  affiliation. This is checked when creating or using author information
  and when updating citation information.
- [`read_checklist()`](https://inbo.github.io/checklist/reference/read_checklist.md)
  looks for `checklist.yml` in parent folders when it can’t find it in
  the provided path.
- [`validate_orcid()`](https://inbo.github.io/checklist/reference/validate_orcid.md)
  checks the format and the checksum of the ORCID.
- Add
  [`vignette("folder", package = "checklist")`](https://inbo.github.io/checklist/articles/folder.md).

## checklist 0.3.2

- [`citation_meta()`](https://inbo.github.io/checklist/reference/citation_meta.md)
  gains support for [`bookdown`](https://pkgs.rstudio.com/bookdown/)
  reports.
- Add
  [`bookdown_zenodo()`](https://inbo.github.io/checklist/reference/bookdown_zenodo.md)
  which first extracts the citation metadata from the yaml header. Then
  it cleans the output folder and renders the required output formats.
  Finally it uploads the rendered files to a draft deposit on
  [Zenodo](https://zenodo.org).
- [`setup_project()`](https://inbo.github.io/checklist/reference/setup_project.md)
  and
  [`create_project()`](https://inbo.github.io/checklist/reference/create_project.md)
  provides support for [`renv`](https://pkgs.rstudio.com/renv/).

## checklist 0.3.1

- Fixes two bugs in case `MIT` license was chosen
- GitHub Actions now uses the latest version of checklist as default
  when checking packages or projects.

## checklist 0.3.0

- Improved
  [`create_project()`](https://inbo.github.io/checklist/reference/create_project.md)
  and
  [`setup_project()`](https://inbo.github.io/checklist/reference/setup_project.md)
  which interactively guides the user through the set-up.
- Add
  [`vignette("getting_started_project", package = "checklist")`](https://inbo.github.io/checklist/articles/getting_started_project.md).
- Improved GitHub Actions. They use the built-in `GITHUB_TOKEN`. The
  user only needs to set the `CODECOV_TOKEN` in case of a package.
- Fixes a note about `"MIT"` license.
- The Dockerimage uses the same dictionaries as the local installation.
- Add a German dictionary?
- Spell check `roxygen2` tags in `.R` files.
- Don’t spell check `.Rd` files generated by `roxygen2`.
- [`check_cran()`](https://inbo.github.io/checklist/reference/check_cran.md)
  ignores `Days since last update` note.
- [`check_documentation()`](https://inbo.github.io/checklist/reference/check_documentation.md)
  yields a warning when it find documented but unexported function. Use
  the `@noRD` tag in case you still want to document the function
  without exporting it.
- Improved error messages for `check_news()`.
- [`check_source()`](https://inbo.github.io/checklist/reference/check_source.md)
  is now deprecated. Use
  [`check_project()`](https://inbo.github.io/checklist/reference/check_project.md)
  instead.
- Parse `DESCRIPTION` (for a package) or `README.md` (for a project) to
  extract citation information into a `citation_meta` object. Then
  export this object into the different citation files.
- Standardise the `DESCRIPTION` and `README.md` to accommodate all
  citation information. `DESCRIPTION` gains `checklist` specific
  settings like `Config/checklist/communities` and
  `Config/checklist/keywords`.
- Store author information to reuse when running
  [`create_package()`](https://inbo.github.io/checklist/reference/create_package.md)
  or
  [`create_project()`](https://inbo.github.io/checklist/reference/create_project.md).
- Add
  [`check_folder()`](https://inbo.github.io/checklist/reference/check_folder.md).

## checklist 0.2.6

- [`check_license()`](https://inbo.github.io/checklist/reference/check_license.md)
  allows `"MIT"` license in addition to `"GPLv3"` for packages

## checklist 0.2.5

- Add spell checking functionality. See
  [`vignette("spelling", package = "checklist")`](https://inbo.github.io/checklist/articles/spelling.md)
  for more details.
- The `checklist` class stores the required checks.
- Add
  [`setup_project()`](https://inbo.github.io/checklist/reference/setup_project.md)
  to set-up `checklist` on an existing project. This function allows the
  user to choose which checks to be required.
- Add
  [`check_project()`](https://inbo.github.io/checklist/reference/check_project.md)
  to run the required checks of a project.
- Fix bug in `.zenodo.json` when only one keyword is present.

## checklist 0.2.4

- [`check_description()`](https://inbo.github.io/checklist/reference/check_description.md)
  enforces a `Language` field with a valid \[ISO 639-3 code\]
  (<https://en.wikipedia.org/wiki/Wikipedia:WikiProject_Languages/List_of_ISO_639-3_language_codes_(2019)>).
- [`create_package()`](https://inbo.github.io/checklist/reference/create_package.md)
  gains a required `language` argument. This adds the required
  `Language` field to the `DESCRIPTION`.
- `checklist` objects gain an `update_keywords` method. This is
  currently only relevant for packages. Usage: check your package with
  `x <- check_package()`. Add keywords with
  `x$update_keywords(c("keyword 1", "keyword 2")`. The method adds the
  keyword `"R package"` automatically. Store the keywords with
  `write_checklist(x)`. Run
  [`update_citation()`](https://inbo.github.io/checklist/reference/update_citation.md)
  to update the citation files with the keywords. Use `x$get_keywords()`
  to retrieve the current keywords.
- Improve the extraction of the DOI from the URL field.
- Allow `.rda` files in the `inst` folder of a package.
- Allow back ticks around package name in `NEWS.md`.
- Add
  [`prepare_ghpages()`](https://inbo.github.io/checklist/reference/prepare_ghpages.md).
- [`check_cran()`](https://inbo.github.io/checklist/reference/check_cran.md)
  ignores the insufficient package version when checking the main
  branch. This required when checking an R package when the current
  version equals the latest version on CRAN.
- Define explicit which lintr options to use.

## checklist 0.2.3

- Add
  [`vignette("zenodo")`](https://inbo.github.io/checklist/articles/zenodo.md)
  on how to set up the integration with [Zenodo](https://zenodo.org) and
  [ORCID](https://orcid.org)
- [`check_environment()`](https://inbo.github.io/checklist/reference/check_environment.md)
  makes sure that the required repository secrets are set.
  [`check_package()`](https://inbo.github.io/checklist/reference/check_package.md)
  performs this check when it runs in a GitHub Action. A missing
  repository secret results in an error. It points to
  [`vignette("getting_started")`](https://inbo.github.io/checklist/articles/getting_started.md)
  which indicates how to solve it.

### Bugfix

- Fix problem in
  [`write_zenodo_json()`](https://inbo.github.io/checklist/reference/write_zenodo_json.md)
  which produced a `.zenodo.json` which failed to parse on
  <https://zenodo.org>.
- [`write_zenodo_json()`](https://inbo.github.io/checklist/reference/write_zenodo_json.md)
  and
  [`write_citation_cff()`](https://inbo.github.io/checklist/reference/write_citation_cff.md)
  return the checklist object and pass it to
  [`update_citation()`](https://inbo.github.io/checklist/reference/update_citation.md).

## checklist 0.2.2

### Bugfix

- Update URLS to [`lintr`](https://github.com/r-lib/lintr).

## checklist 0.2.1

### Bugfix

- Fixed git diff used by
  [`check_description()`](https://inbo.github.io/checklist/reference/check_description.md)
  when checking for changes in version number.

## checklist 0.2.0

- Migrate from [‘git2r’](https://docs.ropensci.org/git2r/) to
  [`gert`](https://docs.ropensci.org/gert/) to communicate with Git and
  GitHub

### Bugfix

- `update_package()` escapes double quotes in the abstract of
  `inst/CITATION`.
- Docker image uses the development version of
  [`lintr`](https://github.com/r-lib/lintr)
- [`check_source()`](https://inbo.github.io/checklist/reference/check_source.md)
  handles projects with [`renv`](https://rstudio.github.io/renv/) on
  GitHub Actions.

## checklist 0.1.14

- Improve error message when changes in `CITATION` need to be commit.
  ([\#64](https://github.com/inbo/checklist/issues/64))
- [`create_package()`](https://inbo.github.io/checklist/reference/create_package.md)
  can use maintainer information stored in the options. See
  [`usethis::use_description()`](https://usethis.r-lib.org/reference/use_description.html)
  on how to set the option.
- Add R universe badges to README.
- Add
  [`write_zenodo_json()`](https://inbo.github.io/checklist/reference/write_zenodo_json.md)
  and
  [`write_citation_cff()`](https://inbo.github.io/checklist/reference/write_citation_cff.md).
- Improve the checklist GitHub Actions.

### Bugfix

- [`create_package()`](https://inbo.github.io/checklist/reference/create_package.md)
  replaces package name place holder with actual package name in
  `_pkgdown.yml`.

## checklist 0.1.13

- A new function
  [`update_citation()`](https://inbo.github.io/checklist/reference/update_citation.md)
  creates or updates a default citation in `inst/CITATION`.
- When INBO is not listed as copyright holder,
  [`check_description()`](https://inbo.github.io/checklist/reference/check_description.md)
  returns a warning rather than an error. This implies that you can
  motivate to ignore it via
  [`write_checklist()`](https://inbo.github.io/checklist/reference/write_checklist.md).
  ([\#33](https://github.com/inbo/checklist/issues/33))
- Ignore all `.Rd` files when running
  [`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md).
  ([\#59](https://github.com/inbo/checklist/issues/59))
- [`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md)
  allows `R/sysdata.rda`.
  ([\#62](https://github.com/inbo/checklist/issues/62))

## checklist 0.1.12

### User visible changes

- New
  [`new_branch()`](https://inbo.github.io/checklist/reference/new_branch.md)
  function to start a new branch from the most recent version of the
  main branch. This function will run
  [`clean_git()`](https://inbo.github.io/checklist/reference/clean_git.md)
  before creating the new branch.
- [`check_package()`](https://inbo.github.io/checklist/reference/check_package.md)
  runs the
  [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
  by default in interactive sessions. The function gains a `pkgdown`
  argument to turn of this behaviour.

### Bugfixes

- [`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md)
  handles git repositories without commits.
- [`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md)
  ignores Rd files. They have use a different naming convention when
  generated by `roxygen2`.
- [`clean_git()`](https://inbo.github.io/checklist/reference/clean_git.md)
  yields cleaner warnings.
- [`create_hexsticker()`](https://inbo.github.io/checklist/reference/create_hexsticker.md)
  will create the target directory when it doesn’t exist.

### Package management

- Add Docker build tests.
- [`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md)
  ignores `docker-compose` files.

## checklist 0.1.11

- Exclude `renv` and `packrat` folders from
  [`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md).
- GitHub Actions bash script for packages checks out the main branch
  before setting tags.
- Install `codemetar` from GitHub because is it not available from CRAN.
- Install `devtools` from CRAN as the relevant version in available on
  CRAN.
- Add GitHub Action to automatically remove artefacts. This is required
  to keep the [used
  storage](https://github.com/inbo/tutorials/issues/251) to a minimum.
- Checks on different OS’s only halt on errors. Because importing
  `codemetar` from GitHub results in a warning.
- Don’t install dependencies automatically in the `Dockerfile`. This
  triggers an error when a dependency is not listed in the `Dockerfile`.
- `pkgdown` ensures that the reference page lists all exported
  functions.
- New `pkgdown` cascading style sheet.
- Bugfix in
  [`clean_git()`](https://inbo.github.io/checklist/reference/clean_git.md).

## checklist 0.1.10

### User visible changes

- Add
  [`clean_git()`](https://inbo.github.io/checklist/reference/clean_git.md)
  to bring a local git repo up-to-date.
  - Bring local branches up-to-date when there are behind the origin.
  - Remove remote branches when removed from the origin.
  - Remove local branches when fully merged into the main branch.
  - Warn for diverging branches.
- [`create_hexsticker()`](https://inbo.github.io/checklist/reference/create_hexsticker.md)
  yields an `svg` file instead of `png`. The user can optionally specify
  an `svg` icon file to add to the hexagonal sticker.
- Keep failed build artefacts only 14 days
  (<https://github.com/inbo/tutorials/issues/251>).

### Bugfixes

- Avoid false positive linters when `.Rproj` file is put under version
  control.
- `check_files()` considers files with `svg` extensions as graphical
  files.
- Minor bugfix in `entrypoint_package.sh`.

## checklist 0.1.9

### User visible changes

- Many communities, both on GitHub and in the wider Git community, are
  considering renaming the default branch name of their repository from
  `master`. GitHub is gradually renaming the default branch of our own
  repositories from `master` to `main`. Therefore `checklist` now allows
  both a `main` or `master` branch as default. In case both are present,
  `checklist` uses `main`. Using only a `master` branch yields a note.
  Hence you must either which to a `main` branch or allow the note with
  [`write_checklist()`](https://inbo.github.io/checklist/reference/write_checklist.md)
  ([\#44](https://github.com/inbo/checklist/issues/44)).

### Bugfixes

- Convert fancy single quotes to neutral single quotes
  ([\#42](https://github.com/inbo/checklist/issues/42)).
- Fix
  [`check_description()`](https://inbo.github.io/checklist/reference/check_description.md).

## checklist 0.1.8

- Create a release when pushing a tag starting with `v`. We use a GitHub
  Action to create the release instead of an R function.
- New function:
  [`setup_source()`](https://inbo.github.io/checklist/reference/setup_source.md)
  to setup projects with only source files.
- Add auxiliary function
  [`create_hexsticker()`](https://inbo.github.io/checklist/reference/create_hexsticker.md).
- Update
  [`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md)
  rules
  - Allow a `data-raw` folder
  - Allow more default GitHub file names
  - Ignore font files
  - `csl` files must follow the rules for graphics files
- [`create_package()`](https://inbo.github.io/checklist/reference/create_package.md)
  adds
  - URL and BugReports to `DESCRIPTION`
  - GitHub Actions
  - basic setup for [`pkgdown`](https://pkgdown.r-lib.org/).
- [`setup_package()`](https://inbo.github.io/checklist/reference/setup_package.md)
  updates `.Rbuildignore` and basic setup for
  [`pkgdown`](https://pkgdown.r-lib.org/).
- Add more documentation on all functions.
- Add two vignettes:
  - [`vignette("getting_started")`](https://inbo.github.io/checklist/articles/getting_started.md)
  - [`vignette("philosophy")`](https://inbo.github.io/checklist/articles/philosophy.md)
- Use Ubuntu 18.04 instead of the end of life Ubuntu 16.04 when checking
  the package on the previous R release
  ([\#31](https://github.com/inbo/checklist/issues/31)).

## checklist 0.1.7

- Pushing to master should automatically create a release, using
  [`set_tag()`](https://inbo.github.io/checklist/reference/set_tag.md).
- Add a Zenodo DOI badge to the README and DOI URL to DESCRIPTION.
- [`check_description()`](https://inbo.github.io/checklist/reference/check_description.md)
  now checks authors
  ([\#7](https://github.com/inbo/checklist/issues/7)).
  - INBO is set as copyright holder and funder.
  - Every author has an ORCID.
- [`setup_package()`](https://inbo.github.io/checklist/reference/setup_package.md)
  adds the required files for a `pkgdown` website
  ([\#21](https://github.com/inbo/checklist/issues/21)).

## checklist 0.1.6

- Drop the `codemeta.json` file. It requires constant updating as it
  contains a package file size.

## checklist 0.1.5

- [`check_documentation()`](https://inbo.github.io/checklist/reference/check_documentation.md)
  allows `NEWS.md` to have level 2 headings (`##`) and single line
  subitems (`*`). It doesn’t count URLs when determining the line of a
  line. This allows lines to be longer than 80 characters due to long
  URLs.
- [`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md)
  is more liberal.
  - Allows files ending on `-package.Rd`.
  - Allows `json` or `yml` files starting with a dot and followed by
    letters.
  - Allows filename `cran-comment.md` and `WORDLIST`.
  - Allows `man-roxygen` as folder name.
  - Requires underscore (`_`) as separator for non-graphics files.
  - Requires dash (`-`) as separator for graphics files.
  - Basename separator issue are warnings instead of errors. So you can
    allow these warnings via
    [`write_checklist()`](https://inbo.github.io/checklist/reference/write_checklist.md).
- Fix deploying pkgdown website and release.
- Package require a `codemeta.json` as written by
  [`codemetar::write_codemeta`](https://docs.ropensci.org/codemetar/reference/write_codemeta.html).
  Suggestions by `codemetar` to improve the package become checklist
  notes.
- [`set_tag()`](https://inbo.github.io/checklist/reference/set_tag.md)
  fails when in a detached HEAD state.
- [`set_tag()`](https://inbo.github.io/checklist/reference/set_tag.md)
  creates a release when a tag is created on GitHub.
- [`check_cran()`](https://inbo.github.io/checklist/reference/check_cran.md)
  ignores system time check when world clock API is not available.
- [`check_license()`](https://inbo.github.io/checklist/reference/check_license.md)
  verifies the license information of a package. This check is included
  via
  [`check_description()`](https://inbo.github.io/checklist/reference/check_description.md)
  in
  [`check_package()`](https://inbo.github.io/checklist/reference/check_package.md).

## checklist 0.1.4

- [`set_tag()`](https://inbo.github.io/checklist/reference/set_tag.md)
  skips if the tag already exists.
- [`create_package()`](https://inbo.github.io/checklist/reference/create_package.md)
  sets a code of conduct and contributing guidelines.
- [`create_package()`](https://inbo.github.io/checklist/reference/create_package.md)
  sets `LICENSE.md`.
- Run
  [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
  during the [`check_pkg`](https://github.com/inbo/actions/) GitHub
  action.
- Deploy the `pkgdown` website to a `gp-pages` branch when pushing to
  master during the [`check_pkg`](https://github.com/inbo/actions/)
  GitHub action.

## checklist 0.1.3

- Add
  [`validate_email()`](https://inbo.github.io/checklist/reference/validate_email.md)
  to check for valid email addresses.
- Add `orcid2person()` which converts a valid ORCID into a `person`
  object.
- Add
  [`create_package()`](https://inbo.github.io/checklist/reference/create_package.md)
  which prepare an RStudio project with an empty package.

## checklist 0.1.2

- Correctly check the package version on the master branch and during
  rebasing.
- Updating the master branch will set a tag with the current version.

## checklist 0.1.1

- Added a `NEWS.md` file to track changes to the package.
- Added a `README.Rmd` file with installation instructions.
- Rework `checklist_template()` into
  [`write_checklist()`](https://inbo.github.io/checklist/reference/write_checklist.md).
- Add
  [`check_description()`](https://inbo.github.io/checklist/reference/check_description.md).
- Add
  [`check_documentation()`](https://inbo.github.io/checklist/reference/check_documentation.md).
- Add
  [`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md).
- Add
  [`check_source()`](https://inbo.github.io/checklist/reference/check_source.md).
- [`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md)
  also works on source code repositories.
- Activate GitHub action `inbo/check_package`.

## checklist 0.1.0

- Initial version.
- Create `checklist` R6 class.
- Add
  [`check_cran()`](https://inbo.github.io/checklist/reference/check_cran.md).
- Add
  [`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md).
- Add
  [`check_package()`](https://inbo.github.io/checklist/reference/check_package.md).
- Add
  [`read_checklist()`](https://inbo.github.io/checklist/reference/read_checklist.md).
- Add `checklist_template()`.
- Add Dockerimage for GitHub actions.
