#' Document and Load Package for Interactive Development
#'
#' Updates the documentation and loads all functions into the current R session for interactive development and testing. This is the fastest way to make code changes available without reinstalling the package.
#'
#' The loaded functions behave as if the package were installed and loaded
#' with `library()`, but without the installation overhead.
#'
#' @return `invisible(TRUE)` on success.
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
#' dev_load()
#' }
dev_load <- function() {
  # Check and install dependencies
  if (!requireNamespace("devtools", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg devtools}")
    utils::install.packages("devtools")
  }

  # Load package
  cli::cli_text()
  cli::cli_alert_info("Running {.code devtools::load_all()} ...")
  cli::cli_text()

  devtools::document()
  devtools::document()
  devtools::load_all()

  # Print summary
  cli::cli_text()
  cli::cli_alert_info("Package loaded!")

  invisible(TRUE)
}
