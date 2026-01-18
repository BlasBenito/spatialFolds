#' Assign Points to Spatial Blocks
#'
#' @description
#' Assigns points in an sf object to a regular grid cells (blocks), returning 0-based block IDs. Used for pre-computing block assignments for [method_blocks()] to avoid recalculation across iterations.
#'
#' @param df (required, sf dataframe) Spatial dataframe with point geometries. Default: NULL
#' @param blocks (optional, NULL, integer, or vector) Grid configuration for
#'   blocks method. If NULL: auto-computed as floor(n_points/30), creating ~30
#'   samples per block. If a single integer: number of blocks (minimum 4),
#'   auto-arranged by aspect ratio to create roughly square blocks in geographic
#'   space. If a length-2 vector: c(rows, cols) for direct grid control.
#'   Default: NULL
#' @param quiet (optional, logical) If FALSE, messages are printed.
#'   Default: FALSE
#' @return Integer vector of length nrow(df) with 0-based cell IDs. Cell 0 is top-left, numbering increases left-to-right then top-to-bottom (row-major order).
#'
#' @details
#' Algorithm:
#' 1. Calculate bounding box from point coordinates
#' 2. Divide bounding box into rows × cols cells
#' 3. Assign each point to a cell based on its coordinates
#' 4. Return cell IDs in row-major order
#'
#' Points exactly on maximum boundaries are assigned to the rightmost/topmost cells.
#' Empty cells (no points) are valid and handled by [method_blocks()].
#'
#' This function enables a critical optimization: computing cell assignments once instead of once per iteration. For 1000 iterations, this provides ~1.5× speedup.
#'
#' @examples
#' data(xy_sf)
#' blocks <- block_ids(
#'   xy_sf,
#'   rows = 10,
#'   cols = 10
#'   )
#'
#' # Check distribution
#' table(blocks)
#'
#' # Use in blocks method
#' training <- method_blocks(
#'   xy = xy_matrix,
#'   block_id = blocks,
#'   seed = 123,
#'   target = 15000
#' )
#'
#' @noRd
block_ids <- function(
  df = NULL,
  blocks = NULL,
  function_name = NULL,
  quiet = FALSE
) {
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::block_ids()",
    function_name = function_name
  )

  df <- validate_arg_sf(
    df = df,
    function_name = function_name
  )

  blocks <- validate_arg_blocks(
    blocks = blocks,
    df = df,
    quiet = quiet,
    function_name = function_name
  )

  rows <- blocks$rows
  cols <- blocks$cols

  #bounding box
  df_bbox <- sf::st_bbox(obj = df)

  # Calculate bounding box
  x_min <- df_bbox["xmin"]
  x_max <- df_bbox["xmax"]
  y_min <- df_bbox["ymin"]
  y_max <- df_bbox["ymax"]

  # Calculate cell dimensions
  cell_width <- (x_max - x_min) / cols
  cell_height <- (y_max - y_min) / rows

  xy <- cast_sf_to_xy(
    df = df
  )

  x_coords <- xy[, "x"]
  y_coords <- xy[, "y"]

  # Vectorized cell assignment
  # Column index: which column (0 to cols - 1)
  col_indices <- floor((x_coords - x_min) / cell_width)

  # Row index: which row (0 to rows - 1)
  row_indices <- floor((y_coords - y_min) / cell_height)

  # Handle points exactly on max boundaries (assign to last cell)
  col_indices <- pmin(col_indices, cols - 1)
  row_indices <- pmin(row_indices, rows - 1)

  # Ensure indices are non-negative (safety check)
  col_indices <- pmax(col_indices, 0)
  row_indices <- pmax(row_indices, 0)

  # Calculate cell ID (0-based, row-major order)
  block_id <- row_indices * cols + col_indices

  # Convert to integer
  block_id <- as.integer(block_id)

  # Validate output
  if (any(block_id < 0)) {
    stop(
      function_name,
      ": Internal error - negative cell IDs produced.",
      call. = FALSE
    )
  }

  if (any(block_id >= rows * cols)) {
    stop(
      function_name,
      ": Internal error - cell IDs exceed grid size.",
      call. = FALSE
    )
  }

  block_id
}
