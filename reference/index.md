# Package index

## Functions relevant for checking packages

- [`check_package()`](https://inbo.github.io/checklist/reference/check_package.md)
  : Run the complete set of standardised tests on a package

- [`check_codemeta()`](https://inbo.github.io/checklist/reference/check_codemeta.md)
  : Check the package metadata

- [`check_cran()`](https://inbo.github.io/checklist/reference/check_cran.md)
  : Run all the package checks required by CRAN

- [`check_description()`](https://inbo.github.io/checklist/reference/check_description.md)
  :

  Check the `DESCRIPTION` file

- [`check_documentation()`](https://inbo.github.io/checklist/reference/check_documentation.md)
  : Check the documentation

- [`check_environment()`](https://inbo.github.io/checklist/reference/check_environment.md)
  : Make sure that the required environment variables are set on GitHub

- [`check_license()`](https://inbo.github.io/checklist/reference/check_license.md)
  : Check the license of a package

- [`tidy_desc()`](https://inbo.github.io/checklist/reference/tidy_desc.md)
  : Make your DESCRIPTION tidy

## Functions relevant for checking projects with R and Rmd scripts

- [`check_folder()`](https://inbo.github.io/checklist/reference/check_folder.md)
  : Check the folder structure
- [`check_project()`](https://inbo.github.io/checklist/reference/check_project.md)
  : Run the required quality checks on a project
- [`check_source()`](https://inbo.github.io/checklist/reference/check_source.md)
  : Standardised test for an R source repository

## Functions relevant for checking packages and projects

- [`add_badges()`](https://inbo.github.io/checklist/reference/add_badges.md)
  : add badges to a README

- [`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md)
  : Check the style of file and folder names

- [`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md)
  : Check the packages for linters

- [`check_spelling()`](https://inbo.github.io/checklist/reference/check_spelling.md)
  : Spell check a package or project

- [`custom_dictionary()`](https://inbo.github.io/checklist/reference/custom_dictionary.md)
  : Add words to custom dictionaries

- [`default_organisation()`](https://inbo.github.io/checklist/reference/default_organisation.md)
  : Write default organisation settings

- [`print(`*`<checklist_spelling>`*`)`](https://inbo.github.io/checklist/reference/print.checklist_spelling.md)
  :

  Display a `checklist_spelling` summary

- [`read_checklist()`](https://inbo.github.io/checklist/reference/read_checklist.md)
  : Read the check list file from a package

- [`read_organisation()`](https://inbo.github.io/checklist/reference/read_organisation.md)
  : Read the organisation file

- [`update_citation()`](https://inbo.github.io/checklist/reference/update_citation.md)
  : Create or update the citation files

- [`write_checklist()`](https://inbo.github.io/checklist/reference/write_checklist.md)
  : Write a check list with allowed issues in the source code

- [`write_citation_cff()`](https://inbo.github.io/checklist/reference/write_citation_cff.md)
  :

  Write a `CITATION.cff` file

- [`write_organisation()`](https://inbo.github.io/checklist/reference/write_organisation.md)
  : Write organisation settings

- [`write_zenodo_json()`](https://inbo.github.io/checklist/reference/write_zenodo_json.md)
  :

  Write a `.zenodo.json` file

## Setting up a project use the checklist package

- [`create_package()`](https://inbo.github.io/checklist/reference/create_package.md)
  : Create an R package according to INBO requirements

- [`create_project()`](https://inbo.github.io/checklist/reference/create_project.md)
  : Initialise a new R project

- [`new_org_list()`](https://inbo.github.io/checklist/reference/new_org_list.md)
  : Interactively create a new organisation list

- [`prepare_ghpages()`](https://inbo.github.io/checklist/reference/prepare_ghpages.md)
  :

  Prepare a `gh-pages` branch with a place holder page

- [`set_license()`](https://inbo.github.io/checklist/reference/set_license.md)
  : Set the proper license

- [`setup_package()`](https://inbo.github.io/checklist/reference/setup_package.md)
  : Add or update the checklist infrastructure to an existing package

- [`setup_project()`](https://inbo.github.io/checklist/reference/setup_project.md)
  :

  Set-up `checklist` on an existing R project

- [`setup_source()`](https://inbo.github.io/checklist/reference/setup_source.md)
  : Add or update the checklist infrastructure to a repository with
  source files.

## Git related functions

- [`clean_git()`](https://inbo.github.io/checklist/reference/clean_git.md)
  : Clean the git repository
- [`create_draft_pr()`](https://inbo.github.io/checklist/reference/create_draft_pr.md)
  : Create a draft pull request
- [`get_branches_tags()`](https://inbo.github.io/checklist/reference/get_branches_tags.md)
  : Get branches and tags of a GitHub repository
- [`is_repository()`](https://inbo.github.io/checklist/reference/is_repository.md)
  : Determine if a directory is in a git repository
- [`is_workdir_clean()`](https://inbo.github.io/checklist/reference/is_workdir_clean.md)
  : Check if the current working directory of a repo is clean
- [`new_branch()`](https://inbo.github.io/checklist/reference/new_branch.md)
  : Create a new branch after cleaning the repo
- [`set_tag()`](https://inbo.github.io/checklist/reference/set_tag.md) :
  Set a New Tag

## R6 classses behind the checklist package

- [`checklist`](https://inbo.github.io/checklist/reference/checklist.md)
  : The checklist R6 class

- [`citation_meta`](https://inbo.github.io/checklist/reference/citation_meta.md)
  :

  The `citation_meta` R6 class

- [`org_item`](https://inbo.github.io/checklist/reference/org_item.md) :

  The `org_item` R6 class

- [`org_list`](https://inbo.github.io/checklist/reference/org_list.md) :

  The `org_list` R6 class

- [`organisation`](https://inbo.github.io/checklist/reference/organisation.md)
  : The organisation R6 class

- [`spelling`](https://inbo.github.io/checklist/reference/spelling.md) :
  The spelling R6 class

## Auxiliary functions

- [`ask_rightsholder_funder()`](https://inbo.github.io/checklist/reference/ask_rightsholder_funder.md)
  : Ask for rights holder or funder

- [`ask_yes_no()`](https://inbo.github.io/checklist/reference/ask_yes_no.md)
  :

  Function to ask a simple yes no question Provides a simple wrapper
  around [`utils::askYesNo()`](https://rdrr.io/r/utils/askYesNo.html).
  This function is used to ask questions in an interactive way. It
  repeats the question until a valid answer is given.

- [`author2df()`](https://inbo.github.io/checklist/reference/author2df.md)
  : Convert person object in a data.frame.

- [`bookdown_zenodo()`](https://inbo.github.io/checklist/reference/bookdown_zenodo.md)
  :

  Render a `bookdown` and upload to Zenodo

- [`c_sort()`](https://inbo.github.io/checklist/reference/c_sort.md) :
  Sort using the C locale

- [`create_hexsticker()`](https://inbo.github.io/checklist/reference/create_hexsticker.md)
  : Make hexagonal logo for package

- [`execshell()`](https://inbo.github.io/checklist/reference/execshell.md)
  : Pass command lines to a shell

- [`get_default_org_list()`](https://inbo.github.io/checklist/reference/get_default_org_list.md)
  : Get the default organization list

- [`inbo_org_list()`](https://inbo.github.io/checklist/reference/inbo_org_list.md)
  : The INBO organisation list

- [`install_pak()`](https://inbo.github.io/checklist/reference/install_pak.md)
  :

  Install extra packages defined in `checklist.yml`

- [`menu_first()`](https://inbo.github.io/checklist/reference/menu_first.md)
  : Improved version of menu()

- [`store_authors()`](https://inbo.github.io/checklist/reference/store_authors.md)
  : Store author details for later usage

- [`use_author()`](https://inbo.github.io/checklist/reference/use_author.md)
  : Which author to use

- [`validate_email()`](https://inbo.github.io/checklist/reference/validate_email.md)
  : Check if a vector contains valid email

- [`validate_orcid()`](https://inbo.github.io/checklist/reference/validate_orcid.md)
  : Validate the structure of an ORCID id

- [`yesno()`](https://inbo.github.io/checklist/reference/yesno.md) : A
  function that asks a yes or no question to the user
