# ==============================================================================
# .Rprofile - Project-level R configuration
# ==============================================================================
#
# This file runs automatically when R starts in this directory.
# It sets up the development environment for this R package.
#
# ==============================================================================

# Quiet startup
if (interactive()) {
  # --------------------------------------------------------------------------
  # Package development helpers
  # --------------------------------------------------------------------------

  # Load devtools if available (for convenience)
  if (requireNamespace("devtools", quietly = TRUE)) {
    suppressMessages(library(devtools))
  }

  # Set options for package development
  options(
    # Use browser for help
    help_type = "html",

    # Warn on partial matches
    warnPartialMatchArgs = TRUE,
    warnPartialMatchAttr = TRUE,
    warnPartialMatchDollar = TRUE,

    # Show more in error traces (only if rlang is available)
    error = if (requireNamespace("rlang", quietly = TRUE)) {
      rlang::entrace
    } else {
      NULL
    },

    # Timezone
    tz = "UTC"
  )

  # --------------------------------------------------------------------------
  # Load development functions
  # --------------------------------------------------------------------------

  # Source all dev/ functions to make them available in the global environment
  if (dir.exists("dev")) {
    # Get all .R files in dev/ folder
    dev_files <- list.files("dev", pattern = "\\.R$", full.names = TRUE)

    # Exclude files that have executable code (not pure functions)
    exclude_patterns <- c(
      "pre_commit_hook", # Git hook, not an R file
      "reference_package_creation" # Has executable setup code
    )

    # Filter out excluded files
    for (pattern in exclude_patterns) {
      dev_files <- dev_files[!grepl(pattern, dev_files)]
    }

    # Source each file silently
    for (file in dev_files) {
      tryCatch(
        {
          source(file, local = FALSE) # Load into global environment
        },
        error = function(e) {
          # Silently skip files that can't be sourced
        }
      )
    }
  }

  cat("\nDevelopment functions loaded from dev/\n")
  cat("See dev/TUTORIAL.md for a complete guide\n\n")
}
