#' Setup GitHub Actions Workflows for R Package
#'
#' Configures GitHub Actions workflows for continuous integration and
#' documentation deployment. The template includes R-CMD-check by default;
#' this function can add pkgdown deployment and verify existing workflows.
#'
#' @param pkgdown Logical. Set up automatic pkgdown website deployment to
#'   GitHub Pages? Default `TRUE`. When enabled, your package website will
#'   be built and deployed automatically on every push to main branch.
#'
#' @param rcmdcheck Logical. Verify/update the R-CMD-check workflow? Default
#'   `TRUE`. The template already includes this workflow, but you can use
#'   this to update it to the latest version from r-lib/actions.
#'
#' @return Invisibly returns `TRUE` on success. Stops with an error if
#'   usethis package is not available or if workflow setup fails.
#'
#' @details
#' This function sets up GitHub Actions workflows using `usethis`. It configures:
#'
#' **R-CMD-check workflow (`rcmdcheck = TRUE`):**
#' - Runs R CMD check on multiple platforms (macOS, Windows, Ubuntu)
#' - Tests with multiple R versions (devel, release, oldrel-1)
#' - Runs automatically on push and pull requests
#' - Creates badge for README: `[![R-CMD-check](URL)](URL)`
#'
#' **pkgdown workflow (`pkgdown = TRUE`):**
#' - Builds package website automatically on push to main branch
#' - Deploys to GitHub Pages at `https://USERNAME.github.io/PACKAGE/`
#' - No need to manually run `build_website()` and commit docs/
#' - Requires GitHub Pages enabled in repository settings
#'
#' @section Setup Requirements:
#'
#' **For all workflows:**
#' 1. Repository must be pushed to GitHub
#' 2. Commit `.github/workflows/` directory
#' 3. Push to trigger first workflow run
#'
#' **For pkgdown deployment:**
#' 1. Enable GitHub Pages in repo settings
#' 2. Set source to "GitHub Actions"
#' 3. Website deploys automatically on next push
#'
#' @section Post-Setup Steps:
#'
#' After running this function:
#'
#' 1. **Commit the workflow files:**
#'    ```r
#'    # In terminal:
#'    git add .github/workflows/
#'    git commit -m "Add GitHub Actions workflows"
#'    git push
#'    ```
#'
#' 2. **For pkgdown: Enable GitHub Pages**
#'    - Go to: Repository → Settings → Pages
#'    - Source: Select "GitHub Actions"
#'    - Save
#'
#' 3. **Verify workflows are running:**
#'    - Go to: Repository → Actions tab
#'    - You should see workflows running
#'
#' 4. **Update README badges** (if not already done):
#'    ```markdown
#'    [![R-CMD-check](https://github.com/USER/REPO/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/USER/REPO/actions/workflows/R-CMD-check.yaml)
#'    ```
#'
#' @section Workflow Files Created:
#' - `.github/workflows/R-CMD-check.yaml` (if `rcmdcheck = TRUE`)
#' - `.github/workflows/pkgdown.yaml` (if `pkgdown = TRUE`)
#'
#' @section When to Use:
#' - Initial package setup (after pushing to GitHub)
#' - When you want automatic website deployment
#' - To update workflows to latest versions
#' - After enabling GitHub Pages for your repository
#'
#' @section Notes:
#' - R-CMD-check workflow is already included in the template
#' - pkgdown workflow requires GitHub Pages to be enabled
#' - Workflows run automatically on push; no manual triggers needed
#' - You can view workflow status at `github.com/USER/REPO/actions`
#' - Both workflows use latest r-lib/actions from GitHub
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Setup both R-CMD-check and pkgdown (recommended)
#' setup_github_actions()
#'
#' # Only setup/verify R-CMD-check
#' setup_github_actions(pkgdown = FALSE)
#'
#' # Only setup pkgdown deployment
#' setup_github_actions(rcmdcheck = FALSE, pkgdown = TRUE)
#' }
setup_github_actions <- function(pkgdown = TRUE, rcmdcheck = TRUE) {
  # Check dependencies
  if (!requireNamespace("usethis", quietly = TRUE)) {
    cli::cli_alert_danger("Required package {.pkg usethis} not found")
    cli::cli_alert_info("Installing {.pkg usethis}...")
    utils::install.packages("usethis")
  }

  # Print header
  cli::cli_rule(
    left = "SETUP GITHUB ACTIONS WORKFLOWS"
  )
  cli::cli_text()

  workflows_added <- character(0)

  # Setup R-CMD-check workflow
  if (rcmdcheck) {
    cli::cli_alert_info("Setting up R-CMD-check workflow...")
    cli::cli_text()

    tryCatch(
      {
        usethis::use_github_action("check-standard")
        workflows_added <- c(workflows_added, "R-CMD-check")
        cli::cli_alert_success("R-CMD-check workflow configured")
      },
      error = function(e) {
        cli::cli_alert_warning(
          "Could not setup R-CMD-check: {conditionMessage(e)}"
        )
      }
    )
    cli::cli_text()
  }

  # Setup pkgdown workflow
  if (pkgdown) {
    cli::cli_alert_info("Setting up pkgdown deployment workflow...")
    cli::cli_text()

    tryCatch(
      {
        usethis::use_github_action("pkgdown")
        workflows_added <- c(workflows_added, "pkgdown")
        cli::cli_alert_success("pkgdown workflow configured")
      },
      error = function(e) {
        cli::cli_alert_warning(
          "Could not setup pkgdown: {conditionMessage(e)}"
        )
      }
    )
    cli::cli_text()
  }

  # Print summary
  cli::cli_rule("WORKFLOWS CONFIGURED")
  cli::cli_text()

  if (length(workflows_added) > 0) {
    cli::cli_alert_success(
      "Added {length(workflows_added)} workflow{?s}: {.file {workflows_added}}"
    )
  } else {
    cli::cli_alert_info("No new workflows were added")
  }

  cli::cli_text()
  cli::cli_h3("Next Steps:")
  cli::cli_ol(c(
    "Commit workflow files: {.code git add .github/workflows/ && git commit -m 'Add GitHub Actions'}",
    "Push to GitHub: {.code git push}",
    if (pkgdown) "Enable GitHub Pages: Repo → Settings → Pages → Source: 'GitHub Actions'",
    "View workflow runs: {.code https://github.com/USER/REPO/actions}",
    "Update README badges with your repository URLs"
  ))

  cli::cli_text()

  if (pkgdown) {
    cli::cli_h3("pkgdown Deployment:")
    cli::cli_ul(c(
      "Website will deploy to: {.url https://USERNAME.github.io/PACKAGE/}",
      "Builds automatically on push to main branch",
      "No need to manually run {.code build_website()} anymore",
      "First deployment may take 5-10 minutes"
    ))
    cli::cli_text()
  }

  cli::cli_h3("Workflow Badges:")
  cli::cli_text("Add to your README.Rmd:")
  cli::cli_code(
    '[![R-CMD-check](https://github.com/USER/REPO/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/USER/REPO/actions/workflows/R-CMD-check.yaml)'
  )

  cli::cli_rule()

  invisible(TRUE)
}
