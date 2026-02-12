#!/bin/bash

# Build orgauth package from checklist repository
# This script creates the orgauth package structure locally from the checklist source files
#
# Usage: ./build_orgauth_package.sh [output_directory]
#
# Example:
#   ./build_orgauth_package.sh ~/projects/orgauth
#   ./build_orgauth_package.sh ../orgauth

set -e  # Exit on error

# Configuration
CHECKLIST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${1:-../orgauth}"

echo "=================================="
echo "Building orgauth Package"
echo "=================================="
echo ""
echo "Checklist source: $CHECKLIST_DIR"
echo "Output directory: $OUTPUT_DIR"
echo ""

# Create output directory
if [ -d "$OUTPUT_DIR" ]; then
    echo "⚠️  Warning: Directory $OUTPUT_DIR already exists"
    read -p "Do you want to overwrite it? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        exit 1
    fi
    rm -rf "$OUTPUT_DIR"
fi

echo "Creating directory structure..."
mkdir -p "$OUTPUT_DIR"/{R,man,tests/testthat,inst/extdata,.github/workflows}

# Copy R files
echo "Copying R source files..."
cp "$CHECKLIST_DIR/R/org_item_class.R" "$OUTPUT_DIR/R/"
cp "$CHECKLIST_DIR/R/org_list_class.R" "$OUTPUT_DIR/R/"
cp "$CHECKLIST_DIR/R/use_author.R" "$OUTPUT_DIR/R/"
cp "$CHECKLIST_DIR/R/store_authors.R" "$OUTPUT_DIR/R/"
cp "$CHECKLIST_DIR/R/get_default_org_list.R" "$OUTPUT_DIR/R/"

# Create utils.R with extracted validation functions
echo "Creating utils.R with validation functions..."
cat > "$OUTPUT_DIR/R/utils.R" << 'UTILS_EOF'
#' Check if a vector contains valid email
#'
#' It only checks the format of the text, not if the email address exists.
#' @param email A vector with email addresses.
#' @return A logical vector.
#' @export
#' @importFrom assertthat assert_that
#' @family utils
validate_email <- function(email) {
  assert_that(is.character(email))
  # expression taken from https://emailregex.com/
  grepl(
    paste0(
      "(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"",
      "(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|",
      "\\[\x01-\x09\x0b\x0c\x0e-\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*",
      "[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|",
      "2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9]",
      "[0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a",
      "\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\\])"
    ),
    tolower(email)
  )
}

#' Validate the structure of an ORCID id
#'
#' Checks whether the ORCID has the proper format and the checksum.
#' @param orcid A vector of ORCID
#' @returns A logical vector with the same length as the input vector.
#' @export
#' @importFrom assertthat assert_that noNA
#' @family utils
validate_orcid <- function(orcid) {
  assert_that(is.character(orcid), noNA(orcid))
  format_ok <- grepl("^(\\d{4}-){3}\\d{3}[\\dX]$", orcid, perl = TRUE)
  if (!any(format_ok)) {
    return(orcid == "" | format_ok)
  }
  gsub("-", "", orcid[format_ok]) |>
    strsplit(split = "") |>
    do.call(what = cbind) -> digits
  checksum <- digits[16, ]
  seq_len(15) |>
    rev() |>
    matrix(ncol = 1) -> powers
  apply(digits[-16, , drop = FALSE], 1, as.integer, simplify = FALSE) |>
    do.call(what = rbind) |>
    crossprod(2^powers) |>
    as.vector() -> total
  remainder <- (12 - (total %% 11)) %% 11
  remainder <- as.character(remainder)
  remainder[remainder == "10"] <- "X"
  format_ok[format_ok] <- remainder == checksum
  return(orcid == "" | format_ok)
}

validate_ror <- function(ror) {
  stopifnot(
    "`ror` must be a string" = assertthat::is.string(ror),
    "`ror` cannot be NA" = assertthat::noNA(ror)
  )
  grepl(
    "^https:\\/\\/ror\\.org\\/0[a-hj-km-np-tv-z|0-9]{6}[0-9]{2}$",
    ror,
    perl = TRUE
  )
}

validate_url <- function(url) {
  stopifnot(
    "`url` must be a string" = assertthat::is.string(url),
    "`url` cannot be NA" = assertthat::noNA(url)
  )
  grepl(
    "^(http|https)://[a-z0-9-]+(\\.[a-z0-9-]+)+(:[0-9]+)?(/.*)?$",
    url,
    perl = TRUE
  )
}

#' Determine if a directory is in a git repository
#'
#' The path arguments specifies the directory at which to start the search for
#' a git repository.
#' If it is not a git repository itself, then its parent directory is consulted,
#' then the parent's parent, and so on.
#' @inheritParams gert::git_find
#' @importFrom gert git_find
#' @return TRUE if directory is in a git repository else FALSE
#' @export
#' @family git
is_repository <- function(path = ".") {
  out <- tryCatch(git_find(path = path), error = function(e) e)
  !any(class(out) == "error")
}

