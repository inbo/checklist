% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_package.R
\name{create_package}
\alias{create_package}
\title{Create an R package according to INBO requirements}
\usage{
create_package(package, path = ".", title, description, maintainer)
}
\arguments{
\item{package}{Name of the new package.}

\item{path}{Where to create the package directory.}

\item{title}{A single sentence with the title of the package.}

\item{description}{A single paragraph describing the package.}

\item{maintainer}{The output of \code{orcid2person()}.}
}
\description{
Create an R package according to INBO requirements
}
\seealso{
Other setup: 
\code{\link{setup_package}()}
}
\concept{setup}
