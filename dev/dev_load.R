#' Load Package for Interactive Development
#'
#' Loads all package functions into the current R session for interactive
#' development and testing. This is the fastest way to make code changes
#' available without reinstalling the package.
#'
#' @return `invisible(TRUE)` on success.
#'
#' @details
#' This function provides instant access to your package code during development.
#' It performs the following steps:
#'
#' 1. Checks for required dependencies (installs if needed)
#' 2. Clears the console for a clean workspace
#' 3. Loads all package functions with `devtools::load_all()`
#' 4. Reports load time
#'
#' The loaded functions behave as if the package were installed and loaded
#' with `library()`, but without the installation overhead.
#'
#' @section Typical Runtime:
#' Less than 1 second for most packages
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - Package must have valid R code in `R/` directory
#'
#' @section Notes:
#' - Use this for interactive development and experimentation
#' - Much faster than the install-and-load cycle
#' - Rerun after changing function code to reload changes
#' - Functions available immediately without `library()` call
#' - Source code changes require reload (rerun this function)
#' - Does NOT update documentation; use `check()` for that
#'
#' @section Typical Workflow:
#' 1. Edit function code in `R/` directory
#' 2. Run `dev_load()` to load changes
#' 3. Test functions interactively in console
#' 4. Repeat until satisfied
#' 5. Run `check()` to update docs and verify package
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Load package for interactive development
#' dev_load()
#'
#' # Now test your functions interactively
#' my_function(test_data)
#'
#' # Make changes to R/my_function.R
#' # Then reload:
#' dev_load()
#' }
dev_load <- function() {
  # Check and install dependencies
  if (!requireNamespace("devtools", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg devtools}")
    utils::install.packages("devtools")
  }

  # Clear console
  cat("\014")

  # Print header
  cli::cli_rule(
    left = "DAILY WORKFLOW: LOAD PACKAGE"
  )
  cli::cli_text()

  # Load package
  cli::cli_alert_info("Running {.code devtools::load_all()} ...")
  cli::cli_text()

  devtools::load_all()

  # Print summary
  cli::cli_text()
  cli::cli_rule("PACKAGE LOADED")
  cli::cli_text()
  cli::cli_alert_info(
    "Package functions are now available for interactive use"
  )
  cli::cli_alert_info(
    "Modify code and rerun {.code dev_load()} to reload changes"
  )
  cli::cli_rule()

  invisible(TRUE)
}
