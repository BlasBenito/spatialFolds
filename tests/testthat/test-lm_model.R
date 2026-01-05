# ============================================================================ #
# Comprehensive Test Suite for lm_model() Function
# ============================================================================ #
#
# WHAT IS TESTING AND WHY IT MATTERS:
#
# Automated testing is the practice of writing code that verifies your functions
# work correctly. This is essential for:
#   - Catching bugs before users do
#   - Ensuring changes don't break existing functionality
#   - Documenting expected behavior
#   - Building confidence in your code
#   - Making refactoring safer
#
# INTRODUCTION TO TESTTHAT:
#
# testthat is R's most popular testing framework. It provides:
#   - test_that(): Creates a test with a description
#   - expect_*(): Functions that check specific conditions
#   - Organized test structure
#   - Clear output showing what passed/failed
#
# BASIC STRUCTURE OF A TEST:
#
#   test_that("description of what you're testing", {
#     # Setup: Create test data
#     result <- my_function(test_input)
#
#     # Expectations: Check that results are correct
#     expect_equal(result, expected_value)
#   })
#
# TYPES OF TESTS TO WRITE:
#
# 1. SUCCESS CASES: Tests where the function should work correctly
#    - Test default behavior
#    - Test different valid input combinations
#    - Test edge cases (empty data, single values, etc.)
#
# 2. ERROR CASES: Tests where the function should fail with clear errors
#    - Invalid inputs
#    - Missing required data
#    - Type mismatches
#
# 3. RETURN VALUE TESTS: Verify the function returns the right type/structure
#    - Check object class
#    - Check dimensions
#    - Check names/attributes
#
# COMMON TESTTHAT EXPECTATIONS:
#
#   expect_equal(x, y)        # x and y are equal (with tolerance for numbers)
#   expect_identical(x, y)    # x and y are exactly identical
#   expect_true(x)            # x is TRUE
#   expect_false(x)           # x is FALSE
#   expect_null(x)            # x is NULL
#   expect_type(x, "type")    # x has specified type
#   expect_s3_class(x, "lm")  # x is an S3 object of specified class
#   expect_length(x, n)       # x has length n
#   expect_error(code, "msg") # code produces an error (optionally matching msg)
#   expect_warning(code)      # code produces a warning
#   expect_silent(code)       # code runs without messages/warnings/errors
#
# ============================================================================ #

# ============================================================================ #
# SECTION 1: SUCCESS CASES - Default Behavior
# ============================================================================ #
#
# These tests verify the function works correctly with default arguments.
# This is what most users will do first, so it's critical to test thoroughly.
#
# ============================================================================ #

test_that("lm_model works with all default arguments", {
  # SETUP: Call function with defaults (uses built-in dummy_df)
  model <- lm_model()

  # EXPECTATION 1: Returns an lm object
  # Why test this? Users expect a standard lm object they can use with
  # summary(), plot(), predict(), etc.
  expect_s3_class(model, "lm")

  # EXPECTATION 2: Formula uses first column as response
  # Why test this? This is the documented default behavior
  # Note: We compare formula as strings to avoid environment comparison issues
  expect_equal(
    deparse(formula(model)),
    "a ~ b + c + d + e + f + g + h + i + j"
  )

  # EXPECTATION 3: Model uses all 1000 observations
  # Why test this? Ensures no data is accidentally dropped
  expect_equal(nrow(model$model), 1000)

  # EXPECTATION 4: Model has 10 coefficients (intercept + 9 predictors)
  # Why test this? Verifies all predictors are included
  expect_length(coef(model), 10)
})


test_that("lm_model produces a well-fitted model with dummy_df", {
  # SETUP: Fit the model
  model <- lm_model()

  # EXPECTATION 1: Model has high R-squared (data was generated with known relationship)
  # Why test this? The dummy_df was created with a specific linear relationship,
  # so we should recover it with good fit
  r_squared <- summary(model)$r.squared
  expect_gt(r_squared, 0.8) # expect greater than 0.8

  # EXPECTATION 2: All predictors are significant (p < 0.05)
  # Why test this? With 1000 observations and true relationships, all should be significant
  p_values <- summary(model)$coefficients[-1, "Pr(>|t|)"] # exclude intercept
  expect_true(all(p_values < 0.05))
})


# ============================================================================ #
# SECTION 2: SUCCESS CASES - Custom Response Variable
# ============================================================================ #
#
# These tests verify the function correctly handles the 'response' argument.
#
# ============================================================================ #

