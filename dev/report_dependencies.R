#' Analyze Package Dependencies with Network Visualization
#'
#' Creates a comprehensive visual network graph of package structure and
#' dependencies using the pkgnet package.
#'
#' @return The pkgnet report object, returned invisibly.
#'
#' @details
#' This function creates an interactive HTML report analyzing your package's
#' dependency structure. It performs the following steps:
#'
#' 1. Detects current package name automatically
#' 2. Checks for required dependencies (installs if needed)
#' 3. Creates comprehensive package report using pkgnet
#' 4. Analyzes internal function dependencies
#' 5. Generates HTML report with interactive network graphs
#' 6. Saves report to `dev/dependency_report.html`
#' 7. Opens report automatically in browser
#'
#' @section Report Contents:
#' The HTML report includes:
#' - **Function dependency networks** - Visual graph of function relationships
#' - **Package structure visualization** - Overall architecture diagram
#' - **Complexity metrics** - Quantitative measures of code complexity
#' - **Dependency graphs** - External package dependencies
#'
#' @section Typical Runtime:
#' 30-120 seconds depending on package size
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - Package must be in buildable state
#' - pkgnet package will be installed if missing
#'
#' @section Notes:
#' - Report automatically opens in browser
#' - Useful for understanding package architecture
#' - Identifies tightly coupled functions
#' - Helps plan refactoring and modularization
#' - Report saved to `dev/dependency_report.html`
#' - Interactive visualizations allow exploration
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Analyze package dependencies
#' report_dependencies()
#'
#' # Report opens in browser automatically
#' # Review:
#' # - Function dependency networks
#' # - Package structure
#' # - Complexity metrics
#' # - Tightly coupled code sections
#' }
report_dependencies <- function() {
  # Helper function to detect package name
  get_package_name <- function() {
    # Method 1: desc package
    if (requireNamespace("desc", quietly = TRUE)) {
      return(desc::desc_get_field("Package"))
    }
    # Method 2: read DESCRIPTION directly
    if (file.exists("DESCRIPTION")) {
      lines <- readLines("DESCRIPTION", n = 20)
      pkg_line <- grep("^Package:", lines, value = TRUE)
      if (length(pkg_line) > 0) {
        return(trimws(sub("^Package:", "", pkg_line[1])))
      }
    }
    # Method 3: basename of current directory
    basename(normalizePath("."))
  }

  # Check and install dependencies
  if (!requireNamespace("pkgnet", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg pkgnet}")
    utils::install.packages("pkgnet")
  }

  # Get package name
  pkg_name <- get_package_name()

  # Print header
  cli::cli_rule(
    left = "PACKAGE DEPENDENCY ANALYSIS"
  )
  cli::cli_text()

  cli::cli_alert_info("Analyzing package: {.pkg {pkg_name}}")
  cli::cli_text()

  # Create report path
  report_path <- file.path("dev", "dependency_report.html")

  cli::cli_alert_info("Running {.code pkgnet::CreatePackageReport()} ...")
  cli::cli_text("(This may take a moment)")
  cli::cli_text()

  # Create package report
  report <- pkgnet::CreatePackageReport(
    pkg_name = pkg_name,
    report_path = report_path
  )

  cli::cli_text()
  cli::cli_rule("ANALYSIS COMPLETE")
  cli::cli_text()
  cli::cli_alert_success("Report saved to: {.file {report_path}}")
  cli::cli_text()
  cli::cli_text("The report should open automatically in your browser.")
  cli::cli_text()
  cli::cli_text("If not, open the file manually to view:")
  cli::cli_ul(c(
    "Function dependency networks",
    "Package structure visualization",
    "Complexity metrics",
    "Dependency graphs"
  ))
  cli::cli_rule()

  # Return report invisibly
  invisible(report)
}
