#' Quick plot of a single training fold
#' @param df (required, matrix or data.frame) A matrix or data frame with at
#'   least two numeric columns representing x and y coordinates. Can also be
#'   an sf object, from which coordinates will be extracted. Default: `NULL`
#' @param training_fold (required, logical vector) Column of a dataframe
#'   produced with [spatial_folds()] or a training mask resulting from
#'   [training_mask()]. Default: `NULL`
#' @param color_training (optional, color name) Color of the training records.
#'   Default: `"blue3"`
#' @param color_testing (optional, color name) Color of the testing records.
#'   Default: `"red3"`
#' @param legend_position (optional, string) Position of the legend. One of
#'   "bottomright", "bottom", "bottomleft", "left", "topleft", "top",
#'   "topright", "right" and "center". Default: `"bottomleft"`
#'
#' @param ... Internal parameters passed from parent functions.
#' @returns invisible
#' @examples
#' training <- method_contiguous_planar(
#'   xy = xy_matrix,
#'   center = 1,
#'   step_x = 0.4,
#'   step_y = 0.1,
#'   target = 15000
#' )
#'
#' spatial_fold_plot(
#'   df = xy_matrix,
#'   training_fold = training
#' )
#' @autoglobal
#' @export
spatial_fold_plot <- function(
  df = NULL,
  training_fold = NULL,
  color_training = "blue3",
  color_testing = "red3",
  legend_position = "bottomleft",
  ...
) {
  # ==========================================================================
  # Function name for hierarchical error messages
  # ==========================================================================
  dots <- list(...)
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::spatial_fold_plot()",
    function_name = dots$function_name
  )

  if (!is.logical(training_fold)) {
    stop(
      function_name, ": argument 'training_fold' must be a logical vector.",
      call. = FALSE
    )
  }

  # Handle sf objects
  if (inherits(df, "sf")) {
    df <- sf::st_coordinates(df)
  }

  if (length(training_fold) != nrow(df)) {
    stop(
      function_name, ": argument 'training_fold' must be of the same length as rows in argument 'df'.",
      call. = FALSE
    )
  }

  if (ncol(df) < 2) {
    stop(
      function_name, ": argument 'df' must have at least two columns",
      call. = FALSE
    )
  }

  colnames(df) <- c("x", "y")

  if (!is.numeric(df[, "x"]) || !is.numeric(df[, "y"])) {
    stop(
      function_name, ": argument 'df' must be a dataframe or matrix with two numeric columns",
      call. = FALSE
    )
  }

  cols <- ifelse(
    test = training_fold,
    yes = color_training,
    no = color_testing
  )

  graphics::plot(
    x = df[, "x"],
    y = df[, "y"],
    col = cols,
    xlim = range(df[, "x"]),
    ylim = range(df[, "y"]),
    xlab = "x",
    ylab = "y"
  )

  graphics::legend(
    legend_position,
    legend = c("Training", "Testing"),
    col = c(color_training, color_testing),
    pch = c(1, 1, 19),
    pt.cex = c(1, 1, 2),
    x.intersp = 0.6,
    y.intersp = 0.7,
    bty = "n"
  )

  return(invisible())
}
