#' @importFrom assertthat assert_that
#' @importFrom fs file_exists path
#' @importFrom tools R_user_dir
#' @importFrom utils menu read.table
use_author <- function() {
  root <- R_user_dir("checklist", which = "data")
  assert_that(
    file_exists(path(root, "author.txt")),
    msg = paste(
      "no stored author information.",
      "Please use `store_authors()` on existing packages."
    )
  )
  path(root, "author.txt") |>
    read.table(header = TRUE, sep = "\t") -> current
  current <- current[
    order(-current$usage, current$family, current$given, current$orcid),
  ]
  while (TRUE) {
    sprintf("%s, %s", current$family, current$given) |>
      c("new person") |>
      menu(title = "Which person information you want to use?") -> selected
    cat(
      "given name: ", current$given[selected],
      "\nfamily name:", current$family[selected],
      "\ne-mail:     ", current$email[selected],
      "\norcid:      ", current$orcid[selected],
      "\naffiliation:", current$affiliation[selected])
    final <- menu(choices = c("use ", "update", "other"))
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

#' @importFrom fs path
#' @importFrom utils menu write.table
update_author <- function(current, selected, root) {
  original <- current
  item <- c("given", "family", "e-mail", "orcid", "affiliation")
  while (TRUE) {
    cat(
      "given name: ", current$given[selected],
      "\nfamily name:", current$family[selected],
      "\ne-mail:     " , current$email[selected],
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
    cbind(current) -> current
  write.table(
    current, file = path(root, "author.txt"), sep = "\t", row.names = FALSE,
    fileEncoding = "UTF8"
  )
  return(current)
}

author2person <- function(role = "aut") {
  df <- use_author()
  if (df$email == "") {
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
