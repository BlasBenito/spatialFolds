#' Convert Planar `xy` to Spherical
#'
#' @description Transforms geographic coordinates (longitude/latitude in
#'   degrees) to 3D Cartesian coordinates on a unit sphere. This transformation
#'   eliminates discontinuities at the dateline and poles, enabling correct
#'   distance calculations for global data.
#'
#' @param xy (required, numeric matrix) Two-column matrix with longitude (x) in
#'   the first column and latitude (y) in the second column. Coordinates must be
#'   in degrees. Default: `NULL`
#' @param function_name (optional, character) Name of the calling function
#'   for error messages. Default: `NULL`
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
#' @family spherical
#' @export
#' @autoglobal
cast_xy_to_xyz <- function(xy, function_name = NULL) {
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::cast_xy_to_xyz()",
    function_name = function_name
  )

  # Input validation
  validate_arg_xy(
    xy = xy,
    function_name = function_name
  )

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
