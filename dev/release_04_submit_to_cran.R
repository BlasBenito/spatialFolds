#' Submit Package to CRAN (Step 4 of 4 - FINAL)
#'
#' Final step in CRAN release workflow. Displays pre-submission checklist,
#' confirms readiness, and initiates CRAN submission via `devtools::release()`.
#'
#' @return Result from `devtools::release()`, returned invisibly.
#'
#' @details
#' This function is **Step 4 of 4 (FINAL)** in the CRAN release workflow. It
#' takes no parameters and guides you through the final CRAN submission.
#'
#' **This is the point of no return - you're actually submitting to CRAN!**
#'
#' **Actions performed:**
#' 1. Displays final pre-submission checklist
#' 2. Confirms you're ready to submit
#' 3. Initiates CRAN submission via `devtools::release()`
#' 4. Provides post-submission instructions
#'
#' @section CRITICAL - Sequential Workflow:
#' **PREREQUISITE: Must have passed ALL previous steps (01, 02, 03)!**
#'
#' 1. [release_01_prepare()] - Prepare
#' 2. [release_02_local_checks()] - Local validation
#' 3. [release_03_remote_checks()] - Remote validation
#' 4. **[release_04_submit_to_cran()]** - Final submission (this function)
#'
#' @section Pre-Submission Checklist:
#' Before submitting, confirm:
#' - Local R CMD check passed (0/0/0)
#' - Windows R-devel check passed
#' - macOS R-release check passed
#' - Version number updated in DESCRIPTION
#' - NEWS.md updated with all changes
#' - All documentation is current
#' - All code committed to version control
#' - Good practice recommendations reviewed
#' - Spelling check passed
#' - Package website updated (if using pkgdown)
#'
#' @section What Happens:
#' - `devtools::release()` is interactive
#' - Answer all questions honestly
#' - You will receive email confirmation from CRAN
#' - First submissions may take 1-2 weeks for review
#' - Updates usually processed within 1-3 days
#'
#' @section After Submission:
#' 1. Watch for confirmation email from CRAN
#' 2. Respond to any CRAN requests promptly
#' 3. Tag the release in version control
#' 4. Update package website
#' 5. Announce release
#' 6. Start development version (increment version, add .9000)
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - ALL previous steps (01-03) must be complete
#' - Remote check results must be passing
#'
#' @section Notes:
#' - Read all prompts carefully - this submits to CRAN!
#' - CRAN may request changes before acceptance
#' - Be responsive and professional in communications
#' - Re-submission window is typically 2-4 weeks
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Step 4: Final submission to CRAN
#' release_04_submit_to_cran()
#'
#' # Follow interactive prompts
#' # After submission, tag the release:
#' # git tag -a v1.0.0 -m "Release 1.0.0"
#' # git push --tags
#' }
release_04_submit_to_cran <- function() {
  # Check and install dependencies
  if (!requireNamespace("devtools", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg devtools}")
    utils::install.packages("devtools")
  }

  # Print header
  cli::cli_rule(
    left = "SUBMIT TO CRAN (STEP 4/4 - FINAL)"
  )
  cli::cli_text()

  cli::cli_h2("FINAL PRE-SUBMISSION CHECKLIST")
  cli::cli_text()

  cli::cli_text("Before submitting, confirm that:")
  cli::cli_text()

  cli::cli_ul(c(
    "[ ] Local R CMD check passed (0 errors, 0 warnings, 0 notes)",
    "[ ] Windows R-devel check passed",
    "[ ] macOS R-release check passed",
    "[ ] Version number updated in DESCRIPTION",
    "[ ] NEWS.md updated with all changes",
    "[ ] All documentation is current",
    "[ ] All code committed to version control",
    "[ ] Good practice recommendations reviewed",
    "[ ] Spelling check passed",
    "[ ] Package website updated (if using pkgdown)"
  ))
  cli::cli_text()

  cli::cli_h2("IMPORTANT REMINDERS")
  cli::cli_ul(c(
    "First submissions may require manual CRAN review",
    "CRAN may request changes before acceptance",
    "Respond to CRAN emails promptly",
    "Be polite and professional in all communications",
    "Re-submission window is typically 2-4 weeks"
  ))
  cli::cli_text()

  cli::cli_rule()
  cli::cli_text()

  if (interactive()) {
    cli::cli_alert_warning("Are you ready to submit to CRAN?")
    response <- readline("Type 'yes' to proceed, or anything else to cancel: ")

    if (tolower(trimws(response)) != "yes") {
      cli::cli_text()
      cli::cli_alert_info("Submission cancelled")
      cli::cli_text("Review checklist and rerun when ready")
      cli::cli_rule()
      return(invisible(FALSE))
    }
  } else {
    cli::cli_alert_info("Running in non-interactive mode")
    cli::cli_alert_warning(
      "IMPORTANT: Review the checklist above carefully before proceeding!"
    )
    cli::cli_alert_info("Proceeding with CRAN submission...")
    cli::cli_text()
  }

  cli::cli_text()
  cli::cli_rule("INITIATING CRAN SUBMISSION")
  cli::cli_text()

  cli::cli_alert_info("Running {.code devtools::release()} ...")
  cli::cli_alert_info("Follow the interactive prompts carefully")
  cli::cli_text()

  # Run release
  result <- devtools::release()

  cli::cli_text()
  cli::cli_rule("POST-SUBMISSION STEPS")
  cli::cli_text()

  cli::cli_h2("WHAT TO DO NOW:")
  cli::cli_ol(c(
    "Watch for confirmation email from CRAN",
    "Respond to any CRAN requests promptly",
    "Tag the release in version control:",
    "    git tag -a vX.Y.Z -m 'Release X.Y.Z'",
    "    git push --tags",
    "Update package website if using pkgdown",
    "Announce release (Twitter, blog, mailing list, etc.)",
    "Start development version:",
    "    - Increment version in DESCRIPTION (add .9000)",
    "    - Add new section to NEWS.md"
  ))
  cli::cli_text()

  cli::cli_h2("IF CRAN REQUESTS CHANGES:")
  cli::cli_ol(c(
    "Make requested changes",
    "Restart release process from step 1",
    "Re-submit within the allowed window (typically 2-4 weeks)"
  ))
  cli::cli_text()

  cli::cli_alert_success("CONGRATULATIONS on submitting to CRAN!")
  cli::cli_rule()

  invisible(result)
}
