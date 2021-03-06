% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{yesno}
\alias{yesno}
\title{A function that asks a yes or no question to the user}
\usage{
yesno(...)
}
\arguments{
\item{...}{Currently ignored}
}
\value{
A logical where \code{TRUE} implies a "yes" answer from the user.
}
\description{
A function that asks a yes or no question to the user
}
\seealso{
Other utils: 
\code{\link{is_workdir_clean}()},
\code{\link{orcid2person}()},
\code{\link{validate_email}()}
}
\author{
Hadley Wickham \href{mailto:hadley@rstudio.com}{hadley@rstudio.com}
Largely based on devtools:::yesno().
The user gets three options in an random order: 2 for "no", 1 for "yes".
The wording for "yes" and "no" is random as well.
This forces the user to carefully read the question.
}
\concept{utils}
