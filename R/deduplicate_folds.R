#' Remove Redundant Folds Based on Correlation
#'
#' @description
#' Reduces redundancy in spatial folds by removing highly correlated folds
#' within each method-fraction group. Uses `collinear::collinear_select()` to
#' identify and keep only folds that are sufficiently different from each other.
#'
#' @param folds (required, data.frame) Output from `spatial_folds()` containing
#'   logical vector columns. Each column represents a fold with TRUE for training
#'   and FALSE for testing samples.
#' @param max_cor (optional, numeric) Maximum allowed correlation between folds.
#'   Folds with correlation above this threshold are considered redundant and
#'   removed. Must be between 0 and 1. Default: 0.9
#'
#' @return Data frame with same structure as input, but with redundant columns
#'   removed. Column names and data types are preserved.
#'
#' @details
#' This function addresses the issue where spatial folding methods (especially
#' "contiguous") can produce similar folds when center points are close to each
#' other. Redundant folds add computational overhead without contributing unique
#' information to cross-validation.
#'
#' The algorithm works as follows:
#'
#' 1. **Parse column names** to identify method-fraction groups (e.g., "contiguous_0.75")
#' 2. **For each group**:
#'    - Extract columns belonging to that group
#'    - Convert logical vectors to numeric (TRUE=1, FALSE=0)
#'    - Apply `collinear::collinear_select()` to find uncorrelated columns
#' 3. **Combine** selected columns from all groups
#' 4. **Return** reduced data frame with original column order preserved
#'
#' Deduplication is performed within groups (not across groups) because different
#' methods and training fractions produce structurally different folds that should
#' not be compared directly.
#'
#' @examples
#' # Generate folds with potential redundancy
#' folds <- spatial_folds(
#'   df = xy_sf,
#'   methods = "random",
#'   training_fraction = 0.75,
#'   repetitions = 50,
#'   seed = 123
#' )
#'
#' # Remove redundant folds (correlation > 0.9)
#' folds_unique <- deduplicate_folds(folds)
#'
#' # More aggressive deduplication
#' folds_strict <- deduplicate_folds(folds, max_cor = 0.8)
#'
#' @param ... Internal parameters passed from parent functions.
#' @family primary_functions
#' @autoglobal
#' @export
deduplicate_folds <- function(
  folds,
  max_cor = 0.9,
  ...
) {
  # ==========================================================================
  # Function name for hierarchical error messages
  # ==========================================================================
  dots <- list(...)
  function_name <- collinear::validate_arg_function_name(
    default_name = "spatialFolds::deduplicate_folds()",
    function_name = dots$function_name
  )

  # ============================================================================
  # Input Validation
  # ============================================================================

  if (is.null(folds)) {
    stop(
      function_name, ": argument 'folds' cannot be NULL.",
      call. = FALSE
    )
  }

  if (!is.data.frame(folds)) {
    stop(
      function_name, ": argument 'folds' must be a data.frame.",
      call. = FALSE
    )
  }

  if (ncol(folds) == 0) {
    stop(
      function_name, ": argument 'folds' has no columns.",
      call. = FALSE
    )
  }

  if (ncol(folds) == 1) {
    message(
      function_name, ": Only 1 fold provided, nothing to deduplicate."
    )
    return(folds)
  }

  # Validate max_cor
  if (!is.numeric(max_cor) || length(max_cor) != 1) {
    stop(
      function_name, ": argument 'max_cor' must be a single numeric value.",
      call. = FALSE
    )
  }

  if (max_cor <= 0 || max_cor >= 1) {
    stop(
      function_name, ": argument 'max_cor' must be between 0 and 1 (exclusive).",
      call. = FALSE
    )
  }

  # Validate all columns are logical
  if (!all(sapply(folds, is.logical))) {
    stop(
      function_name, ": all columns in 'folds' must be logical vectors.",
      call. = FALSE
    )
  }

  # ============================================================================
  # Parse Column Names to Identify Groups
  # ============================================================================

  col_names <- colnames(folds)

 # Extract group identifier (method_fraction) from column names
  # Pattern: method_fraction_iteration (e.g., "contiguous_0.75_1")
  get_group <- function(name) {
    parts <- strsplit(name, "_")[[1]]
    if (length(parts) >= 3) {
      # Combine all parts except the last (iteration number)
      paste(parts[-length(parts)], collapse = "_")
    } else {
      name
    }
  }

  groups <- sapply(col_names, get_group)
  unique_groups <- unique(groups)

  # ============================================================================
  # Deduplicate Within Each Group
  # ============================================================================

  selected_columns <- character(0)

  for (group in unique_groups) {
    # Get columns in this group
    group_cols <- col_names[groups == group]

    if (length(group_cols) == 1) {
      # Single column, keep it
      selected_columns <- c(selected_columns, group_cols)
      next
    }

    # Extract group data and convert logical to numeric
    group_df <- folds[, group_cols, drop = FALSE]
    group_df_numeric <- as.data.frame(lapply(group_df, as.numeric))

    # Apply collinear_select to find uncorrelated columns
    selected <- collinear::collinear_select(
      df = group_df_numeric,
      max_cor = max_cor
    )

    selected_columns <- c(selected_columns, selected)
  }

  # ============================================================================
  # Build Result
  # ============================================================================

  # Preserve original column order
  selected_columns <- col_names[col_names %in% selected_columns]

  # Subset to selected columns
  result <- folds[, selected_columns, drop = FALSE]

  # Report reduction
  n_original <- ncol(folds)
  n_kept <- ncol(result)
  n_removed <- n_original - n_kept

  message(
    function_name, ": Reduced from ",
    n_original,
    " to ",
    n_kept,
    " folds (",
    n_removed,
    " redundant folds removed, ",
    round(100 * n_removed / n_original, 1),
    "% reduction)"
  )

  result
}
