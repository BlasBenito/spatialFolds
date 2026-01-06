#' Quick plot of a single training fold
#'
#' @inheritParams training_fold
#' @param training_fold (required, logical vector) Output of [training_fold] on `xy`. Default: `NULL`
#' @param color_training (optional, color name) Color of the training records. Default: `"blue3"`
#' @param color_testing (optional, color name) Color of the testing records. Default: `"red3"`
#' @param legend_position (optional, string) Position of the legend. One of "bottomright", "bottom", "bottomleft", "left", "topleft", "top", "topright", "right" and "center". Default: `"bottomleft"`
#'
#' @returns invisible
#' @examples
#' training <- training_fold(
#'   xy = xy_matrix,
#'   center = 1,
#'   step_x = 0.4,
#'   step_y = 0.1,
#'   training_fraction = 0.50
#' )
#'
#' training_fold_plot(
#'   xy = xy_matrix,
#'   center = 1,
#'   training_fold = training
#' )
#' @autoglobal
#' @export
training_fold_plot <- function(
  xy = NULL,
  center = NULL,
  training_fold = NULL,
  color_training = "blue3",
  color_testing = "red3",
  legend_position = "bottomleft"
) {
  if (!is.logical(training_fold)) {
    stop(
      "spatialFolds::plot_training_fold(): argument 'training_fold' must be a logical vector.",
      call. = FALSE
    )
  }

  if (length(training_fold) != nrow(xy)) {
    stop(
      "spatialFolds::plot_training_fold(): argument 'training_fold' must be of the same length as rows in argument 'xy'.",
      call. = FALSE
    )
  }

  if (ncol(xy) < 2) {
    stop(
      "spatialFolds::plot_training_fold(): argument 'xy' must have at least two columns",
      call. = FALSE
    )
  }

  colnames(xy) <- c("x", "y")

  if (!is.numeric(xy[, "x"]) || !is.numeric(xy[, "x"])) {
    stop(
      "spatialFolds::plot_training_fold(): argument 'xy' must be a dataframe or matrix with two numeric columns",
      call. = FALSE
    )
  }

  if (center > nrow(xy)) {
    stop(
      "spatialFolds::plot_training_fold(): argument 'center' must be a integer between 1 and ",
      nrow(xy),
      ".",
      call. = FALSE
    )
  }

  cols <- ifelse(
    test = training_fold,
    yes = color_training,
    no = color_testing
  )

  graphics::plot(
    x = xy[, "x"],
    y = xy[, "y"],
    col = cols,
    xlim = range(xy[, "x"]),
    ylim = range(xy[, "y"]),
    xlab = "x",
    ylab = "y"
  )

  graphics::points(
    x = xy[1, "x"],
    y = xy[1, "y"],
    col = "black",
    pch = 19,
    cex = 2
  )

  graphics::legend(
    legend_position,
    legend = c("Training", "Testing", "Fold center"),
    col = c(color_training, color_testing, "black"),
    pch = c(1, 1, 19),
    pt.cex = c(1, 1, 2),
    x.intersp = 0.6,
    y.intersp = 0.7,
    bty = "n"
  )

  return(invisible())
}
