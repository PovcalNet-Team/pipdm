% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/db_select_lineup_surveys.R
\name{select_lineup_survey}
\alias{select_lineup_survey}
\title{Select a single line-up survey}
\usage{
select_lineup_survey(df, ref_year)
}
\arguments{
\item{df}{data.frame: Subset of reference_year table.}

\item{ref_year}{numeric: Reference year.}
}
\value{
data.frame
}
\description{
Prioritize surveys to be used for the line-up. This is needed when multiple
choices of surveys are available. For instance, if two surveys are available
for the same year, one using consumption, the other one income.
}
\keyword{internal}
