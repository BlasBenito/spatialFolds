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
#'
#' @return The validated sf object.
#'
#' @details
#' Validation steps performed in order:
#' \enumerate{
#'   \item NULL check
#'   \item Zero rows check
#'   \item Convert to sf via cast_df_to_sf() with crs = NA
#' }
#'
#' @noRd
validate_arg_sf <- function(
  df = NULL,
  function_name = NULL
) {
  if (!is.null(attributes(df)$validated)) {
    return(df)
  }

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

  if (!inherits(x = df, what = "sf")) {
    df <- cast_df_to_sf(
      df = df,
      crs = NA,
      function_name = function_name
    )
  }

  attr(
    x = df,
    which = "validated"
  ) <- TRUE

  df
}
