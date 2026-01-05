#' Install jarl linter (Rust-based CLI tool)
#'
#' Displays platform-specific installation instructions for jarl, a fast
#' Rust-based command-line linter for R. Jarl is not an R package - it's a
#' standalone CLI tool that must be installed separately.
#'
#' @return Invisibly returns TRUE on success.
#'
#' @details
#' Jarl is a command-line linting tool written in Rust that provides extremely
#' fast code analysis for R files. It's approximately 140x faster than lintr
#' (0.13s vs 18.5s on 25k lines of code).
#'
#' This function detects your operating system and displays the appropriate
#' installation command that you should run in your terminal (not in R).
#'
#' \strong{Installation locations:}
#' \itemize{
#'   \item Linux/macOS: Downloads installer script and installs to ~/.cargo/bin/
#'   \item Windows: Downloads PowerShell installer
#'   \item Alternative: Install via Cargo (Rust package manager)
#' }
#'
#' After installation, jarl is available as a system command from your terminal.
#'
#' @section Performance:
#' Benchmarked on dplyr package (~25k lines of R code):
#' \itemize{
#'   \item jarl: 0.131 seconds
#'   \item lintr: 18.5 seconds (140x slower)
#' }
#'
#' @section Resources:
#' \itemize{
#'   \item GitHub: \url{https://github.com/etiennebacher/jarl}
#'   \item Blog: \url{https://www.etiennebacher.com/posts/2025-11-20-introducing-jarl/}
#'   \item VS Code extension: Search "jarl" in extensions marketplace
#' }
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' help_install_jarl()
#' # Then run the displayed command in your terminal
#' }
help_install_jarl <- function() {
  # TODO: Future enhancement (Option 2 - Automated installation)
  # ============================================================
  # Consider adding automated installation using system() calls:
  # - Add install_now parameter (default FALSE for safety)
  # - Use system2() to run platform-specific installer scripts
  # - Add confirmation prompt before running system commands
  # - Warn about system-level changes and permission requirements
  # - Handle errors from system() calls gracefully
  # - Verify installation with system2("jarl", "--version")
  # - May require elevated permissions on some systems
  # Challenges:
  # - Security concerns with running remote scripts
  # - PATH updates may not take effect until terminal restart
  # - Different security policies across systems
  # - Need to handle firewall/antivirus interference

  # Check for cli package
  if (!requireNamespace("cli", quietly = TRUE)) {
    utils::install.packages('cli')
  }

  # Print header
  cli::cli_rule(center = "INSTALL JARL LINTER (RUST-BASED CLI TOOL)")
  cli::cli_text("")

  cli::cli_alert_warning("IMPORTANT: Jarl is NOT an R package!")
  cli::cli_text("It's a standalone command-line tool written in Rust.")
  cli::cli_text(
    "It will be installed as a system command, not in your R library."
  )
  cli::cli_text("")

  # Detect OS
  os <- Sys.info()["sysname"]
  cli::cli_alert_info("Detected OS: {os}")
  cli::cli_text("")

  # Installation instructions based on OS
  if (os == "Linux" || os == "Darwin") {
    cli::cli_h2("Linux/macOS Installation")
    cli::cli_text("")

    cli::cli_text("The installer will:")
    cli::cli_ul(c(
      "Download the latest jarl binary for your system",
      "Install it to ~/.cargo/bin/ (or similar location)",
      "Make it available as 'jarl' command"
    ))
    cli::cli_text("")

    cli::cli_text(
      "Run this command in your {.strong terminal} (not R console):"
    )
    cli::cli_text("")
    cli::cli_code(
      "curl --proto '=https' --tlsv1.2 -LsSf https://github.com/etiennebacher/jarl/releases/latest/download/jarl-installer.sh | sh"
    )
    cli::cli_text("")

    cli::cli_h3("After installation")
    cli::cli_text("Verify with:")
    cli::cli_code("jarl --version")
    cli::cli_text("")
    cli::cli_text("NOTE: You may need to restart your terminal or run:")
    cli::cli_code("source ~/.bashrc    # or ~/.zshrc, depending on your shell")
    cli::cli_text("")
  } else if (os == "Windows") {
    cli::cli_h2("Windows Installation")
    cli::cli_text("")

    cli::cli_text("The installer will:")
    cli::cli_ul(c(
      "Download the latest jarl binary for Windows",
      "Install it to a standard location",
      "Make it available as 'jarl' command"
    ))
    cli::cli_text("")

    cli::cli_text("Run this command in {.strong PowerShell}:")
    cli::cli_text("")
    cli::cli_code(
      "irm https://github.com/etiennebacher/jarl/releases/latest/download/jarl-installer.ps1 | iex"
    )
    cli::cli_text("")

    cli::cli_h3("After installation")
    cli::cli_text("Verify with:")
    cli::cli_code("jarl --version")
    cli::cli_text("")
    cli::cli_text("NOTE: You may need to restart PowerShell.")
    cli::cli_text("")
  } else {
    cli::cli_alert_danger("Unsupported OS detected")
    cli::cli_text("Please install manually using Cargo (see below).")
    cli::cli_text("")
  }

  # Alternative: Cargo installation
  cli::cli_rule(center = "ALTERNATIVE: INSTALL VIA CARGO")
  cli::cli_text("")

  cli::cli_text("If you have the Rust toolchain installed:")
  cli::cli_text("")
  cli::cli_code(
    "cargo install --git https://github.com/etiennebacher/jarl jarl --profile=release"
  )
  cli::cli_text("")
  cli::cli_text("To install Rust first, visit: {.url https://rustup.rs/}")
  cli::cli_text("")

  # Usage instructions
  cli::cli_rule(center = "USAGE (AFTER INSTALLATION)")
  cli::cli_text("")

  cli::cli_alert_info("Jarl is a COMMAND-LINE TOOL, not an R package")
  cli::cli_text("Use it from the terminal/command prompt:")
  cli::cli_text("")

  cli::cli_h3("Basic commands")
  cli::cli_text("Lint a single file:")
  cli::cli_code("jarl lint path/to/file.R")
  cli::cli_text("")

  cli::cli_text("Lint entire directory:")
  cli::cli_code("jarl lint R/")
  cli::cli_text("")

  cli::cli_text("Lint with auto-fix:")
  cli::cli_code("jarl lint --fix R/")
  cli::cli_text("")

  cli::cli_text("Show help:")
  cli::cli_code("jarl --help")
  cli::cli_code("jarl lint --help")
  cli::cli_text("")

  # Performance comparison
  cli::cli_h3("Performance")
  cli::cli_text("Benchmarked on dplyr package (~25,000 lines of R code):")
  cli::cli_ul(c(
    "jarl: 0.131 seconds",
    "lintr: 18.5 seconds {.emph (140x slower!)}"
  ))
  cli::cli_text("")

  # IDE integration
  cli::cli_h3("IDE Integration")
  cli::cli_text("VS Code/Positron extensions available:")
  cli::cli_ul(c(
    "Search 'jarl' in extensions marketplace",
    "Extension ID: EtienneBacher.jarl-vscode"
  ))
  cli::cli_text("")

  # Resources
  cli::cli_h3("More Information")
  cli::cli_ul(c(
    "Installation instructions: {.url https://github.com/etiennebacher/jarl#installation}",
    "GitHub: {.url https://github.com/etiennebacher/jarl}",
    "Blog: {.url https://www.etiennebacher.com/posts/2025-11-20-introducing-jarl/}",
    "Releases: {.url https://github.com/etiennebacher/jarl/releases}"
  ))
  cli::cli_text("")

  # R package alternatives
  cli::cli_rule(center = "R PACKAGE ALTERNATIVES")
  cli::cli_text("")

  cli::cli_text("If you prefer a traditional R package linter:")
  cli::cli_text("")

  cli::cli_text("lintr (most popular R linter):")
  cli::cli_code("install.packages('lintr')")
  cli::cli_code("lintr::lint_package()")
  cli::cli_text("")

  cli::cli_text("styler (code formatter):")
  cli::cli_code("install.packages('styler')")
  cli::cli_code("styler::style_pkg()")
  cli::cli_text("")

  cli::cli_rule()
  cli::cli_text("")
  cli::cli_alert_info(
    "To install jarl, copy the command above and run it in your terminal"
  )
  cli::cli_text("")

  invisible(TRUE)
}
