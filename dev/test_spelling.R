#' Check Package Documentation for Spelling Errors
#'
#' Scans all package documentation for spelling errors and reports potential
#' issues. Valid technical terms can be added to the package-specific dictionary.
#'
#' @return A data frame of spelling errors from `spelling::spell_check_package()`,
#'   returned invisibly. Contains columns "word" and "found" (character vectors)
#'   indicating misspelled words and where they were found. Returns zero rows if
#'   no errors found.
#'
#' @details
#' This function checks spelling across all documentation sources in your
#' package. It performs the following steps:
#'
#' 1. Checks for required dependencies (installs if needed)
#' 2. Scans all documentation files (.Rd files, vignettes, README)
#' 3. Checks spelling against package dictionary
#' 4. Reports potential spelling errors with file locations
#' 5. Suggests words to add to WORDLIST
#'
#' The spell checker uses `inst/WORDLIST` for package-specific terms that
#' are valid but not in the standard dictionary.
#'
#' @section Adding Valid Words:
#' To add valid words to the package dictionary:
#'
#' 1. Open `inst/WORDLIST`
#' 2. Add one word per line (case-sensitive)
#' 3. Save and rerun `test_spelling()`
#'
#' Or use: `spelling::update_wordlist()` to automatically add flagged words
#'
#' @section Common Valid Words to Add:
#' - Technical terms and jargon
#' - Package names (e.g., "devtools", "testthat")
#' - Function names (e.g., "load_all", "roxygen2")
#' - Author names and institutions
#' - Acronyms and abbreviations
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - `inst/WORDLIST` file should exist (create with `usethis::use_spell_check()`)
#'
#' @section Notes:
#' - CRAN submission requires clean spell check
#' - Function names may be flagged as errors
#' - Package-specific jargon will need to be added to WORDLIST
#' - Rerun after adding words to verify all errors resolved
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Check spelling
#' test_spelling()
#'
#' # If errors found, add valid words to inst/WORDLIST
#' # Or use automatic update:
#' spelling::update_wordlist()
#'
#' # Rerun to verify
#' test_spelling()
#' }
test_spelling <- function() {
  # Check and install dependencies
  if (!requireNamespace("spelling", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg spelling}")
    utils::install.packages("spelling")
  }

  # Print header
  cli::cli_rule(
    left = "SPELL CHECK"
  )
  cli::cli_text()

  # Run spell check
  cli::cli_alert_info("Running {.code spelling::spell_check_package()} ...")
  cli::cli_text()

  spelling_errors <- spelling::spell_check_package()

  # Print results
  if (nrow(spelling_errors) == 0) {
    cli::cli_text()
    cli::cli_rule("NO SPELLING ERRORS FOUND")
    cli::cli_alert_success("All documentation passed spell check")
    cli::cli_rule()
  } else {
    cli::cli_text()
    cli::cli_rule("SPELLING ERRORS DETECTED")
    cli::cli_alert_danger(
      "Found {nrow(spelling_errors)} potential spelling error{?s}"
    )
    cli::cli_rule()
    cli::cli_text()

    print(spelling_errors)

    cli::cli_text()
    cli::cli_h3("To add valid words to the dictionary:")
    cli::cli_ol(c(
      "Open {.file inst/WORDLIST}",
      "Add one word per line",
      "Save and rerun {.code test_spelling()}"
    ))
    cli::cli_text()
    cli::cli_alert_info(
      "Or update WORDLIST automatically: {.code spelling::update_wordlist()}"
    )
    cli::cli_rule()
  }

  invisible(spelling_errors)
}
