#' Create Example Dataset Template
#'
#' Demonstrates how to create and save example datasets for your R package.
#' This is a TEMPLATE function that creates the `dummy_df` dataset as an example.
#'
#' @return Logical value `TRUE`, returned invisibly, on successful dataset creation.
#'
#' @details
#' **IMPORTANT: This is a TEMPLATE function - customize it for your data!**
#'
#' This function demonstrates the complete workflow for creating package datasets:
#'
#' 1. Generates or loads your data
#' 2. Cleans and formats the data appropriately
#' 3. Saves it using `usethis::use_data()`
#' 4. Shows how to document it in R/data.R
#' 5. Verifies the dataset with example usage
#'
#' The function creates the `dummy_df` dataset as a working example. To create
#' your own dataset, modify the data generation code to match your needs.
#'
#' @section Files Created:
#' - `data/dummy_df.rda` - The actual dataset file
#' - Documentation should be added to `R/data.R`
#' - Help file generated via `devtools::document()` creates `man/dummy_df.Rd`
#'
#' @section Best Practices:
#' - Use `set.seed()` for reproducibility with random data
#' - Keep datasets reasonably small (<1 MB recommended)
#' - Use `compress = "xz"` for better compression
#' - Use `overwrite = TRUE` when updating existing datasets
#' - Document all variables clearly in R/data.R
#' - Include data source and generation method
#'
#' @section Data Sources:
#' Your data can come from:
#' - Generated synthetically (as in this example)
#' - Loaded from CSV: `read.csv("path/to/data.csv")`
#' - Built-in datasets: `data(mtcars)`
#' - Other packages: `package::dataset`
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - usethis package will be installed if missing
#'
#' @section Notes:
#' - This template creates the `dummy_df` dataset
#' - Modify the generation code for your own data
#' - Always document datasets in R/data.R
#' - Run `devtools::document()` after creating data
#' - Commit both .rda file and documentation
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Create the example dataset
#' template_create_dataset()
#'
#' # After running:
#' # 1. Review data/dummy_df.rda
#' # 2. Document in R/data.R
#' # 3. Run devtools::document()
#' # 4. Test with data(dummy_df)
#' }
template_create_dataset <- function() {
  # Check and install dependencies
  if (!requireNamespace("usethis", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg usethis}")
    utils::install.packages("usethis")
  }

  # Print header
  cli::cli_rule(
    left = "CREATE EXAMPLE DATASET"
  )
  cli::cli_text()

  cli::cli_alert_info("Creating example dataset: {.code dummy_df}")
  cli::cli_text()

  # Set seed for reproducibility
  set.seed(42)

  cli::cli_h3("STEP 1: Generate the data")

  # Number of observations
  n <- 1000
  cli::cli_text("Observations: {n}")

  # Generate predictor variables
  b <- rnorm(n, mean = 10, sd = 2)
  c <- rnorm(n, mean = 5, sd = 1.5)
  d <- rnorm(n, mean = 15, sd = 3)
  e <- rnorm(n, mean = 20, sd = 2.5)
  f <- rnorm(n, mean = 8, sd = 1)
  g <- rnorm(n, mean = 12, sd = 2)
  h <- rnorm(n, mean = 6, sd = 1.2)
  i <- rnorm(n, mean = 18, sd = 3.5)
  j <- rnorm(n, mean = 25, sd = 4)

  # Generate response variable
  a <- 2 +
    0.5 * b +
    1.2 * c -
    0.3 * d +
    0.8 * e +
    0.4 * f -
    0.6 * g +
    1.1 * h +
    0.2 * i -
    0.5 * j +
    rnorm(n, mean = 0, sd = 2)

  cli::cli_alert_success("Data generated")
  cli::cli_text()

  cli::cli_h3("STEP 2: Create data structure")

  # Create dataframe
  dummy_df <- data.frame(
    a = a, # Response variable
    b = b, # Predictor variables
    c = c,
    d = d,
    e = e,
    f = f,
    g = g,
    h = h,
    i = i,
    j = j
  )

  cli::cli_alert_success(
    "Data frame created: {nrow(dummy_df)} rows x {ncol(dummy_df)} columns"
  )
  cli::cli_text()

  cli::cli_h3("STEP 3: Save to package")

  # Save to package data directory
  cli::cli_alert_info("Running {.code usethis::use_data()} ...")
  usethis::use_data(dummy_df, overwrite = TRUE, compress = "xz")

  cli::cli_text()

  cli::cli_h3("STEP 4: Verify dataset")

  # Example usage
  cli::cli_text("Example linear model:")
  cli::cli_text()
  model <- lm(a ~ ., data = dummy_df)
  print(summary(model))

  cli::cli_text()
  cli::cli_rule("DATASET CREATION COMPLETE")
  cli::cli_text()

  cli::cli_h3("NEXT STEPS:")
  cli::cli_ol(c(
    "Document the dataset in {.file R/data.R} with roxygen2 comments",
    "Run {.code devtools::document()} to generate {.file man/dummy_df.Rd}",
    "Test that users can access: {.code data(dummy_df)} and {.code ?dummy_df}",
    "Consider adding dataset to function examples",
    "Commit both {.file data/dummy_df.rda} and documentation"
  ))
  cli::cli_text()

  cli::cli_h3("TO CREATE YOUR OWN DATASET:")
  cli::cli_ul(c(
    "Modify the data generation code above",
    "Change variable names and relationships",
    "Use {.code read.csv()} to load external data",
    "Adjust documentation in {.file R/data.R}",
    "Keep datasets small (<1 MB) for package size"
  ))
  cli::cli_rule()

  invisible(TRUE)
}
