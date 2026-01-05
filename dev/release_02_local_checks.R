#' Run Local Validation Checks for CRAN Release (Step 2 of 4)
#'
#' Runs comprehensive local validation including R CMD check and best practices
#' analysis. All checks must pass before proceeding to remote validation.
#'
#' @return A list containing check results (`check` and `gp`), returned invisibly.
#'   Stops with an error if required packages are not installed.
#'
#' @details
#' This function is **Step 2 of 4** in the CRAN release workflow. It takes no
#' parameters and runs comprehensive local validation checks.
#'
#' **Checks performed:**
#' 1. `devtools::check()` - Full R CMD check
#' 2. `goodpractice::gp()` - Best practices analysis
#'
#' Both checks provide detailed output and timing information.
#'
#' @section CRITICAL - Sequential Workflow:
#' **PREREQUISITE: Must complete [release_01_prepare()] first!**
#'
#' 1. [release_01_prepare()] - Prepare
#' 2. **[release_02_local_checks()]** - Local validation (this function)
#' 3. [release_03_remote_checks()] - Remote validation
#' 4. [release_04_submit_to_cran()] - Final submission
#'
#' @section Passing Criteria:
#' **ALL checks must pass before proceeding:**
#' - 0 errors
#' - 0 warnings
#' - 0 notes
#'
#' If checks fail, fix issues and rerun until all pass.
#'
#' @section Performance:
#' - Typical runtime: 2-5 minutes
#' - Time increases with package size
#' - Good practice analysis may take longer
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - Release preparation (step 1) must be complete
#' - Package must be in buildable state
#'
#' @section Notes:
#' - Do NOT skip to step 3 if checks fail
#' - Fix all issues before proceeding
#' - Review good practice recommendations
#' - Some recommendations are optional
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Step 2: Run local validation
#' release_02_local_checks()
#'
#' # If all checks pass:
#' release_03_remote_checks()
#'
#' # If checks fail, fix issues and rerun:
#' release_02_local_checks()
#' }
release_02_local_checks <- function() {
  # Check and install dependencies
  if (!requireNamespace("devtools", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg devtools}")
    utils::install.packages("devtools")
  }

  if (!requireNamespace("goodpractice", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg goodpractice}")
    utils::install.packages("goodpractice")
  }

  # Print header
  cli::cli_rule(
    left = "LOCAL VALIDATION CHECKS (STEP 2/4)"
  )
  cli::cli_text()

  cli::cli_alert_info("Running comprehensive local checks...")
  cli::cli_alert_info("This may take 2-5 minutes")
  cli::cli_text()

  overall_start <- Sys.time()

  # Check 1: R CMD check
  cli::cli_h2("CHECK 1/2: R CMD CHECK")
  cli::cli_text()
  cli::cli_alert_info("Running {.code devtools::check()} ...")
  cli::cli_text()
  check_start <- Sys.time()

  check_result <- devtools::check()

  check_time <- difftime(Sys.time(), check_start, units = "secs")

  cli::cli_text()
  cli::cli_alert_success(
    "R CMD check completed in {round(check_time, 1)} seconds"
  )
  cli::cli_text()
  cli::cli_text(
    "  Errors:   {length(check_result$errors)} {ifelse(length(check_result$errors) == 0, '[OK]', '[FAIL]')}"
  )
  cli::cli_text(
    "  Warnings: {length(check_result$warnings)} {ifelse(length(check_result$warnings) == 0, '[OK]', '[FAIL]')}"
  )
  cli::cli_text(
    "  Notes:    {length(check_result$notes)} {ifelse(length(check_result$notes) == 0, '[OK]', '[FAIL]')}"
  )

  check_passed <- (length(check_result$errors) == 0 &&
    length(check_result$warnings) == 0 &&
    length(check_result$notes) == 0)

  # Check 2: Good practice
  cli::cli_text()
  cli::cli_h2("CHECK 2/2: GOOD PRACTICE ANALYSIS")
  cli::cli_text()
  cli::cli_alert_info("Running {.code goodpractice::gp(quiet = TRUE)} ...")
  cli::cli_text()
  gp_start <- Sys.time()

  gp_result <- goodpractice::gp(quiet = TRUE)

  gp_time <- difftime(Sys.time(), gp_start, units = "secs")

  cli::cli_text()
  cli::cli_alert_success(
    "Good practice analysis completed in {round(gp_time, 1)} seconds"
  )
  cli::cli_text()
  print(gp_result)

  # Final summary
  total_time <- difftime(Sys.time(), overall_start, units = "secs")

  cli::cli_text()
  cli::cli_rule("LOCAL CHECKS COMPLETE")
  cli::cli_alert_success(
    "Total time: {round(total_time, 1)} seconds"
  )
  cli::cli_text()

  if (check_passed) {
    cli::cli_alert_success(
      "R CMD CHECK PASSED - Ready for remote checks"
    )
    cli::cli_text()
    cli::cli_h3("NEXT STEPS:")
    cli::cli_ul(c(
      "Review good practice recommendations above",
      "Address any critical issues",
      "Then run: {.code release_03_remote_checks()}"
    ))
  } else {
    cli::cli_alert_danger(
      "R CMD CHECK FAILED - Fix issues before proceeding"
    )
    cli::cli_text()
    cli::cli_alert_warning("DO NOT PROCEED TO REMOTE CHECKS")
    cli::cli_ol(c(
      "Fix all errors, warnings, and notes",
      "Rerun this function",
      "Ensure all checks pass"
    ))
  }

  cli::cli_rule()

  invisible(list(check = check_result, gp = gp_result))
}
