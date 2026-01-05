#' Install air formatter for R code
#'
#' Sets up the air code formatter in your R package. Air is a Rust-based
#' formatter that provides fast, opinionated code formatting for R files.
#'
#' @param vscode Logical. Should VS Code/Positron integration be configured?
#'   Default is FALSE. If TRUE, creates VS Code settings for air integration.
#'
#' @return Invisibly returns TRUE on success.
#'
#' @details
#' This function wraps \code{usethis::use_air()} to configure the air formatter
#' in your package. Air is a fast, Rust-based code formatter that enforces
#' consistent style across your R code.
#'
#' The function performs the following steps:
#' \enumerate{
#'   \item Runs \code{usethis::use_air(vscode = vscode)} to configure air
#'   \item Creates \code{air.toml} configuration file in package root
#'   \item Optionally sets up VS Code/Positron integration (if \code{vscode = TRUE})
#'   \item Provides guidance on using air
#' }
#'
#' @section Installation:
#' Before using this function, you need to install the air CLI tool.
#' See \url{https://posit-dev.github.io/air} for installation instructions.
#'
#' Quick install (requires Rust/Cargo):
#' \itemize{
#'   \item \code{cargo install air}
#' }
#'
#' @section Usage:
#' After configuration, format your code with:
#' \itemize{
#'   \item Format entire package: \code{air format .}
#'   \item Format specific directory: \code{air format R/}
#'   \item Format single file: \code{air format R/myfile.R}
#' }
#'
#' @section Resources:
#' \itemize{
#'   \item Documentation: \url{https://posit-dev.github.io/air}
#'   \item GitHub: \url{https://github.com/posit-dev/air}
#' }
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Basic setup (no VS Code integration)
#' help_install_air()
#'
#' # With VS Code/Positron integration
#' install_formatter_air(vscode = TRUE)
#' }
help_install_air <- function(vscode = FALSE) {
  # Check for cli package
  if (!requireNamespace("cli", quietly = TRUE)) {
    utils::install.packages('cli')
  }

  # Check for usethis package
  if (!requireNamespace("usethis", quietly = TRUE)) {
    utils::install.packages('usethis')
  }

  # Print header
  cli::cli_rule(center = "INSTALL AIR FORMATTER")
  cli::cli_text("")

  cli::cli_alert_info("Setting up air formatter in your package")
  cli::cli_text("")

  # Run usethis::use_air()
  cli::cli_h2("Configuring air formatter")
  cli::cli_text("")

  cli::cli_alert_info("Running {.code usethis::use_air(vscode = {vscode})} ...")
  cli::cli_text("")

  usethis::use_air(vscode = vscode)

  cli::cli_text("")
  cli::cli_alert_success("Air formatter configured successfully")
  cli::cli_text("")

  # Provide usage guidance
  cli::cli_rule(center = "NEXT STEPS")
  cli::cli_text("")

  cli::cli_h3("1. Install air CLI tool (if not already installed)")
  cli::cli_text("Air requires the air command-line tool to be installed.")
  cli::cli_text("")
  cli::cli_text("Install via Cargo (Rust package manager):")
  cli::cli_code("cargo install air")
  cli::cli_text("")
  cli::cli_text("For other installation methods, see:")
  cli::cli_text("{.url https://posit-dev.github.io/air}")
  cli::cli_text("")

  cli::cli_h3("2. Format your code")
  cli::cli_text("Use air from the terminal to format your R code:")
  cli::cli_text("")
  cli::cli_text("Format entire package:")
  cli::cli_code("air format .")
  cli::cli_text("")
  cli::cli_text("Format R/ directory:")
  cli::cli_code("air format R/")
  cli::cli_text("")
  cli::cli_text("Format specific file:")
  cli::cli_code("air format R/myfile.R")
  cli::cli_text("")

  cli::cli_h3("3. Configuration")
  cli::cli_text(
    "The {.file air.toml} file in your package root controls formatting options."
  )
  cli::cli_text("Edit this file to customize air's behavior.")
  cli::cli_text("")

  if (vscode) {
    cli::cli_h3("4. VS Code/Positron integration")
    cli::cli_alert_success("VS Code settings configured for air")
    cli::cli_text(
      "Air will be used automatically when formatting in VS Code/Positron."
    )
    cli::cli_text("")
  }

  cli::cli_h3("Pre-commit hook integration")
  cli::cli_text(
    "If you have a pre-commit hook, air can format code automatically before commits."
  )
  cli::cli_text(
    "The pre-commit hook in this template already uses air if installed."
  )
  cli::cli_text("")

  cli::cli_h3("Resources")
  cli::cli_ul(c(
    "Documentation: {.url https://posit-dev.github.io/air}",
    "GitHub: {.url https://github.com/posit-dev/air}",
    "Configuration options: {.url https://posit-dev.github.io/air/configuration.html}"
  ))
  cli::cli_text("")

  cli::cli_rule()
  cli::cli_text("")
  cli::cli_alert_info(
    "Air formatter configured! Install the CLI tool and run {.code air format .}"
  )
  cli::cli_text("")

  invisible(TRUE)
}
