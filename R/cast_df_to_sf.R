#' Transform data.frame with coordinates to sf data frame
#' @description
#' Takes a data frame or tibble with coordinates and converts it to `sf` data frame of type POINT.
#' @param df (required, data.frame) Dataframe with coordinate columns. Default: NULL
#' @param crs (optional, integer or NULL) EPSG code. If NULL (default), the CRS is guessed
#'   automatically via [guess_crs()]. Pass an explicit integer (e.g. 4326, 3857) to override
#'   detection. Default: NULL
#' @param ... (optional) For internal arguments only.
#' @return sf data frame with POINT geometry
#' @details
#' When `crs = NULL`, CRS detection is attempted using coordinate ranges and column names.
#' EPSG:4326 is returned when x ∈ [−180, 180] and y ∈ [−90, 90]. EPSG:3857 is returned
#' for Web Mercator scale values (x > ±1,000,000). UTM and other projected CRS cannot be
#' detected from coordinate values alone — pass `crs` explicitly in those cases.
#'
#' Small local datasets in a projected CRS whose coordinate values happen to fall within
#' ±180/±90 will be misidentified as EPSG:4326; pass `crs` explicitly to avoid this.
#' @seealso [guess_crs()]
#' @family casting_functions
#' @autoglobal
#' @export
cast_df_to_sf <- function(
  df = NULL,
  crs = NULL,
  ...
) {
  dots <- list(...)

  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::cast_df_to_sf()",
    function_name = dots$function_name
  )

  # Check if already an sf object
  if (inherits(x = df, what = "sf")) {
    return(df)
  }

  # Validate df is a data.frame
  if (!is.data.frame(df)) {
    stop(
      "\n",
      function_name,
      ": argument 'df' must be a data.frame.",
      call. = FALSE
    )
  }

  # Validate df has rows
  if (nrow(df) == 0) {
    stop(
      "\n",
      function_name,
      ": argument 'df' has no rows.",
      call. = FALSE
    )
  }

  # Validate user-supplied crs (skip when NULL — will be auto-detected later)
  if (!is.null(crs)) {
    if (length(crs) != 1 || (!is.na(crs) && !is.numeric(crs))) {
      stop(
        "\n",
        function_name,
        ": argument 'crs' must be NA or a single numeric EPSG code.",
        call. = FALSE
      )
    }
  }

  # Convert column names to lowercase for matching
  colnames_lower <- tolower(colnames(df))

  # Find matching columns using the coordinates_names dictionary
  x_matches <- intersect(x = colnames_lower, y = coordinates_names$x)
  y_matches <- intersect(x = colnames_lower, y = coordinates_names$y)

  # Check for no matches
  if (length(x_matches) == 0 || length(y_matches) == 0) {
    stop(
      "\n",
      function_name,
      ": argument 'df' does not have recognizable coordinate columns. ",
      "Inspect `coordinates_names` to see recognized column name variants.",
      call. = FALSE
    )
  }

  # Warn about multiple coordinate column matches
  if (length(x_matches) > 1) {
    warning(
      "\n",
      function_name,
      ": Multiple x-coordinate columns found: ",
      paste(x_matches, collapse = ", "),
      ". Using '",
      x_matches[1],
      "'.",
      call. = FALSE
    )
  }

  if (length(y_matches) > 1) {
    warning(
      "\n",
      function_name,
      ": Multiple y-coordinate columns found: ",
      paste(y_matches, collapse = ", "),
      ". Using '",
      y_matches[1],
      "'.",
      call. = FALSE
    )
  }

  x_column <- x_matches[1]
  y_column <- y_matches[1]

  # Get original column names (not lowercase)
  x_col_original <- colnames(df)[which(colnames_lower == x_column)]
  y_col_original <- colnames(df)[which(colnames_lower == y_column)]

  # Extract coordinate vectors
  x_coords <- df[[x_col_original]]
  y_coords <- df[[y_col_original]]

  # Validate coordinates are numeric
  if (!is.numeric(x_coords)) {
    stop(
      "\n",
      function_name,
      ": x-coordinate column '",
      x_col_original,
      "' must be numeric. Found type: ",
      class(x_coords)[1],
      ".",
      call. = FALSE
    )
  }

  if (!is.numeric(y_coords)) {
    stop(
      "\n",
      function_name,
      ": y-coordinate column '",
      y_col_original,
      "' must be numeric. Found type: ",
      class(y_coords)[1],
      ".",
      call. = FALSE
    )
  }

  # Check for NA values
  x_na_count <- sum(is.na(x_coords))
  y_na_count <- sum(is.na(y_coords))

  if (x_na_count > 0 || y_na_count > 0) {
    stop(
      "\n",
      function_name,
      ": Coordinate columns contain NA values. ",
      "x: ",
      x_na_count,
      " NA(s), y: ",
      y_na_count,
      " NA(s). ",
      "Please remove or impute missing coordinates.",
      call. = FALSE
    )
  }

  # Check for NaN values
  x_nan_count <- sum(is.nan(x_coords))
  y_nan_count <- sum(is.nan(y_coords))

  if (x_nan_count > 0 || y_nan_count > 0) {
    stop(
      "\n",
      function_name,
      ": Coordinate columns contain NaN values. ",
      "x: ",
      x_nan_count,
      " NaN(s), y: ",
      y_nan_count,
      " NaN(s). ",
      "Please remove or replace NaN coordinates.",
      call. = FALSE
    )
  }

  # Check for Inf values
  x_inf_count <- sum(is.infinite(x_coords))
  y_inf_count <- sum(is.infinite(y_coords))

  if (x_inf_count > 0 || y_inf_count > 0) {
    stop(
      "\n",
      function_name,
      ": Coordinate columns contain infinite values. ",
      "x: ",
      x_inf_count,
      " Inf(s), y: ",
      y_inf_count,
      " Inf(s). ",
      "Please remove or replace infinite coordinates.",
      call. = FALSE
    )
  }

  # Auto-detect CRS when not supplied by the user
  if (is.null(crs)) {
    crs <- guess_crs(
      x = x_coords,
      y = y_coords,
      x_name = x_col_original,
      y_name = y_col_original
    )
  }

  # Create sf object
  df_sf <- sf::st_as_sf(
    x = df,
    coords = c(x_col_original, y_col_original),
    remove = FALSE,
    crs = crs
  )

  df_sf
}