test_that("lm_model works with explicit response argument", {
  # SETUP: Specify response explicitly (should give same result as default)
  model <- lm_model(response = "a")

  # EXPECTATION: Formula uses specified response
  expect_equal(
    as.character(formula(model))[2], # Left side of formula
    "a"
  )

  # EXPECTATION: All other columns used as predictors
  expect_length(coef(model), 10) # intercept + 9 predictors
})


test_that("lm_model can use any column as response", {
  # SETUP: Use a different column as response
  # This tests flexibility - users might want to predict different variables
  model <- lm_model(response = "b")

  # EXPECTATION: Formula has 'b' as response
  expect_equal(as.character(formula(model))[2], "b")

  # EXPECTATION: Response variable is 'b'
  expect_equal(names(model$model)[1], "b")

  # EXPECTATION: 'b' is not in the predictors
  predictor_names <- names(coef(model))[-1] # exclude intercept
  expect_false("b" %in% predictor_names)
})


# ============================================================================ #
# SECTION 3: SUCCESS CASES - Custom Predictors
# ============================================================================ #
#
# These tests verify the function correctly handles the 'predictors' argument.
#
# ============================================================================ #

test_that("lm_model works with subset of predictors", {
  # SETUP: Use only specific predictors
  # Common use case: feature selection, testing specific hypotheses
  model <- lm_model(response = "a", predictors = c("b", "c", "d"))

  # EXPECTATION 1: Model has correct number of coefficients
  expect_length(coef(model), 4) # intercept + 3 predictors

  # EXPECTATION 2: Coefficient names match specified predictors
  expect_equal(
    names(coef(model)),
    c("(Intercept)", "b", "c", "d")
  )

  # EXPECTATION 3: Formula is constructed correctly
  # Note: We compare formula as strings to avoid environment comparison issues
  expect_equal(
    deparse(formula(model)),
    "a ~ b + c + d"
  )
})


test_that("lm_model works with single predictor", {
  # SETUP: Simple linear regression (one predictor)
  # Edge case: minimum valid model
  model <- lm_model(response = "a", predictors = "b")

  # EXPECTATION 1: Model has 2 coefficients (intercept + 1 predictor)
  expect_length(coef(model), 2)

  # EXPECTATION 2: Predictor name is correct
  expect_equal(names(coef(model))[2], "b")
})


test_that("lm_model works with predictors in different order", {
  # SETUP: Specify predictors in non-alphabetical order
  # Why test this? Order shouldn't matter for correctness
  model1 <- lm_model(response = "a", predictors = c("b", "c", "d"))
  model2 <- lm_model(response = "a", predictors = c("d", "b", "c"))

  # EXPECTATION: Both models have same predictors (order in formula might differ)
  expect_setequal(
    names(coef(model1)),
    names(coef(model2))
  )
})


# ============================================================================ #
# SECTION 4: SUCCESS CASES - Custom Data
# ============================================================================ #
#
# These tests verify the function works with user-provided dataframes.
#
# ============================================================================ #

test_that("lm_model works with custom data frame", {
  # SETUP: Create custom test data
  # Why test this? Most users will use their own data, not dummy_df
  set.seed(123)
  custom_df <- data.frame(
    y = rnorm(50),
    x1 = rnorm(50),
    x2 = rnorm(50)
  )

  model <- lm_model(df = custom_df)

  # EXPECTATION 1: Uses custom data
  expect_equal(nrow(model$model), 50)

  # EXPECTATION 2: Uses first column as response
  expect_equal(names(model$model)[1], "y")

  # EXPECTATION 3: Model is fitted
  expect_s3_class(model, "lm")
})


test_that("lm_model works with custom data and explicit variables", {
  # SETUP: Custom data with specific variable selection
  set.seed(456)
  custom_df <- data.frame(
    outcome = rnorm(30),
    feature1 = rnorm(30),
    feature2 = rnorm(30),
    feature3 = rnorm(30)
  )

  model <- lm_model(
    df = custom_df,
    response = "outcome",
    predictors = c("feature1", "feature3") # skip feature2
  )

  # EXPECTATION 1: Correct predictors used
  expect_equal(
    names(coef(model)),
    c("(Intercept)", "feature1", "feature3")
  )

  # EXPECTATION 2: feature2 not in model
  expect_false("feature2" %in% names(coef(model)))
})


# ============================================================================ #
# SECTION 5: ERROR CASES - Invalid 'df' Argument
# ============================================================================ #
#
# These tests verify the function fails gracefully with clear error messages
# when given invalid data. Good error messages help users fix their mistakes.
#
# ============================================================================ #

