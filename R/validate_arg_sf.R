#' Validate sf/data.frame Input
#'
#' @description
#' Internal function that validates sf or data.frame input. Consolidates
#' validation logic used by spatial_folds() and spatial_thinning().
#'
#' @param df (required, sf or data.frame) Spatial data with point geometries.
#'   If data.frame, must have recognizable coordinate columns (x/lon/longitude
#'   and y/lat/latitude). Default: NULL
#' @param function_name (required, character) Name of the calling function
#'   for error messages. Default: NULL
#' @param min_rows (optional, integer) Minimum number of rows required.
#'   Default: 0L
#' @param check_coord_range (optional, logical) If TRUE, validates that
#'   x and y coordinates are not all identical. Default: FALSE
#'
#' @return The validated sf object.
#'
#' @details
#' Validation steps performed in order:
#' \enumerate{
#'   \item NULL check
#'   \item Zero rows check
#'   \item Minimum rows check (if min_rows > 0)
#'   \item Convert to sf via cast_df_to_sf() with crs = NA
#'   \item Coordinate range check (if check_coord_range = TRUE)
#' }
#'
#' @noRd
validate_arg_sf <- function(
  df = NULL,
  function_name = NULL,
  min_rows = 0L,
  check_coord_range = FALSE
) {
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::validate_arg_sf()",
    function_name = function_name
  )

  if (is.null(df)) {
    stop(
      "\n",
      function_name,
      ": argument 'df' cannot be NULL.",
      call. = FALSE
    )
  }

  n_rows <- nrow(df)
  if (is.null(n_rows) || n_rows == 0) {
    stop(
      "\n",
      function_name,
      ": argument 'df' has no rows.",
      call. = FALSE
    )
  }

  # Validate min_rows
  if (n_rows < min_rows) {
    stop(
      "\n",
      function_name,
      ": argument 'df' must have at least ",
      min_rows,
      " rows.",
      call. = FALSE
    )
  }

  if (!inherits(x = df, what = "sf")) {
    df <- cast_df_to_sf(
      df = df,
      crs = NA,
      function_name = function_name
    )
  }

  # Validate coordinate ranges if requested
  if (check_coord_range) {
    xy <- cast_sf_to_xy(df = df, function_name = function_name)
    if (diff(range(xy[, "x"])) == 0) {
      stop(
        "\n",
        function_name,
        ": All x coordinates are identical.",
        call. = FALSE
      )
    }
    if (diff(range(xy[, "y"])) == 0) {
      stop(
        "\n",
        function_name,
        ": All y coordinates are identical.",
        call. = FALSE
      )
    }
  }

  df
}
