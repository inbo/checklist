# Naming conventions for folders and files

To make this easier to remember we choose the same name conventions for
file names as for objects. We acknowledge that these rules sometimes
clash with requirements from other sources (e.g. `DESCRIPTION` in an R
package, `README.md` on GitHub, `.gitignore` for git, …). In such case
we allow the file names as required by R, git or GitHub. When
[`check_filename()`](https://inbo.github.io/checklist/reference/check_filename.md)
does unfairly not allow a certain file or folder name, then please open
an [issue on GitHub](https://github.com/inbo/checklist/issues) and
motivate why this should be allowed.

## Rules for folder names

- Folder names should only contain lower case letters, numbers and
  underscore (`_`).
- They can start with a single dot (`.`).

## Rules for file names

- Base names should only contain lower case letters, numbers and
  underscore (`_`).
- File extensions should only contains lower case letters and numbers.
  Exceptions: file extensions related to R must have an upper case R
  (`.R`, `.Rmd`, `.Rd`, `.Rnw`, `.Rproj`).

## Rules for graphical file names

- Currently applies to files with these extensions: `csl`, `eps`, `gif`,
  `jpg`, `jpeg`, `pdf`, `png`, `ps`, `svg`, `tiff`, `tif` and `wmf`.
- Same rules except that you need to use a dash (`-`) as separator
  instead of an underscore (`_`). We need this exception because
  underscores cause problems with graphics files in certain situations.
