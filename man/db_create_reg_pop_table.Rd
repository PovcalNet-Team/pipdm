% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/db_create_reg_pop_table.R
\name{db_create_reg_pop_table}
\alias{db_create_reg_pop_table}
\title{Create regional population table}
\usage{
db_create_reg_pop_table(
  pop_table,
  cl_table,
  pip_years,
  region_code = c("pcn_region_code", "region_code")
)
}
\arguments{
\item{pop_table}{data.table: A table with population data.}

\item{cl_table}{data.table: A table with country metadata.}

\item{pip_years}{numeric: A vector with calender years used in PIP.}

\item{region_code}{character: A value with the region code column to use.}
}
\value{
data.table
}
\description{
Create an aggregated population table by region.
}
