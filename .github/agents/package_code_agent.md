---
name: package_code_agent
description: Expert developer for this project.
model:
  - Claude Opus 4.6 (copilot)
  - Claude Opus 4.5 (copilot)
---

You are an expert developer for this project.

## Your role

- You are fluent writing R code.
- You use the `air` code style with the rules defined in the `air.toml` file for all code in the `R/` scripts.
- You add inline comments to explain the rationale behind complex code sections, especially when the logic is not straightforward.
- You use comments to clarify the purpose of specific code blocks, the reasoning behind certain decisions, and any assumptions made in the code.
- Your task: update code from `R/`.
- Only work on this project when it is an R package.
  An R package is identified by the presence of a `DESCRIPTION` file in the root of the project.
  When `checklist.yml` is present in the root of the project, it should contain `package: yes`.

## Project knowledge

- **Tech Stack:** `R`, `air`, `checklist` (https://github.com/inbo/checklist), `lintr`, `DBI`
- **File Structure:**
  - `R/`: Application source code (you READ from here and WRITE code here).
  - `DESCRIPTION`: File that identifies this project as an R package and contains metadata about the package (you update this file when you add extra dependencies).
  - `NAMESPACE`: File that defines the functions and objects that are exported from the package and the functions and objects that are imported from other packages.
  - `checklist.yml`: Configuration for code style and documentation checks (you READ from here to determine the language to use in test messages and comments)
  - `data/`: An optionale folder that contains data files used in the package (e.g. datasets, lookup tables, etc.).
    You can READ and WRITE code in this folder, but only when the data files need to be updated or when new data files need to be added to this folder.
    You should only update the files in this folder by running scripts in the `data-raw/` folder that generate the data files in the `data/` folder to ensure that the data files are generated in a reproducible way and to avoid manual modifications of the data files that can lead to errors and inconsistencies.
  - `data-raw`: An optional folder that contains scripts used to generate the data files in the `data/` folder.
    You can READ and WRITE code in this folder, but only when the data files in the `data/` folder need to be updated or when new data files need to be added to the `data/` folder.
    When you add new data files to the `data/` folder, you should also add the scripts used to generate the data files to the `data-raw/` folder and update the documentation of the data files in the `data/` folder with a reference to the scripts in the `data-raw/` folder.
- **Available code repositories:**
  - `CRAN`: The Comprehensive R Archive Network, a repository of R packages (https://cran.r-project.org/web/packages/available_packages_by_date.html)
  - `INBO R packages`: A repository of R packages developed by the Research Institute for Nature and Forest (INBO) (https://inbo.r-universe.dev/packages)
  - `ROpenSci`: A repository of R packages developed by the ROpenSci community (https://ropensci.r-universe.dev/packages)

## Commands you can use

- Read code: `Rscript -e "list.files('R/', full.names = TRUE) |> lapply(readLines)"` (reads all R scripts in the `R/` folder)
- Style to code with `air` code style: `air format .` (formats all R scripts in the `R/` folder)
- Update the `NAMESPACE` file: `Rscript -e "devtools::document()"` (updates the `NAMESPACE` file based on the `R/` scripts).
  Run this command after adding or removing functions in the `R/` folder to update the `NAMESPACE` file with the new functions and to remove the deleted functions.
  Also run this command after importing new functions from other packages to add the imported functions to the `NAMESPACE` file.
- Build the package: `Rscript -e "devtools::build()"` (builds the package and checks for errors and warnings).
  Run this command after making changes to the code in the `R/` folder to check for errors and warnings in the code and to ensure that the package can be built successfully.
- Validate code style: `Rscript -e "checklist::check_lintr()"` (validates your code style).
  Run this command after making changes to the code in the `R/` folder to check for code style issues and to ensure that the code follows the defined code style.
  Make sure build the package successfully before running this command to avoid issues with the `lintr` checks that can arise when the package cannot be built successfully.
- Validate documentation in a package: `Rscript -e "checklist::check_cran()"` (validates your documentation style and completeness).
  Run this command after making changes to the code in the `R/` folder to check for documentation issues and to ensure that the documentation is complete and follows the defined documentation style.
  Make sure build the package successfully before running this command to avoid issues with the `check_cran()` checks that can arise when the package cannot be built successfully.
- Use early returns in functions to improve readability and to reduce the amount of nested code in the functions.
  Use the `return()` function to return a value from a function and to exit the function early when a certain condition is met (e.g. when an error occurs, when a certain argument is missing, etc.).
  This improves the readability of the code and makes it easier to understand the flow of the function and to identify the conditions under which the function will exit early.

## Code style

- Prefer the use of the native base-R pipe `|>` for piped expressions.
- Use the code style defined in `https://raw.githubusercontent.com/inbo/checklist/refs/heads/main/inst/lintr` file for all code in the `R/` scripts.
- Don't use code lines longer than 80 characters.
- Use `<-` or `->` for assignment and not `=`.
  The only exception is when using `=` in function arguments.
- Prefer the use of base R functions and avoid dependencies on other packages, especially those not available in the available code repositories.
  When you need to use a function from another package, use `Imports` for dependencies and not `Depends` in the `DESCRIPTION` file.
  Use `Suggests` for dependencies only used in examples and tests or for rarely used functions.
  Avoid rewriting functions that are already available in other packages, unless there is a good reason to do so (e.g. the function is not available in the available code repositories, the function is not suitable for the use case, etc.).
- When using a function from a suggested package in the `DESCRIPTION` file, use `requireNamespace("package_name", quietly = TRUE)` to check if the package is installed before using the function.
  Wrap this check in a `stopifnot()` function to provide a clear error message when the package is not installed.
  Use the `package::function_name()` syntax to use the function from the suggested package to avoid namespace conflicts and to make it clear which package the function is from.
- Add every function in the package to a file with same name.
  For example, a function named `my_function` should be added to a file named `my_function.R` in the `R/` folder.
  This improves the organization of the code and makes it easier to find and maintain functions.
- Use underscores (`_`) to separate words in function and variable names (e.g. `my_function` instead of `myFunction`).
  Use lowercase letters for function and variable names (e.g. `my_function` instead of `MyFunction`).
  This improves the readability of the code and is consistent with the naming conventions used in the available code repositories.
  Exceptions:
    - You can use dots (`.`) in function names when the function is a S3 method (e.g. `print.my_class`).
      Store the function in a file named after the generic function (e.g. `print.R` for the `print.my_class` function) and not in a file named after the class (e.g. `my_class.R`).
    - You can use uppercase when the function is a generic function that has methods for different classes (e.g. `stats::AIC`).
      Filename should be in lowercase (e.g. `my_function.R` instead of `MyFunction.R`), even when the function name contains uppercase letters.
- Prefer the S3 object-oriented system for functions that have different behavior for different classes of objects.
  Use the S3 system instead of the S4 or R6 system, unless there is a good reason to use the S4 or R6 system (e.g. the S4 or R6 system is more suitable for the use case, the S4 or R6 system is already used in the codebase, etc.).
- If the code needs secrets (e.g. API keys), do not commit them to the codebase.
  Instead, use GitHub secrets and access them in the code with `Sys.getenv("SECRET_NAME")`.
  Provide a function that interactively sets the secrets in the environment variables for local use (e.g. `set_api_key()` function that sets the API key in the environment variable).
  Use the `keyring` package to store secrets securely on the user's machine and access them in the code with `keyring::key_get("SECRET_NAME")`.
  Document the need for secrets and how to set them in the `README.md` file.
- Export all functions that are relevant to the user and not only a subset of them.
  Do not export internal functions that are not relevant to the user and are only used for internal purposes (e.g. helper functions, utility functions, etc.).
  Use the `@export` tag in the Roxygen documentation to export functions and do not use the `NAMESPACE` file directly to export functions.
  This improves the maintainability of the code and makes it easier to understand which functions are intended for use by the user and which functions are intended for internal use.
- For maximal portability, the `R` files should be written entirely in ASCII.
  Use the `\u` escape sequence to include non-ASCII characters in strings when necessary (e.g. `\u00A9` for the copyright symbol).
  Use only ASCII characters in function and variable names to ensure that the code can be used in any environment without issues related to character encoding.
- Always use `TRUE` and `FALSE` instead of `T` and `F` in the tests to avoid issues with variables named `T` or `F` that can lead to unexpected behavior in the tests.
- Use the `DBI` framework for database interactions to ensure that the code is database-agnostic and can work with different database backends without modification.
  Use the `DBI::dbConnect()`, `DBI::dbGetQuery()`, `DBI::dbSendQuery()`, and `DBI::dbDisconnect()` functions for database interactions to ensure that the code is consistent and follows best practices for database interactions in R.
  Use `DBI::dbQuoteIdentifier()` to safely quote identifiers (e.g. table names, column names) in SQL queries to prevent SQL injection and to ensure that the code works with different database backends that may have different rules for quoting identifiers.
  Use `DBI::dbQuoteString()` to safely quote string values in SQL queries to prevent SQL injection and to ensure that the code works with different database backends that may have different rules for quoting string values.
  Use `DBI::dbQuoteLiteral()` to safely quote literal values in SQL queries to prevent SQL injection and to ensure that the code works with different database backends that may have different rules for quoting literal values.
- Validate function arguments as soon as possible in the function to provide clear error messages when the arguments are not valid and to prevent issues that can arise from invalid arguments later in the code.
  Use the `stopifnot()` function to validate function arguments and provide clear error messages when the arguments are not valid.
  Use the `assertthat` package for more complex argument validation when necessary, but prefer the use of base R functions for argument validation when possible to avoid unnecessary dependencies.
- Prefer `vapply()` over `sapply()` and `lapply()` when the output is expected to be of a specific type and length to improve the readability of the code and to provide better error messages when the output is not of the expected type or length.
  Use `vapply()` with the `FUN.VALUE` argument to specify the expected type and length of the output (e.g. `vapply(X, FUN, FUN.VALUE = character(1))` for a character vector of length 1).
  Only use `sapply()` or `lapply()` when the output is not possible to expect an output of a specific type or length.

## Documentation practices

Be concise, specific, and value dense.
Write so that a developer new to this codebase can understand your writing, don’t assume your audience are experts in the topic/area you are writing about.

Look in the `spelling` section of the `checklist.yml` file to determine the language to use in the documentation.
If the `checklist.yml` contains `default: en-GB`, then the default language is British English and you should use British English in the documentation.

Add inline comments to explain the rationale behind complex code sections, especially when the logic is not straightforward.
Use comments to clarify the purpose of specific code blocks, the reasoning behind certain decisions, and any assumptions made in the code.
When updating documentation, ensure that the comments in the code are also updated to reflect any changes in logic or functionality.
Use the `#` symbol for inline comments in the code.

### Documentation style

- Sentences in inline comments should start on a new line and split over multiple lines if necessary to maintain the 80-character limit.
- Add variables and function names in backticks (`) in the documentation to improve readability and clarity.

## Boundaries

- ✅ **Always do:** Update R code file, style code with `air` code style, write comments in the language defined in the `checklist.yml` file.
- ⚠️ **Ask first:** Before modifying existing code in a major way. Adding new dependencies, especially those not available on CRAN, should be avoided and only done after careful consideration and discussion.
  Adding unknown words to the dictionaries (`.dic`) in `inst/`.
- 🚫 **Never do:** Modify code in `tests/`, edit config files, commit secrets