#' Improved version of menu()
#' @inheritParams utils::menu
#' @export
#' @family utils
menu_first <- function(choices, graphics = FALSE, title = NULL) {
  if (!interactive()) {
    return(1)
  }
  menu(choices = choices, graphics = graphics, title = title)
}

rules <- function(x = "#", nl = "\n") {
  assertthat::assert_that(assertthat::is.string(nl), assertthat::noNA(nl))
  paste(c(nl, rep(x, getOption("width", 80)), nl), collapse = "")
}

file_exists <- function(path) {
  file.exists(path)
}

set_non_empty <- function(x, fun, prompt) {
  if (x == "") {
    return(x)
  }
  fun(x) |>
    setNames(prompt) |>
    stopifnot()
  return(x)
}

ask_orcid <- function(prompt = "orcid: ") {
  orcid <- readline(prompt = prompt)
  if (orcid == "") {
    return(orcid)
  }
  while (!validate_orcid(orcid)) {
    message(
      "\nPlease provide a valid ORCiD in the format `0000-0000-0000-0000`\n"
    )
    orcid <- readline(prompt = prompt)
  }
  return(orcid)
}

coalesce <- function(...) {
  dots <- list(...)
  i <- 1
  while (i <= length(dots)) {
    if (!is.null(dots[[i]])) {
      return(dots[[i]])
    }
    i <- i + 1
  }
  return(NULL)
}

first_non_null <- function(...) {
  dots <- list(...)
  if (length(dots) == 0) {
    return(NULL)
  }
  if (!is.null(dots[[1]])) {
    return(dots[[1]])
  }
  do.call(first_non_null, utils::tail(dots, -1))
}

validate_license <- function(license) {
  stopifnot(
    "`license` must be a list" = inherits(license, "list"),
    "`license` must contain \`package\`, \`project\`, and \`data\`" =
      all(c("package", "project", "data") %in% names(license)),
    "`license` must contain character vectors" = all(
      vapply(license, is.character, FUN.VALUE = logical(1))
    ),
    "`license` must contain named vectors" = all(
      vapply(
        license,
        function(x) {
          length(x) == 0 || (!is.null(names(x)) && all(names(x) != ""))
        },
        FUN.VALUE = logical(1)
      )
    ),
    "`license` must contain uniquely named vectors" = all(
      vapply(
        license,
        function(x) {
          length(x) == 0 || anyDuplicated(names(x)) == 0
        },
        FUN.VALUE = logical(1)
      )
    ),
    "`license` must contain vectors with unique licenses" = all(
      vapply(
        license,
        function(x) {
          length(x) == 0 || anyDuplicated(x) == 0
        },
        FUN.VALUE = logical(1)
      )
    )
  )
}
UTILS_EOF

