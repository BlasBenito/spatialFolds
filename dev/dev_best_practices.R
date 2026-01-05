#' Analyze Package for R Best Practices
#'
#' Runs comprehensive analysis to check adherence to R package development
#' best practices using the goodpractice package.
#'
#' @return A goodpractice object containing analysis results, returned invisibly.
#'   Contains recommendations categorized by type (error, warning, note).
#'
#' @details
#' This function provides opinionated analysis that goes beyond standard R CMD check.
#' It performs the following steps:
#'
#' 1. Checks for required dependencies (installs if needed)
#' 2. Analyzes package structure and code quality
#' 3. Checks coding style and conventions
#' 4. Validates documentation completeness
#' 5. Reviews function complexity
#' 6. Checks for common anti-patterns
#' 7. Provides actionable recommendations
#'
#' @section Types of Checks Performed:
#' - Code style issues (formatting, naming conventions)
#' - Documentation gaps (missing or incomplete docs)
#' - Complexity warnings (overly complex functions)
#' - Best practice violations (deprecated patterns)
#' - Dependency issues (missing or unnecessary)
#'
#' @section Interpreting Results:
#' - Recommendations are more opinionated than R CMD check
#' - Not all suggestions are mandatory for CRAN
#' - Use judgment to decide which to implement
#' - Focus on errors and warnings first
#' - Notes are suggestions for improvement
#'
#' @section Performance:
#' - Typical runtime: 1-3 minutes
#' - Time increases with package size
#' - Runs more checks than basic R CMD check
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - Package should be in buildable state
#' - Local R CMD check should pass first
#'
#' @section Notes:
#' - Recommended to run before CRAN submission
#' - Can help catch issues before review
#' - Useful for improving overall code quality
#' - Results help maintain consistent code style
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' dev_best_practices()
#' }
dev_best_practices <- function() {
  # Check and install dependencies
  if (!requireNamespace("goodpractice", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg goodpractice}")
    utils::install.packages("goodpractice")
  }

  # Print header
  cli::cli_rule(
    left = "GOOD PRACTICE ANALYSIS"
  )
  cli::cli_text()

  # Run analysis
  cli::cli_alert_info("Running {.code goodpractice::gp()} ...")
  cli::cli_alert_info("This may take 1-3 minutes")
  cli::cli_text()

  gp_result <- goodpractice::gp()

  # Print results
  print(gp_result)

  cli::cli_alert_info(
    "Not all suggestions are mandatory, but consider each one"
  )
  cli::cli_alert_info(
    "Address critical issues before CRAN submission"
  )
  cli::cli_rule()

  invisible(gp_result)
}
