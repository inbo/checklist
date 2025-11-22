#' Which author to use
#'
#' Reuse existing author information or add a new author.
#' Allows to update existing author information.
#' @return A data.frame with author information.
#' @param email An optional email address.
#' When given and it matches with a single person, the function immediately
#' returns the information of that person.
#' @param lang The language to use for the affiliation.
#' Defaults to the first language in the `name` vector of the
#' `org_list` object.
#' When the affiliation is not available in that language,
#' it will use the first available language.
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom fs path
#' @importFrom tools R_user_dir
#' @importFrom utils write.table
#' @family utils
#' @export
use_author <- function(email, lang) {
  root <- R_user_dir("checklist", which = "data")
  org <- org_list$new()$read()
  current <- stored_authors(root)
  assert_that(
    interactive() || nrow(current) > 0,
    msg = "No available authors in a non-interactive session."
  )
  current <- current[
    order(-current$usage, current$family, current$given, current$orcid),
  ]
  run_loop <- TRUE
  if (!missing(email)) {
    assert_that(is.string(email), noNA(email))
    selected <- which(current$email == email)
    run_loop <- length(selected) != 1
  }
  while (run_loop) {
    sprintf("%s, %s", current$family, current$given) |>
      c("new person") |>
      menu_first("Which person information do you want to use?") -> selected
    if (selected < 1) {
      warning("You must select a person\n", immediate. = TRUE, call. = FALSE)
      next
    }
    if (selected > nrow(current)) {
      current <- new_author(current = current, root = root, org = org)
    }
    current <- validate_author(
      current = current,
      selected = selected,
      org = org,
      lang = lang
    )
    final <- menu_first(choices = c("use ", "update", "other"))
    if (final == 1) {
      break
    }
    if (final == 2) {
      current <- update_author(
        current = current,
        selected = selected,
        root = root,
        org = org,
        lang = lang
      )
      next
    }
  }
  current$usage[selected] <- pmax(current$usage[selected], 0) + 1
  write.table(
    current,
    file = path(root, "author.txt"),
    sep = "\t",
    row.names = FALSE,
    fileEncoding = "UTF8"
  )
  message("author information stored at ", path(root, "author.txt"))
  aff <- org$get_name_by_domain(current$email[selected], lang = lang)
  if (length(aff) == 1) {
    current$affiliation[selected] <- names(aff)
  } else if (length(aff) > 1) {
    default_aff <- org$get_name_by_domain(current$email[selected])
    current$affiliation[selected] <- names(aff[
      names(default_aff) == current$affiliation[selected]
    ])
  }
  return(current[selected, ])
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

#' @importFrom fs path
#' @importFrom utils menu write.table
update_author <- function(current, selected, root, org, lang) {
  original <- current
  item <- c("given", "family", "email", "orcid", "affiliation")
  while (TRUE) {
    current <- validate_author(
      current = current,
      selected = selected,
      org = org,
      lang = lang
    )
    command <- menu(
      choices = c(item, "save and exit", "undo changes and exit"),
      title = "\nWhich item to update?"
    )
    if (command > length(item)) {
      break
    }
    sprintf(
      "current %s: %s\n",
      item[command],
      current[selected, item[command]]
    ) |>
      cat()
    current[selected, item[command]] <- readline(
      prompt = sprintf("New value for %s: ", item[command])
    )
  }
  if (command > length(item) + 1) {
    return(original)
  }
  write.table(
    current,
    file = path(root, "author.txt"),
    sep = "\t",
    row.names = FALSE,
    fileEncoding = "UTF8"
  )
  message("author information stored at ", path(root, "author.txt"))
  return(current)
}

#' @importFrom assertthat assert_that
new_author <- function(current, root, org, lang) {
  assert_that(inherits(org, "org_list"))
  cat("Please provide person information.\n")
  data.frame(
    given = readline(prompt = "given name:  "),
    family = readline(prompt = "family name: "),
    email = readline(prompt = "e-mail:      "),
    orcid = ask_orcid(prompt = "orcid:       ")
  ) -> extra
  which_org <- org$get_name_by_domain(extra$email, lang = lang)
  if (length(which_org) == 1) {
    extra$affiliation <- names(which_org)
    while (which_org && extra$orcid == "") {
      warning(
        "An ORCID is required for",
        names(which_org),
        immediate. = TRUE,
        call. = FALSE
      )
      extra$orcid <- ask_orcid(prompt = "orcid: ")
    }
  } else if (length(which_org) == 0) {
    extra$affiliation <- readline(prompt = "affiliation: ")
  } else {
    menu_first(
      choices = c(names(which_org), "other"),
      title = "Which organisation for the affiliation?"
    ) -> selection
    if (selection == length(which_org) + 1) {
      extra$affiliation <- readline(prompt = "affiliation: ")
    } else {
      extra$affiliation <- names(which_org)[selection]
    }
  }
  extra$usage <- 0
  rbind(current, extra) -> current
  write.table(
    current,
    file = path(root, "author.txt"),
    sep = "\t",
    row.names = FALSE,
    fileEncoding = "UTF8"
  )
  message("author information stored at ", path(root, "author.txt"))
  return(current)
}

author2person <- function(role = "aut", lang) {
  df <- use_author(lang = lang)
  if (is.na(df$email) || df$email == "") {
    email <- NULL
  } else {
    email <- df$email
  }
  if (is.na(df$orcid) || df$orcid == "") {
    comment <- character(0)
  } else {
    comment <- c(ORCID = df$orcid)
  }
  if (!is.na(df$affiliation) && df$affiliation != "") {
    comment <- c(comment, affiliation = df$affiliation)
  }
  if (length(comment) == 0) {
    comment <- NULL
  }
  person(
    given = df$given,
    family = df$family,
    email = email,
    comment = comment,
    role = role
  )
}

authors2badge <- function(df, role = "aut") {
  badges <- character(nrow(df))
  footnotes <- vector(mode = "list", length = nrow(df))
  for (i in seq_len(nrow(df))) {
    if (has_name(df, "role")) {
      strsplit(df$role[i], ", ") |>
        unlist() -> this_role
    } else {
      this_role <- role
    }
    badge <- author2badge(df[i, ], role = this_role)
    footnotes[[i]] <- attr(badge, "footnote")
    badges[i] <- badge
  }
  attr(badges, which = "footnote") <- unlist(footnotes) |>
    unique()
  return(badges)
}

#' @importFrom assertthat assert_that
#' @importFrom utils tail
author2badge <- function(df, role = "aut") {
  if (nrow(df) > 1) {
    return(authors2badge(df, role = role))
  }
  sprintf("[^%s]", role) |>
    paste(collapse = "") -> role_link
  if (is.na(df$orcid) || df$orcid == "") {
    if (is.na(df$email) || df$email == "") {
      ifelse(df$family == "", "", paste0(df$family, ", ")) |>
        paste0(df$given, role_link) -> badge
    } else {
      df$email |>
        gsub(pattern = "@", replacement = "%40") |>
        sprintf(
          fmt = "[%2$s%3$s](mailto:%1$s)%4$s",
          ifelse(df$family == "", "", paste0(df$family, ", ")),
          df$given,
          role_link
        ) -> badge
    }
  } else {
    badge <- paste0(
      "[%s, %s![ORCID logo](https://info.orcid.org/wp-content/uploads/2019/11/",
      "orcid_16x16.png)](https://orcid.org/%s)%s"
    ) |>
      sprintf(df$family, df$given, df$orcid, role_link)
  }
  c(
    aut = "author",
    cre = "contact person",
    cph = "copyright holder",
    ctb = "contributor",
    fnd = "funder",
    rev = "reviewer"
  )[role] |>
    sprintf(fmt = "[^%2$s]: %1$s", role) -> attr(badge, "footnote")
  if (is.na(df$affiliation) || df$affiliation == "") {
    return(badge)
  }
  if (grepl("\\(.+\\)", df$affiliation)) {
    aff <- gsub(".*\\((.+)\\).*", "\\1", df$affiliation)
  } else {
    aff <- abbreviate(df$affiliation)
  }

  sprintf("%s[^%s]", badge, aff) |>
    `attr<-`(
      which = "footnote",
      value = c(
        attr(badge, "footnote"),
        sprintf("[^%s]: %s", aff, df$affiliation)
      )
    )
}

validate_author <- function(current, selected, org, lang) {
  assert_that(inherits(org, "org_list"))
  affiliation <- org$get_name_by_domain(current$email[selected], lang = lang)
  if (length(affiliation) == 0) {
    return(current)
  }
  if (!current$affiliation[selected] %in% names(affiliation)) {
    if (length(affiliation) == 1) {
      current$affiliation[selected] <- names(affiliation)
    } else {
      menu_first(
        choices = names(affiliation),
        title = paste(
          "Which organisation for the affiliation?",
          "Update `organisation.yml` if not listed."
        )
      ) -> selected_affiliation
      current$affiliation[selected] <- names(affiliation)[selected_affiliation]
    }
  }
  while (
    affiliation[current$affiliation[selected]] && current$orcid[selected] == ""
  ) {
    warning(
      "\nAn ORCID is required for",
      current$affiliation[selected],
      immediate. = TRUE,
      call. = FALSE
    )
    current$orcid[selected] <- ask_orcid(prompt = "orcid: ")
  }
  cat(
    "given name: ",
    current$given[selected],
    "\nfamily name:",
    current$family[selected],
    "\ne-mail:     ",
    current$email[selected],
    "\norcid:      ",
    current$orcid[selected],
    "\naffiliation:",
    current$affiliation[selected]
  )
  return(current)
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
  if (all(!format_ok)) {
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
