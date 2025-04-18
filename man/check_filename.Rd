% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check_filename.R
\name{check_filename}
\alias{check_filename}
\title{Check the style of file and folder names}
\usage{
check_filename(x = ".")
}
\arguments{
\item{x}{Either a \code{checklist} object or a path to the source code.
Defaults to \code{.}.}
}
\description{
A consistent naming schema avoids problems when working together,
especially when working with different OS.
Some OS (e.g. Windows) are case-insensitive whereas others (e.g. Linux) are
case-sensitive.
Note that the \code{checklist} GitHub Actions will test your code on Linux,
Windows and MacOS.
}
\details{
The sections below describe the default rules.
We allow several exceptions when the community standard is different.
E.g. a package stores the function scripts in the \code{R} folder, while our
standard enforces lower case folder names.
Use the community standard, even if it does not conform with the \code{checklist}
rules.
Most likely \code{checklist} will have an exception for the name.
If not, you can file an \href{https://github.com/inbo/checklist/issues}{issue} and
motivate why you think we should add an exception.
}
\section{Rules for folder names}{

\itemize{
\item Folder names should only contain lower case letters, numbers, dashes (\code{-})
and underscores (\verb{_}).
\item They can start with a single dot (\code{.}).
}
}

\section{Default rules for file names}{

\itemize{
\item Base names should only contain lower case letters, numbers, dashes (\code{-})
and underscores (\verb{_}).
\item File extensions should only contain lower case letters and numbers.
Exceptions: file extensions related to \code{R} must have an upper case \code{R} (
\code{.R}, \code{.Rd}, \code{.Rda}, \code{.Rnw}, \code{.Rmd}, \code{.Rproj}).
Exception to these exceptions: \code{R/sysdata.rda}.
}
}

\section{Exceptions for some file formats}{

Underscores (\verb{_}) causes problems for graphical files when using LaTeX to
create pdf output.
This is how we generate pdf output from rmarkdown.
Therefore you need to use a dash (\code{-}) as separator instead of
an underscores (\verb{_}).
Applies to files with extensions \code{eps}, \code{jpg}, \code{jpeg}, \code{pdf}, \code{png}, \code{ps}, \code{svg} and \code{.cls}.

We ignore files with \code{.otf} or \code{.ttf} extensions.
These are fonts files which often require their own file name scheme.
}

\seealso{
Other both: 
\code{\link{add_badges}()},
\code{\link{check_lintr}()},
\code{\link{check_spelling}()},
\code{\link{custom_dictionary}()},
\code{\link{default_organisation}()},
\code{\link{print.checklist_spelling}()},
\code{\link{read_checklist}()},
\code{\link{read_organisation}()},
\code{\link{update_citation}()},
\code{\link{write_checklist}()},
\code{\link{write_citation_cff}()},
\code{\link{write_organisation}()},
\code{\link{write_zenodo_json}()}
}
\concept{both}
