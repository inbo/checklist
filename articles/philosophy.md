# Philosophy of the checklist package

Everybody develops its own coding habits and style. Some people take a
lot of effort in making their source code
[readable](https://en.wikipedia.org/wiki/Computer_programming#Readability_of_source_code),
while others don’t bother at all. Working together with other people is
easier when everyone uses the same standard.

The `checklist` package defines a set of standards and provides tools to
validate whether your project or R package adheres to these standards.
It integrates several existing tools like
[`rcmdcheck`](https://rcmdcheck.r-lib.org/),
[`lintr`](https://lintr.r-lib.org/),
[`devtools`](https://devtools.r-lib.org/),
[`desc`](https://desc.r-lib.org/),
[`hunspell`](https://docs.ropensci.org/hunspell/),
[`pkgdown`](https://pkgdown.r-lib.org/). `checklist` always uses these
tools with hard-coded settings, ensuring that everyone uses the same
settings. Since version 0.5.0, every organisation can define its own
settings in a central repository. More information on that in
[`vignette("organisation")`](https://inbo.github.io/checklist/articles/organisation.md).

`checklist` tries to make on-boarding as easy as possible. We do this by
providing the interactive functions
[`create_package()`](https://inbo.github.io/checklist/reference/create_package.md)
and
[`create_project()`](https://inbo.github.io/checklist/reference/create_project.md).
These function don’t just provide a template which the user must fill
in. Instead they guide the user through a series of questions to set up
the project or package according to the best practices. Hence the user
can start from a solid basis rather than having to figure out all the
best practices by him/herself. We deliberately choose the highest
quality level for R packages by enforcing all relevant checks. In case
of project we allow the user to choose which checks to apply. More
information on that in
[`vignette("getting_started")`](https://inbo.github.io/checklist/articles/getting_started.md)
or
[`vignette("getting_started_project")`](https://inbo.github.io/checklist/articles/getting_started_project.md).
You can apply (or update) the checklist setting to an existing project
or package using
[`setup_package()`](https://inbo.github.io/checklist/reference/setup_package.md)
or
[`setup_project()`](https://inbo.github.io/checklist/reference/setup_project.md).
However, we recommend that you first get used to `checklist` by creating
a new project or package from scratch. Since `checklist` enforces
several best practices, it is easier to learn them from the start rather
than trying to adapt an existing project. You might need to refactor
some parts of your existing code to meet the quality standards.

## Available checks

Currently, `checklist` handles two different types of projects: R
packages and non-package R projects. For both types of projects,
`checklist` provides a set of checks to validate the quality of your
code. You can either choose to run the entire set of checks at once, or
run individual checks.

We have a set of rules that are relevant for both packages and
non-package projects.

- [`check_spelling()`](https://inbo.github.io/checklist/reference/check_spelling.md):
  checks the spelling in R code and markdown files using `hunspell`.
  More information in
  [`vignette("spelling")`](https://inbo.github.io/checklist/articles/spelling.md).
- [`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md):
  runs
  [`lintr::lint_dir()`](https://lintr.r-lib.org/reference/lint.html) to
  check the code style. More information in
  [`vignette("coding_style")`](https://inbo.github.io/checklist/articles/coding_style.md).
- [`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md):
  checks whether all file names meet the naming conventions. More
  information in
  [`vignette("file_name")`](https://inbo.github.io/checklist/articles/file_name.md).
- [`check_folder()`](https://inbo.github.io/checklist/reference/check_folder.md):
  checks whether the folder structure meets the conventions. More
  information in
  [`vignette("file_name")`](https://inbo.github.io/checklist/articles/file_name.md).
- [`check_license()`](https://inbo.github.io/checklist/reference/check_license.md):
  checks whether a valid license is present.
- [`update_citation()`](https://inbo.github.io/checklist/reference/update_citation.md):
  checks the citation metadata and update the citation files

On a package, you can run
[`check_package()`](https://inbo.github.io/checklist/reference/check_package.md)
to run these additional checks.

- [`check_cran()`](https://inbo.github.io/checklist/reference/check_cran.md):
  runs
  [`rcmdcheck::rcmdcheck()`](http://r-lib.github.io/rcmdcheck/reference/rcmdcheck.md)
  to check whether the package meets CRAN standards.
- [`check_description()`](https://inbo.github.io/checklist/reference/check_description.md):
  checks the `DESCRIPTION` file for common problems.
- [`check_documentation()`](https://inbo.github.io/checklist/reference/check_documentation.md):
  checks whether the documentation is up-to-date.
- [`check_codemeta()`](https://inbo.github.io/checklist/reference/check_codemeta.md):
  checks whether the `codemeta.json` file is present and valid.
- build the documentation website with `pkgdown`
- check the code coverage of the unit tests with
  [`covr::package_coverage()`](http://covr.r-lib.org/reference/package_coverage.md).
  Adding more code should not (significantly) decrease the code
  coverage.

You can run these functions interactively on your machine. We recommend
to run the individual checks while developing your code to fix problems
as soon as they arise. Before pushing your code to GitHub, always run
[`check_package()`](https://inbo.github.io/checklist/reference/check_package.md)
or
[`check_project()`](https://inbo.github.io/checklist/reference/check_project.md).
You can also add these checks as [GitHub
actions](https://github.com/features/actions), which runs them
automatically after every [push](https://github.com/git-guides/git-push)
to the repository on [GitHub](https://github.com). We recommend to set
up these checks as required checks on GitHub. This prevents merging code
to the main branch that does not meet the quality standards. In case of
an R package, merging a pull request on GitHub will update the pkgdown
website automatically too and creates a release of the new version.
Therefore you must increase the version of the package in the
`DESCRIPTION` file when starting a new branch.

## Extensive report on checks

Both
[`check_package()`](https://inbo.github.io/checklist/reference/check_package.md)
and
[`check_project()`](https://inbo.github.io/checklist/reference/check_project.md)
generate an extensive report on the checks that were performed. The
report contains the following sections:

- used organisation settings
- output of the individual checks
- extracted citation metadata
- list of files for spell checking, aggregated by language
- session info with loaded packages and their version
- any changes made to files during the checks
- a summary of errors, warnings and notes

### Errors, warnings and notes

The report lists all errors, warnings and notes that were found during
the checks. You can use this report to fix the problems in your code.
After fixing the problems, you can run the checks again to see whether
all problems are solved. You must fix all errors in order to pass
[`check_package()`](https://inbo.github.io/checklist/reference/check_package.md)
or
[`check_project()`](https://inbo.github.io/checklist/reference/check_project.md).
You should try to fix as many warnings and notes as possible too. Some
warnings and notes might be acceptable in certain situations. You can
document these exceptions via
[`write_checklist()`](https://inbo.github.io/checklist/reference/write_checklist.md)
in the `checklist.yml` file. The report can have three categories of
warnings and notes: “new”, “allowed” and “missing”.

- **New** warnings and notes are those that were found during the
  checks, but are not yet documented as allowed exceptions. You should
  try to fix these problems. They result in failing
  [`check_package()`](https://inbo.github.io/checklist/reference/check_package.md)
  or
  [`check_project()`](https://inbo.github.io/checklist/reference/check_project.md).
  Allow them, when fixing is not possible at the moment.
- **Allowed** warnings and notes are those that were found during the
  checks and are documented as allowed exceptions. Allowing warnings and
  notes require a short motivation. This motivation is included in the
  report and in the `checklist.yml` file. They don’t result in failing
  [`check_package()`](https://inbo.github.io/checklist/reference/check_package.md)
  or
  [`check_project()`](https://inbo.github.io/checklist/reference/check_project.md).
- **Missing** warnings and notes are those that were documented as
  allowed exceptions, but are no longer found during the checks. They
  result in failing
  [`check_package()`](https://inbo.github.io/checklist/reference/check_package.md)
  or
  [`check_project()`](https://inbo.github.io/checklist/reference/check_project.md).
  You should remove these exceptions from the documentation via
  [`write_checklist()`](https://inbo.github.io/checklist/reference/write_checklist.md).

### Changes

When you use version control like `git`, `checklist` can detect which
files were changed since the last commit. This is useful because some
checks rewrite an improved version of a file. E.g.
[`check_documentation()`](https://inbo.github.io/checklist/reference/check_documentation.md)
regenerates the documentation files from the `roxygen2` tags in the R
code. If you forgot to regenerate the documentation after changing the
code,
[`check_documentation()`](https://inbo.github.io/checklist/reference/check_documentation.md)
will detect that the documentation files are out-of-date. The
`checklist` will report this and show which changes took place.

### Session info

Most problems are related to the R version or the versions of the
packages that are used. To help you debug problems, the report contains
the session info. This is especially important when checks pass locally
but fail on GitHub Actions. When this occurs, you can compare the
session info of your local machine with the session info on GitHub
Actions to find out which package versions differ. Then use the same
package versions locally to reproduce and fix the problem.

The GitHub Actions run on a Docker image based on
[`rocker/verse:latest`](https://hub.docker.com/r/rocker/verse). It
should contain the latest R version and the latest versions of the most
common R packages. Any other packages that your code need are installed
on the fly.

## Making code findable and citable

When you share your code with other people, you want them to be able to
find it easily. You also want them to be able to cite a specific version
of your code in a report or paper. `checklist` helps you to achieve this
by enforcing a strict usage of metadata either in the `DESCRIPTION`
(package) or `README.md` (non-package). Because of the strict format of
the person information, we recommend to add most people when creating
the project or package via the interactive functions
[`create_project()`](https://inbo.github.io/checklist/reference/create_project.md)
or
[`create_package()`](https://inbo.github.io/checklist/reference/create_package.md).
The functions not only add the people to the metadata, but also store
their information for later reuse.

You can define a list of default organisations in your organisations’
`checklist` repository. This ensures that everyone in the organisation
uses the standard names of these organisations. Based on matching e-mail
domains, `checklist` enforces that persons use their official
organisation name as affiliation. More information in
[`vignette("organisation")`](https://inbo.github.io/checklist/articles/organisation.md).

### Integration with Zenodo and ORCID

When you push your code to GitHub, you can use the [GitHub-Zenodo
integration](https://docs.github.com/repositories/archiving-a-github-repository/referencing-and-citing-content)
to create a DOI for every release of your code. `checklist`
automatically adds the required metadata to a `.zenodo.json` in your
repository so that Zenodo can create a proper citation for your code.
When authors add their ORCID to their person information, this ORCID is
included in the Zenodo metadata too. Then every release of your code can
automatically flow into you ORCID profile. Which makes it easier to
maintain an up-to-date list of your publications. And your organisation
can import the publications of all its researchers based on their ORCID.
More information in
[`vignette("zenodo")`](https://inbo.github.io/checklist/articles/zenodo.md).

## Bundling your code in a package

Most users think of an R package as a collection of generic functions
that they can use to run their analysis. However, an R package is a
useful way to bundle and document a stand-alone analysis too! Suppose
you want to pass your code to a collaborator or your future self who is
working on a different computer. If you have a project folder with a
bunch of files, people will need to get to know your project structure,
find out what scripts to run and which dependencies they need. Unless
you documented everything well they (including your future self!) will
have a hard time figuring out how things work.

Having the analysis as a package *and* running
[`check_package()`](https://inbo.github.io/checklist/reference/check_package.md)
to ensure a minimal quality standard, makes things a lot easier for the
user. Agreed, it will take a bit more time to create the analysis,
especially with the first few projects. In the long run you save time
due to a better quality of your code. Try to start by packaging a
recurrent analysis or standardised report when you want to learn writing
a package. Once you have some experience, it is little overhead to do it
for smaller analysis. Keep in mind that you seldom run an analysis
*exactly* once.

### Benefits of using a package for your analysis

- The package itself is a way to cite (a specific version of) the
  analysis in a report or paper.
- You have to list all dependencies on other R packages. This makes
  installing your code as simple as running
  `remotes::install_github("inbo/packagename")`.
- You must split your analysis in a set of functions. Say goodbye to
  unreadable scripts with thousands lines of code.
- Functions make it easy to re-use code. Need to run the same thing with
  a different parameter value? Add the parameter as an argument to the
  function and run the function once for every different parameter
  value. This avoids the need to copy-paste large chunks of scripts and
  replace a few values. The copy-paste work flow typically results in
  hard-to-read long scripts. Imagine you made a mistake in the code and
  copy-pasted that mistake several times before you found it. You have
  to check your entire project to fix the mistake several times. Having
  it as a function reduces the workload to fixing only the function.
- Packages require that every object is either defined within the
  package or imported from another package. Global variables are not
  allowed. The user only needs to load your package and run the function
  with the required arguments. The results will not depend on any other
  packages loaded nor by user-defined objects like vectors or dataframes
  (unless the user passes them explicitly as arguments to a function).
- A package gives the opportunity to add documentation to your code.
  Afterwards you can simply consult this documentation rather than
  having to dig into your code to find out what it is actually doing.
  Every function needs at least a title and an entry for every argument.
- Most likely you would still need a short script that combines a few
  high level functions of your package to run the analysis. The `inst`
  folder is an ideal place to bundle such scripts within the package.
  You can also use it to store small (!) datasets or rmarkdown reports.
