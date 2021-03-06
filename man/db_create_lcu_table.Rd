% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/db_create_lcu_table.R
\name{db_create_lcu_table}
\alias{db_create_lcu_table}
\title{Create survey mean table (LCU)}
\usage{
db_create_lcu_table(dl, pop_table, pfw_table)
}
\arguments{
\item{dl}{list: A list with survey mean datasets.}

\item{pop_table}{data.table: A table with population data.}

\item{pfw_table}{data.table: A table with the Price Framework.}
}
\value{
data.table
}
\description{
Create a table with welfare means in Local Currency Units (LCU) for each
survey.
}
