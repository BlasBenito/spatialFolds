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
  validate_arg_xy(
    xy = xy,
    function_name = function_name
  )

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
