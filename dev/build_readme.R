#' Render README.Rmd to README.md
#'
#' Renders the package README.Rmd file to README.md, executing all R code
#' chunks and updating output.
#'
#' @return Logical value `TRUE`, returned invisibly, on successful build.
#'
#' @details
#' This function builds the package README from the source .Rmd file.
#' It performs the following steps:
#'
#' 1. Checks for required dependencies (installs if needed)
#' 2. Verifies README.Rmd exists in package root
#' 3. Renders README.Rmd to README.md using `devtools::build_readme()`
#' 4. Executes any R code chunks in README.Rmd
#' 5. Updates README.md with current output
#' 6. Reports build time
#'
#' @section README Files:
#' - **README.Rmd** - Source file with R Markdown content (edit this)
#' - **README.md** - Auto-generated Markdown file (don't edit directly)
#' - GitHub displays README.md on repository page
#' - Both files should be committed to version control
#'
#' @section When to Build:
#' - After modifying README.Rmd content
#' - When R code chunks produce new output
#' - Before committing changes to repository
#' - To update package examples in README
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - README.Rmd file must exist in root
#' - Create with: `usethis::use_readme_rmd()`
#'
#' @section Notes:
#' - README.md is auto-generated; make all edits in README.Rmd
#' - Code chunks are executed during build
#' - Ensure code chunks are up-to-date and runnable
#' - Commit both .Rmd and .md files together
#' - Build fails if README.Rmd doesn't exist
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Build README from README.Rmd
#' build_readme()
#'
#' # Typical workflow:
#' # 1. Edit README.Rmd
#' # 2. build_readme() to update README.md
#' # 3. Review changes
#' # 4. Commit both files
#' }
build_readme <- function() {
  # Check and install dependencies
  if (!requireNamespace("devtools", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg devtools}")
    utils::install.packages("devtools")
  }

  # Print header
  cli::cli_rule(
    left = "BUILD README"
  )
  cli::cli_text()

  # Check if README.Rmd exists
  if (!file.exists("README.Rmd")) {
    cli::cli_alert_danger("No README.Rmd found in package root")
    cli::cli_text()
    cli::cli_alert_info("This package has no README.Rmd to build")
    cli::cli_text()
    cli::cli_alert_info("To create one: {.code usethis::use_readme_rmd()}")
    cli::cli_rule()
    cli::cli_abort("README.Rmd not found")
  }

  # Build README
  cli::cli_alert_info("Running {.code devtools::build_readme()} ...")
  cli::cli_text()

  start_time <- Sys.time()

  devtools::build_readme()

  build_time <- difftime(Sys.time(), start_time, units = "secs")

  cli::cli_text()
  cli::cli_rule("README BUILD COMPLETE")
  cli::cli_alert_success(
    "Build time: {round(build_time, 1)} seconds"
  )
  cli::cli_text()
  cli::cli_alert_success("README.md has been updated")
  cli::cli_text()

  cli::cli_h3("Reminder:")
  cli::cli_ul(c(
    "Commit both README.Rmd and README.md",
    "Don't edit README.md directly",
    "Make changes in README.Rmd and rebuild"
  ))
  cli::cli_rule()

  invisible(TRUE)
}
