#' Fit Linear Model to Dataset
#'
#' Fits a linear regression model with flexible specification of response and
#' predictor variables. This is a demonstration function that works with the
#' `dummy_df` dataset included in this package or any custom data frame.
#'
#' @param df Data frame to fit the model to. If `NULL` (default), uses the
#'   package's built-in `dummy_df` dataset. Must contain the specified
#'   response and predictor columns.
#' @param response Character string specifying the name of the response variable.
#'   If `NULL` (default), uses the first column of `df`.
#' @param predictors Character vector specifying the names of predictor variables.
#'   If `NULL` (default), uses all columns except the response variable.
#'
#' @return An object of class `"lm"` containing the fitted linear model.
#'   Use [summary()], [coef()], [predict()], and other standard methods
#'   to extract information from the model.
#'
#' @details
#' The function fits a linear model using [stats::lm()]. The formula is
#' constructed from the specified response and predictor variables. By default,
#' it uses the first column as response and all other columns as predictors.
#'
#' Input validation checks:
#' - `df` must be a data frame or NULL
#' - `response` must be a column name in `df` (if specified)
#' - `predictors` must be column names in `df` (if specified)
#' - Response and predictor columns must be numeric
#' - At least one predictor must be specified
#'
#' @export
#' @autoglobal
#'
#' @examples
#' # Use built-in dummy_df dataset with default settings
#' # (first column as response, all others as predictors)
#' model <- lm_model()
#' summary(model)
#'
#' # Specify response variable explicitly
#' model_a <- lm_model(response = "a")
#' coef(model_a)
#'
#' # Specify both response and predictors
#' model_subset <- lm_model(response = "a", predictors = c("b", "c", "d"))
#' summary(model_subset)
#'
#' # Use only specific predictors
#' model_select <- lm_model(
#'   response = "a",
#'   predictors = c("b", "e", "h")
#' )
#' coef(model_select)
#'
#' # Make predictions
#' predictions <- predict(model, newdata = dummy_df[1:10, ])
#' head(predictions)
#'
#' # Model diagnostics
#' par(mfrow = c(2, 2))
#' plot(model)
#'
#' # Use custom data with explicit variable specification
#' custom_data <- data.frame(
#'   y = rnorm(100),
#'   x1 = rnorm(100),
#'   x2 = rnorm(100),
#'   x3 = rnorm(100)
#' )
#' custom_model <- lm_model(
#'   df = custom_data,
#'   response = "y",
#'   predictors = c("x1", "x2")
#' )
#' summary(custom_model)
lm_model <- function(df = NULL, response = NULL, predictors = NULL) {
  # Use built-in dataset if none provided
  if (is.null(df)) {
    # Load the built-in dataset (avoids R CMD check NOTE)
    df <- get("dummy_df", envir = asNamespace("blankpkg"))
  }

  # Input validation: df must be a data frame
  if (!is.data.frame(df)) {
    stop(
      "Argument `df` must be a data frame or NULL. ",
      "Received object of class: ",
      class(df)[1],
      call. = FALSE
    )
  }

  # Determine response variable
  if (is.null(response)) {
    response <- names(df)[1]
  } else {
    if (!is.character(response) || length(response) != 1) {
      stop(
        "Argument `response` must be a single character string or NULL. ",
        "Received object of class: ",
        class(response)[1],
        " with length: ",
        length(response),
        call. = FALSE
      )
    }
    if (!response %in% names(df)) {
      stop(
        "Response variable '",
        response,
        "' not found in data frame. ",
        "Available columns: ",
        paste(names(df), collapse = ", "),
        call. = FALSE
      )
    }
  }

  # Determine predictor variables
  if (is.null(predictors)) {
    predictors <- setdiff(names(df), response)
  } else {
    if (!is.character(predictors)) {
      stop(
        "Argument `predictors` must be a character vector or NULL. ",
        "Received object of class: ",
        class(predictors)[1],
        call. = FALSE
      )
    }
    missing_predictors <- setdiff(predictors, names(df))
    if (length(missing_predictors) > 0) {
      stop(
        "Predictor variable(s) not found in data frame: ",
        paste(missing_predictors, collapse = ", "),
        "\nAvailable columns: ",
        paste(names(df), collapse = ", "),
        call. = FALSE
      )
    }
  }

  # Validate at least one predictor
  if (length(predictors) == 0) {
    stop(
      "At least one predictor variable must be specified. ",
      "Data frame has ",
      ncol(df),
      " column(s), ",
      "but response variable uses one of them.",
      call. = FALSE
    )
  }

  # Validate numeric columns
  cols_to_check <- c(response, predictors)
  non_numeric <- cols_to_check[!sapply(df[cols_to_check], is.numeric)]
  if (length(non_numeric) > 0) {
    stop(
      "Response and predictor columns must be numeric. ",
      "Non-numeric columns found: ",
      paste(non_numeric, collapse = ", "),
      call. = FALSE
    )
  }

  # Build formula: response ~ predictor1 + predictor2 + ...
  formula_string <- paste(response, "~", paste(predictors, collapse = " + "))
  formula <- stats::as.formula(formula_string)

  # Fit linear model
  model <- stats::lm(formula, data = df)

  return(model)
}
