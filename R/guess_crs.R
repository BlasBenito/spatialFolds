#' Guess the EPSG code from coordinate ranges and column names
#' @description
#' Attempts to identify the EPSG code from coordinate value ranges and column names.
#' Returns EPSG:4326 for geographic (lat/lon) coordinates, EPSG:3857 for Web Mercator
#' scale values, and `NA_integer_` for projected CRS that cannot be determined from
#' values alone (e.g. UTM).
#' @param x (required, numeric) Numeric vector of x (longitude or easting) coordinates.
#' @param y (required, numeric) Numeric vector of y (latitude or northing) coordinates.
#' @param x_name (optional, character) Column name for x coordinates. Names matching the
#'   lat/lon family (`lat`, `lon`, `long`, `longitude`, `latitude`, `latitud`, `longitud`)
#'   provide additional confirmation of EPSG:4326. Default: NULL
#' @param y_name (optional, character) Column name for y coordinates. Same name-matching
#'   logic as `x_name`. Default: NULL
#' @return Single integer EPSG code (4326L or 3857L), or `NA_integer_` with an
#'   informative message when the CRS cannot be determined.
#' @details
#' Detection proceeds in three steps:
#' \enumerate{
#'   \item **Name heuristic**: if `x_name` or `y_name` matches the lat/lon family,
#'     this is recorded as additional confirmation of EPSG:4326.
#'   \item **EPSG:4326 range check**: if `max(abs(x)) <= 180` AND `max(abs(y)) <= 90`,
#'     returns 4326L. A message notes whether the column names also confirmed this.
#'   \item **EPSG:3857 range check**: if `max(abs(x)) > 1000000` AND
#'     `max(abs(x)) <= 20037509` AND `max(abs(y)) <= 20048967`, returns 3857L.
#'   \item **Fallback**: returns `NA_integer_` with a message asking the user to
#'     supply `crs` explicitly.
#' }
#'
#' **Limitations**:
#' - Small spatial extents in a projected CRS whose coordinate values happen to fall
#'   within ±180/±90 will be misclassified as EPSG:4326. Pass `crs` explicitly for
#'   such cases.
#' - UTM and other national or regional projected CRS cannot be detected from coordinate
#'   values alone. Pass `crs` explicitly.
#' - Web Mercator datasets with x extents below ±1,000,000 (e.g., a small local area
#'   near the prime meridian) will not be detected as EPSG:3857. Pass `crs` explicitly.
#' @examples
#' # EPSG:4326 from coordinate ranges
#' guess_crs(x = c(-10, 0, 10), y = c(35, 40, 45))
#'
#' # EPSG:4326 confirmed by column names
#' guess_crs(x = c(1, 2, 3), y = c(40, 41, 42), x_name = "lon", y_name = "lat")
#'
#' # EPSG:3857 from Web Mercator scale values
#' guess_crs(x = c(-8000000, 0, 8000000), y = c(-5000000, 0, 5000000))
#'
#' # NA for UTM or other projected CRS
#' guess_crs(x = c(500000, 510000), y = c(4500000, 4510000))
#' @family casting_functions
#' @autoglobal
#' @export
guess_crs <- function(x, y, x_name = NULL, y_name = NULL) {
  all_coord_names <- c(coordinates_names$x, coordinates_names$y)
  lat_lon_names <- all_coord_names[grepl("lat|lon|lng", all_coord_names)]

  name_suggests_4326 <- (
    (!is.null(x_name) && tolower(x_name) %in% lat_lon_names) ||
    (!is.null(y_name) && tolower(y_name) %in% lat_lon_names)
  )

  max_abs_x <- max(abs(x))
  max_abs_y <- max(abs(y))

  if (max_abs_x <= 180 && max_abs_y <= 90) {
    if (name_suggests_4326) {
      message(
        "spatialFolds::guess_crs(): CRS detected as EPSG:4326 (WGS84 geographic) ",
        "from coordinate ranges and column names."
      )
    } else {
      message(
        "spatialFolds::guess_crs(): CRS detected as EPSG:4326 (WGS84 geographic) ",
        "from coordinate ranges."
      )
    }
    return(4326L)
  }

  if (max_abs_x > 1000000 && max_abs_x <= 20037509 && max_abs_y <= 20048967) {
    message(
      "spatialFolds::guess_crs(): CRS detected as EPSG:3857 (Web Mercator) ",
      "from coordinate ranges."
    )
    return(3857L)
  }

  message(
    "spatialFolds::guess_crs(): CRS could not be detected automatically. ",
    "Coordinate values do not match EPSG:4326 (geographic) or EPSG:3857 (Web Mercator) patterns. ",
    "Pass 'crs' explicitly to suppress this message."
  )
  NA_integer_
}
