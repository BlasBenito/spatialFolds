#' Validate xy Matrix Input
#'
#' @description
#' Internal function that validates xy matrix or data.frame input. Consolidates
#' validation logic used by functions that accept xy coordinate matrices.
#'
#' @param xy (required, matrix or data.frame) Coordinate data with at least two
#'   columns (x/longitude and y/latitude). Default: NULL
#' @param function_name (required, character) Name of the calling function
#'   for error messages. Default: NULL
#'
#' @return The validated xy object unchanged.
#'
#' @details
#' Validation steps performed in order:
#' \enumerate{
#'   \item NULL check
#'   \item Type check (matrix or data.frame)
#'   \item Column count check (at least 2 columns)
#'   \item Zero rows check
#' }
#'
#' @noRd
validate_arg_xy <- function(
  xy = NULL,
  function_name = NULL
) {
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::validate_arg_xy()",
    function_name = function_name
  )

  if (is.null(xy)) {
    stop(
      "\n",
      function_name,
      ": argument 'xy' cannot be NULL.",
      call. = FALSE
    )
  }

  if (!is.matrix(xy) && !is.data.frame(xy)) {
    stop(
      "\n",
      function_name,
      ": argument 'xy' must be a matrix or data frame.",
      call. = FALSE
    )
  }

  if (ncol(xy) < 2) {
    stop(
      "\n",
      function_name,
      ": argument 'xy' must have at least 2 columns.",
      call. = FALSE
    )
  }

  n_rows <- nrow(xy)
  if (is.null(n_rows) || n_rows == 0) {
    stop(
      "\n",
      function_name,
      ": argument 'xy' has no rows.",
      call. = FALSE
    )
  }

  xy
}
