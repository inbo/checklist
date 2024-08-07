% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/organisation_class.R
\name{organisation}
\alias{organisation}
\title{The organisation R6 class}
\description{
A class with the organisation defaults
}
\seealso{
Other class: 
\code{\link{checklist}},
\code{\link{citation_meta}},
\code{\link{spelling}}
}
\concept{class}
\section{Active bindings}{
\if{html}{\out{<div class="r6-active-bindings">}}
\describe{
\item{\code{as_person}}{The default organisation funder and rightsholder.}

\item{\code{get_community}}{The default organisation Zenodo communities.}

\item{\code{get_email}}{The default organisation email.}

\item{\code{get_funder}}{The default funder.}

\item{\code{get_github}}{The default GitHub organisation domain.}

\item{\code{get_organisation}}{The organisation requirements.}

\item{\code{get_rightsholder}}{The default rightsholder.}

\item{\code{template}}{A list for a check list template.}
}
\if{html}{\out{</div>}}
}
\section{Methods}{
\subsection{Public methods}{
\itemize{
\item \href{#method-organisation-new}{\code{organisation$new()}}
\item \href{#method-organisation-print}{\code{organisation$print()}}
\item \href{#method-organisation-clone}{\code{organisation$clone()}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-organisation-new"></a>}}
\if{latex}{\out{\hypertarget{method-organisation-new}{}}}
\subsection{Method \code{new()}}{
Initialize a new \code{organisation} object.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{organisation$new(...)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{...}}{The organisation settings.
See the details.}
}
\if{html}{\out{</div>}}
}
\subsection{Details}{
\itemize{
\item \code{github}: the name of the github organisation.
Set to \code{NA_character_} in case you don't want a mandatory github
organisation.
\item \code{community}: the mandatory Zenodo community.
Defaults to \code{"inbo"}.
Set to \code{NA_character_} in case you don't want a mandatory community.
\item \code{email}: the e-mail of the organisation.
Defaults to \code{"info@inbo.be"}.
Set to \code{NA_character_} in case you don't want an organisation e-mail.
\item \code{funder}: the funder.
Defaults to \code{"Research Institute for Nature and Forest (INBO)"}.
Set to \code{NA_character_} in case you don't want to set a funder.
\item \code{rightsholder}: the rightsholder.
Defaults to \code{"Research Institute for Nature and Forest (INBO)"}.
Set to \code{NA_character_} in case you don't want to set a rightsholder.
\item \code{organisation}: a named list with one or more organisation default
rules.
The names of the element must match the e-mail domain name of the
organisation.
Every element should be a named list containing \code{affiliation} and
\code{orcid}.
\code{affiliation} is a character vector with the approved organisation
names in one or more languages.
\code{orcid = TRUE} indicated a mandatory ORCiD for every member.
Use an empty list in case you don't want to set this.
}
}

}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-organisation-print"></a>}}
\if{latex}{\out{\hypertarget{method-organisation-print}{}}}
\subsection{Method \code{print()}}{
Print the \code{organisation} object.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{organisation$print(...)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{...}}{currently ignored.}
}
\if{html}{\out{</div>}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-organisation-clone"></a>}}
\if{latex}{\out{\hypertarget{method-organisation-clone}{}}}
\subsection{Method \code{clone()}}{
The objects of this class are cloneable with this method.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{organisation$clone(deep = FALSE)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{deep}}{Whether to make a deep clone.}
}
\if{html}{\out{</div>}}
}
}
}
