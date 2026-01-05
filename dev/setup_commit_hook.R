#' Setup Customizable Pre-Commit Hook for R Package Development
#'
#' Creates and installs a pre-commit git hook with optional quality check
#' components. The hook always runs documentation updates and R CMD check,
#' with configurable linting, formatting, and testing steps.
#'
#' @param lint Logical. Include jarl linting step in hook? Default `TRUE`.
#'   If jarl is not installed, this step will be skipped gracefully with a
#'   warning. The hook will not fail if jarl is missing.
#'
#' @param format Logical. Include air formatting step in hook? Default `TRUE`.
#'   If air is not installed, this step will be skipped gracefully with a
#'   warning. The hook will not fail if air is missing.
#'
#' @param testthat Logical. Include testthat test run in hook? Default `TRUE`.
#'   Runs all tests before allowing commit. Useful for ensuring tests pass
#'   before committing, but can slow down commits. Set to `FALSE` for faster
#'   commits during rapid development.
#'
#' @return Logical value `TRUE`, returned invisibly, on successful hook installation.
#'
#' @details
#' This function generates a customized pre-commit hook based on your
#' preferences and installs it to `.git/hooks/pre-commit`. The hook performs
#' the following steps in order:
#'
#' **Optional Steps (configurable via arguments):**
#' 1. **Jarl Linting** (`lint = TRUE`) - Fast Rust-based linting with auto-fix
#' 2. **Air Formatting** (`format = TRUE`) - Rust-based code formatting
#' 3. **Testthat Tests** (`testthat = TRUE`) - Run complete test suite
#'
#' **Required Steps (always included):**
#' 4. **Update Documentation** - Runs `devtools::document()` to update roxygen docs
#' 5. **R CMD Check** - Runs `devtools::check()` with CRAN standards; stops commit on errors
#'
#' @section Hook Behavior:
#' - **Linting/Formatting**: If tools are not installed, hook warns but continues
#' - **Documentation**: Always runs; fails commit if documentation errors occur
#' - **R CMD Check**: Always runs; fails commit only on ERRORS (warnings/notes allowed)
#' - **Auto-staging**: Automatically stages files modified by linter/formatter
#'
#' @section Bypassing the Hook:
#' To commit without running the hook (use sparingly):
#' ```
#' git commit --no-verify -m "your message"
#' ```
#'
#' Use `--no-verify` for:
#' - Quick WIP commits during development
#' - Emergency hotfixes (but run checks immediately after!)
#' - When you know checks will fail but need to save progress
#'
#' **WARNING:** Never push commits that haven't passed checks!
#'
#' @section Disabling the Hook:
#' To disable permanently:
#' ```
#' rm .git/hooks/pre-commit
#' ```
#'
#' Or rename it:
#' ```
#' mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled
#' ```
#'
#' @section Typical Runtime:
#' - Without testthat: 30-90 seconds (documentation + check)
#' - With testthat: 45-120 seconds (adds test execution time)
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - Must be inside a git repository
#' - devtools package required (for document() and check())
#' - jarl optional (for linting, if `lint = TRUE`)
#' - air optional (for formatting, if `format = TRUE`)
#' - testthat optional (for tests, if `testthat = TRUE`)
#'
#' @section Notes:
#' - Hook is automatically installed to `.git/hooks/pre-commit`
#' - Hook is made executable automatically
#' - Overwrites existing pre-commit hook (backup recommended)
#' - Hook runs before each `git commit` command
#' - Use `--no-verify` to bypass when needed
#' - Re-run this function to update hook configuration
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Install hook with all optional components
#' setup_commit_hook()
#'
#' # Install hook without testthat (faster commits)
#' setup_commit_hook(testthat = FALSE)
#'
#' # Install hook with only required checks (minimal)
#' setup_commit_hook(lint = FALSE, format = FALSE, testthat = FALSE)
#'
#' # Install hook for quick development (no tests, no linting)
#' setup_commit_hook(lint = FALSE, testthat = FALSE)
#'
#' # After installation, commit normally:
#' # git commit -m "your message"
#'
#' # Or bypass the hook when needed:
#' # git commit --no-verify -m "WIP: quick save"
#' }
setup_commit_hook <- function(lint = TRUE, format = TRUE, testthat = TRUE) {
  # Print header
  cli::cli_rule(
    left = "SETUP PRE-COMMIT HOOK"
  )
  cli::cli_text()

  # Validate we're in a git repository
  if (!dir.exists(".git")) {
    cli::cli_alert_danger("Not a git repository!")
    cli::cli_text()
    cli::cli_text(
      "This function must be run from the root of a git repository."
    )
    cli::cli_text("Initialize git first: {.code git init}")
    cli::cli_rule()
    cli::cli_abort("Cannot install pre-commit hook outside git repository")
  }

  cli::cli_alert_success("Git repository detected")
  cli::cli_text()

  # Show configuration
  cli::cli_h3("HOOK CONFIGURATION:")
  cli::cli_text()
  cli::cli_text("Optional components:")
  cli::cli_ul(c(
    paste0(
      "Jarl linting: ",
      if (lint) "{.strong enabled}" else "{.emph disabled}"
    ),
    paste0(
      "Air formatting: ",
      if (format) "{.strong enabled}" else "{.emph disabled}"
    ),
    paste0(
      "Testthat tests: ",
      if (testthat) "{.strong enabled}" else "{.emph disabled}"
    )
  ))
  cli::cli_text()
  cli::cli_text("Required components (always enabled):")
  cli::cli_ul(c(
    "{.strong devtools::document()} - Update documentation",
    "{.strong devtools::check()} - R CMD check (stops on errors)"
  ))
  cli::cli_text()

  # Generate the hook script
  cli::cli_alert_info("Generating pre-commit hook script...")

  # Build the hook content dynamically
  hook_content <- c(
    "#!/bin/bash",
    "# ==============================================================================",
    "# PRE-COMMIT HOOK FOR R PACKAGE DEVELOPMENT",
    "# ==============================================================================",
    "#",
    "# This hook was generated by setup_commit_hook() from blankpkg template.",
    "#",
    "# WHAT IT DOES:",
    if (lint) "#   1. Runs jarl linter with auto-fix (if jarl is installed)",
    if (format) {
      paste0(
        "#   ",
        if (lint) "2" else "1",
        ". Runs air formatter on all R files (if air is installed)"
      )
    },
    if (testthat) {
      paste0("#   ", sum(c(lint, format)) + 1, ". Runs testthat tests")
    },
    paste0(
      "#   ",
      sum(c(lint, format, testthat)) + 1,
      ". Updates package documentation (devtools::document())"
    ),
    paste0(
      "#   ",
      sum(c(lint, format, testthat)) + 2,
      ". Runs R CMD check with CRAN standards"
    ),
    "#",
    "# TO SKIP THIS HOOK FOR A SINGLE COMMIT:",
    "#   git commit --no-verify -m \"your message\"",
    "#",
    "# TO DISABLE THIS HOOK PERMANENTLY:",
    "#   rm .git/hooks/pre-commit",
    "#",
    "# ==============================================================================",
    "",
    "set -e  # Exit on first error",
    "",
    "echo \"================================================================================\"",
    "echo \"PRE-COMMIT HOOK: Running code quality checks\"",
    "echo \"================================================================================\"",
    "echo \"\"",
    "",
    "# Colors for output",
    "RED='\\033[0;31m'",
    "GREEN='\\033[0;32m'",
    "YELLOW='\\033[1;33m'",
    "NC='\\033[0m' # No Color",
    "",
    "# Track overall success",
    "HOOK_FAILED=0",
    "",
    "# Count steps",
    paste0("TOTAL_STEPS=", sum(c(lint, format, testthat)) + 2),
    "CURRENT_STEP=0",
    ""
  )

  # Add jarl linting step if enabled
  if (lint) {
    hook_content <- c(
      hook_content,
      "# ==============================================================================",
      "# Jarl Linter (optional)",
      "# ==============================================================================",
      "",
      "CURRENT_STEP=$((CURRENT_STEP + 1))",
      "echo \"STEP $CURRENT_STEP/$TOTAL_STEPS: Running jarl linter...\"",
      "echo \"--------------------------------------------------------------------------------\"",
      "",
      "if command -v jarl &> /dev/null; then",
      "    echo \"jarl found - running linter with auto-fix...\"",
      "",
      "    # Lint and auto-fix R directory",
      "    if jarl lint --fix R/ 2>&1; then",
      "        echo -e \"${GREEN}✓ Jarl linting completed${NC}\"",
      "",
      "        # Stage any files that were auto-fixed",
      "        if ls R/*.R 1> /dev/null 2>&1; then",
      "            git add R/*.R",
      "        fi",
      "    else",
      "        echo -e \"${RED}✗ Jarl linting failed${NC}\"",
      "        echo \"Fix the linting errors above before committing.\"",
      "        HOOK_FAILED=1",
      "    fi",
      "else",
      "    echo -e \"${YELLOW}⚠ jarl not found - skipping linting${NC}\"",
      "    echo \"Install jarl: source('dev/install_linter_jarl.R')\"",
      "fi",
      "",
      "echo \"\"",
      ""
    )
  }

  # Add air formatting step if enabled
  if (format) {
    hook_content <- c(
      hook_content,
      "# ==============================================================================",
      "# Air Formatter (optional)",
      "# ==============================================================================",
      "",
      "CURRENT_STEP=$((CURRENT_STEP + 1))",
      "echo \"STEP $CURRENT_STEP/$TOTAL_STEPS: Running air formatter...\"",
      "echo \"--------------------------------------------------------------------------------\"",
      "",
      "if command -v air &> /dev/null; then",
      "    echo \"air found - formatting R files...\"",
      "",
      "    # Format all R files",
      "    if air format . 2>&1; then",
      "        echo -e \"${GREEN}✓ Air formatting completed${NC}\"",
      "",
      "        # Stage any files that were formatted",
      "        if ls R/*.R 1> /dev/null 2>&1; then",
      "            git add R/*.R",
      "        fi",
      "        find tests -name \"*.R\" -type f 2>/dev/null | xargs -r git add",
      "        if ls dev/*.R 1> /dev/null 2>&1; then",
      "            git add dev/*.R",
      "        fi",
      "    else",
      "        echo -e \"${RED}✗ Air formatting failed${NC}\"",
      "        echo \"Fix the formatting errors above before committing.\"",
      "        HOOK_FAILED=1",
      "    fi",
      "else",
      "    echo -e \"${YELLOW}⚠ air not found - skipping formatting${NC}\"",
      "    echo \"Install air: source('dev/install_formatter_air.R')\"",
      "fi",
      "",
      "echo \"\"",
      ""
    )
  }

  # Add testthat step if enabled
  if (testthat) {
    hook_content <- c(
      hook_content,
      "# ==============================================================================",
      "# Testthat Tests (optional)",
      "# ==============================================================================",
      "",
      "CURRENT_STEP=$((CURRENT_STEP + 1))",
      "echo \"STEP $CURRENT_STEP/$TOTAL_STEPS: Running testthat tests...\"",
      "echo \"--------------------------------------------------------------------------------\"",
      "",
      "if Rscript -e \"",
      "    if (!requireNamespace('testthat', quietly = TRUE)) {",
      "        cat('testthat not installed - skipping tests\\\\n')",
      "        quit(status = 0)",
      "    }",
      "    if (!dir.exists('tests/testthat')) {",
      "        cat('No tests found in tests/testthat/ - skipping\\\\n')",
      "        quit(status = 0)",
      "    }",
      "    cat('Running tests...\\\\n')",
      "    devtools::test()",
      "\" 2>&1; then",
      "    echo -e \"${GREEN}✓ Tests passed${NC}\"",
      "else",
      "    echo -e \"${RED}✗ Tests failed${NC}\"",
      "    echo \"Fix the failing tests before committing.\"",
      "    HOOK_FAILED=1",
      "fi",
      "",
      "echo \"\"",
      ""
    )
  }

  # Add documentation step (always included)
  hook_content <- c(
    hook_content,
    "# ==============================================================================",
    "# Update Documentation (required)",
    "# ==============================================================================",
    "",
    "CURRENT_STEP=$((CURRENT_STEP + 1))",
    "echo \"STEP $CURRENT_STEP/$TOTAL_STEPS: Updating package documentation...\"",
    "echo \"--------------------------------------------------------------------------------\"",
    "",
    "if Rscript -e \"devtools::document()\" 2>&1; then",
    "    echo -e \"${GREEN}✓ Documentation updated${NC}\"",
    "",
    "    # Stage updated documentation files",
    "    [ -d man ] && git add man/*.Rd 2>/dev/null || true",
    "    [ -f NAMESPACE ] && git add NAMESPACE",
    "    [ -f R/globals.R ] && git add R/globals.R",
    "else",
    "    echo -e \"${RED}✗ Documentation update failed${NC}\"",
    "    echo \"Fix documentation errors before committing.\"",
    "    HOOK_FAILED=1",
    "fi",
    "",
    "echo \"\"",
    ""
  )

  # Add R CMD check step (always included)
  hook_content <- c(
    hook_content,
    "# ==============================================================================",
    "# R CMD Check (required)",
    "# ==============================================================================",
    "",
    "CURRENT_STEP=$((CURRENT_STEP + 1))",
    "echo \"STEP $CURRENT_STEP/$TOTAL_STEPS: Running R CMD check (CRAN standards)...\"",
    "echo \"--------------------------------------------------------------------------------\"",
    "echo \"NOTE: This may take 30-90 seconds. Use --no-verify to skip for quick commits.\"",
    "echo \"\"",
    "",
    "if Rscript -e \"",
    "    result <- devtools::check(",
    "        document = FALSE,    # Already documented above",
    "        cran = TRUE,         # CRAN standards",
    "        error_on = 'error'   # Fail on errors only",
    "    )",
    "",
    "    # Exit with error code if there are errors",
    "    if (length(result\\$errors) > 0) {",
    "        quit(status = 1)",
    "    }",
    "\" 2>&1; then",
    "    echo -e \"${GREEN}✓ R CMD check passed${NC}\"",
    "else",
    "    echo -e \"${RED}✗ R CMD check failed${NC}\"",
    "    echo \"\"",
    "    echo \"Fix the errors above before committing.\"",
    "    echo \"Warnings and notes are allowed, but errors must be fixed.\"",
    "    HOOK_FAILED=1",
    "fi",
    "",
    "echo \"\"",
    ""
  )

  # Add summary section
  hook_content <- c(
    hook_content,
    "# ==============================================================================",
    "# Summary",
    "# ==============================================================================",
    "",
    "echo \"================================================================================\"",
    "if [ $HOOK_FAILED -eq 0 ]; then",
    "    echo -e \"${GREEN}✓ PRE-COMMIT CHECKS PASSED${NC}\"",
    "    echo \"================================================================================\"",
    "    echo \"\"",
    "    echo \"Your commit is ready to proceed.\"",
    "    echo \"All quality checks passed successfully.\"",
    "    exit 0",
    "else",
    "    echo -e \"${RED}✗ PRE-COMMIT CHECKS FAILED${NC}\"",
    "    echo \"================================================================================\"",
    "    echo \"\"",
    "    echo \"Please fix the errors above before committing.\"",
    "    echo \"\"",
    "    echo \"To commit anyway (not recommended):\"",
    "    echo \"  git commit --no-verify -m 'your message'\"",
    "    echo \"\"",
    "    exit 1",
    "fi"
  )

  # Write the hook file
  hook_path <- ".git/hooks/pre-commit"
  cli::cli_alert_info("Writing hook to {.file {hook_path}} ...")

  # Create hooks directory if it doesn't exist
  if (!dir.exists(".git/hooks")) {
    dir.create(".git/hooks", recursive = TRUE)
  }

  # Write the hook
  writeLines(hook_content, hook_path)

  # Make executable (chmod +x)
  Sys.chmod(hook_path, mode = "0755")

  cli::cli_alert_success("Hook installed successfully")
  cli::cli_text()

  # Summary
  cli::cli_rule("INSTALLATION COMPLETE")
  cli::cli_text()

  cli::cli_h3("HOOK ENABLED WITH:")
  cli::cli_ul(c(
    if (lint) "Jarl linting (skips if not installed)",
    if (format) "Air formatting (skips if not installed)",
    if (testthat) "Testthat tests (skips if no tests found)",
    "devtools::document() - Update docs {.emph (always runs)}",
    "devtools::check() - R CMD check {.emph (always runs, stops on errors)}"
  ))
  cli::cli_text()

  cli::cli_h3("HOW TO USE:")
  cli::cli_text("The hook runs automatically before each commit:")
  cli::cli_code("git commit -m \"your message\"")
  cli::cli_text()

  cli::cli_text("To bypass the hook when needed (use sparingly):")
  cli::cli_code("git commit --no-verify -m \"WIP: quick save\"")
  cli::cli_text()

  cli::cli_h3("TO RECONFIGURE:")
  cli::cli_text("Re-run this function with different arguments:")
  cli::cli_code("# Faster hook without tests")
  cli::cli_code("source(\"dev/setup_commit_hook.R\")")
  cli::cli_code("setup_commit_hook(testthat = FALSE)")
  cli::cli_text()

  cli::cli_h3("TO DISABLE:")
  cli::cli_code("rm .git/hooks/pre-commit")
  cli::cli_text()

  cli::cli_rule()

  invisible(TRUE)
}
