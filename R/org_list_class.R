#' @title The `org_list`  R6 class
#' @description A class containing a list of organisations
#' @export
#' @importFrom assertthat has_name is.string noNA
#' @importFrom R6 R6Class
#' @family class
org_list <- R6Class(
  "org_list",
  public = list(
    #' @description Initialize a new `org_list` object.
    #' @param ... One or more `org_item` objects.
    initialize = function(...) {
      dots <- list(...)
      vapply(dots, inherits, logical(1), what = "org_item") |>
        as.list() -> ok
      names(ok) <- sprintf("element %i is not an `org_item`", seq_along(dots))
      do.call(stopifnot, ok)
      vapply(dots, FUN.VALUE = character(1), FUN = function(x) {
        x$get_rightsholder
      }) |>
        compatible_rules()
      vapply(dots, FUN.VALUE = character(1), FUN = function(x) {
        x$get_funder
      }) |>
        compatible_rules()
      vapply(
        dots,
        FUN.VALUE = vector(mode = "list", length = 1),
        FUN = function(x) {
          list(x$get_name)
        }
      ) |>
        unlist() -> names
      ok <- list(anyDuplicated(names) == 0)
      names(ok) <- sprintf(
        "duplicated organisation name: `%s`",
        names[anyDuplicated(names)]
      )
      do.call(stopifnot, ok)
      private$items <- dots
      return(self)
    },
    #' @description Print the `org_list` object.
    print = function() {
      vapply(
        seq_along(private$items),
        FUN.VALUE = logical(1),
        x = private$items,
        FUN = function(i, x) {
          rules() |>
            c(sprintf("organisation %i", i), rules(".")) |>
            cat()
          print(x[[i]])
          return(invisible(TRUE))
        }
      )
      cat(rules())
      return(invisible(self))
    },
    #' @description  Read the `org_list` object from an `organisation.yml` file.
    #' @param x The path to the directory where the `organisation.yml` file
    #' is stored.
    #' @importFrom fs is_dir path
    #' @importFrom yaml read_yaml write_yaml
    read = function(x = ".") {
      checklist <- try(read_checklist(x = x), silent = TRUE)
      if (inherits(checklist, "checklist")) {
        x <- checklist$get_path
      } else {
        stopifnot("`x` is not an existing directory" = is_dir(x))
      }
      path(x, "organisation.yml") |>
        read_yaml() |>
        lapply(function(z) {
          do.call(org_item$new, z)
        }) |>
        do.call(what = org_list$new) -> self
      return(self)
    },
    #' @description  Write the `org_list` object to an `organisation.yml` file.
    #' @param x The path to the directory where the `organisation.yml` file
    #' should be written.
    #' @importFrom fs path
    #' @importFrom yaml write_yaml
    write = function(x = ".") {
      checklist <- try(read_checklist(x = x), silent = TRUE)
      if (inherits(checklist, "checklist")) {
        x <- checklist$get_path
      }
      vapply(
        private$items,
        FUN.VALUE = vector(mode = "list", length = 1),
        FUN = function(x) {
          list(x$as_list)
        }
      ) |>
        write_yaml(file = path(x, "organisation.yml"))
      return(path(x, "organisation.yml"))
    }
  ),
  private = list(items = list())
)

compatible_rules <- function(rules) {
  if (length(rules) < 2) {
    return(TRUE)
  }
  stopifnot(
    "more than one organisation with `single`" = sum(rules == "single") <= 1,
    "`single` is not compatible with `shared`" = !(any(rules == "single") &&
      any(rules == "shared")),
    "`single` is not compatible with `when no other`" = !(any(
      rules == "single"
    ) &&
      any(rules == "when no other")),
    "more than one organisation with `when no other`" = sum(
      rules == "when no other"
    ) <=
      1
  )
}
