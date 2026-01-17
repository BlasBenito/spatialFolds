#' Generate Multiple Spatial Cross-Validation Folds
#'
#' @description
#' MGenerates training and testing folds for
#' spatial cross-validation using multiple methods, training fractions, and
#' iterations. Supports parallel execution via `future` and progress tracking
#' via `progressr` (see examples).
#'
#' @param df (required, sf or data.frame) Spatial data with point geometries.
#'   If data.frame, must have recognizable coordinate columns (x/lon/longitude
#'   and y/lat/latitude). Will be converted to sf with CRS 4326. Default: NULL
#' @param methods (optional, character vector) Methods to use. One or more of:
#'   "contiguous", "random", "blocks". Default: c("contiguous", "random", "blocks")
#' @param training_fraction (optional, numeric vector) Proportion of data for training (0.1 to 0.9, exclusive). Multiple values generate separate fold sets. Default: 0.75
#' @param repetitions (optional, integer) Number of folds to generate per
#'   method-fraction combination. Default: 30
#' @param seed (optional, integer) Random seed for reproducibility. Each
#'   repetition gets unique seed derived from this base seed. Default: 1
#' @param blocks (optional, NULL, integer, or vector) Grid configuration for
#'   blocks method. If NULL: auto-computed as floor(nrow(df)/30), creating ~30
#'   samples per block. If a single integer: number of blocks (minimum 4),
#'   auto-arranged by aspect ratio to create roughly square blocks in geographic
#'   space. If a length-2 vector: c(rows, cols) for direct grid control.
#'   Default: NULL.
#' @param spherical (optional, logical) If TRUE, uses spherical geometry for
#'   the method `"contiguous"`. If FALSE, uses planar geometry. If NULL (default),
#'   auto-detects based on coordinate ranges using `utils_needs_spherical()`.
#'   Spherical geometry is recommended for global data near the dateline
#'   (longitude near +-180) or poles (latitude near +-90). Default: `NULL`
#' @param quiet (optional; logical) If FALSE, messages are printed. Default: FALSE.
#' @param ... (optional) Not used, reserved for future advanced arguments.
#'
#' @return Data frame with one logical vector column per fold. Column names
#'   follow pattern "method_training_fraction_iteration" (e.g., "contiguous_0.75_1").
#'   TRUE indicates training samples, FALSE indicates testing samples. Each
#'   column has length equal to nrow(df).
#'
#' @details
#'
#' **Parallelization**: Users control execution strategy via future::plan():
#' - Sequential: future::plan("sequential") (default)
#' - Parallel: future::plan("multisession", workers = 4)
#'
#' **Progress bars**: Respects user's progressr configuration. Enable with:
#' progressr::handlers(global = TRUE)
#'
#' @examples
#'
#' # Generate 5 folds with random method
#' folds <- spatial_folds(
#'   df = xy_sf,
#'   methods = "random",
#'   training_fraction = 0.75,
#'   repetitions = 5,
#'   seed = 123
#' )
#'
#' # Result: data.frame with 5 columns
#' dim(folds)  # 30000 rows (points) x 5 columns (folds)
#'
#' # Access specific folds
#' fold_1 <- folds$random_0.75_1
#' sum(fold_1)  # Number of training samples
#'
#' # Parallel execution (requires future package)
#' \dontrun{
#' library(future)
#' plan("multisession", workers = 4)
#' folds_parallel <- spatial_folds(xy_sf, repetitions = 100)
#' plan("sequential")  # Reset to sequential
#' }
#'
#' @family primary_functions
#' @autoglobal
#' @export
spatial_folds <- function(
  df = NULL,
  methods = c("contiguous", "random", "blocks"),
  training_fraction = c(0.75, 0.5),
  repetitions = 30,
  seed = 1,
  blocks = NULL,
  spherical = NULL,
  quiet = FALSE,
  ...
) {
  dots <- list(...)

  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::spatial_folds()",
    function_name = dots$function_name
  )

  df <- validate_arg_sf(
    df = df,
    function_name = function_name
  )
  xy <- cast_sf_to_xy(df = df, function_name = function_name)

  # Validate methods
  if (is.null(methods) || length(methods) == 0) {
    stop(
      "spatialFolds::spatial_folds(): argument 'methods' cannot be empty.",
      call. = FALSE
    )
  }

  # Match and validate methods
  methods <- match.arg(
    arg = unique(methods),
    choices = c("contiguous", "random", "blocks"),
    several.ok = TRUE
  )

  # training_fraction ----
  # First check if NULL or non-numeric (reset to default with message)
  if (
    is.null(training_fraction) ||
      length(training_fraction) == 0 ||
      !is.numeric(training_fraction)
  ) {
    training_fraction <- 0.75
    if (!quiet) {
      message(
        "\n",
        function_name,
        ": Argument 'training_fraction' is invalid. Resetting it to 0.75."
      )
    }
  }

  # Then check if out of range (error)
  if (any(training_fraction <= 0.1) || any(training_fraction >= 0.9)) {
    stop(
      "\n",
      function_name,
      ": Argument 'training_fraction' must be between 0.1 and 0.9 (exclusive).",
      call. = FALSE
    )
  }

  training_fraction <- sort(
    x = unique(training_fraction),
    decreasing = TRUE
  )

  # repetitions ----
  if (length(repetitions) != 1) {
    stop(
      "\n",
      function_name,
      ": Argument 'repetitions' must be a single integer.",
      call. = FALSE
    )
  }

  if (!is.numeric(repetitions)) {
    stop(
      "\n",
      function_name,
      ": Argument 'repetitions' must be numeric.",
      call. = FALSE
    )
  }

  repetitions <- as.integer(repetitions)

  if (repetitions < 1) {
    stop(
      "\n",
      function_name,
      ": Argument 'repetitions' must be at least 1.",
      call. = FALSE
    )
  }

  if (repetitions > 1000) {
    warning(
      "\n",
      function_name,
      ": repetitions is large (",
      repetitions,
      "). This may take considerable time and memory.",
      call. = FALSE
    )
  }

  # Validate seed
  if (length(seed) != 1) {
    stop(
      "\n",
      function_name,
      ": Argument 'seed' must be a single integer.",
      call. = FALSE
    )
  }

  if (!is.numeric(seed)) {
    stop(
      "\n",
      function_name,
      ": Argument 'seed' must be numeric.",
      call. = FALSE
    )
  }

  seed <- as.integer(seed)

  set.seed(seed)

  # Calculate coordinate ranges (xy already extracted by validate_arg_sf)
  x_range <- diff(range(xy[, "x"]))
  y_range <- diff(range(xy[, "y"]))
  n_points <- nrow(xy)

  # Validate blocks parameter
  rows <- NULL
  cols <- NULL
  if ("blocks" %in% methods) {
    blocks_validated <- validate_arg_blocks(
      blocks = blocks,
      n_points = n_points,
      x_range = x_range,
      y_range = y_range,
      quiet = quiet,
      function_name = function_name
    )
    rows <- blocks_validated$rows
    cols <- blocks_validated$cols
  }

  # Auto-detect spherical geometry if not specified
  if ("contiguous" %in% methods && is.null(spherical)) {
    spherical <- utils_needs_spherical(xy)
    if (spherical && !quiet) {
      message(
        "\n",
        function_name,
        ": Using spherical geometry to generate contiguous folds."
      )
    }
  }

  # Pre-compute block_id for blocks method
  block_id_vector <- NULL
  if ("blocks" %in% methods) {
    block_id_vector <- block_ids(df, rows, cols)
  }

  # Pre-compute centers for contiguous method
  center_indices <- NULL
  step_x <- NULL
  step_y <- NULL
  if ("contiguous" %in% methods) {
    # Check if we have enough points
    if (repetitions > n_points) {
      repetitions <- n_points
    }

    #reshuffle
    xy <- cbind(xy, 1:nrow(xy))
    colnames(xy) <- c("x", "y", "id")
    xy_reshuffled <- xy[sample.int(nrow(xy)), ]

    # Get well-distributed center indices via thinning (returns indices directly)
    center_indices <- thinning_to_target(
      xy = xy_reshuffled,
      target = repetitions
    )

    center_indices <- xy_reshuffled[center_indices, "id"]

    # Calculate step values
    step_x <- x_range / 1000
    step_y <- y_range / 1000
  }

  iterations_list <- list()
  counter <- 0
  center_counter <- 0
  combo_counter <- list()

  for (method in methods) {
    for (fraction in training_fraction) {
      # Format fraction once per combination
      fraction_str <- format(fraction, nsmall = 2, trim = TRUE)
      key <- paste0(method, "_", fraction_str)

      for (i in 1:repetitions) {
        counter <- counter + 1

        # Update combo counter
        if (is.null(combo_counter[[key]])) {
          combo_counter[[key]] <- 1
        } else {
          combo_counter[[key]] <- combo_counter[[key]] + 1
        }

        # Generate column name
        column_name <- paste0(key, "_", combo_counter[[key]])

        target <- as.integer(fraction * n_points)
        iteration_seed <- seed + counter

        if (method == "contiguous") {
          center_counter <- center_counter + 1
          center_idx <- center_indices[center_counter]

          row <- data.frame(
            iteration = counter,
            method = "contiguous",
            training_fraction = fraction,
            seed = iteration_seed,
            target = target,
            center = center_idx,
            step_x = step_x,
            step_y = step_y,
            column_name = column_name,
            stringsAsFactors = FALSE
          )
        } else if (method == "random") {
          row <- data.frame(
            iteration = counter,
            method = "random",
            training_fraction = fraction,
            seed = iteration_seed,
            target = target,
            center = NA_integer_,
            step_x = NA_real_,
            step_y = NA_real_,
            column_name = column_name,
            stringsAsFactors = FALSE
          )
        } else if (method == "blocks") {
          row <- data.frame(
            iteration = counter,
            method = "blocks",
            training_fraction = fraction,
            seed = iteration_seed,
            target = target,
            center = NA_integer_,
            step_x = NA_real_,
            step_y = NA_real_,
            column_name = column_name,
            stringsAsFactors = FALSE
          )
        }

        iterations_list[[counter]] <- row
      }
    }
  }

  # Combine into single dataframe
  iterations_df <- do.call(rbind, iterations_list)

  total_iterations <- nrow(iterations_df)
  p <- progressr::progressor(steps = total_iterations)

  # Define wrapper function for single iteration
  run_iteration <- function(
    i,
    xy,
    iterations_df,
    block_id_vector,
    spherical,
    p
  ) {
    # Extract parameters for this iteration
    params <- iterations_df[i, ]

    # Build arguments list based on method
    if (params$method == "contiguous") {
      args_list <- list(
        xy = xy,
        method = "contiguous",
        spherical = spherical,
        center = params$center,
        step_x = params$step_x,
        step_y = params$step_y,
        target = params$target
      )
    } else if (params$method == "random") {
      args_list <- list(
        xy = xy,
        method = "random",
        seed = params$seed,
        target = params$target
      )
    } else if (params$method == "blocks") {
      args_list <- list(
        xy = xy,
        method = "blocks",
        block_id = block_id_vector,
        seed = params$seed,
        target = params$target
      )
    }

    # Call training_mask
    result <- do.call(training_mask, args_list)

    # Update progress
    p()

    return(result)
  }

  # Execute parallel loop with progress
  fold_list <- future.apply::future_lapply(
    X = 1:nrow(iterations_df),
    FUN = run_iteration,
    xy = xy,
    iterations_df = iterations_df,
    block_id_vector = block_id_vector,
    spherical = spherical,
    p = p,
    future.seed = TRUE
  )

  # Convert list to dataframe
  results_df <- as.data.frame(fold_list)
  rm(fold_list)

  # Set column names from iterations_df
  colnames(results_df) <- iterations_df$column_name

  results_df
}
