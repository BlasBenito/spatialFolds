#' Check if Spherical Geometry is Needed
#'
#' @description Analyzes coordinate ranges to determine if spherical geometry
#'   should be used for spatial fold generation. Returns TRUE when data is near
#'   the dateline (longitude boundaries) or poles (latitude boundaries), where
#'   planar geometry produces incorrect results.
#'
#' @param xy (required, numeric matrix) Two-column matrix with longitude (x) in
#'   the first column and latitude (y) in the second column. Coordinates must be
#'   in degrees. Default: `NULL`
#'
#' @return Logical. TRUE if spherical geometry is recommended, FALSE if planar
#'   geometry is sufficient.
#'
#' @details
#' The function uses aggressive thresholds to detect potential issues:
#' \enumerate{
#'   \item Near dateline: longitude < -150 or longitude > 150 degrees
#'   \item Near poles: latitude < -70 or latitude > 70 degrees
#' }
#'
#' When either condition is met, spherical geometry is recommended to avoid
#' artifacts from coordinate wrap-around at the dateline or longitude
#' convergence at the poles.
#'
#' @examples
#' # Local data - planar geometry sufficient
#' local_xy <- cbind(x = runif(100, -10, 10), y = runif(100, 40, 50))
#' utils_needs_spherical(local_xy)  # FALSE
#'
#' # Global data near dateline - spherical recommended
#' dateline_xy <- cbind(x = runif(100, 160, 200), y = runif(100, -20, 20))
#' utils_needs_spherical(dateline_xy)
#'
#' # Polar data - spherical recommended
#' polar_xy <- cbind(x = runif(100, -180, 180), y = runif(100, 75, 90))
#' utils_needs_spherical(polar_xy)
#'
#' @param ... Internal parameters passed from parent functions.
#' @family spherical
#' @export
#' @autoglobal
utils_needs_spherical <- function(xy, ...) {
  # ==========================================================================
  # Function name for hierarchical error messages
  # ==========================================================================
  dots <- list(...)
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::utils_needs_spherical()",
    function_name = dots$function_name
  )

  # Input validation

  if (!is.matrix(xy) && !is.data.frame(xy)) {
    stop(
      function_name, ": argument 'xy' must be a matrix or data frame.",
      call. = FALSE
    )
  }

  if (ncol(xy) < 2) {
    stop(
      function_name, ": argument 'xy' must have at least 2 columns.",
      call. = FALSE
    )
  }

  # Get coordinate ranges
  x_range <- range(xy[, 1], na.rm = TRUE)
  y_range <- range(xy[, 2], na.rm = TRUE)

  # Aggressive thresholds for detecting boundary issues
  lon_threshold <- 150
  lat_threshold <- 70

  # Check proximity to problematic boundaries
  near_dateline <- x_range[1] < -lon_threshold || x_range[2] > lon_threshold
  near_poles <- y_range[1] < -lat_threshold || y_range[2] > lat_threshold

  near_dateline || near_poles

}


#' Convert Lon/Lat to 3D Cartesian Coordinates
#'
#' @description Transforms geographic coordinates (longitude/latitude in
#'   degrees) to 3D Cartesian coordinates on a unit sphere. This transformation
#'   eliminates discontinuities at the dateline and poles, enabling correct
#'   distance calculations for global data.
#'
#' @param xy (required, numeric matrix) Two-column matrix with longitude (x) in
#'   the first column and latitude (y) in the second column. Coordinates must be
#'   in degrees. Default: `NULL`
#'
#' @return Numeric matrix with three columns (x, y, z) representing Cartesian
#'   coordinates on a unit sphere. The number of rows matches the input.
#'
#' @details
#' The transformation uses the standard spherical to Cartesian conversion:
#' \enumerate{
#'   \item Convert degrees to radians: lon_rad = lon * pi / 180
#'   \item Convert degrees to radians: lat_rad = lat * pi / 180
#'   \item x = cos(lat_rad) * cos(lon_rad)
#'   \item y = cos(lat_rad) * sin(lon_rad)
#'   \item z = sin(lat_rad)
#' }
#'
#' The resulting coordinates lie on a unit sphere centered at the origin.
#' Points that are geographically close (even across the dateline or near
#' poles) will be close in 3D Euclidean distance.
#'
#' @examples
#' # Convert sample coordinates
#' xy <- cbind(x = c(0, 90, 180, -90), y = c(0, 0, 0, 0))
#' xyz <- cast_xy_to_xyz(xy)
#'
#' # Points on equator at 0, 90, 180, -90 degrees longitude
#' round(xyz, 3)
#'
#' # North pole (all longitudes converge)
#' pole_xy <- cbind(x = c(0, 90, 180), y = c(90, 90, 90))
#' pole_xyz <- cast_xy_to_xyz(pole_xy)
#' round(pole_xyz, 3)  # All points are identical at (0, 0, 1)
#'
#' @param ... Internal parameters passed from parent functions.
#' @family spherical
#' @export
#' @autoglobal
cast_xy_to_xyz <- function(xy, ...) {
  # ==========================================================================
  # Function name for hierarchical error messages
  # ==========================================================================
  dots <- list(...)
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::cast_xy_to_xyz()",
    function_name = dots$function_name
  )

  # Input validation
  if (!is.matrix(xy) && !is.data.frame(xy)) {
    stop(
      function_name, ": argument 'xy' must be a matrix or data frame.",
      call. = FALSE
    )
  }

  if (ncol(xy) < 2) {
    stop(
      function_name, ": argument 'xy' must have at least 2 columns.",
      call. = FALSE
    )
  }

  # Extract coordinates
  lon <- xy[, 1]
  lat <- xy[, 2]

  # Convert degrees to radians
  lon_rad <- lon * pi / 180
  lat_rad <- lat * pi / 180

  # Convert to 3D Cartesian on unit sphere
  xyz <- cbind(
    x = cos(lat_rad) * cos(lon_rad),
    y = cos(lat_rad) * sin(lon_rad),
    z = sin(lat_rad)
  )

  xyz

}
