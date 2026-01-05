#' Run Comprehensive Multi-Platform Package Checks
#'
#' Submits package for checking across 20 platforms using R-Hub and
#' platform-specific builders (Windows, macOS).
#'
#' @return Logical value `TRUE`, returned invisibly, on successful submission.
#'
#' @details
#' This function runs the most comprehensive cross-platform testing available,
#' submitting your package to multiple checking services. It performs the
#' following steps:
#'
#' 1. Verifies GITHUB_PAT is configured (required for R-Hub)
#' 2. Submits to Windows R-devel builder
#' 3. Submits to macOS R-release builder
#' 4. Submits to 20 R-Hub platforms with various compilers and configurations
#'
#' @section Platforms Tested:
#' The function tests on 20 platforms including:
#' - linux, macos-arm64, windows (standard platforms)
#' - Various compilers: clang16-19, gcc13-14, intel
#' - Special configurations: atlas, mkl, nosuggests, nold
#' - Sanitizers: clang-asan
#' - C23 standard testing
#'
#' @section Prerequisites:
#' **First-time setup required:**
#' 1. Create GitHub token: `usethis::create_github_token()`
#' 2. Add to .Renviron: `usethis::edit_r_environ()`
#'    Add line: `GITHUB_PAT=your_token_here`
#' 3. Restart R session
#' 4. Run rhub setup: `rhub::rhub_setup()` and `rhub::rhub_doctor()`
#' 5. Run from package root directory
#'
#' **Ongoing requirements:**
#' - GITHUB_PAT environment variable must be set
#' - Package should pass local R CMD check first
#' - Internet connection required
#'
#' @section Results:
#' - Each platform sends separate email notification (20 emails!)
#' - Typical completion time: 15-60 minutes per platform
#' - Results also viewable on R-Hub website
#' - Check spam folder if emails don't arrive
#'
#' @section When to Use:
#' - **Use sparingly** - generates many emails and takes significant time
#' - Before major CRAN releases
#' - When targeting specific platforms or compilers
#' - For packages with compiled code
#' - **Not needed for routine checks** - use `check_win_devel()` and
#'   `check_mac_release()` instead
#'
#' @section Notes:
#' - Very comprehensive but time-consuming
#' - Not all platforms may be available at all times
#' - For routine CRAN prep, Windows + Mac checks are usually sufficient
#' - Results persist on R-Hub website for later review
#' - Free service provided by the R Consortium
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # First-time setup (do once):
#' usethis::create_github_token()
#' usethis::edit_r_environ()  # Add GITHUB_PAT=your_token
#' # Restart R
#' rhub::rhub_setup()
#' rhub::rhub_doctor()
#'
#' # Run comprehensive checks:
#' dev_check_all_platforms()
#'
#' # Wait for emails (15-60 minutes per platform)
#' # Review results for platform-specific issues
#' }
dev_check_all_platforms <- function() {
  # Check and install dependencies
  if (!requireNamespace("rhub", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg rhub}")
    utils::install.packages("rhub")
  }

  if (!requireNamespace("devtools", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg devtools}")
    utils::install.packages("devtools")
  }

  # Print header
  cli::cli_rule(
    left = "MULTI-PLATFORM PACKAGE CHECKS"
  )
  cli::cli_text()

  cli::cli_alert_info("This will run checks on multiple platforms:")
  cli::cli_ul(c(
    "Windows R-devel",
    "Mac R-release",
    "20 R-Hub platforms (various compilers and configurations)"
  ))
  cli::cli_text()

  cli::cli_alert_info(
    "IMPORTANT: Checks run remotely and may take 15-60 minutes"
  )
  cli::cli_alert_info(
    "You will receive email notifications when complete"
  )
  cli::cli_text()

  cli::cli_h3("First-time setup (if needed):")
  cli::cli_code("rhub::rhub_setup()")
  cli::cli_code("rhub::rhub_doctor()")
  cli::cli_text()

  cli::cli_rule()
  cli::cli_text()

  # Verify GITHUB_PAT is configured
  if (Sys.getenv("GITHUB_PAT") == "") {
    cli::cli_text()
    cli::cli_rule("ERROR: GITHUB_PAT NOT SET")
    cli::cli_text()

    cli::cli_alert_danger(
      "R-Hub requires GitHub authentication via a Personal Access Token (PAT)"
    )
    cli::cli_text()

    cli::cli_h3("To set up your GITHUB_PAT:")
    cli::cli_ol(c(
      "Create a GitHub token: {.code usethis::create_github_token()}",
      "Add token to .Renviron: {.code usethis::edit_r_environ()}
       Add this line: {.code GITHUB_PAT=your_token_here}",
      "Restart R session: {.code .rs.restartR()} or restart manually",
      "Verify setup: {.code Sys.getenv('GITHUB_PAT')} should show your token",
      "Run rhub setup: {.code rhub::rhub_setup()} and {.code rhub::rhub_doctor()}"
    ))

    cli::cli_text()
    cli::cli_rule()

    cli::cli_abort("GITHUB_PAT required for rhub authentication")
  }

  # Windows check
  cli::cli_alert_info("Starting Windows R-devel check...")
  devtools::check_win_devel()
  cli::cli_alert_success("Windows check submitted")
  cli::cli_text()

  # Mac check
  cli::cli_alert_info("Starting Mac R-release check...")
  devtools::check_mac_release()
  cli::cli_alert_success("Mac check submitted")
  cli::cli_text()

  # Full rhub multi-platform check
  cli::cli_alert_info("Running {.code rhub::rhub_check()} ...")
  cli::cli_alert_info(
    "20 platforms including linux, macos-arm64, windows, and various compilers"
  )
  cli::cli_text()

  rhub::rhub_check(
    platforms = c(
      "linux",
      "macos-arm64",
      "windows",
      "atlas",
      "c23",
      "clang-asan",
      "clang16",
      "clang17",
      "clang18",
      "clang19",
      "gcc13",
      "gcc14",
      "intel",
      "mkl",
      "nold",
      "nosuggests",
      "ubuntu-clang",
      "ubuntu-gcc12",
      "ubuntu-next",
      "ubuntu-release"
    )
  )

  cli::cli_text()
  cli::cli_rule("ALL CHECKS SUBMITTED")
  cli::cli_alert_success(
    "Check your email for results (usually arrives in 15-60 minutes)"
  )
  cli::cli_alert_info(
    "You can also view results on the R-Hub website"
  )
  cli::cli_rule()

  invisible(TRUE)
}
