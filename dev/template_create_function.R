#' Create Example Function Template
#'
#' Demonstrates how to create and document functions for your R package.
#' This is a TEMPLATE function that creates `lm_model.R` as an example.
#'
#' @return Logical value `TRUE`, returned invisibly, on successful function creation.
#'
#' @details
#' **IMPORTANT: This is a TEMPLATE function - customize it for your needs!**
#'
#' This function demonstrates the complete workflow for creating package functions:
#'
#' 1. Writes a complete function with proper structure
#' 2. Adds roxygen2 documentation comments
#' 3. Includes @autoglobal for automatic global variable detection
#' 4. Adds @export tag to make function available to users
#' 5. Provides working examples in @examples section
#' 6. Includes input validation and error handling
#'
#' The function creates `R/lm_model.R` as a working example. To create your own
#' function, modify the function code and documentation to match your needs.
#'
#' @section Files Created:
#' - `R/lm_model.R` - The function file
#' - Help file generated via `devtools::document()` creates `man/lm_model.Rd`
#' - NAMESPACE updated with export directive
#'
#' @section Best Practices:
#' - Use snake_case for function names consistently
#' - Validate inputs and provide clear error messages
#' - Include @examples with working code
#' - Add @autoglobal for roxyglobals integration
#' - Document all parameters with @param
#' - Describe return value with @return
#' - Keep functions focused on a single task
#' - Use explicit namespace calls (pkg::function)
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - R/ directory should exist (created if missing)
#'
#' @section Notes:
#' - This template creates the `lm_model()` function
#' - Modify function code for your own needs
#' - Run `devtools::document()` after creating function
#' - Test with `devtools::load_all()` and `?lm_model`
#' - Add tests in `tests/testthat/test-lm_model.R`
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Create the example function
#' template_create_function()
#'
#' # After running:
#' # 1. Review R/lm_model.R
#' # 2. Run devtools::document()
#' # 3. Test with devtools::load_all()
#' # 4. Try ?lm_model
#' # 5. Add tests in tests/testthat/
#' }
template_create_function <- function() {
  # Print header
  cli::cli_rule(
    left = "CREATE EXAMPLE FUNCTION"
  )
  cli::cli_text()

  cli::cli_alert_info("Creating example function: {.code lm_model()}")
  cli::cli_text()

  # Function code with roxygen documentation
  function_code <- '#\' Fit Linear Model to Dummy Dataset
#\'
#\' Fits a linear regression model using the first column as response variable
#\' and all remaining columns as predictors. This is a demonstration function
#\' that works with the `dummy_df` dataset included in this package.
#\'
#\' @param df Data frame to fit the model to. If `NULL` (default), uses the
#\'   package\'s built-in `dummy_df` dataset. Must have at least 2 columns,
#\'   where the first column is treated as the response variable and remaining
#\'   columns as predictors.
#\'
#\' @return An object of class `"lm"` containing the fitted linear model.
#\'   Use [summary()], [coef()], [predict()], and other standard methods
#\'   to extract information from the model.
#\'
#\' @details
#\' The function fits a linear model using [stats::lm()] with the formula
#\' `first_column ~ .`, which means the first column is predicted by all
#\' other columns in the dataframe.
#\'
#\' Input validation checks:
#\' - `df` must be a data frame or NULL
#\' - Data frame must have at least 2 columns
#\' - All columns must be numeric
#\'
#\' @export
#\' @autoglobal
#\'
#\' @examples
#\' # Use built-in dummy_df dataset
#\' model <- lm_model()
#\' summary(model)
#\'
#\' # Check coefficients
#\' coef(model)
#\'
#\' # Make predictions
#\' predictions <- predict(model, newdata = dummy_df[1:10, ])
#\' head(predictions)
#\'
#\' # Model diagnostics
#\' par(mfrow = c(2, 2))
#\' plot(model)
#\'
#\' # Use custom data
#\' custom_data <- data.frame(
#\'   y = rnorm(100),
#\'   x1 = rnorm(100),
#\'   x2 = rnorm(100)
#\' )
#\' custom_model <- lm_model(df = custom_data)
#\' summary(custom_model)
lm_model <- function(df = NULL) {
  # Use built-in dataset if none provided
  if (is.null(df)) {
    df <- dummy_df
  }

  # Input validation
  if (!is.data.frame(df)) {
    stop(
      "Argument `df` must be a data frame or NULL. ",
      "Received object of class: ", class(df)[1],
      call. = FALSE
    )
  }

  if (ncol(df) < 2) {
    stop(
      "Data frame must have at least 2 columns ",
      "(1 response + 1 predictor). ",
      "Found ", ncol(df), " column(s).",
      call. = FALSE
    )
  }

  if (!all(sapply(df, is.numeric))) {
    non_numeric <- names(df)[!sapply(df, is.numeric)]
    stop(
      "All columns must be numeric. ",
      "Non-numeric columns found: ",
      paste(non_numeric, collapse = ", "),
      call. = FALSE
    )
  }

  # Fit linear model: first column ~ all other columns
  formula <- stats::as.formula(paste(names(df)[1], "~ ."))
  model <- stats::lm(formula, data = df)

  return(model)
}
'

  cli::cli_h3("STEP 1: Create R/ directory")

  # Create R directory if it doesn't exist
  if (!dir.exists("R")) {
    dir.create("R")
    cli::cli_alert_success("Created R/ directory")
  } else {
    cli::cli_alert_info("R/ directory already exists")
  }
  cli::cli_text()

  cli::cli_h3("STEP 2: Write function to file")

  # Write function code to file
  cat(function_code, file = "R/lm_model.R")
  cli::cli_alert_success("Created {.file R/lm_model.R}")

  # Check file info
  file_info <- file.info("R/lm_model.R")
  cli::cli_text("File size: {file_info$size} bytes")
  cli::cli_text()

  cli::cli_rule("FUNCTION CREATION COMPLETE")
  cli::cli_text()

  cli::cli_h3("NEXT STEPS:")
  cli::cli_ol(c(
    "Review the generated function in {.file R/lm_model.R}",
    "Adjust documentation as needed",
    "Modify function logic if required",
    "Run {.code devtools::document()} to generate documentation",
    "Test interactively with {.code devtools::load_all()} and {.code ?lm_model}",
    "Add tests in {.file tests/testthat/test-lm_model.R}",
    "Use the function in vignettes and documentation"
  ))
  cli::cli_text()

  cli::cli_h3("TO CREATE YOUR OWN FUNCTION:")
  cli::cli_ul(c(
    "Modify the function code above to match your needs",
    "Change function name and parameters",
    "Update roxygen2 documentation",
    "Add appropriate input validation",
    "Include working examples in {.code @examples}",
    "Use snake_case naming consistently",
    "Add {.code @autoglobal} tag for global variable detection"
  ))
  cli::cli_rule()

  invisible(TRUE)
}
