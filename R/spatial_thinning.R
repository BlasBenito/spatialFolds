#' @title Apply Spatial Thinning to Point Data
#' @description Resamples points to enforce minimum distance separation or reach a target sample size. Provides two methods:
#' \itemize{
#'   \item **distance**: fixed minimum distance between locations.
#'   \item **target**: iterative distance increase until target count reached.
#'
#' }
#' @param distance (optional, numeric) Incompatible with `target`. Minimum distance between nearby points. Must be in same units as coordinates. Auto-calculated (see Details) when `NULL` and `target = NULL`. Default: `NULL` (auto-calculated)
#' @param target (optional, integer) Incompatible with `distance`. Number of points to retain (exact count not guaranteed). Must be between 1 and `nrow(df) - 1`. Default: `NULL`
#' @param seed (optional, integer) Seed used to reshuffle the argument `df` to change the thinning origin and provide an alternative output. If `1`, argument `df` is not reshuffled and its first sample is used as thinning origin. Default: `1`
#' @inheritParams spatial_folds
#' @return sf dataframe
#' @details
#' This function provides two spatial thinning strategies implemented in C++ for performance:
#'
#' ##"distance" - Minimum Distance Between Points
#'
#' If `distance = NULL` and `target = NULL`, automatically calculates `distance = 0.5 × √(area(bbox(df)) / nrow(df))`. This provides a reasonable starting point based on data extent and point density.
#'
#' The C++ function [thinning_to_distance()] applies a fast sequential thinning by removing points within rectangular neighborhoods:
#' - Processes points sequentially from first to last.
#' - For each retained point, defines rectangular neighborhood: x ± distance, y ± distance.
#' - Removes all points falling within this rectangle.
#' - Continues until all points processed
#' - Returns indices of retained points
#'
#' **Characteristics:**
#' - Guarantees no two retained points within distance.
#' - Order-dependent: always keeps first point in each neighborhood
#' - Result size depends on point distribution and ordering
#' - Rectangular (Manhattan-style) neighborhoods for computational efficiency
#'
#' ##"target" - Iterative Distance Increase to Target Count
#'
#' The C++ function [thinning_to_target()] applies thinning with progressively increasing distances until target reached:
#'
#' - Calculates initial distance as 0.1% of bounding box diagonal (if distance_step not provided)
#' - Applies "distance" method with current minimum distance
#' - If result has > target points, increases distance and repeats
#' - Continues until result has <= target points
#' - Returns indices of retained points
#'
#' **Characteristics:**
#' - Result will have <= target points (may be fewer, never more)
#' - Cannot guarantee exact count due to greedy algorithm behavior
#' - Automatically balances distance with target through iteration
#'
#' ## Use Cases
#'
#' - **Reduce pseudo-replication:** Remove spatially redundant observations
#' - **Disaggregate clusters:** Break up clustered point patterns
#' - **Generate centers:** Create well-distributed focal points for spatial cross-validation
#' - **Subsample large datasets:** Reduce dataset size while maintaining spatial coverage
#'
#'
#' @examples
#' # example data
#' data(xy_sf)
#'
#' # auto-calculated distance
#' df_thinned <- spatial_thinning(
#'   df = xy_sf,
#'   distance = NULL
#' )
#'
#' nrow(df_thinned)
#'
#' # fixed distance
#' df_thinned <- spatial_thinning(
#'   df = xy_sf,
#'   distance = 5 #~555km
#' )
#' nrow(df_thinned)
#'
#' # target
#' thinned_target <- spatial_thinning(
#'   df = xy_sf,
#'   target = 100
#' )
#'
#' nrow(thinned_target)
#'
#' @family user
#' @autoglobal
#' @export
spatial_thinning <- function(
  df = NULL,
  distance = NULL,
  target = NULL,
  seed = 1,
  quiet = FALSE,
  ...
) {
  dots <- list(...)
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::spatial_thinning()",
    function_name = dots$function_name
  )

  df <- validate_arg_sf(
    df = df,
    function_name = function_name
  )

  xy <- cast_sf_to_xy(
    df = df,
    function_name = function_name
  )

  #rearrange xy
  set.seed(as.integer(seed))

  xy.id <- cbind(xy, 1:nrow(xy))
  colnames(xy.id) <- c("x", "y", "id")
  xy_reshuffled <- xy.id
  if (seed > 1) {
    xy_reshuffled <- xy.id[sample.int(nrow(xy.id)), ]
  }

  #select method
  if (is.null(target)) {
    method <- "distance"
  } else if (is.null(distance)) {
    method <- "target"
  } else if (!is.null(distance) && !is.null(target)) {
    method <- "distance"
    target <- NULL

    if (!quiet) {
      message(
        "\n",
        function_name,
        ": Arguments 'distance' and 'target' cannot be used together. Using 'distance = ",
        distance,
        "'."
      )
    }
  }

  #using distance
  if (method == "distance") {
    distance <- validate_arg_distance(
      df = df,
      distance = distance,
      function_name = function_name
    )
  } else if (method == "target") {
    target <- validate_arg_target(
      df = df,
      target = target,
      function_name = function_name
    )
  }

  result_indices <- switch(
    method,
    distance = thinning_to_distance(
      xy = xy_reshuffled[, c("x", "y")],
      distance = distance
    ),
    target = thinning_to_target(
      xy = xy_reshuffled[, c("x", "y")],
      target = target
    )
  )

  result_indices <- xy_reshuffled[result_indices, "id"]

  df_thinned <- df[sort(result_indices), ]

  df_thinned
}
