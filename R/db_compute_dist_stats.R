#' Calculate distributional statistics
#'
#' Calculate distributional statistics  for a single survey dataset.
#'
#' @inheritParams db_clean_data
#' @param pop_table data.table: A table with population data.
#' @param mean numeric: A value with the survey mean.
#' @param cache_id character: cache id to identify the right process
#' @return list
#' @export
db_compute_dist_stats <- function(dt, mean, pop_table, cache_id, gc = FALSE) {

  tryCatch(
    expr = {

      # Compute dist stats
      res <- compute_dist_stats(dt, mean, pop_table, cache_id)

      # Garbage collection
      if (gc) gc(verbose = FALSE)

      return(res)

    }, # end of expr section

    error = function(e) {

      rlang::warn('Distributional statistics caluclation failed. Returning NULL.')

      # Garbage collection
      if (gc) gc(verbose = FALSE)

      return(NULL)

    } # end of error
  ) # End of trycatch

}

#' compute_dist_stats
#' @inheritParams db_compute_dist_stats
#' @return list
#' @noRd
compute_dist_stats <- function(dt, mean, pop_table, cache_id) {

  # identify procedure
  source      <- gsub("(.*_)([A-Z]+$)", "\\2", cache_id)
  data_level  <- gsub("(.*_)(D[123])(.+$)", "\\2", cache_id)

  # NOTE: we should variable pop_data_level to something more general. We could
  # use something similar to vartiable max_domain in the function db_filter_inventory

  # Order by population data level
  data.table::setorder(dt, pop_data_level)
  pop_level <- unique(dt$pop_data_level)

  # get estimates by level
  res  <- purrr::map(.x = pop_level,
                     .f = ~get_dist_stats_by_level(dt, mean, source, level = .x))

  names(res) <- pop_level

  if (data_level != "D1") { # Urban/rural or subnat level

    if (source == "GROUP") { # Group data

      # create synthetic vector
      wf <- purrr::map_df(.x = pop_level,
                          .f = ~get_synth_vector(dt, pop_table, mean, level = .x))

    } else { # microdata

      wf <- data.table::copy(dt)

    }

    # national mean
    res_national <- md_dist_stats(wf)

    res <- append(list(res_national), res)
    names(res) <- c("national", pop_level)

  }

  return(res)

}

#' md_dist_stats
#' @inheritParams db_compute_dist_stats
#' @return list
#' @noRd
md_dist_stats <- function(dt, mean = NULL){
  # Calculate dist stats
  res <- md_compute_dist_stats(
    welfare = dt$welfare,
    weight  = dt$weight,
    mean    = mean)
  return(res)
}

#' gd_dist_stats
#' @inheritParams db_compute_dist_stats
#' @return list
#' @noRd
gd_dist_stats <- function(dt, mean){
  # Calculate dist stats
  res <- gd_compute_dist_stats(
    welfare    = dt$welfare,
    population = dt$weight,
    mean       = mean)

  # Select dist stats
  res <- res[c('mean', 'median', 'gini', 'polarization', 'mld', 'deciles')]

  # Rename deciles to quantiles (for comparability with md_compute_dist_stats)
  names(res)[length(res)] <- 'quantiles'
  return(res)
}

#' id_dist_stats
#' @inheritParams db_compute_dist_stats
#' @return list
#' @noRd
id_dist_stats <- function(dt){

  # Slit by imputation id
  dl <- split(dt, f = list(dt$imputation_id))

  # Compute stats by group
  dl_stats <- purrr::map(dl, function(x) md_dist_stats(x, mean = NULL))

  # Aggregate quantiles
  q <- purrr::map(dl_stats, function(x) x$quantiles)
  qm <- do.call('cbind', q)
  quantiles <- rowMeans(qm)

  # Aggregate the rest and
  # combine to list
  res <- list(
    mean         = mean(purrr::map_dbl(dl_stats, function(x) x$mean)),
    median       = mean(purrr::map_dbl(dl_stats, function(x) x$median)),
    gini         = mean(purrr::map_dbl(dl_stats, function(x) x$gini)),
    polarization = mean(purrr::map_dbl(dl_stats, function(x) x$polarization)),
    mld          = mean(purrr::map_dbl(dl_stats, function(x) x$mld)),
    quantiles    = quantiles
  )
  return(res)
}

#' Get dist stats based on data level for md or gd
#'
#' @inheritParams db_compute_dist_stats
#' @inheritParams get_synth_vector
#'
#' @return list
#' @noRd
get_dist_stats_by_level <- function(dt, mean, source, level) {

  df  <- dt[max_domain == level]

  if (source == "GROUP") {
    res <- gd_dist_stats(df, mean[level])
  } else {
    is_imputed <- length(unique(df$imputation_id)) > 1
    if (is_imputed) {
      res <- id_dist_stats(df)
    } else {
      res <- md_dist_stats(df, mean[level])
    }
  }
  return(res)

}

#' Get synthetic vector based on data level
#'
#' @param dt data.table: A table with grouped data.
#' @param pop_table data.table: A table with population data.
#' @param mean numeric: A named vector of means. The name must correspond to
#'   the data level of the value,
#' @param level character: data level. it could  be national, urban, rural, or
#'   any other subnational division
#'
#' @return data.frame
#' @noRd
get_synth_vector <- function(dt, pop_table, mean, level) {

  df <- dt[max_domain == level]
  ccode     <- dt[, unique(country_code)]
  svid_year <- dt[, unique(surveyid_year)]

  popf   <- pop_table[country_code     == ccode
                      & year           == svid_year
                      & pop_data_level == level,
                      pop]

  wf <- sd_create_synth_vector(df$welfare,
                               df$weight,
                               mean = mean[level],
                               pop  = popf)
  return(wf)
}
