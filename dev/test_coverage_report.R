#' Run Tests with Code Coverage Analysis
#'
#' Runs all package tests and generates an interactive HTML coverage report
#' showing which lines of code are tested and which are not.
#'
#' @return A coverage object from `covr::package_coverage()` (class "coverage"),
#'   returned invisibly. Contains coverage statistics for each source file and
#'   function in the package.
#'
#' @details
#' This function combines test execution with coverage analysis to identify
#' untested code. It performs the following steps:
#'
#' 1. Checks for required dependencies (installs if needed)
#' 2. Runs all package tests
#' 3. Calculates code coverage for each file
#' 4. Generates interactive HTML coverage report
#' 5. Opens report in web browser
#' 6. Highlights untested code lines in red
#'
#' The interactive report allows you to click through files and see exactly
#' which lines are covered by tests (green) and which are not (red).
#'
#' @section Coverage Goals:
#' - Aim for greater than 80% overall coverage
#' - Focus on covering critical functionality first
#' - Some code may be difficult to test (error handlers, edge cases)
#' - CRAN doesn't require specific coverage percentage
#'
#' @section Performance:
#' - Takes longer than a regular test run (tests executed twice)
#' - Typical runtime: 10-30 seconds for small packages
#' - Time increases with package size and test complexity
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - `tests/testthat/` directory must exist
#' - Package must use testthat for testing
#'
#' @section Understanding the Report:
#' - Green highlighting shows covered code (tested)
#' - Red highlighting shows uncovered code (not tested)
#' - Percentage shown for each file and overall
#' - Click file names to see line-by-line coverage
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Generate coverage report
#' test_coverage_report()
#'
#' # Review the interactive HTML report that opens
#' # Identify red (untested) code
#' # Write tests for uncovered functionality
#' # Rerun to verify improvement
#' }
test_coverage_report <- function() {
  # Check and install dependencies
  if (!requireNamespace("covr", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg covr}")
    utils::install.packages("covr")
  }

  # Print header
  cli::cli_rule(
    left = "TEST WITH COVERAGE ANALYSIS"
  )
  cli::cli_text()

  # Run coverage
  cli::cli_alert_info("Running {.code covr::package_coverage()} ...")
  cli::cli_alert_info(
    "This may take a moment as all tests are executed twice"
  )
  cli::cli_text()

  start_time <- Sys.time()

  coverage <- covr::package_coverage()

  # Show coverage summary
  print(coverage)

  # Calculate total coverage
  total_coverage <- covr::percent_coverage(coverage)

  cli::cli_text()
  cli::cli_rule("COVERAGE RESULTS")
  cli::cli_alert_success(
    "Overall coverage: {round(total_coverage, 1)}%"
  )
  cli::cli_rule()

  # Generate interactive report
  cli::cli_text()
  cli::cli_alert_info(
    "Running {.code covr::report()} to generate HTML report ..."
  )

  covr::report(coverage)

  total_time <- difftime(Sys.time(), start_time, units = "secs")

  cli::cli_text()
  cli::cli_alert_success(
    "Total time: {round(total_time, 1)} seconds"
  )
  cli::cli_text()
  cli::cli_alert_info(
    "Interactive coverage report should open in your browser"
  )
  cli::cli_alert_info(
    "Red lines indicate untested code"
  )
  cli::cli_rule()

  invisible(coverage)
}
