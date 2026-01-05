#' Quick package check for development
#'
#' Quick R CMD check optimized for rapid development iteration. Skips tests
#' and examples for maximum speed while still validating package structure,
#' documentation, and code quality.
#'
#' @return Invisibly returns the check results object from \code{devtools::dev_check_quick()}.
#'
#' @details
#' This function performs a streamlined package check designed for frequent use
#' during active development:
#' \enumerate{
#'   \item Runs \code{devtools::document()} twice to ensure NAMESPACE changes
#'         are properly handled
#'   \item Runs R CMD check with \code{--no-tests} and \code{--no-examples}
#'         flags for maximum speed
#'   \item Reports errors, warnings, and notes
#' }
#'
#' This check validates:
#' \itemize{
#'   \item Package structure and metadata (DESCRIPTION)
#'   \item Documentation completeness and formatting
#'   \item Code syntax and basic quality checks
#'   \item NAMESPACE consistency
#'   \item File organization and permissions
#' }
#'
#' This check skips:
#' \itemize{
#'   \item Running tests (use \code{check_full()} or \code{devtools::test()})
#'   \item Running examples (use \code{check_full()} for full validation)
#' }
#'
#' @section When to use:
#' \itemize{
#'   \item During active development (run frequently)
#'   \item After modifying documentation
#'   \item Before committing changes (quick validation)
#'   \item When tests are time-consuming
#' }
#'
#' For comprehensive checking including tests and examples, use \code{check_full()}.
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' dev_check_quick()
#' }
dev_check_quick <- function() {
  # Check prerequisites
  if (!requireNamespace("devtools", quietly = TRUE)) {
    utils::install.packages('devtools')
  }

  if (!requireNamespace("cli", quietly = TRUE)) {
    utils::install.packages('cli')
  }

  # Print header
  cli::cli_rule(center = "FAST PACKAGE CHECK")
  cli::cli_text("")
  cli::cli_alert_info("Quick check: skipping tests and examples for speed")
  cli::cli_text("")

  # Step 1: Document (twice for NAMESPACE handling)
  cli::cli_h2("STEP 1: Documenting package")
  cli::cli_text("")

  cli::cli_alert_info("Running {.code devtools::document()} ...")
  devtools::document()
  cli::cli_text("")

  cli::cli_alert_success("Documentation complete")
  cli::cli_text("")

  # Step 2: Check (without tests and examples)
  cli::cli_h2("STEP 2: Running R CMD check")
  cli::cli_text("")

  cli::cli_alert_info(
    "Running {.code devtools::check(args = c('--no-tests', '--no-examples'))} ..."
  )
  cli::cli_text("")

  result <- devtools::check(
    document = FALSE, # Already documented above
    args = c("--no-tests", "--no-examples")
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
    cli::cli_alert_warning("Fix errors and warnings before committing!")
    cli::cli_text("")
  } else if (length(result$notes) > 0) {
    cli::cli_alert_info("Review notes - some may be acceptable")
    cli::cli_text("")
  } else {
    cli::cli_alert_success("Perfect! Package structure looks good")
    cli::cli_text("")
    cli::cli_text(
      "Run {.code check_full()} to verify tests and examples before release."
    )
    cli::cli_text("")
  }

  cli::cli_rule()

  invisible(result)
}
