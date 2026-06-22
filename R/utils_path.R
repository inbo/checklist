# Internal path utility functions replacing the `fs` package equivalents.

#' Find the longest common directory prefix of a vector of paths.
#' @param paths Character vector of file paths.
#' @return A single string with the common directory prefix.
#' @noRd
path_common_ <- function(paths) {
  paths <- normalizePath(paths, winslash = "/", mustWork = FALSE)
  if (length(paths) <= 1L) {
    return(dirname(paths))
  }
  parts <- strsplit(paths, "/")
  min_len <- min(lengths(parts))
  common <- character(0)

  for (i in seq_len(min_len)) {
    elements <- vapply(parts, `[`, character(1), i)
    if (length(unique(elements)) != 1L) {
      break
    }
    common <- c(common, elements[1L])
  }
  if (length(common) == 0L) {
    return("")
  }
  paste(common, collapse = "/")
}

#' Filter paths by a glob pattern.
#' @param paths Character vector of file paths.
#' @param glob A glob pattern (using `*` as wildcard).
#' @param invert If `TRUE`, return paths that do NOT match.
#' @return Filtered character vector.
#' @noRd
path_filter_ <- function(paths, glob, invert = FALSE) {
  # Convert glob to regex: escape dots, convert * to [^/]*, ** to .*
  regex <- glob
  regex <- gsub("\\.", "\\\\.", regex)
  regex <- gsub("\\*\\*", "\x01", regex)
  regex <- gsub("\\*", "[^/]*", regex)
  regex <- gsub("\x01", ".*", regex)
  regex <- paste0("^", regex, "$")
  matched <- grepl(regex, paths)
  if (invert) {
    return(paths[!matched])
    paths[matched]
  }
  paths[matched]
}

#' Check whether a path has a given parent (i.e. starts with the parent).
#' @param path A single file path or character vector.
#' @param parent A single directory path pattern to check against.
#' @return Logical vector of the same length as `path`.
#' @noRd
path_has_parent_ <- function(path, parent) {
  # Normalise separators
  path <- gsub("\\\\", "/", path)
  parent <- gsub("\\\\", "/", parent)

  # Remove trailing slashes
  parent <- sub("/+$", "", parent)
  path <- sub("/+$", "", path)
  # Use vectorised `|` instead of scalar `||` to support multiple paths
  startsWith(path, paste0(parent, "/")) | path == parent
}

#' Compute a relative path from `start` to `path`.
#' @param path Character vector of paths.
#' @param start A single base directory.
#' @return Character vector of relative paths.
#' @noRd
path_rel_ <- function(path, start) {
  start <- normalizePath(start, winslash = "/", mustWork = FALSE)
  start <- sub("/+$", "", start)
  vapply(path, FUN.VALUE = character(1), USE.NAMES = FALSE, function(p) {
    p <- normalizePath(p, winslash = "/", mustWork = FALSE)
    if (startsWith(p, paste0(start, "/"))) {
      return(substring(p, nchar(start) + 2L))
    }
    # Fall back: split and find divergence
    sp <- strsplit(p, "/")[[1]]
    ss <- strsplit(start, "/")[[1]]
    common_len <- 0L
    for (i in seq_len(min(length(sp), length(ss)))) {
      if (sp[i] != ss[i]) {
        break
      }
      common_len <- i
    }
    ups <- rep("..", length(ss) - common_len)
    rest <- sp[seq(common_len + 1L, length(sp))]
    paste(c(ups, rest), collapse = "/")
  })
}
