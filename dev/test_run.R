#' Run All Package Tests
#'
#' Runs the complete test suite using testthat. Optionally clears the console
#' before running tests for a clean output.
#'
#' @param clear_console Logical. Clear console before running tests? Default `TRUE`.
#'   Set to `FALSE` to preserve previous console output (useful when you want
#'   to review previous messages or compare results).
#'
#' @return Test results from `devtools::test()`, returned invisibly.
#'
#' @details
#' This function provides a quick way to run your entire test suite during
#' development. It performs the following steps:
#'
#' 1. Checks for and installs devtools if needed
#' 2. Optionally clears the console for clean output (default)
#' 3. Runs all tests using `devtools::test()`
#' 4. Reports total execution time
#'
#' The `clear_console` parameter allows you to choose between a clean slate
#' (default, good for quick iterations) or preserving previous output (useful
#' when comparing results or reviewing earlier messages).
#'
#' @section Typical Runtime:
#' 5-30 seconds depending on number and complexity of tests
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - Tests must exist in tests/testthat/ directory
#' - devtools package will be installed if missing
#'
#' @section Notes:
#' - Default behavior (`clear_console = TRUE`) matches quick development workflow
#' - Use `clear_console = FALSE` when you need to review previous console output
#' - Tests run with testthat edition 3 features if configured
#' - Output shows test results in real-time
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Clear console and run tests (default - good for quick iterations)
#' test_run()
#'
#' # Preserve previous console output (useful when comparing results)
#' test_run(clear_console = FALSE)
#'
#' # Typical development workflow:
#' # 1. Make code changes
#' # 2. Run test_run() to verify
#' # 3. Iterate quickly with clean console each time
#' }
test_run <- function(clear_console = TRUE) {
  # Check dependencies
  if (!requireNamespace("devtools", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg devtools}")
    utils::install.packages("devtools")
  }

  # Clear console if requested (default matches quick workflow)
  if (clear_console) {
    cat("\014")
  }

  # Print header
  cli::cli_rule(left = "RUN ALL TESTS")
  cli::cli_text()

  # Run tests
  cli::cli_alert_info("Running {.code devtools::test()} ...")
  cli::cli_text()

  start_time <- Sys.time()
  result <- devtools::test()

  # Calculate timing
  total_time <- difftime(Sys.time(), start_time, units = "secs")

  cli::cli_text()
  cli::cli_rule("TESTS COMPLETE")
  cli::cli_alert_success("Total time: {round(total_time, 1)} seconds")
  cli::cli_rule()

  invisible(result)
}
