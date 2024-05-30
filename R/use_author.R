#' Which author to use
#'
#' Reuse existing author information or add a new author.
#' Allows to update existing author information.
#' @return A data.frame with author information.
#' @param email An optional email address.
#' When given and it matches with a single person, the function immediately
#' returns the information of that person.
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom fs path
#' @importFrom tools R_user_dir
#' @importFrom utils write.table
#' @family utils
#' @export
use_author <- function(email) {
  root <- R_user_dir("checklist", which = "data")
  org <- read_organisation()
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
      cat("You must select a person\n")
      next
    }
    if (selected > nrow(current)) {
      current <- new_author(current = current, root = root, org = org)
    }
    cat(
      "given name: ", current$given[selected],
      "\nfamily name:", current$family[selected],
      "\ne-mail:     ", current$email[selected],
      "\norcid:      ", current$orcid[selected],
      "\naffiliation:", current$affiliation[selected]
    )
    current <- validate_author(
      current = current, selected = selected, org = org
    )
    final <- menu_first(choices = c("use ", "update", "other"))
    if (final == 1) {
      break
    }
    if (final == 2) {
      current <- update_author(current, selected, root, org)
      next
    }
  }
  current$usage[selected] <- pmax(current$usage[selected], 0) + 1
  write.table(
    current, file = path(root, "author.txt"), sep = "\t", row.names = FALSE,
    fileEncoding = "UTF8"
  )
  message("author information stored at ", path(root, "author.txt"))
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
update_author <- function(current, selected, root, org) {
  original <- current
  item <- c("given", "family", "email", "orcid", "affiliation")
  while (TRUE) {
    cat(
      "given name: ", current$given[selected],
      "\nfamily name:", current$family[selected],
      "\ne-mail:     ", current$email[selected],
      "\norcid:      ", current$orcid[selected],
      "\naffiliation:", current$affiliation[selected]
    )
    current <- validate_author(
      current = current, selected = selected, org = org
    )
    command <- menu(
      choices = c(item, "save and exit", "undo changes and exit"),
      title = "\nWhich item to update?"
    )
    if (command > length(item)) {
      break
    }
    sprintf(
      "current %s: %s\n", item[command], current[selected, item[command]]
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
    current, file = path(root, "author.txt"), sep = "\t", row.names = FALSE,
    fileEncoding = "UTF8"
  )
  message("author information stored at ", path(root, "author.txt"))
  return(current)
}

#' @importFrom assertthat assert_that
new_author <- function(current, root, org) {
  assert_that(inherits(org, "organisation"))
  org <- org$get_organisation
  cat("Please provide person information.\n")
  data.frame(
    given = readline(prompt = "given name:  "),
    family = readline(prompt = "family name: "),
    email = readline(prompt = "e-mail:      "),
    orcid = ask_orcid(prompt = "orcid:       ")
  ) -> extra
  gsub(".*@", "", extra$email) |>
    grepl(names(org), ignore.case = TRUE) |>
    which() -> which_org
  if (extra$email != "" && length(which_org) > 0) {
    org <- org[which_org]
    while (org[[1]]$orcid && extra$orcid == "") {
      cat("An ORCID is required for", names(org))
      extra$orcid <- ask_orcid(prompt = "orcid: ")
    }
    names(org[[1]]$affiliation) |>
      menu_first(title = "Which default language for the affiliation?") -> lang
    extra$affiliation <- org[[1]]$affiliation[lang]
  } else {
    extra$affiliation <- readline(prompt = "affiliation: ")
  }
  extra$usage <- 0
  rbind(current, extra) -> current
  write.table(
    current, file = path(root, "author.txt"), sep = "\t", row.names = FALSE,
    fileEncoding = "UTF8"
  )
  message("author information stored at ", path(root, "author.txt"))
  return(current)
}

author2person <- function(role = "aut") {
  df <- use_author()
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
    given = df$given, family = df$family, email = email, comment = comment,
    role = role
  )
}

#' @importFrom assertthat assert_that
#' @importFrom utils tail
author2badge <- function(role = "aut", org) {
  assert_that(inherits(org, "organisation"))
  df <- use_author()
  sprintf("[^%s]", role) |>
    paste(collapse = "") -> role_link
  if (is.na(df$orcid) || df$orcid == "") {
    badge <- sprintf("%s, %s%s", df$family, df$given, role_link)
  } else {
    badge <- paste0(
      "[%s, %s![ORCID logo](https://info.orcid.org/wp-content/uploads/2019/11/",
      "orcid_16x16.png)](https://orcid.org/%s)%s"
    ) |>
      sprintf(df$family, df$given, df$orcid, role_link)
  }
  c(
    aut = "author", cre = "contact person", cph = "copyrightholder",
    ctb = "contributor", fnd = "funder", rev = "reviewer"
  )[role] |>
    sprintf(fmt = "[^%2$s]: %1$s", role) -> attr(badge, "footnote")
  if (is.na(df$affiliation) || df$affiliation == "") {
    return(badge)
  }
  org <- org$get_organisation
  vapply(
    names(org), FUN.VALUE = vector(mode = "list", length = 1L),
    FUN = function(x) {
      data.frame(domain = x, affiliation = org[[x]]$affiliation) |>
        list()
    }
  ) |>
    do.call(what = rbind) -> aff_domain
  aff <- aff_domain$domain[aff_domain$affiliation == df$affiliation]
  gsub(".*\\((.+)\\).*", "\\1", df$affiliation) |>
    abbreviate() |>
    c(aff) |>
    tail(1) -> aff
  sprintf("%s[^%s]", badge, aff) |>
    `attr<-`(
      which = "footnote",
      value = c(
        attr(badge, "footnote"), sprintf("[^%s]: %s", aff, df$affiliation)
      )
    )
}

validate_author <- function(current, selected, org) {
  assert_that(inherits(org, "organisation"))
  org <- org$get_organisation
  names(org) |>
    gsub(pattern = "\\.", replacement = "\\\\.") |>
    paste(collapse = "|") |>
    sprintf(fmt = "@%s$") -> rg
  if (!grepl(rg, current$email[selected], ignore.case = TRUE)) {
    return(current)
  }
  this_org <- org[gsub(".*@", "", current$email[selected])]
  while (
    this_org[[1]]$orcid &&
    (is.na(current$orcid[selected]) || current$orcid[selected] == "")
  ) {
    cat("\nAn ORCID is required for", names(this_org))
    current$orcid[selected] <- ask_orcid(prompt = "orcid: ")
  }
  if (current$affiliation[selected] %in% this_org[[1]]$affiliation) {
    return(current)
  }
  names(this_org[[1]]$affiliation) |>
    menu_first(
      title = sprintf(
        "\nNon standard affiliation for `%s`.\n
Which default language for the affiliation?",
        names(this_org)
      )
    ) -> lang
  current$affiliation[selected] <- this_org[[1]]$affiliation[lang]
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
    crossprod(2 ^ powers) |>
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
