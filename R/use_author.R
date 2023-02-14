#' Which author to use
#'
#' Reuse existing author information or add a new author.
#' Allows to update existing author information.
#' @return A data.frame with author information.
#' @importFrom fs path
#' @importFrom tools R_user_dir
#' @importFrom utils write.table
#' @family utils
#' @export
use_author <- function() {
  root <- R_user_dir("checklist", which = "data")
  current <- stored_authors(root)
  assert_that(
    interactive() || nrow(current) > 0,
    msg = "No available authors in a non-interactive session."
  )
  current <- current[
    order(-current$usage, current$family, current$given, current$orcid),
  ]
  while (TRUE) {
    sprintf("%s, %s", current$family, current$given) |>
      c("new person") |>
      menu_first("Which person information do you want to use?") -> selected
    cat(
      "given name: ", current$given[selected],
      "\nfamily name:", current$family[selected],
      "\ne-mail:     ", current$email[selected],
      "\norcid:      ", current$orcid[selected],
      "\naffiliation:", current$affiliation[selected])
    final <- menu_first(choices = c("use ", "update", "other"))
    if (final == 1) {
      break
    }
    if (final == 2) {
      current <- update_author(current, selected, root)
      next
    }
  }
  current$usage[selected] <- current$usage[selected] + 1
  write.table(
    current, file = path(root, "author.txt"), sep = "\t", row.names = FALSE,
    fileEncoding = "UTF8"
  )
  return(current[selected, ])
}

menu_first <- function(choices, graphics = FALSE, title = NULL) {
  if (!interactive()) {
    return(1)
  }
  menu(choices = choices, graphics = graphics, title = title)
}

#' @importFrom fs path
#' @importFrom utils menu write.table
update_author <- function(current, selected, root) {
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
  return(current)
}

new_author <- function(current, root) {
  cat("Please provide person information.\n")
  data.frame(
    given = readline(prompt = "given name:  "),
    family = readline(prompt = "family name: "),
    email = readline(prompt = "e-mail:      "),
    orcid = readline(prompt = "orcid:       "),
    affiliation = readline(prompt = "affiliation: "),
    usage = 0
  ) |>
    rbind(current) -> current
  write.table(
    current, file = path(root, "author.txt"), sep = "\t", row.names = FALSE,
    fileEncoding = "UTF8"
  )
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
    comment <- c(orcid = df$orcid)
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

author2badge <- function(role = "aut") {
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
  gsub(".*\\((.+)\\).*", "\\1", df$affiliation) |>
    gsub(pattern = "[a-z]*\\s*", replacement = "") -> aff
  sprintf("%s[^%s]", badge, aff) |>
    `attr<-`(
      which = "footnote",
      value = c(
        attr(badge, "footnote"), sprintf("[^%s]: %s", aff, df$affiliation)
      )
    )
}
