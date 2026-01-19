#' Validates Argument `target` in `spatial_thinning()`
#'
#' @inheritParams spatial_thinning
#' @param function_name (optional, string) Name of the calling function
#'
#' @returns integer
#' @examples
#' data(sf_xy)
#' x <- validate_arg_target(
#'   df = sf_xy,
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

  target <- as.integer(target)

  if (!is.numeric(target) || target > (nrow(df) - 1) || target < 1) {
    stop(
      function_name,
      ": argument 'target' must be numeric integer between 1 and ",
      nrow(df),
      ".",
      call. = FALSE
    )
  }
}
