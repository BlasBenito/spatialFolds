#' Validates Argument `target` in `spatial_thinning()`
#'
#' @inheritParams spatial_thinning
#' @param function_name (optional, string) Name of the calling function
#'
#' @returns integer
#' @examples
#' data(xy_sf)
#' x <- validate_arg_target(
#'   df = xy_sf,
#'   target = 10
#'   )
#' @family arg_validation
#' @autoglobal
#' @export
validate_arg_target <- function(
  df = NULL,
  target = NULL,
  function_name = NULL
) {
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::validate_arg_target()",
    function_name = function_name
  )

  if (is.null(target)) {
    target <- ceiling(nrow(df) / 2)
  }

  # Type validation BEFORE coercion
  if (!is.numeric(target)) {
    stop(
      function_name,
      ": argument 'target' must be numeric.",
      call. = FALSE
    )
  }

  target <- as.integer(target)

  # Take first value if length > 1
  if (length(target) > 1) {
    target <- target[1]
  }

  # Range validation
  if (target < 1 || target > (nrow(df) - 1)) {
    stop(
      function_name,
      ": argument 'target' must be between 1 and nrow(df) - 1 (",
      nrow(df) - 1,
      ").",
      call. = FALSE
    )
  }

  target
}
