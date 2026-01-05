#' Analyze Package Structure and Organization
#'
#' Analyzes and reports on package structure, function counts, documentation
#' coverage, and organization metrics.
#'
#' @return Logical value `TRUE`, returned invisibly, on successful analysis.
#'
#' @details
#' This function provides a comprehensive overview of package structure and
#' organization. It performs the following steps:
#'
#' 1. Detects current package name automatically
#' 2. Counts total functions in R/ directory
#' 3. Identifies exported vs internal functions from NAMESPACE
#' 4. Analyzes function documentation coverage
#' 5. Reports on test files and vignettes
#' 6. Calculates package size metrics
#' 7. Lists undocumented functions (if any)
#'
#' @section Analysis Categories:
#' - **R Code Analysis** - Function counts, export ratios
#' - **Documentation Analysis** - Coverage, undocumented functions
#' - **Tests Analysis** - Test file counts
#' - **Vignettes Analysis** - Vignette file counts
#' - **Package Size** - Total package size in MB
#'
#' @section Typical Runtime:
#' 1-5 seconds depending on package size
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - Package should have R/ directory with functions
#' - NAMESPACE should exist (run `devtools::document()` first)
#'
#' @section Notes:
#' - Helps understand package complexity
#' - Identifies documentation gaps
#' - Useful for refactoring decisions
#' - Quick way to see package scope
#' - Consider splitting if too many functions
#' - High export ratio may indicate lack of abstraction
#' - Missing documentation should be addressed
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Analyze package structure
#' report_package_structure()
#'
#' # Review output for:
#' # - Function counts and export ratio
#' # - Documentation coverage
#' # - Undocumented functions to address
#' # - Overall package organization
#' }
report_package_structure <- function() {
  # Helper function to detect package name
  get_package_name <- function() {
    if (requireNamespace("desc", quietly = TRUE)) {
      return(desc::desc_get_field("Package"))
    }
    if (file.exists("DESCRIPTION")) {
      lines <- readLines("DESCRIPTION", n = 20)
      pkg_line <- grep("^Package:", lines, value = TRUE)
      if (length(pkg_line) > 0) {
        return(trimws(sub("^Package:", "", pkg_line[1])))
      }
    }
    basename(normalizePath("."))
  }

  # Print header
  cli::cli_rule(
    left = "PACKAGE STRUCTURE ANALYSIS"
  )
  cli::cli_text()

  pkg_name <- get_package_name()
  cli::cli_alert_info("Package: {.pkg {pkg_name}}")
  cli::cli_text()

  # Analyze R files
  cli::cli_h3("R CODE ANALYSIS")

  r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
  cli::cli_text("R files: {length(r_files)}")

  # Count functions
  all_functions <- c()
  for (file in r_files) {
    lines <- readLines(file, warn = FALSE)
    func_lines <- grep(
      "^[a-zA-Z_][a-zA-Z0-9_.]*\\s*<-\\s*function",
      lines,
      value = TRUE
    )
    func_names <- sub("\\s*<-.*", "", func_lines)
    func_names <- trimws(func_names)
    all_functions <- c(all_functions, func_names)
  }

  cli::cli_text("Total functions: {length(all_functions)}")

  # Check NAMESPACE for exports
  if (file.exists("NAMESPACE")) {
    ns_lines <- readLines("NAMESPACE")
    export_lines <- grep("^export\\(", ns_lines, value = TRUE)
    exported_funcs <- gsub("export\\((.*)\\)", "\\1", export_lines)
    cli::cli_text("Exported functions: {length(exported_funcs)}")
    cli::cli_text(
      "Internal functions: {length(all_functions) - length(exported_funcs)}"
    )
    if (length(all_functions) > 0) {
      export_ratio <- 100 * length(exported_funcs) / length(all_functions)
      cli::cli_text("Export ratio: {round(export_ratio, 1)}%")
    }
  } else {
    cli::cli_alert_warning(
      "NAMESPACE not found (run {.code devtools::document()})"
    )
  }

  cli::cli_text()

  # Analyze documentation
  cli::cli_h3("DOCUMENTATION ANALYSIS")

  if (dir.exists("man")) {
    rd_files <- list.files("man", pattern = "\\.Rd$")
    cli::cli_text("Documentation files: {length(rd_files)}")

    documented_funcs <- sub("\\.Rd$", "", rd_files)
    if (length(all_functions) > 0) {
      undocumented <- setdiff(all_functions, documented_funcs)
      cli::cli_text("Undocumented functions: {length(undocumented)}")
      if (length(undocumented) > 0 && length(undocumented) <= 20) {
        cli::cli_text()
        cli::cli_text("Undocumented functions:")
        for (func in undocumented) {
          cli::cli_text("  - {func}")
        }
      }
    }
  } else {
    cli::cli_alert_warning("man/ directory not found")
  }

  cli::cli_text()

  # Analyze tests
  cli::cli_h3("TESTS ANALYSIS")

  if (dir.exists("tests/testthat")) {
    test_files <- list.files("tests/testthat", pattern = "^test.*\\.R$")
    cli::cli_text("Test files: {length(test_files)}")
  } else {
    cli::cli_alert_warning("No tests/testthat/ directory")
  }

  cli::cli_text()

  # Analyze vignettes
  cli::cli_h3("VIGNETTES ANALYSIS")

  if (dir.exists("vignettes")) {
    vignette_files <- list.files("vignettes", pattern = "\\.(Rmd|Rnw)$")
    cli::cli_text("Vignette files: {length(vignette_files)}")
  } else {
    cli::cli_alert_warning("No vignettes/ directory")
  }

  cli::cli_text()

  # Package size
  cli::cli_h3("PACKAGE SIZE")

  total_size <- sum(
    file.info(list.files(".", recursive = TRUE, full.names = TRUE))$size,
    na.rm = TRUE
  )
  size_mb <- total_size / (1024^2)
  cli::cli_text("Total size: {round(size_mb, 2)} MB")

  cli::cli_text()
  cli::cli_rule("STRUCTURE ANALYSIS COMPLETE")

  invisible(TRUE)
}
