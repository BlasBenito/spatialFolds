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
#' @param n_points (required, integer) Number of points in the dataset.
#'   Default: NULL
#' @param x_range (required, numeric) Range of x coordinates.
#'   Default: NULL
#' @param y_range (required, numeric) Range of y coordinates.
#'   Default: NULL
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
  n_points = NULL,
  x_range = NULL,
  y_range = NULL,
  quiet = FALSE,
  function_name = NULL
) {
  # ==========================================================================
  # Function name for hierarchical error messages
  # ==========================================================================
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::validate_arg_blocks()",
    function_name = function_name
  )

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
        function_name, ": argument 'blocks' must be NULL, numeric, or a length-2 vector c(rows, cols).",
        call. = FALSE
      )
    }
    n_blocks <- max(4, as.integer(blocks))
    if (!quiet) {
      message(
        function_name, ": using ", n_blocks, " blocks for the 'blocks' method."
      )
    }
  } else if (length(blocks) == 2) {
    # Vector case: direct rows/cols specification
    if (!is.numeric(blocks)) {
      stop(
        function_name, ": argument 'blocks' must be NULL, numeric, or a length-2 vector c(rows, cols).",
        call. = FALSE
      )
    }
    rows <- max(2, as.integer(blocks[1]))
    cols <- max(2, as.integer(blocks[2]))
  } else {
    stop(
      function_name, ": argument 'blocks' must be NULL, an integer, or a length-2 vector c(rows, cols).",
      call. = FALSE
    )
  }

  # Calculate rows/cols from n_blocks using aspect ratio
  if (!is.null(n_blocks)) {
    aspect_ratio <- x_range / y_range
    rows <- max(2, round(sqrt(n_blocks / aspect_ratio)))
    cols <- max(2, round(sqrt(n_blocks * aspect_ratio)))
  }

  list(
    rows = rows,
    cols = cols
  )
}
