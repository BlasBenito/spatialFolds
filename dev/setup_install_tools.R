#' Install development dependencies for R package development
#'
#' Installs or updates all packages required for R package development workflow.
#' Uses parallel installation for speed.
#'
#' @return Invisibly returns TRUE on success.
#'
#' @details
#' This function installs/updates the following essential development tools:
#' \itemize{
#'   \item devtools - Development workflow tools
#'   \item roxygen2 - Documentation generation
#'   \item roxygen2Comment - RStudio addin for toggling roxygen2 comments
#'   \item usethis - Package and project setup
#'   \item here - Path management
#'   \item roxyglobals - Automatic global variable detection
#'   \item rhub - Multi-platform package checking
#'   \item covr - Code coverage analysis
#'   \item codetools - Code analysis utilities
#'   \item pkgnet - Package dependency visualization
#'   \item microbenchmark - Performance benchmarking
#'   \item goodpractice - Package quality checks
#'   \item rcmdcheck - R CMD check interface
#'   \item profvis - Performance profiling
#'   \item todor - Find TODO/FIXME comments in code
#'   \item Rcpp - R and C++ integration
#'   \item pkgbuild - Build tools for packages
#'   \item cli - Command line interface tools
#' }
#'
#' Installation uses parallel processing (N-1 cores) for faster completion.
#' All packages are from CRAN.
#'
#' @section Notes:
#' \itemize{
#'   \item May take 5-10 minutes on first run
#'   \item Updates existing packages to latest versions
#'   \item Requires internet connection and sufficient disk space
#' }
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' setup_install_tools()
#' }
setup_install_tools <- function() {
  # Check for cli package
  if (!requireNamespace("cli", quietly = TRUE)) {
    utils::install.packages('cli')
  }

  # Print header
  cli::cli_rule(center = "INSTALL DEVELOPMENT DEPENDENCIES")

  # Define packages
  dev_packages <- c(
    "devtools",
    "roxygen2",
    "roxygen2Comment",
    "usethis",
    "here",
    "roxyglobals",
    "rhub",
    "covr",
    "codetools",
    "pkgnet",
    "microbenchmark",
    "goodpractice",
    "rcmdcheck",
    "profvis",
    "todor",
    "Rcpp",
    "pkgbuild"
  )

  cli::cli_h2("Installing {length(dev_packages)} development packages")
  cli::cli_text("")

  # Show package list
  cli::cli_text("Packages to install/update:")
  cli::cli_ul(dev_packages)
  cli::cli_text("")

  # Calculate number of cores for parallel installation
  ncores <- parallel::detectCores() - 1
  cli::cli_alert_info("Using {ncores} core{?s} for parallel installation")
  cli::cli_text("")

  # Install packages
  cli::cli_alert_info(
    "Running {.code utils::install.packages()} with {ncores} core{?s} ..."
  )
  cli::cli_text("")

  utils::install.packages(
    pkgs = dev_packages,
    Ncpus = ncores
  )

  cli::cli_text("")
  cli::cli_alert_success("All development dependencies installed successfully")

  # Provide next steps
  cli::cli_text("")
  cli::cli_rule(center = "NEXT STEPS")

  cli::cli_h3("Verify Installation")
  cli::cli_text("Check that key packages load correctly:")
  cli::cli_code("library(devtools)")
  cli::cli_code("library(usethis)")
  cli::cli_code("library(roxygen2)")
  cli::cli_text("")

  cli::cli_h3("Package Resources")
  cli::cli_ul(c(
    "devtools: {.url https://devtools.r-lib.org/}",
    "roxygen2: {.url https://roxygen2.r-lib.org/}",
    "roxygen2Comment: {.url https://github.com/csgillespie/roxygen2Comment}",
    "usethis: {.url https://usethis.r-lib.org/}",
    "here: {.url https://here.r-lib.org/}",
    "roxyglobals: {.url https://github.com/anthonynorth/roxyglobals}",
    "rhub: {.url https://r-hub.github.io/rhub/}",
    "covr: {.url https://covr.r-lib.org/}",
    "codetools: {.url https://cran.r-project.org/package=codetools}",
    "pkgnet: {.url https://uptake.github.io/pkgnet/}",
    "microbenchmark: {.url https://github.com/joshuaulrich/microbenchmark/}",
    "goodpractice: {.url https://docs.ropensci.org/goodpractice/}",
    "rcmdcheck: {.url https://rcmdcheck.r-lib.org/}",
    "profvis: {.url https://profvis.r-lib.org/}",
    "todor: {.url https://cran.r-project.org/web/packages/todor/}",
    "Rcpp: {.url https://www.rcpp.org/}",
    "pkgbuild: {.url https://cran.r-project.org/web/packages/pkgbuild/readme/README.html}",
    "cli: {.url https://cli.r-lib.org/}"
  ))
  cli::cli_text("")

  cli::cli_h3("Start Developing")
  cli::cli_text("You're ready to start R package development!")
  cli::cli_text("See {.file dev/README.md} for available development scripts.")
  cli::cli_text("")

  cli::cli_rule()

  invisible(TRUE)
}
