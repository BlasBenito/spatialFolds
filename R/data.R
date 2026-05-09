#' Dictionary of recognized coordinate column names
#'
#' @usage data(coordinates_names)
#'
#' @description
#' A named list with two elements, `x` and `y`, each containing character vectors
#' of recognized coordinate column name variants (case-insensitive). Used internally
#' by [cast_df_to_sf()] and [guess_crs()] to detect coordinate columns automatically.
#' Inspect this object to understand why a column name is or is not recognized.
#'
#' @format Named list with two elements:
#' \describe{
#'   \item{x}{Character vector of recognized x-coordinate column names (longitude / easting variants).}
#'   \item{y}{Character vector of recognized y-coordinate column names (latitude / northing variants).}
#' }
#' @seealso [cast_df_to_sf()], [guess_crs()]
#' @family casting_functions
"coordinates_names"

#' Matrix with 30k pairs of coordiantes
#'
#' @usage data(xy_matrix)
#'
#' @format Matrix with columns "x" and "y"
"xy_matrix"

#' Sf dataframe with 30k points and CRS 4326
#'
#' @usage data(xy_sf)
#'
#' @format Matrix with columns "id" and "geometry"
"xy_sf"
