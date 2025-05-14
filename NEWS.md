# checklist 0.4.3

* Fix bug in `check_folder()` #156

# checklist 0.4.2

* `check_lintr()` checks for missing dependencies.
* Checking projects on GitHub Actions try to install the missing dependencies.
* `check_lintr()` includes `lintr::indentation_linter()`.
* Increase the time-out in `check_cran()`.
* Docker image installs the latest version of `TeXLive`.
* Docker image installs missing packages on the fly.
* `check_filename()` ignores symbolic links.
* When the path is a git repository, `check_filename()` and `check_folder()`
  only check the files and directories under version control.
* `check_folder()` allows quarto specific `_extensions` and `_files` folders.
* `citation_meta()` now supports `quarto` documents.
* Improved support for `quarto` documents in `check_spelling()`.
* `add_badges()` can create a version badge.
* `create_draft_pr()` returns the URL of the draft pull request.
* Fix bug in `use_author()` (#149).

# checklist 0.4.1

* Add new function `create_draft_pr()`.
* Escape quotes in the `CITATION` file.
* Install packages in `Dockerfile` using `pak`.
* `check_description()` doesn't require a funder when not set in the
  organisation.
* `check_document()` handles unexported functions in the documentation.
* `check_lintr()` requires the `cyclocomp` package.
* Improved extraction of citation information.
* Fix false positive from `check_spelling()` as requested in #147.
* Improve `author2df()`.

# checklist 0.4.0

* Updated `README.md`.
* Improved support for `organisation`.
* Add `set_license()`.
* `check_filename()` allows a `CODEOWNERS` file.
* The checklist summary displays the unstaged git changes.
* The GitHub Action on packages installs the `roxygen2` version listed in the
  `DESCRIPTION` of the package it checks.

# checklist 0.3.6

* Add an `organisation` class to store organisation rules different from those
  of the Research Institute for Nature and Forest (INBO).
  See `vignette("organisation", package = "checklist")` for more information.
* The output of the check shows the git diff (#77).
* `add_badges()` helps to add badges to the `README`.
* Put double quotes around the title and abstract fields of `CITATION.cff`.
* `check_documentation()` handles assignment functions and re-exported functions
  correctly.
* `check_lintr()` ignores `renv` subdirectories (#118).
* Update to [`zen4R`](https://github.com/eblondel/zen4R/wiki) version 0.10 to
  reflect the Zenodo API changes (#125).
* `update_citation()` no longer introduces new lines (#124) and handles single
  quotes in titles (#115).
* You can add multiple affiliations per author (#123).
  Separate them by a semi-colon (;) in a `DESCRIPTION` or the yaml of a
  bookdown.
  Use multiple footnotes is a `README.md`.
* `check_spelling()` handles leading or trailing backwards slashes (#107).
* `check_cran()` ignores irrelevant CRAN notes.

# checklist 0.3.5

* Fix release GitHub Action.
* Bugfix in `update_citation()` on a `DESCRIPTION`.
* `check_spelling()` handles Roxygen2 tags `@aliases`, `@importMethodsFrom`,
  `@include`, `@keywords`, `@method`, `@name`, `@slot`

# checklist 0.3.4

* `check_spelling()` ignores numbers.
* Ask which GitHub organisation to use when create a new project.
  Default equals the organisation's default.
* GitHub Action for project allow to install package prior to checking the
  project.
  Use this in case `check_lintr()` returns an error about global variables in a
  function and you did `require()` the package.
* Fix release GitHub Action.

# checklist 0.3.3

* New `organisation()` class to hold the requirements of the organisation.
  For the time being this is hard-coded to the Research Institute for Nature
  and Forest (INBO).
* Author affiliations must match one of the affiliations set in
  `organisation()`.
  The membership of an author is determined by their e-mail or their
  affiliation.
  This is checked when creating or using author information and when updating
  citation information.
* `read_checklist()` looks for `checklist.yml` in parent folders when it can't
  find it in the provided path.
* `validate_orcid()` checks the format and the checksum of the ORCID.
* Add `vignette("folder", package = "checklist")`.

# checklist 0.3.2

* `citation_meta()` gains support for [`bookdown`](https://pkgs.rstudio.com/bookdown/) reports.
* Add `bookdown_zenodo()` which first extracts the citation metadata from the
  yaml header.
  Then it cleans the output folder and renders the required output formats.
  Finally it uploads the rendered files to a draft deposit on [Zenodo](https://zenodo.org).
* `setup_project()` and `create_project()` provides support for [`renv`](https://pkgs.rstudio.com/renv/).

# checklist 0.3.1

* Fixes two bugs in case `MIT` license was chosen
* GitHub Actions now uses the latest version of checklist as default when
  checking packages or projects.

# checklist 0.3.0

* Improved `create_project()` and `setup_project()` which interactively guides
  the user through the set-up.
* Add `vignette("getting_started_project", package = "checklist")`.
* Improved GitHub Actions.
  They use the built-in `GITHUB_TOKEN`.
  The user only needs to set the `CODECOV_TOKEN` in case of a package.
* Fixes a note about `"MIT"` license.
* The Dockerimage uses the same dictionaries as the local installation.
* Add a German dictionary?
* Spell check `roxygen2` tags in `.R` files.
* Don't spell check `.Rd` files generated by `roxygen2`.
* `check_cran()` ignores `Days since last update` note.
* `check_documentation()` yields a warning when it find documented but
  unexported function.
  Use the `@noRD` tag in case you still want to document the function without
  exporting it.
* Improved error messages for `check_news()`.
* `check_source()` is now deprecated.
  Use `check_project()` instead.
* Parse `DESCRIPTION` (for a package) or `README.md` (for a project) to extract
  citation information into a `citation_meta` object.
  Then export this object into the different citation files.
* Standardise the `DESCRIPTION` and `README.md` to accommodate all citation
  information.
  `DESCRIPTION` gains `checklist` specific settings like
  `Config/checklist/communities` and `Config/checklist/keywords`.
* Store author information to reuse when running `create_package()` or
  `create_project()`.
* Add `check_folder()`.

# checklist 0.2.6

* `check_license()` allows `"MIT"` license in addition to `"GPLv3"` for packages

# checklist 0.2.5

* Add spell checking functionality.
  See `vignette("spelling", package = "checklist")` for more details.
* The `checklist` class stores the required checks.
* Add `setup_project()` to set-up `checklist` on an existing project.
  This function allows the user to choose which checks to be required.
* Add `check_project()` to run the required checks of a project.
* Fix bug in `.zenodo.json` when only one keyword is present.

# checklist 0.2.4

* `check_description()` enforces a `Language` field with a valid
  [ISO 639-3 code] (https://en.wikipedia.org/wiki/Wikipedia:WikiProject_Languages/List_of_ISO_639-3_language_codes_(2019)).
* `create_package()` gains a required `language` argument.
  This adds the required `Language` field to the `DESCRIPTION`.
* `checklist` objects gain an `update_keywords` method.
  This is currently only relevant for packages.
  Usage: check your package with `x <- check_package()`.
  Add keywords with `x$update_keywords(c("keyword 1", "keyword 2")`.
  The method adds the keyword `"R package"` automatically.
  Store the keywords with `write_checklist(x)`.
  Run `update_citation()` to update the citation files with the keywords.
  Use `x$get_keywords()` to retrieve the current keywords.
* Improve the extraction of the DOI from the URL field.
* Allow `.rda` files in the `inst` folder of a package.
* Allow back ticks around package name in `NEWS.md`.
* Add `prepare_ghpages()`.
* `check_cran()` ignores the insufficient package version when checking the
  main branch.
  This required when checking an R package when the current version equals the
  latest version on CRAN.
* Define explicit which lintr options to use.

# checklist 0.2.3

* Add `vignette("zenodo")` on how to set up the integration with [Zenodo](https://zenodo.org) and
  [ORCID](https://orcid.org)
* `check_environment()` makes sure that the required repository secrets are set.
  `check_package()` performs this check when it runs in a GitHub Action.
  A missing repository secret results in an error.
  It points to `vignette("getting_started")` which indicates how to solve it.

## Bugfix

* Fix problem in `write_zenodo_json()` which produced a `.zenodo.json` which
  failed to parse on https://zenodo.org.
* `write_zenodo_json()` and `write_citation_cff()` return the checklist object
  and pass it to `update_citation()`.

# checklist 0.2.2

## Bugfix

* Update URLS to [`lintr`](https://github.com/r-lib/lintr).

# checklist 0.2.1

## Bugfix

* Fixed git diff used by `check_description()` when checking for changes in 
  version number.

# checklist 0.2.0

* Migrate from ['git2r'](https://docs.ropensci.org/git2r/) to [`gert`](https://docs.ropensci.org/gert/) to communicate with Git and GitHub

## Bugfix

* `update_package()` escapes double quotes in the abstract of `inst/CITATION`.
* Docker image uses the development version of [`lintr`](https://github.com/r-lib/lintr)
* `check_source()` handles projects with [`renv`](https://rstudio.github.io/renv/) on GitHub Actions.

# checklist 0.1.14

* Improve error message when changes in `CITATION` need to be commit. (#64)
* `create_package()` can use maintainer information stored in the options.
  See `usethis::use_description()` on how to set the option.
* Add R universe badges to README.
* Add `write_zenodo_json()` and `write_citation_cff()`.
* Improve the checklist GitHub Actions.

## Bugfix

* `create_package()` replaces package name place holder with actual package name
  in `_pkgdown.yml`.

# checklist 0.1.13

* A new function `update_citation()` creates or updates a default citation in
  `inst/CITATION`.
* When INBO is not listed as copyright holder, `check_description()` returns a
  warning rather than an error. 
  This implies that you can motivate to ignore it via `write_checklist()`. (#33)
* Ignore all `.Rd` files when running `check_filename()`. (#59)
* `check_filename()` allows `R/sysdata.rda`. (#62)

# checklist 0.1.12

## User visible changes

* New `new_branch()` function to start a new branch from the most recent version
  of the main branch.
  This function will run `clean_git()` before creating the new branch.
* `check_package()` runs the `pkgdown::build_site()` by default in interactive
  sessions.
  The function gains a `pkgdown` argument to turn of this behaviour.

## Bugfixes

* `check_filename()` handles git repositories without commits.
* `check_filename()` ignores Rd files.
  They have use a different naming convention when generated by `roxygen2`. 
* `clean_git()` yields cleaner warnings.
* `create_hexsticker()` will create the target directory when it doesn't exist.

## Package management

* Add Docker build tests.
* `check_filename()` ignores `docker-compose` files.

# checklist 0.1.11

* Exclude `renv` and `packrat` folders from `check_lintr()`.
* GitHub Actions bash script for packages checks out the main branch before
  setting tags.
* Install `codemetar` from GitHub because is it not available from CRAN.
* Install `devtools` from CRAN as the relevant version in available on CRAN.
* Add GitHub Action to automatically remove artefacts.
  This is required to keep the [used storage](https://github.com/inbo/tutorials/issues/251) to a minimum.
* Checks on different OS's only halt on errors.
  Because importing `codemetar` from GitHub results in a warning.
* Don't install dependencies automatically in the `Dockerfile`.
  This triggers an error when a dependency is not listed in the `Dockerfile`.
* `pkgdown` ensures that the reference page lists all exported functions.
* New `pkgdown` cascading style sheet.
* Bugfix in `clean_git()`.

# checklist 0.1.10

## User visible changes

* Add `clean_git()` to bring a local git repo up-to-date.
    * Bring local branches up-to-date when there are behind the origin.
    * Remove remote branches when removed from the origin.
    * Remove local branches when fully merged into the main branch.
    * Warn for diverging branches.
* `create_hexsticker()` yields an `svg` file instead of `png`.
  The user can optionally specify an `svg` icon file to add to the hexagonal
  sticker.
* Keep failed build artefacts only 14 days (https://github.com/inbo/tutorials/issues/251).

## Bugfixes

* Avoid false positive linters when `.Rproj` file is put under version control.
* `check_files()` considers files with `svg` extensions as graphical files.
* Minor bugfix in `entrypoint_package.sh`.

# checklist 0.1.9

## User visible changes

* Many communities, both on GitHub and in the wider Git community, are
  considering renaming the default branch name of their repository from
  `master`.
  GitHub is gradually renaming the default branch of our own repositories from
  `master` to `main`.
  Therefore `checklist` now allows both a `main` or `master` branch as default.
  In case both are present, `checklist` uses `main`.
  Using only a `master` branch yields a note.
  Hence you must either which to a `main` branch or allow the note with
  `write_checklist()` (#44).

## Bugfixes

* Convert fancy single quotes to neutral single quotes (#42).
* Fix `check_description()`.

# checklist 0.1.8

* Create a release when pushing a tag starting with `v`.
  We use a GitHub Action to create the release instead of an R function.
* New function: `setup_source()` to setup projects with only source files.
* Add auxiliary function `create_hexsticker()`.
* Update `check_filename()` rules
    * Allow a `data-raw` folder
    * Allow more default GitHub file names
    * Ignore font files
    * `csl` files must follow the rules for graphics files
* `create_package()` adds
    * URL and BugReports to `DESCRIPTION`
    * GitHub Actions
    * basic setup for [`pkgdown`](https://pkgdown.r-lib.org/).
* `setup_package()` updates `.Rbuildignore` and basic setup for
  [`pkgdown`](https://pkgdown.r-lib.org/).
* Add more documentation on all functions.
* Add two vignettes:
    * `vignette("getting_started")`
    * `vignette("philosophy")`
* Use Ubuntu 18.04 instead of the end of life Ubuntu 16.04 when checking the
  package on the previous R release (#31).

# checklist 0.1.7

* Pushing to master should automatically create a release, using `set_tag()`.
* Add a Zenodo DOI badge to the README and DOI URL to DESCRIPTION.
* `check_description()` now checks authors (#7).
    * INBO is set as copyright holder and funder.
    * Every author has an ORCID.
* `setup_package()` adds the required files for a `pkgdown` website (#21).

# checklist 0.1.6

* Drop the `codemeta.json` file.
  It requires constant updating as it contains a package file size.

# checklist 0.1.5

* `check_documentation()` allows `NEWS.md` to have level 2 headings (`##`) and
  single line subitems (`    *`).
  It doesn't count URLs when determining the line of a line. 
  This allows lines to be longer than 80 characters due to long URLs.
* `check_filename()` is more liberal.
    * Allows files ending on `-package.Rd`.
    * Allows `json` or `yml` files starting with a dot and followed by letters.
    * Allows filename `cran-comment.md` and `WORDLIST`.
    * Allows `man-roxygen` as folder name.
    * Requires underscore (`_`) as separator for non-graphics files.
    * Requires dash (`-`) as separator for graphics files.
    * Basename separator issue are warnings instead of errors.
  So you can allow these warnings via `write_checklist()`.
* Fix deploying pkgdown website and release.
* Package require a `codemeta.json` as written by `codemetar::write_codemeta`.
  Suggestions by `codemetar` to improve the package become checklist notes.
* `set_tag()` fails when in a detached HEAD state.
* `set_tag()` creates a release when a tag is created on GitHub.
* `check_cran()` ignores system time check when world clock API is not
  available.
* `check_license()` verifies the license information of a package.
  This check is included via `check_description()` in `check_package()`.

# checklist 0.1.4

* `set_tag()` skips if the tag already exists.
* `create_package()` sets a code of conduct and contributing guidelines.
* `create_package()` sets `LICENSE.md`.
* Run `pkgdown::build_site()` during the 
  [`check_pkg`](https://github.com/inbo/actions/) GitHub action.
* Deploy the `pkgdown` website to a `gp-pages` branch when pushing to master 
  during the [`check_pkg`](https://github.com/inbo/actions/) GitHub action.

# checklist 0.1.3

* Add `validate_email()` to check for valid email addresses.
* Add `orcid2person()` which converts a valid ORCID into a `person` object.
* Add `create_package()` which prepare an RStudio project with an empty package.

# checklist 0.1.2

* Correctly check the package version on the master branch and during rebasing.
* Updating the master branch will set a tag with the current version.

# checklist 0.1.1

* Added a `NEWS.md` file to track changes to the package.
* Added a `README.Rmd` file with installation instructions.
* Rework `checklist_template()` into `write_checklist()`.
* Add `check_description()`.
* Add `check_documentation()`.
* Add `check_filename()`.
* Add `check_source()`.
* `check_lintr()` also works on source code repositories.
* Activate GitHub action `inbo/check_package`.

# checklist 0.1.0

* Initial version.
* Create `checklist` R6 class.
* Add `check_cran()`.
* Add `check_lintr()`.
* Add `check_package()`.
* Add `read_checklist()`.
* Add `checklist_template()`.
* Add Dockerimage for GitHub actions.
