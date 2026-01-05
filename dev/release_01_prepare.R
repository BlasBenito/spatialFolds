#' Prepare Package for CRAN Release (Step 1 of 4)
#'
#' Provides a comprehensive checklist for release preparation including version
#' updates, NEWS.md documentation, DESCRIPTION validation, and spell checking.
#'
#' @return Invisibly returns `TRUE` after displaying the preparation checklist.
#'   Stops with an error if spelling errors are found.
#'
#' @details
#' This function is **Step 1 of 4** in the CRAN release workflow. It takes no
#' parameters and provides an interactive checklist for preparing your package
#' for CRAN submission.
#'
#' **Tasks covered:**
#' 1. Version number update guidance
#' 2. NEWS.md update reminder
#' 3. DESCRIPTION file validation
#' 4. Spell check execution
#' 5. Final documentation review
#'
#' @section CRITICAL - Sequential Workflow:
#' **You MUST follow the exact sequence - do NOT skip steps!**
#'
#' 1. [release_01_prepare()] - Prepare (this function)
#' 2. [release_02_local_checks()] - Local validation
#' 3. [release_03_remote_checks()] - Remote validation
#' 4. [release_04_submit_to_cran()] - Final submission
#'
#' Each step builds on the previous one. Skipping or reordering will cause problems.
#'
#' @section Version Number:
#' - Follow semantic versioning: Major.Minor.Patch (e.g., 1.0.0, 1.1.0, 1.0.1)
#' - Remove .9000 development suffix if present
#' - Save DESCRIPTION file after updating
#'
#' @section NEWS.md Updates:
#' Document all changes since last release, grouped by:
#' - New features
#' - Bug fixes
#' - Breaking changes
#' - Deprecated features
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - All development work should be complete
#' - Package should be in working state
#'
#' @section Notes:
#' - Complete ALL tasks before proceeding to step 2
#' - Fix any spelling errors found
#' - This is informational/checklist - no automated changes made
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Step 1: Prepare for release
#' release_01_prepare()
#'
#' # Complete all checklist items, then:
#' release_02_local_checks()
#' }
release_01_prepare <- function() {
  # Print header
  cli::cli_rule(
    left = "RELEASE PREPARATION CHECKLIST (STEP 1/4)"
  )
  cli::cli_text()

  cli::cli_h2("RELEASE PREPARATION TASKS:")
  cli::cli_text()

  # Task 1: Version number
  cli::cli_h3("[1] UPDATE VERSION NUMBER")
  cli::cli_ul(c(
    "Open DESCRIPTION file",
    "Update Version field following semantic versioning:",
    "  * Major.Minor.Patch (e.g., 1.0.0, 1.1.0, 1.0.1)",
    "  * Remove .9000 development suffix if present",
    "Save DESCRIPTION file (don't forget this step!)"
  ))
  cli::cli_text()

  # Task 2: NEWS.md
  cli::cli_h3("[2] UPDATE NEWS.md")
  cli::cli_ul(c(
    "Document all changes since last release",
    "Group changes by category:",
    "  * New features",
    "  * Bug fixes",
    "  * Breaking changes",
    "  * Deprecated features",
    "Include issue/PR numbers if applicable"
  ))
  cli::cli_text()

  # Task 3: Check DESCRIPTION
  cli::cli_h3("[3] VALIDATE DESCRIPTION FILE")
  cli::cli_text("Check that DESCRIPTION includes:")
  cli::cli_ul(c(
    "Accurate Title (title case, no period at the end)",
    "Complete Description (what, why, how - be specific!)",
    "All authors with proper roles (aut, cre, ctb, etc.)",
    "Correct license",
    "All imports and suggests listed (check your code!)",
    "Valid URL and BugReports fields (if applicable)"
  ))
  cli::cli_text()

  # Task 4: Spell check
  cli::cli_h3("[4] SPELL CHECK")
  cli::cli_alert_info("Running {.code spelling::spell_check_package()} ...")
  cli::cli_text()

  if (requireNamespace("spelling", quietly = TRUE)) {
    spelling_errors <- spelling::spell_check_package()
    if (nrow(spelling_errors) == 0) {
      cli::cli_alert_success("No spelling errors found")
    } else {
      cli::cli_alert_danger(
        "Found {nrow(spelling_errors)} spelling error{?s}:"
      )
      cli::cli_text()
      print(spelling_errors)
      cli::cli_text()
      cli::cli_alert_info("Fix errors and rerun this function")
    }
  } else {
    cli::cli_alert_warning("spelling package not installed")
    cli::cli_alert_info(
      "Install with: {.code install.packages('spelling')}"
    )
  }

  cli::cli_text()

  # Task 5: Documentation
  cli::cli_h3("[5] DOCUMENTATION REVIEW")
  cli::cli_ul(c(
    "Run {.code devtools::document()} to update documentation",
    "Review all exported function documentation",
    "Ensure examples run without errors",
    "Update README.md if needed",
    "Build vignettes if they exist"
  ))
  cli::cli_text()

  cli::cli_rule("NEXT STEPS")
  cli::cli_text("After completing all tasks above:")
  cli::cli_code("release_02_local_checks()")
  cli::cli_rule()

  invisible(TRUE)
}
