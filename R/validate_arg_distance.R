#' Validates Argument `distance` in `spatial_thinning()`
#'
#' @inheritParams spatial_thinning
#' @param function_name (optional, string) Name of the calling function
#'
#' @returns numeric
#' @examples
#' data(xy_sf)
#' x <- validate_arg_distance(
#'   df = xy_sf,
#'   distance = NULL
#'   )
#' @family arg_validation
#' @autoglobal
#' @export
validate_arg_distance <- function(
  df = NULL,
  distance = NULL,
  function_name = NULL
) {
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::validate_arg_distance()",
    function_name = function_name
  )

  if (is.null(distance)) {
    # Auto-calculate distance based on bounding box and point density
    # Formula: distance = 0.5 * sqrt(bbox_area / n)

    #bounding box
    df_bbox <- sf::st_bbox(obj = df)

    # Calculate bounding box
    x_range <- diff(df_bbox[c("xmin", "xmax")])
    y_range <- diff(df_bbox[c("ymin", "ymax")])
    bbox_area <- x_range * y_range

    # Calculate default distance
    distance <- 0.5 * sqrt(bbox_area / nrow(df))

    # Inform user
    message(
      "\n",
      function_name,
      ": Auto-calculated distance = ",
      round(distance, 6)
    )
  } else {
    # Existing validation for user-provided distance
    if (!is.numeric(distance)) {
      stop(
        function_name,
        ": argument 'distance' must be numeric.",
        call. = FALSE
      )
    }

    # Take first value if length > 1
    if (length(distance) > 1) {
      distance <- distance[1]
    }

    if (distance < 0) {
      stop(
        function_name,
        ": argument 'distance' must be >= 0.",
        call. = FALSE
      )
    }
  }

  distance
}
