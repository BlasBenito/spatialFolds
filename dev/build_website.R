#' Build Package Website with Pkgdown
#'
#' Builds a complete package website using pkgdown, generating HTML
#' documentation from Rd files, vignettes, and README.
#'
#' @return Invisibly returns `TRUE` on successful build. Stops with an error
#'   if `pkgdown::build_site()` fails or required dependencies cannot be installed.
#'
#' @details
#' This function takes no parameters and operates on the current package directory.
#' It builds a complete package website using pkgdown by performing the
#' following steps:
#'
#' 1. Checks for required dependencies and installs them if needed
#' 2. Builds complete package website (generates HTML documentation, function
#'    reference pages, vignettes, articles, and search index)
#' 3. Times the build process and reports duration
#' 4. Saves website to docs/ directory and displays usage instructions
#'
#' @section Website Structure:
#' The built website includes:
#' - **index.html** - Homepage (from README.md)
#' - **reference/** - Function documentation
#' - **articles/** - Vignettes and articles
#' - **news/** - NEWS.md changelog
#' - **search.json** - Search functionality
#'
#' @section Configuration:
#' - Website appearance controlled by `_pkgdown.yml`
#' - Create with: `usethis::use_pkgdown()`
#' - Customize with: [pkgdown_customize_site()]
#' - See: https://pkgdown.r-lib.org/
#'
#' @section When to Build:
#' - After updating documentation
#' - Before deploying to GitHub Pages
#' - After adding/modifying vignettes
#' - When README changes
#' - Before package release
#'
#' @section Performance:
#' - Typical runtime: 10-30 seconds
#' - Rebuilds entire site each time
#' - Time increases with package size
#' - Large vignettes take longer
#'
#' @section Deployment:
#' **GitHub Pages (from docs/):**
#' 1. Build site with this function
#' 2. Commit docs/ directory
#' 3. Push to GitHub
#' 4. Settings → Pages → Source: main branch /docs folder
#'
#' **GitHub Actions (automatic):**
#' - Run: `usethis::use_pkgdown_github_pages()`
#' - Automatic deployment on push
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - A _pkgdown.yml file should exist (create with `usethis::use_pkgdown()`)
#' - Package documentation should be up-to-date
#'
#' @section Notes:
#' - Website saved to docs/ directory
#' - Preview locally by opening docs/index.html
#' - Site includes all exported functions
#' - Vignettes must build without errors
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Build package website
#' build_website()
#'
#' # Preview locally
#' # Open docs/index.html in browser
#'
#' # Deploy to GitHub Pages
#' # git add docs/
#' # git commit -m "Update website"
#' # git push
#' }
build_website <- function() {
  # Check and install dependencies
  if (!requireNamespace("pkgdown", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg pkgdown}")
    utils::install.packages("pkgdown")
  }

  # Print header
  cli::cli_rule(
    left = "BUILD PACKAGE WEBSITE"
  )
  cli::cli_text()

  # Build site
  cli::cli_alert_info("Running {.code pkgdown::build_site()} ...")
  cli::cli_alert_info("This may take 10-30 seconds")
  cli::cli_text()

  start_time <- Sys.time()

  pkgdown::build_site()

  build_time <- difftime(Sys.time(), start_time, units = "secs")

  cli::cli_text()
  cli::cli_rule("SITE BUILD COMPLETE")
  cli::cli_alert_success(
    "Build time: {round(build_time, 1)} seconds"
  )
  cli::cli_text()
  cli::cli_alert_success("Website saved to: {.file docs/}")
  cli::cli_alert_success("Main page: {.file docs/index.html}")
  cli::cli_text()

  cli::cli_h3("To preview locally:")
  cli::cli_text("Open {.file docs/index.html} in your browser")
  cli::cli_text()

  cli::cli_h3("To deploy to GitHub Pages:")
  cli::cli_ol(c(
    "Push docs/ directory to GitHub",
    "Enable GitHub Pages in repository settings",
    "Set source to 'main branch /docs folder'"
  ))
  cli::cli_rule()

  invisible(TRUE)
}
