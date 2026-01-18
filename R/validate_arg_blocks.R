#' Validate Blocks Argument and Compute Grid Dimensions
#'
#' @description
#' Internal function that validates the `blocks` argument and computes
#' grid dimensions (rows and columns) for the blocks method. Consolidates
#' validation logic used by spatial_folds().
#'
#' @param blocks (optional, NULL, integer, or vector) Grid configuration for
#'   blocks method. If NULL: auto-computed as floor(n_points/30), creating ~30
#'   samples per block. If a single integer: number of blocks (minimum 4),
#'   auto-arranged by aspect ratio to create roughly square blocks in geographic
#'   space. If a length-2 vector: c(rows, cols) for direct grid control.
#'   Default: NULL
#' @param df (required, sf or data.frame) Spatial data with point geometries.
#'   If data.frame, must have recognizable coordinate columns (x/lon/longitude
#'   and y/lat/latitude). Will be converted to sf with CRS 4326. Default: NULL
#' @param quiet (optional, logical) If FALSE, messages are printed.
#'   Default: FALSE
#' @param function_name (optional, character) Name of the calling function
#'   for error messages. Default: NULL
#'
#' @return A named list with:
#'   \itemize{
#'     \item \code{rows}: Integer number of rows in the grid
#'     \item \code{cols}: Integer number of columns in the grid
#'   }
#'
#' @details
#' Validation steps performed in order:
#' \enumerate{
#'   \item Validate xy matrix using validate_arg_xy()
#'   \item Compute n_points, x_range, y_range from xy
#'   \item If blocks is NULL: auto-compute n_blocks as max(4, floor(n_points/30))
#'   \item If blocks is length 1: use as n_blocks (minimum 4)
#'   \item If blocks is length 2: use as c(rows, cols) directly (minimum 2 each)
#'   \item Otherwise: error
#'   \item If n_blocks was computed: calculate rows/cols from aspect ratio
#' }
#'
#' @noRd
validate_arg_blocks <- function(
  blocks = NULL,
  df = NULL,
  quiet = FALSE,
  function_name = NULL
) {
  if (!is.null(attributes(blocks)$validated)) {
    return(blocks)
  }
  # ==========================================================================
  # Function name for hierarchical error messages
  # ==========================================================================
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::validate_arg_blocks()",
    function_name = function_name
  )

  # ==========================================================================
  # Validate sf input
  # ==========================================================================
  df <- validate_arg_sf(
    df = df,
    function_name = function_name
  )

  # ==========================================================================
  # Compute derived values from bounding box
  # ==========================================================================
  n_points <- nrow(df)

  df_bbox <- sf::st_bbox(obj = df)
  x_range <- df_bbox["xmax"] - df_bbox["xmin"]
  y_range <- df_bbox["ymax"] - df_bbox["ymin"]

  rows <- NULL
  cols <- NULL
  n_blocks <- NULL

  if (is.null(blocks)) {
    # Auto-compute blocks (~30 samples per block)
    n_blocks <- max(4, floor(n_points / 30))
  } else if (length(blocks) == 1) {
    # Integer case: number of blocks
    if (!is.numeric(blocks)) {
      stop(
        function_name,
        ": argument 'blocks' must be NULL, numeric, or a length-2 vector c(rows, cols).",
        call. = FALSE
      )
    }
    n_blocks <- max(4, as.integer(blocks))
    if (!quiet) {
      message(
        function_name,
        ": using ",
        n_blocks,
        " blocks for the 'blocks' method."
      )
    }
  } else if (length(blocks) == 2) {
    # Vector case: direct rows/cols specification
    if (!is.numeric(blocks)) {
      stop(
        function_name,
        ": argument 'blocks' must be NULL, numeric, or a length-2 vector c(rows, cols).",
        call. = FALSE
      )
    }
    rows <- max(2, as.integer(blocks[1]))
    cols <- max(2, as.integer(blocks[2]))
  } else {
    stop(
      function_name,
      ": argument 'blocks' must be NULL, an integer, or a length-2 vector c(rows, cols).",
      call. = FALSE
    )
  }

  # Calculate rows/cols from n_blocks using aspect ratio
  if (!is.null(n_blocks)) {
    aspect_ratio <- x_range / y_range
    rows <- max(2, round(sqrt(n_blocks / aspect_ratio)))
    cols <- max(2, round(sqrt(n_blocks * aspect_ratio)))
  }

  # Warn if grid has more cells than points
  if (rows * cols > n_points) {
    warning(
      function_name,
      ": Grid has more cells (",
      rows * cols,
      ") than data points (",
      n_points,
      "). Many cells will be empty.",
      call. = FALSE
    )
  }

  out <- list(
    rows = rows,
    cols = cols
  )

  attr(
    x = out,
    which = "validated"
  ) <- TRUE

  out
}
