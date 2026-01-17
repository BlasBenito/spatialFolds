#' Generate a single training mask using a specified method
#'
#' @description
#' Thin R wrapper for C++ methods that generates a single training/testing split.
#' Intended to be called within a parallelized loop. Assumes all inputs are valid.
#'
#' @param xy (required, numeric matrix) Two-column matrix with x (longitude) and
#'   y (latitude) coordinates.
#' @param method (required, character) Method to use: "contiguous", "random", or
#'   "blocks". Default: `"contiguous"`
#' @param spherical (optional, logical) If TRUE, uses spherical geometry for the
#'   contiguous method. Required for global data near dateline or poles. If
#'   FALSE, uses faster planar geometry suitable for local/regional data.
#'   Default: `FALSE`
#' @param ... Method-specific arguments:
#'   - For "contiguous": center (int), step_x (double), step_y (double), target
#'     (double)
#'   - For "random": seed (int), target (double)
#'   - For "blocks": block_id (integer vector), seed (int), target (double)
#'
#' @return Logical vector where TRUE = training samples, FALSE = testing samples
#'
#' @details
#' This function routes to the appropriate C++ method based on the method
#' parameter:
#'
#' 1. **method_contiguous_planar**: Creates contiguous training folds using
#'    planar geometry
#'    - Grows rectangular fold until target count reached
#'    - Fast and suitable for local to subcontinental data
#'
#' 2. **method_contiguous_spherical**: Creates contiguous training folds using
#'    spherical geometry
#'    - Grows spherical cap until target count reached
#'    - Correctly handles dateline wrap-around and polar convergence
#'    - Required for global data near boundaries
#'
#' 3. **method_random**: Random data splitting using modern C++ RNG
#'    - Uses Fisher-Yates shuffle algorithm
#'    - Reproducible with seed
#'
#' 4. **method_blocks**: Selects entire grid blocks until target count reached
#'    - Requires pre-computed block_id vector
#'    - Entire blocks selected (may exceed target)
#'
#' @export
#' @autoglobal
training_mask <- function(
  xy,
  method = c("contiguous", "random", "blocks"),
  spherical = FALSE,
  ...
) {
  # Match method argument
  method <- match.arg(method)

  # Capture method-specific arguments
  args <- list(...)

  # Route to appropriate C++ method
  result <- switch(
    method,
    contiguous = if (spherical) {
      # Convert to 3D Cartesian coordinates for spherical geometry
      xyz <- cast_xy_to_xyz(xy)
      # Calculate angular step from step_x/step_y (convert degrees to radians)
      angular_step <- mean(c(args$step_x, args$step_y)) * pi / 180
      method_contiguous_spherical(
        xyz = xyz,
        center = args$center,
        angular_step = angular_step,
        target = args$target
      )
    } else {
      method_contiguous_planar(
        xy = xy,
        center = args$center,
        step_x = args$step_x,
        step_y = args$step_y,
        target = args$target
      )
    },
    random = method_random(
      xy = xy,
      seed = args$seed,
      target = args$target
    ),
    blocks = method_blocks(
      xy = xy,
      block_id = args$block_id,
      seed = args$seed,
      target = args$target
    )
  )

  result
}
