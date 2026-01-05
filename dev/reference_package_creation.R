# ==============================================================================
# SETUP NEW PACKAGE
# ==============================================================================
#
# PURPOSE:
#   Reference script showing steps used to create this package template
#
# USAGE:
#   DON'T RUN THIS SCRIPT DIRECTLY!
#   This is a reference showing the commands used to set up the package
#   infrastructure. Use individual commands as needed for new packages.
#
# PREREQUISITES:
#   - usethis, here, roxyglobals packages installed
#   - For new package: Run from parent directory of where package will be created
#
# WHAT THIS DOES:
#   Documents the complete setup process for this package template:
#   1. Creates package skeleton with usethis::create_package()
#   2. Initializes git repository
#   3. Sets up MIT license
#   4. Configures testthat for testing
#   5. Enables roxygen2 markdown support
#   6. Sets up pkgdown for website
#   7. Adds spell checking
#   8. Creates NEWS.md
#   9. Configures air formatter
#   10. Sets up roxyglobals for automatic global variable detection
#
# EXPECTED OUTPUT:
#   N/A - This is a reference script, not meant to be executed
#
# NOTES:
#   - DON'T RUN! Reference only - this is a historical record
#   - This script shows what was used to create this package template
#   - usethis::create_package() restarts RStudio automatically
#   - Commands shown in order they were originally executed
#   - Adapt these commands for your own new packages
#   - Some commands may prompt for user confirmation
#   - Think of this as a "recipe" that was already "cooked"
#
# WHY IS THIS SCRIPT HERE?
#   - Documents how the package infrastructure was created
#   - Helps you understand what each piece does
#   - Provides template for creating new packages from scratch
#   - Reference when troubleshooting package setup issues
#
# ==============================================================================

# DON'T RUN THIS SCRIPT!
# This is a historical reference of functions used to create this package template

library(usethis)
library(here)
library(roxyglobals)

# Move one folder up
setwd(here::here())
setwd("..")

# Create skeleton
# Restarts RStudio
# Moves root folder to the project folder
usethis::create_package("blankpkg")

# Setup git
usethis::use_git()

# Package license
usethis::use_mit_license()

# Create testthat infra
usethis::use_testthat()

# Allow using markdown in roxygen2 docs
usethis::use_roxygen_md()

# Setup infra for package website
usethis::use_pkgdown()

# Add words to the spell check dictionary
usethis::use_spell_check()

# Create NEWS.md (asks about committing the file)
usethis::use_news_md(open = FALSE)

# Sets air (https://posit-dev.github.io/air/) as formatter
usethis::use_air(vscode = FALSE)

# Setup autodetection of global variables
# https://github.com/anthonynorth/roxyglobals
# Adds roxygen tag @autoglobal
# Add it to every function
roxyglobals::use_roxyglobals()
roxyglobals::options_set_unique(TRUE)
