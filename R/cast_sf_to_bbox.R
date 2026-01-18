#' Convert sf Object to Bounding Box sf Object
#' @description Extracts the bounding box from an sf object and returns it as a one-row sf dataframe containing a rectangular polygon.
#' @param x (required, sf) Spatial dataframe with point geometries. Default: `NULL`
#' @return One-row sf dataframe containing a rectangular polygon representing the bounding box of the input. Has the same CRS as input.
#' @details
#' This function:
#' \enumerate{
#'   \item Extracts the bounding box from the input sf object using `sf::st_bbox()`
#'   \item Converts the bbox to a rectangular polygon using `sf::st_as_sfc()`
#'   \item Returns as a one-row sf dataframe with the same CRS as input
#' }
#'
#' **Use cases:**
#' - Calculate bounding box area for default parameter calculation
#' - Visualize spatial extent of point data
#' - Quality control and validation of spatial data
#'
#' @examples
#' \dontrun{
#' data(xy_sf)
#'
#' # Get bounding box as sf object
#' bbox_sf <- cast_sf_to_bbox(xy_sf)
#' nrow(bbox_sf)  # 1
#'
#' # Calculate area
#' sf::st_area(bbox_sf)
#'
#' # Plot points with bounding box
#' plot(sf::st_geometry(xy_sf))
#' plot(sf::st_geometry(bbox_sf), add = TRUE, border = "red", lwd = 2)
#' }
#' @param ... Internal parameters passed from parent functions.
#' @family utilities
#' @autoglobal
#' @export
cast_sf_to_bbox <- function(x = NULL, ...) {
  # ==========================================================================
  # Function name for hierarchical error messages
  # ==========================================================================
  dots <- list(...)
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::cast_sf_to_bbox()",
    function_name = dots$function_name
  )

  # Validate input
  if (is.null(x)) {
    stop(
      function_name, ": argument 'x' cannot be NULL.",
      call. = FALSE
    )
  }

  if (!inherits(x, "sf")) {
    stop(
      function_name, ": argument 'x' must be an sf object.",
      call. = FALSE
    )
  }

  if (nrow(x) == 0) {
    stop(
      function_name, ": argument 'x' has no rows.",
      call. = FALSE
    )
  }

  # Extract bounding box
  bbox <- sf::st_bbox(x)

  # Convert to sfc (simple feature geometry collection)
  bbox_sfc <- sf::st_as_sfc(bbox)

  # Convert to sf dataframe
  bbox_sf <- sf::st_sf(geometry = bbox_sfc)

  return(bbox_sf)
}
