% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_checklist.R
\name{read_checklist}
\alias{read_checklist}
\title{Read the check list file from a package}
\usage{
read_checklist(x = ".")
}
\arguments{
\item{x}{Either a \code{checklist} object or a path to the source code.
Defaults to \code{.}.}
}
\value{
A \code{checklist} object.
}
\description{
The checklist package stores configuration information in the \code{checklist.yml}
file in the root of a project.
This function reads this configuration.
It is mainly used by the other functions inside the package.
If no \code{checklist.yml} file is found at the path,
the function walks upwards through the directory structure until it finds
such file.
The function returns an error when it reaches the root of the disk without
finding a \code{checklist.yml} file.
}
\seealso{
Other both: 
\code{\link{add_badges}()},
\code{\link{check_filename}()},
\code{\link{check_lintr}()},
\code{\link{check_spelling}()},
\code{\link{custom_dictionary}()},
\code{\link{default_organisation}()},
\code{\link{print.checklist_spelling}()},
\code{\link{read_organisation}()},
\code{\link{update_citation}()},
\code{\link{write_checklist}()},
\code{\link{write_citation_cff}()},
\code{\link{write_organisation}()},
\code{\link{write_zenodo_json}()}
}
\concept{both}