echo "Updating R files to use 'orgauth' instead of 'checklist'..."
# Update R_user_dir references
sed -i.bak 's/R_user_dir("checklist"/R_user_dir("orgauth"/g' "$OUTPUT_DIR/R"/*.R
rm -f "$OUTPUT_DIR/R"/*.bak

# Remove read_checklist dependencies from org_list_class.R
sed -i.bak '/checklist <- try(read_checklist/,+2d' "$OUTPUT_DIR/R/org_list_class.R"
rm -f "$OUTPUT_DIR/R"/*.bak

# Copy package files
echo "Creating package files..."
cp "$CHECKLIST_DIR/LICENSE.md" "$OUTPUT_DIR/"
cp "$CHECKLIST_DIR/.gitignore" "$OUTPUT_DIR/"

# Create DESCRIPTION
cat > "$OUTPUT_DIR/DESCRIPTION" << 'DESC_EOF'
Package: orgauth
Title: Manage Person and Organisation Information
Version: 0.0.1
Authors@R: c(
    person("Thierry", "Onkelinx", , "thierry.onkelinx@inbo.be", role = c("aut", "cre"),
           comment = c(ORCID = "0000-0001-8804-4216", affiliation = "Research Institute for Nature and Forest (INBO)")),
    person("Research Institute for Nature and Forest (INBO)", , , "info@inbo.be", role = c("cph", "fnd"),
           comment = c(ROR = "https://ror.org/00j54wy13"))
  )
Description: Manage person and organisation information with validation and 
    formatting capabilities. Provides R6 classes for managing organisations
    and their members, with support for multiple languages, ORCID identifiers,
    ROR identifiers, licensing requirements, and integration with citation
    management systems.
License: GPL-3
URL: https://github.com/inbo/orgauth
BugReports: https://github.com/inbo/orgauth/issues
Depends:
    R (>= 4.1.0)
Imports:
    assertthat,
    fs,
    gert,
    httr,
    R6,
    sessioninfo,
    tools,
    utils,
    yaml
Suggests:
    desc,
    testthat (>= 3.0.0)
Config/testthat/edition: 3
Encoding: UTF-8
Language: en-GB
Roxygen: list(markdown = TRUE)
RoxygenNote: 7.3.3
DESC_EOF

# Create NAMESPACE
cat > "$OUTPUT_DIR/NAMESPACE" << 'NS_EOF'
# Generated by roxygen2: do not edit by hand

export(author2df)
export(inbo_org_list)
export(is_repository)
export(menu_first)
export(org_item)
export(org_list)
export(store_authors)
export(use_author)
export(validate_email)
export(validate_orcid)
importFrom(R6,R6Class)
importFrom(assertthat,assert_that)
importFrom(assertthat,has_name)
importFrom(assertthat,is.flag)
importFrom(assertthat,is.string)
importFrom(assertthat,noNA)
importFrom(fs,dir_create)
importFrom(fs,is_dir)
importFrom(fs,is_file)
importFrom(fs,path)
importFrom(gert,git_find)
importFrom(gert,git_ls)
importFrom(gert,git_remote_list)
importFrom(gert,git_status)
importFrom(httr,HEAD)
importFrom(sessioninfo,session_info)
importFrom(tools,R_user_dir)
importFrom(utils,as.person)
importFrom(utils,menu)
importFrom(utils,person)
importFrom(utils,read.table)
importFrom(utils,tail)
importFrom(utils,write.table)
importFrom(yaml,read_yaml)
importFrom(yaml,write_yaml)
NS_EOF

# Create README.md
cat > "$OUTPUT_DIR/README.md" << 'README_EOF'
# orgauth

<!-- badges: start -->
<!-- badges: end -->

The goal of orgauth is to manage person and organisation information with validation and formatting capabilities. It provides R6 classes for managing organisations and their members, with support for multiple languages, ORCID identifiers, ROR identifiers, licensing requirements, and integration with citation management systems.

## Installation

You can install the development version of orgauth from [GitHub](https://github.com/inbo/orgauth) with:

``` r
# install.packages("remotes")
remotes::install_github("inbo/orgauth")
```

## Example

This is a basic example which shows you how to create an organisation item:

``` r
library(orgauth)

# Create an organisation item
org <- org_item$new(
  name = c(
    `en-GB` = "Research Institute for Nature and Forest (INBO)",
    `nl-BE` = "Instituut voor Natuur- en Bosonderzoek (INBO)"
  ),
  email = "info@inbo.be",
  orcid = TRUE,
  rightsholder = "shared",
  funder = "when no other"
)

# Print the organisation
org$print()
```

## Code of Conduct

Please note that the orgauth project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.
README_EOF

# Create NEWS.md
cat > "$OUTPUT_DIR/NEWS.md" << 'NEWS_EOF'
# orgauth 0.0.1

* Initial release
* Extracted person and organisation management functionality from checklist package
* Core R6 classes: `org_item` and `org_list` 
* Author management functions: `use_author()`, `store_authors()`, `author2df()`
* Validation functions: `validate_email()`, `validate_orcid()`
* Support for multiple languages, ORCID/ROR identifiers, and licensing requirements
NEWS_EOF

# Create .Rbuildignore
cat > "$OUTPUT_DIR/.Rbuildignore" << 'RBUILD_EOF'
^.*\.Rproj$
^\.Rproj\.user$
^LICENSE\.md$
^README\.Rmd$
^\.github$
^docs$
^_pkgdown\.yml$
^pkgdown$
RBUILD_EOF

# Initialize git repository
echo "Initializing git repository..."
cd "$OUTPUT_DIR"
git init

# Check if git user is configured
if ! git config user.email > /dev/null 2>&1; then
    echo ""
    echo "⚠️  Git user not configured. Setting up for this repository..."
    echo "   (You can change this later or set globally with git config --global)"
    git config user.name "INBO Developer"
    git config user.email "info@inbo.be"
fi

git add -A
git commit -m "Initial package structure for orgauth

- Extract person and organisation management code from checklist
- Core R6 classes: org_item and org_list
- Author management: use_author, store_authors, author2df
- Validation functions for email, ORCID, ROR, URL
- Support for multilingual org names and licensing
- INBO org list with partner organisations
"

echo ""
echo "=================================="
echo "✅ SUCCESS!"
echo "=================================="
echo ""
echo "The orgauth package has been created at: $OUTPUT_DIR"
echo ""
echo "Package contents:"
echo "  - 6 R files in R/"
echo "  - DESCRIPTION, NAMESPACE, README.md, NEWS.md"
echo "  - LICENSE.md, .gitignore, .Rbuildignore"
echo "  - Git repository initialized with initial commit"
echo ""
echo "Next steps:"
echo "  1. cd $OUTPUT_DIR"
echo "  2. git remote add origin https://github.com/inbo/orgauth.git"
echo "  3. git branch -M main"
echo "  4. git push -u origin main"
echo ""
echo "Then verify at: https://github.com/inbo/orgauth"
echo ""
