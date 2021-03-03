# checklist 0.1.8

* Create a release when pushing a tag starting with `v`.
  We use a GitHub Action to create the release.
* New function: `setup_source()` to setup projects with only source files.
* Add more documentation on:
    * `create_package()`

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
    * Allows json or yml files starting with a dot and followed by letters.
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

* Add `validate_email()` to check for valid email adresses.
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
