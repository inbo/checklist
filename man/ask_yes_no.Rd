% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/setup_project.R
\name{ask_yes_no}
\alias{ask_yes_no}
\title{Function to ask a simple yes no question}
\usage{
ask_yes_no(msg, default = TRUE, prompts = c("Yes", "No", "Cancel"), ...)
}
\arguments{
\item{msg}{
The prompt message for the user.
}

\item{default}{
The default response.
}

\item{prompts}{
Any of:  a character vector containing 3 prompts corresponding to
return values of \code{TRUE}, \code{FALSE}, or \code{NA}, or
a single character value containing the prompts separated by
\code{/} characters, or a function to call.
}

\item{...}{
Additional parameters, ignored by the default function.
}
}
\description{
Function to ask a simple yes no question
}
\seealso{
Other utils: 
\code{\link{author2df}()},
\code{\link{bookdown_zenodo}()},
\code{\link{c_sort}()},
\code{\link{create_hexsticker}()},
\code{\link{execshell}()},
\code{\link{menu_first}()},
\code{\link{orcid2person}()},
\code{\link{store_authors}()},
\code{\link{use_author}()},
\code{\link{validate_email}()},
\code{\link{validate_orcid}()},
\code{\link{yesno}()}
}
\concept{utils}
