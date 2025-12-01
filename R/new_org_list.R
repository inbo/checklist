#' Interactively create a new organisation list
#'
#' An interactive alternative for `org_list$new()`.
#' Reuses available organisations where possible.
#' @param git An optional string with the absolute path to a git
#' organisation.
#' E.g. `"https://github.com/inbo"`
#' @seealso [`org_list`], [`org_item`]
#' @family setup
#' @export
new_org_list <- function(git) {
  available <- get_available_organisations()
  rf_option <- c("optional", "single", "shared", "when no other")
  orgs <- list()
  repeat {
    names(available$names) |>
      c("Other") |>
      menu_first(title = "Select the organisation's email") -> selected
    if (selected <= length(available$names)) {
      extra <- org_item$new(
        email = names(available$names)[selected],
        name = available$names[[selected]],
        rightsholder = rf_option[menu_first(
          choices = rf_option,
          title = "What are the rightsholder requirements for this organisation"
        )],
        funder = rf_option[menu_first(
          choices = rf_option,
          title = "What are the funder requirements for this organisation"
        )],
        orcid = unname(available$orcid[names(available$names)[selected]]),
        zenodo = unname(available$zenodo[names(available$names)[selected]]),
        ror = unname(available$ror[names(available$names)[selected]]),
        website = unname(available$website[names(available$names)[selected]]),
        logo = unname(available$logo[names(available$names)[selected]])
      )
      available$names <- available$names[-selected]
    } else {
      extra <- new_org_item(
        languages = available$languages,
        licenses = available$licenses
      )
    }
    orgs[[length(orgs) + 1]] <- extra
    if (!ask_yes_no("Add another organisation?", default = FALSE)) {
      break
    }
  }
  if (!missing(git)) {
    orgs[["git"]] <- ssh_http(git)
  }
  do.call(org_list$new, orgs)
}

new_org_item <- function(languages, licenses) {
  email <- ask_email("The organisations' email address: ")
  name <- readline(prompt = "The organisations' name: ")
  lang <- ask_language(
    org = list(get_languages = languages),
    prompt = "What is the language of this name?"
  )
  names(name) <- lang
  while (ask_yes_no("Add a name in another language?", default = FALSE)) {
    lang <- ask_language(
      org = list(get_languages = languages[!languages %in% names(name)]),
      prompt = "In what language?"
    )
    extra <- readline(
      prompt = sprintf("The organisations' name in %s: ", lang)
    )
    names(extra) <- lang
    name <- c(name, extra)
  }
  website <- ask_url("The optional organisations' website URL: ")
  logo <- ask_url("The optional organisations' logo URL: ")
  ror <- ask_ror("The optional organisations' ROR identifier: ")
  zenodo <- readline("The optional Zenodo community identifier:")
  orcid <- ask_yes_no(
    "Is an OrcID required for members of this organisation?",
    default = FALSE
  )
  rightsholder <- c("optional", "single", "shared", "when no other")
  rightsholder <- rightsholder[menu_first(
    choices = rightsholder,
    title = "What are the rightsholder requirements for this organisation"
  )]
  funder <- c("optional", "single", "shared", "when no other")
  funder <- funder[menu_first(
    choices = funder,
    title = "What are the funder requirements for this organisation"
  )]
  org_item$new(
    name = name,
    email = email,
    orcid = orcid,
    rightsholder = rightsholder,
    funder = funder,
    ror = ror,
    zenodo = zenodo,
    license = list(
      package = ask_new_license(licenses, type = "package"),
      project = ask_new_license(licenses, type = "project"),
      data = ask_new_license(licenses, type = "data")
    ),
    website = website,
    logo = logo
  )
}

ask_new_license <- function(licenses, type = c("package", "project", "data")) {
  type <- match.arg(type)
  license <- character(0)
  repeat {
    license_choices <- c(names(licenses), "Other license", "No license")
    license_selected <- menu_first(
      choices = license_choices,
      title = sprintf("Select a %s license", type)
    )
    if (license_selected == length(licenses) + 2) {
      break
    }
    if (license_selected <= length(licenses)) {
      license <- c(license, licenses[license_selected])
      licenses <- licenses[-license_selected]
    } else {
      sprintf("Enter the %s license abbrevation: ", type) |>
        readline() -> short
      sprintf(
        "Enter the URL for a markdown version of the %s license: ",
        type
      ) |>
        readline() -> url
      names(url) <- short
      license <- c(license, url)
    }
    if (
      !ask_yes_no(sprintf("Add another a %s license", type), default = FALSE)
    ) {
      break
    }
  }
  return(license)
}

ask_email <- function(prompt) {
  repeat {
    email <- readline(prompt = prompt)
    if (validate_email(email)) {
      break
    }
    warning("Please enter a valid email.", immediate. = TRUE, call. = FALSE)
  }
  return(email)
}

validate_ror <- function(ror) {
  stopifnot(
    "`ror` must be a string" = is.string(ror),
    "`ror` cannot be NA" = noNA(ror)
  )
  grepl(
    "^https:\\/\\/ror\\.org\\/0[a-hj-km-np-tv-z|0-9]{6}[0-9]{2}$",
    ror,
    perl = TRUE
  )
}

ask_ror <- function(prompt) {
  repeat {
    ror <- readline(prompt = prompt)
    if (ror == "" || validate_ror(ror)) {
      break
    }
    warning(
      "`ror` must be in https://ror.org/id format",
      immediate. = TRUE,
      call. = FALSE
    )
  }
  return(ror)
}

ask_url <- function(prompt) {
  repeat {
    url <- readline(prompt = prompt)
    if (url == "" || validate_url(url)) {
      break
    }
    warning("Please enter a valid URL.", immediate. = TRUE, call. = FALSE)
  }
  return(url)
}

validate_url <- function(url) {
  stopifnot(
    "`url` must be a string" = is.string(url),
    "`url` cannot be NA" = noNA(url)
  )
  grepl(
    "^(http|https)://[a-z0-9-]+(\\.[a-z0-9-]+)+(:[0-9]+)?(/.*)?$",
    url,
    perl = TRUE
  )
}
