#' Interactive Guide to Customize Pkgdown Website
#'
#' Provides comprehensive templates and guidance for customizing your package
#' website appearance and structure using pkgdown configuration.
#'
#' @return Invisibly returns `TRUE` after displaying the customization guide.
#'   Stops with an error if _pkgdown.yml file is not found.
#'
#' @details
#' This function takes no parameters and operates on the current package directory.
#' It provides an interactive guide to pkgdown website customization by performing
#' the following steps:
#'
#' 1. Checks for required dependencies (installs if needed)
#' 2. Detects package name from DESCRIPTION
#' 3. Analyzes current _pkgdown.yml configuration
#' 4. Provides templates for common customizations
#' 5. Guides you through configuration options
#' 6. Shows examples of advanced features
#' 7. In interactive mode, offers to build and preview the current site
#'
#' @section Customization Topics:
#' The guide covers 6 major customization areas:
#' - Basic configuration (URL, bootstrap version, theme)
#' - Themes and appearance (20+ Bootswatch themes, custom colors, fonts)
#' - Navigation bar structure, menus, and components
#' - Function reference organization by categories
#' - Home page title, description, links, and sidebar
#' - Deployment options (manual vs GitHub Actions)
#'
#' @section After Customization:
#' 1. Edit _pkgdown.yml with chosen customizations
#' 2. Build site: [pkgdown_build_site()]
#' 3. Preview: Open docs/index.html
#' 4. Deploy to GitHub Pages
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - _pkgdown.yml file should exist (create with `usethis::use_pkgdown()`)
#' - Package should have basic documentation
#'
#' @section Notes:
#' - Templates provided as copy-paste YAML
#' - All examples are fully functional
#' - Customize templates to match your needs
#' - In interactive mode, offers to preview current site
#' - See https://pkgdown.r-lib.org/ for full documentation
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # View customization guide
#' help_customize_website()
#'
#' # Follow templates to edit _pkgdown.yml
#' # Then build site:
#' pkgdown_build_site()
#' }
help_customize_website <- function() {
  # Check and install dependencies
  if (!requireNamespace("pkgdown", quietly = TRUE)) {
    cli::cli_alert_info("Installing required package: {.pkg pkgdown}")
    utils::install.packages("pkgdown")
  }

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

  pkg_name <- get_package_name()

  # Print header
  cli::cli_rule(
    left = "PKGDOWN SITE CUSTOMIZATION GUIDE"
  )
  cli::cli_text()
  cli::cli_alert_info("Package: {.pkg {pkg_name}}")
  cli::cli_text()

  # Check current configuration
  if (file.exists("_pkgdown.yml")) {
    cli::cli_h2("Current _pkgdown.yml configuration:")
    cli::cli_text()
    current_config <- readLines("_pkgdown.yml")
    cli::cli_code(paste(current_config, collapse = "\n"))
    cli::cli_text()
  } else {
    cli::cli_alert_danger("WARNING: _pkgdown.yml not found!")
    cli::cli_alert_info("Run: {.code usethis::use_pkgdown()}")
    cli::cli_text()
    cli::cli_abort("_pkgdown.yml required")
  }

  # Main customization guide
  cli::cli_rule("CUSTOMIZATION OPTIONS")
  cli::cli_text()
  cli::cli_text("Below are templates for common pkgdown customizations.")
  cli::cli_text(
    "Copy the sections you want to _pkgdown.yml and modify as needed."
  )
  cli::cli_text()

  # Section 1: Basic Configuration
  cli::cli_h2("1. BASIC CONFIGURATION")
  cli::cli_text()
  cli::cli_text("Minimal but complete configuration:")
  cli::cli_text()
  cli::cli_code(paste0(
    "url: https://yourusername.github.io/",
    pkg_name,
    "/\n",
    "template:\n",
    "  bootstrap: 5\n",
    "  bootswatch: cosmo  # Theme: cosmo, flatly, cerulean, journal, etc.\n",
    "\n",
    "home:\n",
    "  title: ",
    pkg_name,
    " - Your Package Title\n",
    "  description: A brief description of your package"
  ))
  cli::cli_text()

  # Section 2: Themes
  cli::cli_h2("2. THEMES AND APPEARANCE")
  cli::cli_text()
  cli::cli_text("Popular Bootswatch themes {.url https://bootswatch.com/}:")
  cli::cli_text()

  cli::cli_h3("Modern & Clean:")
  cli::cli_ul(c(
    "bootswatch: cosmo      # Clean, modern",
    "bootswatch: flatly     # Flat design",
    "bootswatch: lumen      # Light, spacious",
    "bootswatch: minty      # Fresh, green accents"
  ))
  cli::cli_text()

  cli::cli_h3("Professional:")
  cli::cli_ul(c(
    "bootswatch: cerulean   # Professional blue",
    "bootswatch: united     # Corporate",
    "bootswatch: yeti       # Clean professional"
  ))
  cli::cli_text()

  cli::cli_h3("Dark Themes:")
  cli::cli_ul(c(
    "bootswatch: darkly     # Dark theme",
    "bootswatch: cyborg     # Dark with blue accents",
    "bootswatch: slate      # Dark gray"
  ))
  cli::cli_text()

  cli::cli_h3("Custom colors:")
  cli::cli_text()
  cli::cli_code(paste0(
    "template:\n",
    "  bootstrap: 5\n",
    "  bslib:\n",
    "    primary: '#0051BA'        # Main color\n",
    "    success: '#28A745'        # Success messages\n",
    "    info: '#17A2B8'           # Info boxes\n",
    "    warning: '#FFC107'        # Warnings\n",
    "    danger: '#DC3545'         # Errors\n",
    "    base_font: {google: 'Roboto'}\n",
    "    heading_font: {google: 'Roboto Slab'}\n",
    "    code_font: {google: 'JetBrains Mono'}"
  ))
  cli::cli_text()

  # Section 3: Navigation
  cli::cli_h2("3. NAVIGATION BAR")
  cli::cli_text()
  cli::cli_text("Customize navigation menu:")
  cli::cli_text()
  cli::cli_code(paste0(
    "navbar:\n",
    "  structure:\n",
    "    left:  [intro, reference, articles, tutorials, news]\n",
    "    right: [search, github]\n",
    "  components:\n",
    "    home: ~  # Remove home icon\n",
    "    articles:\n",
    "      text: Articles\n",
    "      menu:\n",
    "        - text: Getting Started\n",
    "          href: articles/getting-started.html\n",
    "        - text: Advanced Usage\n",
    "          href: articles/advanced.html\n",
    "        - text: -------  # Separator\n",
    "        - text: All Articles\n",
    "          href: articles/index.html\n",
    "    github:\n",
    "      icon: fab fa-github fa-lg\n",
    "      href: https://github.com/yourusername/",
    pkg_name,
    "\n",
    "      aria-label: GitHub"
  ))
  cli::cli_text()

  # Section 4: Function Reference
  cli::cli_h2("4. FUNCTION REFERENCE ORGANIZATION")
  cli::cli_text()
  cli::cli_text("Organize functions into categories:")
  cli::cli_text()
  cli::cli_code(paste0(
    "reference:\n",
    "  - title: Main Functions\n",
    "    desc: Core functionality for end users\n",
    "    contents:\n",
    "      - has_concept('main')  # Functions with @concept main\n",
    "      - starts_with('plot_') # All plot_* functions\n",
    "  \n",
    "  - title: Data Manipulation\n",
    "    desc: Functions for data processing\n",
    "    contents:\n",
    "      - starts_with('data_')\n",
    "  \n",
    "  - title: Utilities\n",
    "    desc: Helper and utility functions\n",
    "    contents:\n",
    "      - starts_with('utils_')\n",
    "  \n",
    "  - title: Internal Functions\n",
    "    desc: Internal functions (not for end users)\n",
    "    contents:\n",
    "      - matches('_internal')"
  ))
  cli::cli_text()

  cli::cli_h3("Function selectors available:")
  cli::cli_ul(c(
    "starts_with('prefix_')   # By prefix",
    "ends_with('_suffix')     # By suffix",
    "matches('pattern')       # Regex pattern",
    "has_concept('concept')   # By @concept tag",
    "has_keyword('keyword')   # By @keywords tag",
    "lacks_concepts()         # No concepts"
  ))
  cli::cli_text()

  # Section 5: Home Page
  cli::cli_h2("5. HOME PAGE CUSTOMIZATION")
  cli::cli_text()
  cli::cli_text("Customize home page sections:")
  cli::cli_text()
  cli::cli_code(paste0(
    "home:\n",
    "  title: ",
    pkg_name,
    " - Fast Data Processing\n",
    "  description: |\n",
    "    A comprehensive package for data processing with\n",
    "    performance and ease of use in mind.\n",
    "  \n",
    "  links:\n",
    "    - text: Browse source code\n",
    "      href: https://github.com/yourusername/",
    pkg_name,
    "\n",
    "    - text: Report a bug\n",
    "      href: https://github.com/yourusername/",
    pkg_name,
    "/issues\n",
    "  \n",
    "  sidebar:\n",
    "    structure: [links, license, community, citation, authors, dev]"
  ))
  cli::cli_text()

  # Section 6: Deployment
  cli::cli_h2("6. GITHUB PAGES DEPLOYMENT")
  cli::cli_text()

  cli::cli_h3("Option 1: Manual deployment (from docs/):")
  cli::cli_ol(c(
    "Build site: pkgdown_build_site()",
    "Commit docs/ directory",
    "Push to GitHub",
    "Settings -> Pages -> Source: main branch /docs folder"
  ))
  cli::cli_text()

  cli::cli_h3("Option 2: GitHub Actions (automatic):")
  cli::cli_text("Run: {.code usethis::use_pkgdown_github_pages()}")
  cli::cli_text("This sets up automatic deployment on push")
  cli::cli_text()

  # Complete Example
  cli::cli_rule("COMPLETE EXAMPLE CONFIGURATION")
  cli::cli_text()
  cli::cli_text("Copy this entire template to _pkgdown.yml and customize:")
  cli::cli_text()
  cli::cli_code(paste0(
    "# Package website URL\n",
    "url: https://yourusername.github.io/",
    pkg_name,
    "/\n\n",
    "# Template configuration\n",
    "template:\n",
    "  bootstrap: 5\n",
    "  bootswatch: cosmo\n",
    "  bslib:\n",
    "    primary: '#0051BA'\n",
    "    base_font: {google: 'Roboto'}\n",
    "    code_font: {google: 'Fira Code'}\n",
    "  \n",
    "  opengraph:\n",
    "    image:\n",
    "      src: man/figures/logo.png\n",
    "    twitter:\n",
    "      creator: '@yourusername'\n",
    "      card: summary\n\n",
    "# Home page\n",
    "home:\n",
    "  title: ",
    pkg_name,
    " - Your Package Subtitle\n",
    "  description: |\n",
    "    A comprehensive description of what your package does.\n",
    "    Use multiple lines for better readability.\n\n",
    "# Navigation\n",
    "navbar:\n",
    "  structure:\n",
    "    left:  [intro, reference, articles, news]\n",
    "    right: [search, github]\n",
    "  components:\n",
    "    github:\n",
    "      icon: fab fa-github fa-lg\n",
    "      href: https://github.com/yourusername/",
    pkg_name,
    "\n\n",
    "# Function reference\n",
    "reference:\n",
    "  - title: Main Functions\n",
    "    desc: Core package functionality\n",
    "    contents:\n",
    "      - starts_with('main_')\n",
    "  \n",
    "  - title: Utilities\n",
    "    desc: Helper functions\n",
    "    contents:\n",
    "      - starts_with('utils_')\n\n",
    "# Development mode\n",
    "development:\n",
    "  mode: auto"
  ))
  cli::cli_text()

  # Next Steps
  cli::cli_rule("NEXT STEPS")
  cli::cli_text()
  cli::cli_ol(c(
    "Edit _pkgdown.yml with your chosen customizations",
    "Build the site: {.code pkgdown_build_site()}",
    "Preview locally: Open {.file docs/index.html} in your browser",
    "Deploy to GitHub Pages: Push docs/ or use GitHub Actions"
  ))
  cli::cli_text()

  cli::cli_h3("RESOURCES:")
  cli::cli_ul(c(
    "pkgdown documentation: {.url https://pkgdown.r-lib.org/}",
    "Customization guide: {.url https://pkgdown.r-lib.org/articles/customise.html}",
    "Example sites: dplyr, ggplot2, testthat"
  ))
  cli::cli_text()
  cli::cli_rule()

  # Offer to preview current site (interactive mode only)
  if (interactive()) {
    cli::cli_text()
    response <- utils::askYesNo(
      "Would you like to preview the current site?",
      default = FALSE
    )

    if (isTRUE(response)) {
      cli::cli_text()
      cli::cli_alert_info("Running {.code pkgdown::build_site()} ...")
      cli::cli_text()
      pkgdown::build_site()
      cli::cli_text()
      cli::cli_alert_success("Site built! Opening docs/index.html...")
      cli::cli_alert_info(
        "If it doesn't open automatically, navigate to {.file docs/index.html}"
      )
      cli::cli_text()
    }
  } else {
    cli::cli_text()
    cli::cli_alert_info("Skipping preview (non-interactive mode)")
    cli::cli_alert_info(
      "To preview: {.code pkgdown::build_site()} then open {.file docs/index.html}"
    )
    cli::cli_text()
  }

  cli::cli_alert_success("Customization guide complete!")

  invisible(TRUE)
}
