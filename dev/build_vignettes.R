#' Build All Package Vignettes
#'
#' Builds all vignettes in the vignettes/ directory, executing R code and
#' generating HTML output for package documentation.
#'
#' @return Logical value `TRUE`, returned invisibly, on successful build.
#'
#' @details
#' This function builds all package vignettes from .Rmd source files.
#' It performs the following steps:
#'
#' 1. Checks for required dependencies (installs if needed)
#' 2. Verifies vignettes/ directory exists with .Rmd files
#' 3. Lists all vignettes to be built
#' 4. Builds all vignettes using `devtools::build_vignettes()`
#' 5. Executes R code in vignette chunks
#' 6. Generates HTML/PDF output
#' 7. Installs vignettes to inst/doc/ for package inclusion
#'
#' @section Vignettes:
#' - Long-form documentation for package functionality
#' - Provide tutorials, examples, and detailed explanations
#' - Users access via `vignette()` or `browseVignettes()`
#' - Built vignettes are included with package installation
#'
#' @section When to Build:
#' - After modifying vignette content
#' - When R code produces new output
#' - Before package release or submission
#' - To test vignette code execution
#'
#' @section Performance:
#' - Build time depends on vignette complexity
#' - Vignettes with heavy computation take longer
#' - Consider caching expensive computations
#' - Use `cache=TRUE` in code chunks for long-running code
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - vignettes/ directory must exist
#' - At least one .Rmd file in vignettes/
#' - Create with: `usethis::use_vignette("vignette-name")`
#'
#' @section Notes:
#' - Built vignettes saved to inst/doc/
#' - Vignettes execute in clean environment
#' - All code chunks must run without errors
#' - Consider reader's knowledge level when writing
#' - Build fails if no vignettes exist
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Build all vignettes
#' build_vignettes()
#'
#' # After building, view them:
#' browseVignettes("yourpackage")
#'
#' # Or view specific vignette:
#' vignette("vignette-name", package = "yourpackage")
#' }
build_vignettes <- function() {
  # Check and install dependencies
  if (!requireNamespace("devtools", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg devtools}")
    utils::install.packages("devtools")
  }

  # Print header
  cli::cli_rule(
    left = "BUILD VIGNETTES"
  )
  cli::cli_text()

  # Check if vignettes exist
  if (
    !dir.exists("vignettes") ||
      length(list.files("vignettes", pattern = "\\.Rmd$")) == 0
  ) {
    cli::cli_alert_danger("No vignettes found in vignettes/ directory")
    cli::cli_text()
    cli::cli_alert_info("This package has no vignettes to build")
    cli::cli_text()
    cli::cli_alert_info(
      "To create one: {.code usethis::use_vignette('vignette-name')}"
    )
    cli::cli_rule()
    cli::cli_abort("No vignettes found")
  }

  # List vignettes
  vignette_files <- list.files("vignettes", pattern = "\\.Rmd$")
  cli::cli_alert_info(
    "Found {length(vignette_files)} vignette{?s} to build:"
  )
  cli::cli_ul(vignette_files)
  cli::cli_text()

  # Build vignettes
  cli::cli_alert_info("Running {.code devtools::build_vignettes()} ...")
  cli::cli_alert_info(
    "This may take a while if vignettes have expensive computations"
  )
  cli::cli_text()

  start_time <- Sys.time()

  devtools::build_vignettes()

  build_time <- difftime(Sys.time(), start_time, units = "secs")

  cli::cli_text()
  cli::cli_rule("VIGNETTES BUILD COMPLETE")
  cli::cli_alert_success(
    "Build time: {round(build_time, 1)} seconds"
  )
  cli::cli_text()
  cli::cli_alert_success("Built vignettes saved to: {.file inst/doc/}")
  cli::cli_text()

  cli::cli_h3("To view vignettes:")
  cli::cli_code("browseVignettes('packagename')")
  cli::cli_rule()

  invisible(TRUE)
}
