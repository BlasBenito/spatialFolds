#' Full package check with tests and examples
#'
#' Comprehensive R CMD check including tests and examples. Use this for
#' thorough validation before commits, releases, or when you need complete
#' package verification.
#'
#' @return Invisibly returns the check results object from \code{devtools::check()}.
#'
#' @details
#' This function performs a complete package check:
#' \enumerate{
#'   \item Runs \code{devtools::document()} twice to ensure NAMESPACE changes
#'         are properly handled
#'   \item Runs full R CMD check with all tests and examples
#'   \item Reports errors, warnings, and notes
#' }
#'
#' This check validates:
#' \itemize{
#'   \item Package structure and metadata (DESCRIPTION)
#'   \item Documentation completeness and formatting
#'   \item Code syntax and quality checks
#'   \item NAMESPACE consistency
#'   \item All test suites (testthat, etc.)
#'   \item All documentation examples
#'   \item File organization and permissions
#' }
#'
#' @section When to use:
#' \itemize{
#'   \item Before committing significant changes
#'   \item Before pushing to remote repository
#'   \item Before creating a release
#'   \item When you need complete package validation
#'   \item After modifying tests or examples
#' }
#'
#' For faster checks during active development, use \code{check()}.
#'
#' @section Performance:
#' This check can take significantly longer than \code{check()} depending
#' on the size of your test suite and number of examples. Typical runtime:
#' 1-5 minutes for packages with comprehensive tests.
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' dev_check_complete()
#' }
dev_check_complete <- function() {
  # Check prerequisites
  if (!requireNamespace("devtools", quietly = TRUE)) {
    utils::install.packages('devtools')
  }

  if (!requireNamespace("cli", quietly = TRUE)) {
    utils::install.packages('cli')
  }

  # Print header
  cli::cli_rule(center = "FULL PACKAGE CHECK")
  cli::cli_text("")
  cli::cli_alert_info("Complete check: including tests and examples")
  cli::cli_text("")

  # Step 1: Document (twice for NAMESPACE handling)
  cli::cli_h2("STEP 1: Documenting package")
  cli::cli_text("")

  cli::cli_alert_info("Running {.code devtools::document()} (1st pass) ...")
  devtools::document()
  cli::cli_text("")

  cli::cli_alert_info(
    "Running {.code devtools::document()} (2nd pass for NAMESPACE) ..."
  )
  devtools::document()
  cli::cli_text("")

  cli::cli_alert_success("Documentation complete")
  cli::cli_text("")

  # Step 2: Full check (with tests and examples)
  cli::cli_h2("STEP 2: Running R CMD check")
  cli::cli_text("")

  cli::cli_alert_info("Running {.code devtools::check()} with CRAN=TRUE ...")
  cli::cli_text("")

  result <- devtools::check(
    document = FALSE # Already documented above
  )

  # Print summary
  cli::cli_text("")
  cli::cli_rule(center = "CHECK COMPLETE")
  cli::cli_text("")

  # Show results with appropriate styling
  if (length(result$errors) == 0) {
    cli::cli_alert_success("Errors:   {length(result$errors)}")
  } else {
    cli::cli_alert_danger("Errors:   {length(result$errors)}")
  }

  if (length(result$warnings) == 0) {
    cli::cli_alert_success("Warnings: {length(result$warnings)}")
  } else {
    cli::cli_alert_warning("Warnings: {length(result$warnings)}")
  }

  if (length(result$notes) == 0) {
    cli::cli_alert_success("Notes:    {length(result$notes)}")
  } else {
    cli::cli_alert_info("Notes:    {length(result$notes)}")
  }

  cli::cli_text("")

  # Provide guidance
  if (length(result$errors) > 0 || length(result$warnings) > 0) {
    cli::cli_alert_danger("Must fix errors and warnings before release!")
    cli::cli_text("")
  } else if (length(result$notes) > 0) {
    cli::cli_alert_info("Review notes - some may be acceptable for CRAN")
    cli::cli_text("")
  } else {
    cli::cli_alert_success("Perfect! Package passes all checks")
    cli::cli_text("")
    cli::cli_text("Ready for commit/release (0 errors, 0 warnings, 0 notes)")
    cli::cli_text("")
  }

  cli::cli_rule()

  invisible(result)
}
