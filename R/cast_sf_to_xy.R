#' Transform sf data.frame into xy matrix
#' @param df (required, sf) An sf data frame with spatial geometry
#' @param ... Internal parameters passed from parent functions.
#' @return Numeric matrix with columns "x" and "y"
#' @family casting_functions
#' @autoglobal
#' @export
cast_sf_to_xy <- function(
  df = NULL,
  ...
) {
  dots <- list(...)

  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::cast_sf_to_xy()",
    function_name = dots$function_name
  )

  df <- validate_arg_sf(
    df = df,
    function_name = function_name
  )

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
      function_name,
      ": Unsupported geometry type '",
      geom_types,
      "'. Supported types are: POINT, MULTIPOINT, POLYGON, MULTIPOLYGON.",
      call. = FALSE
    )
  }

  # Validate coordinates were extracted
  if (nrow(coords) == 0) {
    stop(
      function_name,
      ": Failed to extract coordinates from sf geometry.",
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