test_that("lm_model errors when df is not a data frame", {
  # SETUP: Try to pass a vector instead of data frame
  # Why test this? Common mistake by beginners
  invalid_input <- c(1, 2, 3, 4, 5)

  # EXPECTATION: Function stops with informative error
  # The error message should tell user what went wrong and what's expected
  expect_error(
    lm_model(df = invalid_input),
    "must be a data frame or NULL"
  )
})


test_that("lm_model errors when df is a matrix", {
  # SETUP: Matrices are common in R, but function requires data.frame
  mat <- matrix(rnorm(20), ncol = 4)

  # EXPECTATION: Clear error message
  expect_error(
    lm_model(df = mat),
    "must be a data frame or NULL"
  )
})


test_that("lm_model errors when df has only one column", {
  # SETUP: Data frame with insufficient columns
  # Why test this? Can't fit a model without predictors
  single_col_df <- data.frame(x = 1:10)

  # EXPECTATION: Error mentions need for predictors
  expect_error(
    lm_model(df = single_col_df),
    "At least one predictor"
  )
})


test_that("lm_model errors when df has non-numeric columns", {
  # SETUP: Data frame with character or factor columns
  # Why test this? lm() requires numeric variables
  mixed_df <- data.frame(
    y = rnorm(10),
    x1 = rnorm(10),
    x2 = letters[1:10] # character column
  )

  # EXPECTATION: Error identifies non-numeric columns
  expect_error(
    lm_model(df = mixed_df),
    "must be numeric"
  )
})


# ============================================================================ #
# SECTION 6: ERROR CASES - Invalid 'response' Argument
# ============================================================================ #
#
# These tests verify proper validation of the response argument.
#
# ============================================================================ #

test_that("lm_model errors when response is not a string", {
  # SETUP: Pass numeric instead of character
  # Why test this? Column names are characters, not numbers
  expect_error(
    lm_model(response = 1),
    "must be a single character string"
  )
})


test_that("lm_model errors when response has length > 1", {
  # SETUP: Pass multiple column names as response
  # Why test this? Can only have one response variable
  expect_error(
    lm_model(response = c("a", "b")),
    "must be a single character string"
  )
})


test_that("lm_model errors when response column doesn't exist", {
  # SETUP: Specify non-existent column
  # Why test this? Common typo/mistake
  expect_error(
    lm_model(response = "nonexistent"),
    "not found in data frame"
  )

  # EXPECTATION: Error message should list available columns
  expect_error(
    lm_model(response = "xyz"),
    "Available columns"
  )
})


test_that("lm_model errors when response column is not numeric", {
  # SETUP: Data with non-numeric response
  df_with_char <- data.frame(
    outcome = letters[1:10],
    x1 = rnorm(10),
    x2 = rnorm(10)
  )

  # EXPECTATION: Clear error about numeric requirement
  expect_error(
    lm_model(df = df_with_char, response = "outcome"),
    "must be numeric"
  )
})


# ============================================================================ #
# SECTION 7: ERROR CASES - Invalid 'predictors' Argument
# ============================================================================ #
#
# These tests verify proper validation of the predictors argument.
#
# ============================================================================ #

test_that("lm_model errors when predictors is not character vector", {
  # SETUP: Pass numeric vector instead of character
  expect_error(
    lm_model(predictors = c(1, 2, 3)),
    "must be a character vector"
  )
})


test_that("lm_model errors when predictor columns don't exist", {
  # SETUP: Specify non-existent predictors
  expect_error(
    lm_model(predictors = c("nonexistent1", "nonexistent2")),
    "not found in data frame"
  )

  # EXPECTATION: Error lists which predictors are missing
  expect_error(
    lm_model(predictors = c("b", "xyz", "c")),
    "xyz"
  )
})


test_that("lm_model errors when some predictor columns are non-numeric", {
  # SETUP: Mixed numeric and character predictors
  mixed_df <- data.frame(
    y = rnorm(10),
    x1 = rnorm(10),
    x2 = letters[1:10],
    x3 = rnorm(10)
  )

  # EXPECTATION: Error identifies non-numeric predictor
  expect_error(
    lm_model(df = mixed_df, response = "y", predictors = c("x1", "x2")),
    "must be numeric"
  )
})


test_that("lm_model errors when predictors is empty after excluding response", {
  # SETUP: Only one column total, so no predictors remain
  single_col_df <- data.frame(y = rnorm(10))

  # EXPECTATION: Clear error about needing predictors
  expect_error(
    lm_model(df = single_col_df, response = "y", predictors = NULL),
    "At least one predictor"
  )
})


