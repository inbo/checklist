# checklist 0.1.4

* `set_tag()` skips if the tag already exists.
* `create_package()` sets a code of conduct and contributing guidelines.
* Run `pkgdown::build_site()` during the [`check_pkg`](https://github.com/inbo/actions/) GitHub action.
* Deploy the `pkgdown` website to a `gp-pages` branch when pushing to master during the [`check_pkg`](https://github.com/inbo/actions/) GitHub action.

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

* Initital version.
* Create `checklist` R6 class.
* Add `check_cran()`.
* Add `check_lintr()`.
* Add `check_package()`.
* Add `read_checklist()`.
* Add `checklist_template()`.
* Add Dockerimage for GitHub actions.
