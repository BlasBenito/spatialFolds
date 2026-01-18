#' @title Apply Spatial Thinning to Point Data
#' @description Resamples points to enforce minimum distance separation or reach a target sample size. Provides two methods:
#' \itemize{
#'   \item **distance**: fixed minimum distance between locations.
#'   \item **target**: iterative distance increase until target count reached.
#'
#' }
#' @param df (required, sf or data.frame) Spatial data with point geometries. If data.frame, must have columns named "x" and "y", "longitude" and "latitude", or "lon" and "lat". If sf object, coordinates are extracted from geometry. Default: `NULL`
#' @param method (required, character) Thinning strategy to apply. Must be one of "distance" (fixed minimum distance) or "target" (iterative until the required number of records is achieved). Default: `"distance"`
#' @param distance (required for method="distance", numeric) Minimum distance between retained points in both x and y dimensions. Points within a rectangle of ±distance will be removed. Must be in same units as coordinates. When NULL, auto-calculated as 0.5 × √(bbox_area / n). Use explicit values when you know the desired spacing. Default: `NULL` (auto-calculated)
#' @param target (required for method="target", integer) Target number of points to retain. Result will have <= target points (exact count not guaranteed). Must be between 1 and nrow(df). Default: `NULL`
#' @param seed (optional, integer) Random seed for reproducibility. Each
#'   repetition gets unique seed derived from this base seed. Default: 1
#' @return sf object (matching input type) with thinned subset of points. Row order preserved from input.
#' @details
#' This function provides two spatial thinning strategies implemented in C++ for performance:
#'
#' ## Method: "distance" - Fixed Minimum Distance Enforcement
#'
#' If distance = NULL, automatically calculates distance = 0.5 × √(bbox_area / n).
#' This provides a reasonable starting point based on data extent and point density.
#'
#' Applies greedy sequential thinning by removing points within rectangular neighborhoods:
#' \enumerate{
#'   \item Processes points sequentially from first to last
#'   \item For each retained point, defines rectangular neighborhood: x ± distance, y ± distance
#'   \item Removes all subsequent points falling within this rectangle
#'   \item Continues until all points processed
#'   \item Returns indices of retained points
#' }
#'
#' **Characteristics:**
#' - Guarantees no two retained points within distance in BOTH x and y dimensions
#' - Order-dependent: always keeps first point in each neighborhood
#' - Result size depends on point distribution and ordering
#' - Rectangular (Manhattan-style) neighborhoods for computational efficiency
#'
#' ## Method: "target" - Iterative Distance Increase to Target Count
#'
#' Applies "distance" method with progressively increasing distances until target reached:
#' \enumerate{
#'   \item Calculates initial distance as 0.1% of bounding box diagonal (if distance_step not provided)
#'   \item Applies "distance" method with current minimum distance
#'   \item If result has > target points, increases distance and repeats
#'   \item Continues until result has <= target points
#'   \item Returns indices of retained points
#' }
#'
#' **Characteristics:**
#' - Result will have <= target points (may be fewer, never more)
#' - Cannot guarantee exact count due to greedy algorithm behavior
#' - Automatically balances distance with target through iteration
#' - Typically requires 10-100 iterations with auto-calculated distance_step
#'
#' ## Use Cases
#'
#' - **Reduce pseudo-replication:** Remove spatially redundant observations
#' - **Disaggregate clusters:** Break up clustered point patterns
#' - **Generate centers:** Create well-distributed focal points for spatial cross-validation
#' - **Subsample large datasets:** Reduce dataset size while maintaining spatial coverage
#'
#' ## Performance
#'
#' Implemented in C++ for efficiency:
#' - method = "distance": function [thinning_to_distance()], O(n²) time, typically < 1 second for 30,000 points
#' - method = "target": function [thinning_to_target()], O(k × n²) where k = iterations
#'
#' @examples
#' # Example data
#' data(xy_sf)
#'
#' # Use auto-calculated distance (recommended starting point)
#' thinned_auto <- spatial_thinning(
#'   df = xy_sf,
#'   method = "distance"
#'   # distance = NULL (default) - auto-calculates based on extent and density
#' )
#' nrow(thinned_auto)  # Shows how many points retained
#'
#' # Fixed distance thinning
#' thinned_fixed <- spatial_thinning(
#'   df = xy_sf,
#'   method = "distance",
#'   distance = 10
#' )
#' nrow(thinned_fixed)  # Fewer than original
#'
#' # Target count thinning with auto distance
#' thinned_target <- spatial_thinning(
#'   df = xy_sf,
#'   method = "target",
#'   target = 100
#' )
#' nrow(thinned_target)  # Will be <= 100
#'
#' # Works with data.frames too (converted to sf internally)
#' df <- data.frame(x = runif(1000), y = runif(1000))
#' thinned_df <- spatial_thinning(
#'   df = df,
#'   method = "distance",
#'   distance = 0.1
#' )
#'
#' @param ... Internal parameters passed from parent functions.
#' @family primary_functions
#' @autoglobal
#' @export
spatial_thinning <- function(
  df = NULL,
  method = c("distance", "target"),
  distance = NULL,
  target = NULL,
  seed = 1,
  ...
) {
  # ==========================================================================
  # Function name for hierarchical error messages
  # ==========================================================================
  dots <- list(...)
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::spatial_thinning()",
    function_name = dots$function_name
  )

  # ==========================================================================
  # Pre-check for edge case: all coordinates identical
  # Must handle this before validate_arg_sf which would error
  # ==========================================================================
  if (is.null(df)) {
    stop(
      "\n",
      function_name,
      ": argument 'df' cannot be NULL.",
      call. = FALSE
    )
  }

  if (!inherits(x = df, what = "sf")) {
    df <- cast_df_to_sf(
      df = df,
      crs = NA,
      function_name = function_name
    )
  }

  # Check for identical coordinates (zero bbox area)
  bbox <- sf::st_bbox(df)
  if (bbox["xmin"] == bbox["xmax"] && bbox["ymin"] == bbox["ymax"]) {
    message(
      function_name,
      ": All points at same location. Returning all points with distance = 0."
    )
    return(df)
  }

  # ==========================================================================
  # Validate df (will check for other edge cases like single-axis identical)
  # ==========================================================================
  df <- validate_arg_sf(
    df = df,
    function_name = function_name
  )

  xy <- cast_sf_to_xy(
    df = df,
    function_name = function_name
  )

  set.seed(as.integer(seed))

  xy.id <- cbind(xy, 1:nrow(xy))
  colnames(xy.id) <- c("x", "y", "id")
  xy_reshuffled <- xy.id[sample.int(nrow(xy.id)), ]

  method <- match.arg(method)

  if (method == "distance") {
    # Make distance optional with default = NULL
    if (is.null(distance)) {
      # Auto-calculate distance based on bounding box and point density
      # Formula: distance = 0.5 * sqrt(bbox_area / n)

      # Calculate bbox area directly from xy coordinates (faster, no sf dependency)
      x_range <- diff(range(xy[, "x"]))
      y_range <- diff(range(xy[, "y"]))
      bbox_area <- x_range * y_range

      # Get number of points
      n_points <- nrow(df)

      # Calculate default distance
      distance <- 0.5 * sqrt(bbox_area / n_points)

      # Inform user
      message(
        function_name,
        ": Auto-calculated distance = ",
        round(distance, 6),
        " (based on bounding box area and point density)"
      )
    } else {
      # Existing validation for user-provided distance
      if (!is.numeric(distance)) {
        stop(
          function_name,
          ": argument 'distance' must be numeric.",
          call. = FALSE
        )
      }

      # Take first value if length > 1
      if (length(distance) > 1) {
        warning(
          function_name,
          ": 'distance' has length > 1, using first value.",
          call. = FALSE
        )
        distance <- distance[1]
      }

      if (distance < 0) {
        stop(
          function_name,
          ": argument 'distance' must be >= 0.",
          call. = FALSE
        )
      }
    }
  } else if (method == "target") {
    # Validate target for "target" method
    if (is.null(target)) {
      stop(
        function_name,
        ": argument 'target' is required for method = 'target'.",
        call. = FALSE
      )
    }

    if (!is.numeric(target)) {
      stop(
        function_name,
        ": argument 'target' must be numeric.",
        call. = FALSE
      )
    }

    target <- as.integer(target)

    if (target < 1) {
      stop(
        function_name,
        ": argument 'target' must be >= 1.",
        call. = FALSE
      )
    }

    if (target > nrow(df)) {
      warning(
        function_name,
        ": 'target' exceeds nrow(df), returning all points.",
        call. = FALSE
      )
      return(df)
    }
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

  result_df <- df[sort(result_indices), ]

  # Informative message
  message(
    function_name,
    ": Thinned from ",
    nrow(df),
    " to ",
    length(result_indices),
    " points (",
    round(100 * length(result_indices) / nrow(df), 1),
    "% retained)"
  )

  result_df
}
