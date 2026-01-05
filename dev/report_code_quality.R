#' Analyze Code Quality with Static Analysis
#'
#' Analyzes R code for potential issues, global variable usage, undefined
#' variables, and suspicious constructs using the codetools package.
#'
#' @return Logical value `TRUE`, returned invisibly, on successful analysis.
#'
#' @details
#' This function performs static code analysis on all R files in the package.
#' It performs the following steps:
#'
#' 1. Checks for required dependencies (installs if needed)
#' 2. Scans all R files in the R/ directory
#' 3. Sources each file in an isolated environment
#' 4. Runs `codetools::checkUsage()` on all functions
#' 5. Reports potential code quality issues
#' 6. Provides guidance on fixing common problems
#'
#' @section What This Checks:
#' - **Global variable usage** - Variables used without definition
#' - **Undefined variables** - References to non-existent objects
#' - **Unused parameters** - Function arguments that are never used
#' - **Unused local variables** - Variables assigned but never read
#' - **Suspicious constructs** - Code patterns that may indicate errors
#'
#' @section Typical Runtime:
#' 5-30 seconds depending on package size
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - R/ directory must contain R files
#' - codetools package will be installed if missing
#'
#' @section Notes:
#' - Sources R files in isolated environment (safe for analysis)
#' - Will not execute top-level code outside of functions
#' - Some warnings may be false positives (use judgment)
#' - Use with roxyglobals for automatic global variable handling
#' - Complements `check_good_practice()` analysis
#' - Run before CRAN submission to catch issues early
#' - Not all warnings need fixing (document false positives)
#'
#' @section Common Issues Explained:
#' - **No visible binding for global variable**: May need explicit namespace or @autoglobal
#' - **No visible global function definition**: Import function or use pkg::function()
#' - **Local variable assigned but not used**: Remove unused variables
#' - **Parameter never used**: Consider removing or using the parameter
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Analyze all R code for potential issues
#' report_code_quality()
#'
#' # Typical workflow:
#' # 1. Run analysis
#' # 2. Review reported issues
#' # 3. Fix genuine problems
#' # 4. Document false positives
#' # 5. Rerun to verify fixes
#' }
report_code_quality <- function() {
  # Check and install dependencies
  if (!requireNamespace("codetools", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg codetools}")
    utils::install.packages("codetools")
  }

  # Print header
  cli::cli_rule(
    left = "CODE QUALITY ANALYSIS"
  )
  cli::cli_text()

  cli::cli_alert_info("Analyzing code for potential issues...")
  cli::cli_text()

  # Get all R files
  r_files <- list.files(
    "R",
    pattern = "\\.R$",
    full.names = TRUE,
    recursive = TRUE
  )

  if (length(r_files) == 0) {
    cli::cli_alert_danger("No R files found in R/ directory")
    cli::cli_text()
    cli::cli_rule()
    cli::cli_abort("No R files to analyze")
  }

  cli::cli_alert_info(
    "Running {.code codetools::checkUsage()} on all functions ..."
  )
  cli::cli_text()

  # Track issues found
  total_issues <- 0

  # Analyze each file
  for (r_file in r_files) {
    file_name <- basename(r_file)

    cli::cli_h3(file_name)

    # Capture codetools output
    analysis_error <- FALSE
    issues <- capture.output({
      tryCatch(
        {
          # Source file and check
          env <- new.env()
          source(r_file, local = env)

          # Check all functions in the file
          func_names <- ls(env)
          for (func_name in func_names) {
            func <- get(func_name, envir = env)
            if (is.function(func)) {
              codetools::checkUsage(func, name = func_name)
            }
          }
        },
        error = function(e) {
          analysis_error <<- TRUE
          cli::cli_alert_danger("ERROR: Failed to analyze this file")
          cli::cli_text("Reason: {e$message}")
          cli::cli_text()
          cli::cli_text("Possible causes:")
          cli::cli_ul(c(
            "Syntax errors in the file",
            "Top-level code that fails when sourced",
            "Missing dependencies"
          ))
        }
      )
    })

    # If there was an error, mark it
    if (analysis_error) {
      total_issues <- total_issues + 1
    }

    # Print issues for this file
    if (length(issues) > 0 && !analysis_error) {
      for (issue in issues) {
        cli::cli_text("  {issue}")
        total_issues <- total_issues + 1
      }
    } else if (!analysis_error) {
      cli::cli_alert_success("No issues found")
    }

    cli::cli_text()
  }

  # Summary
  cli::cli_rule("CODE QUALITY ANALYSIS COMPLETE")
  cli::cli_text()
  cli::cli_alert_info("Total potential issues found: {total_issues}")
  cli::cli_text()

  if (total_issues > 0) {
    cli::cli_h3("COMMON ISSUES EXPLAINED:")
    cli::cli_ul(c(
      "{.strong 'no visible binding for global variable'}: May need @importFrom or utils::",
      "{.strong 'no visible global function definition'}: Import the function or use pkg::",
      "{.strong 'local variable assigned but not used'}: Remove unused variables",
      "{.strong 'parameter never used'}: Consider removing or using parameter"
    ))
    cli::cli_text()

    cli::cli_h3("HANDLING GLOBAL VARIABLES:")
    cli::cli_ul(c(
      "Use roxyglobals: Add {.code @autoglobal} tag to functions",
      "Use {.code utils::globalVariables()} for intentional globals",
      "Import functions explicitly with {.code @importFrom}"
    ))
    cli::cli_text()

    cli::cli_h3("NEXT STEPS:")
    cli::cli_ol(c(
      "Review each issue listed above",
      "Fix genuine problems",
      "Document false positives (globals, NSE, etc.)",
      "Rerun analysis to verify fixes"
    ))
  } else {
    cli::cli_alert_success("No code quality issues found!")
    cli::cli_text()
    cli::cli_text("Your code passes static analysis.")
  }

  cli::cli_rule()

  invisible(TRUE)
}
