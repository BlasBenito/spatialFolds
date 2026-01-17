#' Transform sf data.frame into xy matrix
#' @param df (required, sf) An sf data frame with spatial geometry
#' @param function_name (optional, character) Name of the calling function for error messages. Default: NULL
#' @return Numeric matrix with columns "x" and "y"
#' @noRd
cast_sf_to_xy <- function(df, function_name = NULL) {
  # ==========================================================================
  # Function name for hierarchical error messages
  # ==========================================================================
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::cast_sf_to_xy()",
    function_name = function_name
  )

  # Validate input is sf object
  if (!inherits(x = df, what = "sf")) {
    stop(
      function_name, ": argument 'df' must be an sf data.frame.",
      call. = FALSE
    )
  }

  # Validate df has rows
  if (nrow(df) == 0) {
    stop(
      function_name, ": argument 'df' has no rows.",
      call. = FALSE
    )
  }

  # Get geometry types
  geom_types <- as.character(sf::st_geometry_type(df, by_geometry = FALSE))

  # Handle different geometry types
  if (geom_types %in% c("POINT", "MULTIPOINT")) {
    # Direct extraction for POINT and MULTIPOINT
    coords <- sf::st_coordinates(df)
  } else if (geom_types %in% c("POLYGON", "MULTIPOLYGON")) {
    # Use centroids for POLYGON and MULTIPOLYGON
    coords <- df |>
      sf::st_centroid() |>
      sf::st_coordinates()
  } else {
    # Catch-all for other geometry types
    stop(
      function_name, ": Unsupported geometry type '", geom_types,
      "'. Supported types are: POINT, MULTIPOINT, POLYGON, MULTIPOLYGON.",
      call. = FALSE
    )
  }

  # Validate coordinates were extracted
  if (nrow(coords) == 0) {
    stop(
      function_name, ": Failed to extract coordinates from sf geometry.",
      call. = FALSE
    )
  }

  # Create xy matrix
  xy <- matrix(
    data = c(coords[, 1], coords[, 2]),
    ncol = 2,
    dimnames = list(NULL, c("x", "y"))
  )

  xy
}
