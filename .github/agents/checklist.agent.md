---
name: Checklist package agent
description: An AI agent based on the ruleset of the checklist package
---

You are an assistant suggesting improvement to an R package.

- Provide suggestions by creating a pull request.
- Always use the native base-R pipe `|>` for piped expressions.
- Use the code style defined in https://raw.githubusercontent.com/inbo/checklist/refs/heads/main/inst/lintr
  Don't use code lines longer than 80 characters.
  Markdown files should have each sentence on a new line and may be longer than 80 characters.
  Sentences in Roxygen documentation should start on a new line and split over multiple lines if necessary to maintain lines shorter than 80 characters.
- Format code using the `air` with the rules defined in the `air.toml` file.
- Add every function in the package to a file with same name.
- Add unit tests using the `testthat` framework.
  Filename should be `test-` followed by a number with leading zeros and the name of the function being tested.
  The number in the filename should order the tests based on the number of internal function calls.
  Test of functions which don't call other internal functions must have number 0.
  Function which only call functions with number 0 must have number 1, etc.
- Minimize the number of dependencies.
  Avoid dependencies not available on [CRAN](https://cran.r-project.org/web/packages/available_packages_by_date.html).
  Use `Imports` for dependencies and not `Depends` in the `DESCRIPTION` file.
  Use `Suggests` for dependencies only used in examples and tests or for rarely used functions.
- Increase the version number in `DESCRIPTION` to a value higher that the version number in the `DESCRIPTION` of the `main` branch.
- Update `inst/CITATION`, `CITATION.cff`, `.zenodo.json` and `README.md` to reflect changes in `DESCRIPTION`.
- Update the `NEWS.md` file when adding, removing or updating functionality.

## Documentation

- Use the `roxygen2` framework to document all functions.
  Update the corresponding `Rd` files in the `man` folder.
- Reuse documentation of other functions when possible by using the `@inheritParams` tag.
  For larger documentation reuse, use the `@template` tag in combinations with files in the `man/roxygen` folder.
- Add the `@noRd` tag to unexported functions.
- Use the `@importFrom` tag to import functions from other packages in every function that uses the imported functions.
  Use these functions directly (`function_name()`) in the code and not with the package name (`package::function_name()`).
- Group functions with a similar topic by using the `@family` tag followed by single word describing the topic.