# ============================================================================ #
# SECTION 8: EDGE CASES
# ============================================================================ #
#
# Edge cases are unusual but valid inputs that might break naive implementations.
# Testing these ensures robustness.
#
# ============================================================================ #

test_that("lm_model handles data frames with many columns", {
  # SETUP: Large number of predictors
  # Why test this? Some functions struggle with many variables
  set.seed(789)
  n_cols <- 50
  big_df <- as.data.frame(matrix(rnorm(100 * n_cols), ncol = n_cols))

  # EXPECTATION: Function works without error
  expect_silent({
    model <- lm_model(df = big_df)
  })

  # EXPECTATION: All columns used
  expect_length(coef(model), n_cols) # intercept + (n_cols - 1) predictors
})


test_that("lm_model handles small sample sizes", {
  # SETUP: Minimum viable data (n = 3, k = 2)
  # Why test this? Edge case for degrees of freedom
  small_df <- data.frame(
    y = c(1, 2, 3),
    x = c(1, 2, 3)
  )

  # EXPECTATION: Works but will have minimal degrees of freedom
  expect_silent({
    model <- lm_model(df = small_df)
  })

  expect_equal(model$df.residual, 1)
})


test_that("lm_model handles column names with special characters", {
  # SETUP: Column names with spaces, dots, underscores
  # Why test this? Formula construction might fail with special names
  special_df <- data.frame(
    response_var = rnorm(20),
    predictor.one = rnorm(20),
    `predictor two` = rnorm(20),
    check.names = FALSE # Allow spaces in names
  )

  # EXPECTATION: Function handles special names correctly
  expect_silent({
    model <- lm_model(
      df = special_df,
      response = "response_var",
      predictors = "predictor.one"
    )
  })
})


# ============================================================================ #
# SECTION 9: RETURN VALUE VERIFICATION
# ============================================================================ #
#
# These tests verify the structure and attributes of returned objects.
#
# ============================================================================ #

test_that("lm_model returns standard lm object with expected components", {
  # SETUP: Fit a model
  model <- lm_model()

  # EXPECTATION 1: Object has standard lm components
  expect_true("coefficients" %in% names(model))
  expect_true("residuals" %in% names(model))
  expect_true("fitted.values" %in% names(model))
  expect_true("model" %in% names(model))

  # EXPECTATION 2: Can use standard lm methods
  expect_silent(summary(model))
  expect_silent(coef(model))
  expect_silent(residuals(model))
  expect_silent(fitted(model))
})


test_that("lm_model result works with predict()", {
  # SETUP: Fit model and prepare new data
  model <- lm_model(response = "a", predictors = c("b", "c"))

  new_data <- data.frame(
    b = c(10, 11),
    c = c(5, 6)
  )

  # EXPECTATION: Can make predictions
  expect_silent({
    preds <- predict(model, newdata = new_data)
  })

  # EXPECTATION: Predictions have correct length
  preds <- predict(model, newdata = new_data)
  expect_length(preds, 2)
})

# ============================================================================ #
# BEST PRACTICES DEMONSTRATED IN THIS FILE:
# ============================================================================ #
#
# 1. DESCRIPTIVE TEST NAMES
#    Each test_that() has a clear description of what's being tested
#
# 2. ORGANIZED SECTIONS
#    Tests grouped logically (success cases, error cases, edge cases)
#
# 3. SETUP-EXPECTATION PATTERN
#    Each test clearly separates setup from expectations
#
# 4. INFORMATIVE COMMENTS
#    Comments explain WHY we're testing something, not just WHAT
#
# 5. COMPREHENSIVE COVERAGE
#    - All arguments tested
#    - All error conditions tested
#    - Edge cases considered
#
# 6. SPECIFIC EXPECTATIONS
#    Use the most specific expect_* function possible
#    - expect_s3_class() instead of expect_true(inherits(...))
#    - expect_length() instead of expect_equal(length(...), ...)
#
# 7. ERROR MESSAGE TESTING
#    Check that error messages contain helpful information
#
# ============================================================================ #
# RUNNING THESE TESTS:
# ============================================================================ #
#
# Option 1 - Run all tests in package:
#   devtools::test()
#
# Option 2 - Run only this file:
#   testthat::test_file("tests/testthat/test-lm_model.R")
#
# Option 3 - Run specific test interactively:
#   Source the test file and run individual test_that() blocks
#
# Option 4 - Run tests with coverage report:
#   covr::package_coverage()
#
# ============================================================================ #
