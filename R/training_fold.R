#' Internal function to generate a training fold
#' @description Taking a focal point as reference, it grows a rectangular area until a specified fraction of all records falls inside. Records inside the rectangular area are the training set, and records outside are the testing set. This method aims to preserve the spatial structure of the training data.
#' @param xy (required, matrix) Two columns matrix with the locations to arrange. The first column is interpreted as "x" (longitude) and the second as "y" (latitude). Default: `NULL`
#' @param center (required, integer) Index of the training fold center. Default: `NULL`
#' @param step_x (optional, numeric) Rectangle growth increment along the x-axis. Must be in the same units as `xy`. Default: `NULL`
#' @param step_y (optional, numeric) Rectangle growth increment along the y-axis. Must be in the same units as `xy`. Default: `NULL`
#' @param training_fraction (optional, numeric) Fraction of records to include in the training fold. Default: `0.8`.
#' @return logical vector: with length equal to `nrow(xy)`, where `TRUE` indicates a record is in the training fold and `FALSE` indicates it is in the testing fold. The vector is ordered by row position in `xy`.
#' @details
#' This function creates spatially independent training and testing folds for spatial cross-validation. The algorithm works as follows:
#' \enumerate{
#'   \item Starts with a small rectangular fold centered on the focal point (`center`)
#'   \item Grows the fold incrementally by `step_x` and `step_y`
#'   \item Continues growing until the fold contains the desired number of records (`training_fraction * total records`)
#'   \item Assigns records inside the fold to training and records outside to testing
#' }
#'
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
#' @export
#' @autoglobal
training_fold <- function(
  xy = NULL,
  center = NULL,
  step_x = NULL,
  step_y = NULL,
  training_fraction = 0.8
) {
  #center coordinates
  center.x <- xy[center, "x"]
  center.y <- xy[center, "y"]

  #records to hold in training fold
  target <- floor(training_fraction * nrow(xy))

  #generating first fold
  old.fold.x.min <- center.x - step_x
  old.fold.x.max <- center.x + step_x
  old.fold.y.min <- center.y - step_y
  old.fold.y.max <- center.y + step_y

  #track count without materializing dataframe (memory optimization)
  current <- 0

  #growing fold
  while (current < target) {
    #new fold
    new.fold.x.min <- old.fold.x.min - step_x
    new.fold.x.max <- old.fold.x.max + step_x
    new.fold.y.min <- old.fold.y.min - step_y
    new.fold.y.max <- old.fold.y.max + step_y

    #find indices in new fold
    in_fold <- which(
      xy[, 1] >= new.fold.x.min &
        xy[, 1] <= new.fold.x.max &
        xy[, 2] >= new.fold.y.min &
        xy[, 2] <= new.fold.y.max
    )

    current <- length(in_fold)

    #resetting old.fold
    old.fold.x.min <- new.fold.x.min
    old.fold.x.max <- new.fold.x.max
    old.fold.y.min <- new.fold.y.min
    old.fold.y.max <- new.fold.y.max
  }

  #create logical vector (TRUE = training, FALSE = testing)
  training_cases <- rep(FALSE, nrow(xy))
  training_cases[in_fold] <- TRUE

  training_cases
}
