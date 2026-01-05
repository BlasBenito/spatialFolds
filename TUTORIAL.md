# Complete Tutorial: Using the blankpkg_template

**A comprehensive guide to creating R packages with speed and simplicity**

---

## Table of Contents

1. [Introduction](#introduction)
2. [Installation and Initial Setup](#installation-and-initial-setup)
3. [Customizing the Template](#customizing-the-template)
4. [Daily Development Workflow](#daily-development-workflow)
5. [Development Scripts Reference](#development-scripts-reference)
6. [Testing and Quality Assurance](#testing-and-quality-assurance)
7. [Building Documentation](#building-documentation)
8. [Preparing for CRAN (Optional)](#preparing-for-cran-optional)
9. [Advanced Topics](#advanced-topics)
10. [Troubleshooting](#troubleshooting)
11. [What to Keep vs. Replace](#what-to-keep-vs-replace)
12. [Best Practices and Tips](#best-practices-and-tips)
13. [Acknowledgements](#acknowledgements)
14. [Summary Checklist](#summary-checklist)
15. [Next Steps](#next-steps)

---

## Introduction

### What is `blankpkg_template`?

It's a complete R package template that gives you a comprehensive development infrastructure out of the box.

**Design Philosophy:** Make package development as fast and friction-free as possible.

### Key Features at a Glance

**Prefix-Based Organization**: Development functions are named with prefixes (`setup_*`, `daily_*`, `test_*`, `check_*`, `release_*`) so you discover functionality through autocomplete.

**Pre-Commit Quality Gates**: The function `setup_commit_hook()` installs a pre-commit hook that lints, formats, updates docs, and runs R CMD check.

**Optional CRAN Workflow**: CRAN submission is entirely optional. The template works perfectly for GitHub-only packages. Use the `release_*` functions and CRAN_CHECKLIST.md only if and when you're ready to submit.

---

## Installation and Initial Setup

Let's get you up and running. This takes about 10-15 minutes on first run.

### Step 1: Fork and Clone

**On GitHub:**
1. Navigate to the [`blankpkg_template` repository](https://github.com/BlasBenito/blankpkg_template)
2. Click **"Use this template"** (green button in the upper right corner) to create a new repository
3. Name your repository (use your package name: lowercase, no spaces)
4. Clone to your local machine:
   ```bash
   git clone https://github.com/YOUR-USERNAME/YOUR-PACKAGE-NAME.git
   cd YOUR-PACKAGE-NAME
   ```

**Open in RStudio or your preferred R IDE.**

### Step 2: Understanding Auto-Loaded Development Functions

**IMPORTANT:** When you start R in the package directory, the `.Rprofile` automatically **loads all development functions** from `dev/` into your environment

### Step 3: Install Development Dependencies

Start R in the package directory, then run:

```r
setup_install_tools()
```

**What it installs:**
- `devtools`, `roxygen2`, `usethis`, `testthat` (core development)
- `roxyglobals` (automatic global variable detection)
- `covr`, `spelling` (test coverage and spell checking)
- `pkgdown`, `pkgnet` (documentation website and dependency visualization)
- `goodpractice`, `rcmdcheck`, `codetools` (quality analysis)
- `rhub` (multi-platform CRAN checks)
- `microbenchmark`, `profvis` (performance analysis)

**Time:** 5-10 minutes on first run (installs in parallel for speed)

### Step 4: Optional - Install Code Quality Tools

**Install [jarl linter](https://jarl.etiennebacher.com/) (Rust-based, 140x faster than `lintr`):**

```r
help_install_jarl()
```

This displays installation instructions. **Important:** jarl is a CLI tool, not an R package. Install in your terminal (not R console):

**Linux/macOS:**
```bash
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/etiennebacher/jarl/releases/latest/download/jarl-installer.sh | sh
```

**Windows (PowerShell):**
```powershell
irm https://github.com/etiennebacher/jarl/releases/latest/download/jarl-installer.ps1 | iex
```

**Install [air formatter](https://posit-dev.github.io/air/) (wraps usethis::use_air()):**

```r
help_install_air()
```

This runs `usethis::use_air()` which sets up the air code formatter.

**Note:** Both tools are optional but recommended. The pre-commit hook will use them if installed, skip them if not.

### Step 5: Configure Your Multiplatform Check Environment (One-Time Setup)

**For R-Hub checks (multi-platform testing):**

```r
rhub::rhub_setup()
rhub::rhub_doctor()
```

Follow the prompts to authenticate with GitHub.

**Set GitHub PAT in `.Renviron`:**

```r
usethis::edit_r_environ()
```

Add this line (get your token from GitHub settings):

```
GITHUB_PAT=your_token_here
```

Restart R after editing `.Renviron`.

**You're now ready to customize the template for your package!**

---

## Customizing the Template

Now make this template yours. This is where it stops being "blankpkg" and becomes your actual package.

### Step 6: Update Package Metadata (CRITICAL)

Open `DESCRIPTION` and replace **ALL** placeholder text:

**Package name:**
```
Package: pkgname  →  Package: yourpackage
```
Use lowercase, no spaces. This is how users will call `library(yourpackage)`.

**Title (one line, title case):**
```
Title: What the Package Does (One Line, Title Case)
  →  Title: Your Actual Package Title Here
```

**Description (one paragraph, sentence case):**
```
Description: What the package does (one paragraph).
  →  Description: This package does X, Y, and Z. It provides functions for...
```

Be specific. Users see this on CRAN and in `?yourpackage`.

**Authors:**
```r
Authors@R: person(
    "First", "Last",
    email = "first.last@example.com",
    role = c("aut", "cre"),
    comment = c(ORCID = "YOUR-ORCID-ID")
)
```

Replace with your actual name and email. **CRAN will contact you at this email.**

**Maintainer:**

The `cre` (creator) role in `Authors@R` sets the maintainer automatically. Make sure the email is correct.

**URLs:**
```
URL: https://github.com/YOUR-USERNAME/YOUR-PACKAGE,
    https://YOUR-USERNAME.github.io/YOUR-PACKAGE/
BugReports: https://github.com/YOUR-USERNAME/YOUR-PACKAGE/issues
```

Update with your actual GitHub username and repository name.

**Dependencies:**

Review `Imports:` and `Suggests:`. The template includes common dev dependencies. Add packages your functions use under `Imports:`. Add optional packages (for vignettes, examples) under `Suggests:`.

### Step 7: Update License

Open `LICENSE` file:

```
YEAR: 2025  →  YEAR: 2026  (or current year)
COPYRIGHT HOLDER: blankpkg authors  →  COPYRIGHT HOLDER: Your Name
```

The template uses MIT license by default. If you prefer a different license, run:
```r
usethis::use_gpl3_license()  # or use_apache_license(), use_cc0_license(), etc.
```

### Step 8: Replace README (IMPORTANT)

**Delete the entire template README.Rmd.** Don't keep it—it's full of explanations about the *template itself*, not your package.

Create a new `README.Rmd` with your package documentation:

**Minimal structure:**
```markdown
---
output: github_document
---

# yourpackage

<!-- badges: start -->
[![R-CMD-check](https://github.com/YOUR-USERNAME/YOUR-PACKAGE/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/YOUR-USERNAME/YOUR-PACKAGE/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Installation

```r
# Install from GitHub
devtools::install_github("YOUR-USERNAME/YOUR-PACKAGE")
```

## Usage

```{r example}
library(yourpackage)
# Show a simple example
```

## Features

- Feature 1
- Feature 2
- Feature 3
```

**Update badge URLs:** Replace `YOUR-USERNAME/YOUR-PACKAGE` with your actual GitHub username and repository name.

**Render README.md:**
```r
build_readme()
```

This executes code chunks and creates `README.md` from `README.Rmd`.

### Step 9: Replace Example Code

The template includes demonstration code (`lm_model.R`, `dummy_df.rda`) to show you the structure. Now replace it with your own functions.

**Review the example (learn the pattern):**

```r
file.edit("R/lm_model.R")
```

Notice the roxygen2 documentation structure:
- `@title`, `@description` - What the function does
- `@param` - Each parameter explained
- `@return` - What the function returns
- `@details` - Implementation notes
- `@export` - Make function available to users
- `@autoglobal` - **CRITICAL**: Automatic global variable detection (required for every function)
- `@examples` - Working code examples

**Delete the example function:**

```r
file.remove("R/lm_model.R")
```

**Delete the example data (if your package doesn't need example data):**

```r
file.remove("data/dummy_df.rda")
file.remove("R/data.R")
```

**If you DO need example data,** use the template:
```r
template_create_dataset()
```

Modify the data generation code, then document it in `R/data.R` following the example pattern.

**Write your own functions:**

Create new files in `R/` directory. Use this pattern:

```r
#' Title of Your Function
#'
#' @description
#' One-paragraph description of what your function does.
#'
#' @param x Description of parameter x
#' @param y Description of parameter y
#'
#' @return What the function returns
#'
#' @export
#' @autoglobal
#'
#' @examples
#' your_function(x = 1, y = 2)
your_function <- function(x, y) {
  # Your code here
}
```

**CRITICAL:** Add `@autoglobal` to **EVERY** function. This uses roxyglobals to automatically detect and declare global variables. Without it, R CMD check will complain about undefined globals.

**After adding functions, run:**
```r
dev_check_quick()
```

This updates documentation and runs R CMD check to verify everything works.

### Step 10: Update Tests

**Review the example test:**
```r
file.edit("tests/testthat/test-lm_model.R")
```

**Delete it after reviewing:**
```r
file.remove("tests/testthat/test-lm_model.R")
```

**Write tests for your functions:**

Create `tests/testthat/test-yourfunction.R`:

```r
test_that("your_function works correctly", {
  result <- your_function(x = 1, y = 2)
  expect_equal(result, 3)
  expect_type(result, "double")
})

test_that("your_function handles errors", {
  expect_error(your_function(x = "not a number", y = 2))
})
```

**Run tests:**
```r
test_run()
```

All tests should pass before you commit.

**Congratulations!** You've customized the template. Before diving into daily workflows, let's set up continuous integration.

---

## Setup GitHub Actions (Continuous Integration)

Now that you've customized your package, set up GitHub Actions for automatic testing and documentation deployment.

### What GitHub Actions Does

**R-CMD-check workflow (already included):**
- ✅ Runs R CMD check automatically on every push
- ✅ Tests on multiple platforms: macOS, Windows, Ubuntu
- ✅ Tests with multiple R versions: devel, release, oldrel-1
- ✅ Creates a badge for your README showing build status

**pkgdown workflow (optional but recommended):**
- 🌐 Builds your package website automatically
- 🚀 Deploys to GitHub Pages on every push to main branch
- ⚡ No need to manually run `build_website()` and commit docs/
- 🎯 Your website automatically stays up-to-date

### Setup Command

After you've pushed your package to GitHub, run:

```r
# Setup both R-CMD-check and pkgdown (recommended)
setup_github_actions()

# Only verify/update R-CMD-check
setup_github_actions(pkgdown = FALSE)

# Only setup pkgdown deployment
setup_github_actions(rcmdcheck = FALSE, pkgdown = TRUE)
```

### Post-Setup Steps

1. **Commit the workflow files:**
   ```bash
   git add .github/workflows/
   git commit -m "Add GitHub Actions workflows"
   git push
   ```

2. **For pkgdown: Enable GitHub Pages**
   - Navigate to: Repository → Settings → Pages
   - Under "Source", select: **"GitHub Actions"**
   - Save
   - Your website will deploy to: `https://YOUR-USERNAME.github.io/YOUR-PACKAGE/`

3. **View workflow status:**
   - Go to: Repository → Actions tab
   - Workflows run automatically on each push
   - First run may take 3-5 minutes

### Monitoring Workflows

**Every push to GitHub automatically:**
- Runs R CMD check on 5 different platform/R version combinations
- Builds and deploys your pkgdown website (if enabled)
- Shows results with ✓ or ✗ in the Actions tab

**If a workflow fails:**
1. Click on the failed workflow in Actions tab
2. Expand the failed step to read error logs
3. Fix the issue locally with `dev_check_complete()`
4. Commit and push again - workflow reruns automatically

**Pro tip:** Add the R-CMD-check badge to your README to show build status:
```markdown
[![R-CMD-check](https://github.com/YOUR-USERNAME/YOUR-PACKAGE/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/YOUR-USERNAME/YOUR-PACKAGE/actions/workflows/R-CMD-check.yaml)
```

---

## Daily Development Workflow

Here's how you'll actually work with the template day-to-day. These are the scripts you'll use most frequently.

### Understanding Function Organization

Development functions are organized with **prefix-based naming** for autocomplete discovery:

- `setup_*` - Initial package setup, Rcpp configuration
- `daily_*` / `dev_*` - Common daily workflows (most used)
- `test_*` - Testing workflows
- `check_*` - Package validation and checking
- `build_*` - Building documentation (README, vignettes)
- `help_*` - Interactive guides and installation help
- `release_*` - CRAN submission (4-step process)
- `report_*` / `template_*` - Code analysis and templates

**Tip:** Type the prefix (e.g., `dev_` or `test_`) and hit TAB to see all functions in that category. It's autocomplete for your workflow!

**Remember:** Functions are **auto-loaded** when you start R—no need to `source()` anything!

### Typical Development Session

**1. Start your session (load package for interactive testing):**

```r
dev_load()
```

This runs `devtools::load_all()`, making your package functions available in the current R session. Rerun after making code changes.

**Time:** < 1 second

**2. After making changes (quick iteration):**

```r
dev_check_quick()
```

This is the **most frequently used function** during development. It:
- Updates documentation with `devtools::document()`
- Runs R CMD check

**Time:** 30-60 seconds

Use this constantly during development for quick feedback loops.

**3. Quick test run:**

```r
test_run()
```

Runs your test suite quickly without the overhead of a full R CMD check. Use for rapid iteration when writing tests.

**Time:** 5-15 seconds (faster than full check)

**4. Before committing code:**

```r
dev_check_complete()
```

This is the **comprehensive check** that runs `devtools::check(cran = TRUE)`. More thorough than `dev_check_quick()` —it catches CRAN-specific issues.

**Time:** 30-90 seconds

**Must pass with 0 errors, 0 warnings, 0 notes** (or acceptable notes) before committing. No exceptions!

### Pre-Commit Hook in Action

When you run `git commit`, the pre-commit hook automatically:

1. Lints code with `jarl lint --fix R/` (if installed)
2. Formats code with `air format .` (if installed)
3. Updates documentation with `devtools::document()`
4. Runs R CMD check with `devtools::check(cran = TRUE)`

**If any step fails, the commit is blocked.** Fix the issues, then commit again.

**Skip the hook temporarily (use sparingly):**
```bash
git commit --no-verify -m "WIP: quick checkpoint"
```

Only skip for work-in-progress commits. Always run a full check before pushing to remote.

### Common Daily Workflows

**Before committing:**
```r
dev_check_complete()
test_spelling()
```

**Before pushing to remote:**
```r
dev_check_complete()
test_run()
```

**After documentation changes:**
```r
build_website()
build_readme()  # if README.Rmd exists
```

**Periodic quality checks (weekly or monthly):**
```r
check_best_practices()
report_code_quality()
test_coverage_report()
```

**You now have a rhythm.** Code → `dev_check_quick()` → Test → `dev_check_complete()` → Commit. Repeat.

---

## Development Scripts Reference

Complete guide to all 30 development scripts. Each entry includes when to use it, what it does, how long it takes, and important notes.

### Setup & Installation (5 functions)

#### `setup_new_package.R`
**When to use:** Never (reference only)
**What it does:** Documents how the package template was originally created
**Notes:** **DON'T RUN THIS!** It's historical documentation showing the initial setup process. Not meant to be executed.

---

#### `setup_cpp_support()`
**When to use:** Adding C++ code to your package via Rcpp
**What it does:**
- Checks for C++ compiler (saves you from cryptic errors later)
- Configures package for Rcpp
- Creates `src/` directory with example C++ functions
- Updates DESCRIPTION with Rcpp dependencies
- Provides comprehensive guidance on writing C++ code

**Time:** 1-2 minutes
**Prerequisites:** C++ compiler (Rtools on Windows, Xcode on macOS, g++ on Linux)

**What it creates:**
- `src/` directory with example `.cpp` file
- Two example functions: `cpp_square()` and `cpp_vectorized_example()`
- Debugging tips, performance notes, common patterns
- Links to Rcpp resources

**After running, you must:**
```r
devtools::document()  # Compile C++ code
devtools::load_all()  # Load package with compiled code
```

---

#### `setup_install_tools()`
**When to use:** First-time setup, or to update dev packages
**What it does:** Installs all required development packages in parallel
**Time:** 5-10 minutes first run

**Packages installed:**
- devtools, roxygen2, roxygen2Comment, usethis, here
- roxyglobals (automatic global variable detection)
- rhub (multi-platform CRAN checks)
- covr, spelling (test coverage, spell checking)
- codetools, pkgnet, goodpractice (quality analysis)
- microbenchmark, profvis (performance analysis)
- todor (TODO comment tracker)

---

#### `help_install_jarl()`
**When to use:** Setting up fast Rust-based linting
**What it does:** Provides installation instructions for jarl CLI linter
**Time:** Few seconds (displays instructions only)

**Notes:**
- **IMPORTANT:** jarl is NOT an R package—it's a standalone CLI tool
- Install in terminal/PowerShell (not R console!)
- 140x faster than lintr (~0.13s vs 18.5s on 25k lines)
- Supports 25+ linting rules with auto-fix
- IDE extensions available for VS Code/Positron

**Installation (copy to terminal):**

Linux/macOS:
```bash
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/etiennebacher/jarl/releases/latest/download/jarl-installer.sh | sh
```

Windows (PowerShell):
```powershell
irm https://github.com/etiennebacher/jarl/releases/latest/download/jarl-installer.ps1 | iex
```

**Usage (in terminal):**
```bash
jarl lint R/              # Lint directory
jarl lint --fix R/        # Lint with auto-fix
jarl lint path/to/file.R  # Lint single file
```

---

#### `setup_github_actions()`
**When to use:** After pushing your repository to GitHub
**What it does:**
- Verifies/updates R-CMD-check workflow (multi-platform testing)
- Optionally sets up pkgdown deployment workflow (automatic website)
- Provides post-setup instructions and next steps

**Time:** Few seconds
**Prerequisites:** Repository must be on GitHub

**Parameters:**
- `pkgdown = TRUE` - Add automatic pkgdown deployment to GitHub Pages
- `rcmdcheck = TRUE` - Verify/update R-CMD-check workflow

**What it creates:**
- `.github/workflows/R-CMD-check.yaml` - Multi-platform CI testing
- `.github/workflows/pkgdown.yaml` - Automatic website deployment (if `pkgdown = TRUE`)

**After running:**
```bash
git add .github/workflows/
git commit -m "Add GitHub Actions workflows"
git push
```

**For pkgdown deployment:**
- Enable GitHub Pages in repository settings
- Settings → Pages → Source: "GitHub Actions"
- Website deploys to: `https://USERNAME.github.io/PACKAGE/`

**Notes:**
- Workflows run automatically on every push to main branch
- R-CMD-check tests on: macOS, Windows, Ubuntu (R-devel, release, oldrel-1)
- pkgdown builds and deploys your package website automatically
- View workflow status at: Repository → Actions tab
- First run may take 3-5 minutes

---

### Daily Development (4 functions)

#### `dev_check_quick()`
**When to use:** After making code changes (quick iteration workflow)
**What it does:**
- Updates documentation with `devtools::document()`
- Runs R CMD check

**Time:** 30-60 seconds
**Notes:** **Most frequently used function** during development. Run this constantly for quick feedback loops.

---

#### `dev_check_complete()`
**When to use:** Before committing or releasing code
**What it does:**
- Updates documentation with `devtools::document()`
- Runs R CMD check with `cran = TRUE`

**Time:** 30-90 seconds
**Notes:** More comprehensive than `dev_check_quick()`. Catches CRAN-specific issues. Must pass with 0/0/0 before commits.

---

#### `test_run()`
**When to use:** Quick test execution during development
**What it does:** Loads package and runs all tests
**Time:** 5-15 seconds
**Notes:** Faster than full check. Use for rapid iteration when writing tests.

---

#### `dev_load()`
**When to use:** Interactive development and testing
**What it does:** Loads package functions into current R session with `devtools::load_all()`
**Time:** < 1 second
**Notes:** Rerun after changing function code.

---

### Testing Suite (3 functions)

#### `test_run()`
**When to use:** Before committing code
**What it does:** Runs complete test suite with detailed output
**Time:** Varies by test complexity
**Notes:** More detailed than quick test runs. Use before commits.

---

#### `test_coverage_report()`
**When to use:** Checking test coverage
**What it does:**
- Runs tests with `covr::package_coverage()`
- Generates interactive HTML coverage report
- Opens report in browser
- Highlights untested code in red

**Time:** 2x test execution time
**Notes:** Aim for >80% coverage (but use judgment—not all code needs tests).

---

#### `test_spelling()`
**When to use:** Before committing, before release
**What it does:** Spell checks all documentation with `spelling::spell_check_package()`
**Time:** Few seconds

**Add valid words to `inst/WORDLIST`:**
- Package names (ggplot2, dplyr)
- Technical terms (permutations, eigenvector)
- Acronyms (CRAN, API, SQL)

**Required to pass before CRAN submission.**

---

### Build Tools (2 functions)

#### `build_readme()`
**When to use:** After editing README.Rmd
**What it does:** Renders README.Rmd to README.md with `rmarkdown::render()`
**Time:** Few seconds
**Notes:** Only runs if README.Rmd exists. Executes code chunks.

---

#### `build_vignettes()`
**When to use:** After editing vignettes
**What it does:** Builds all vignettes with `devtools::build_vignettes()`
**Time:** Varies by vignette complexity
**Output:** `inst/doc/` directory

**Notes:**
- Only runs if vignettes exist in `vignettes/` directory
- Files in `vignettes/articles/` are pkgdown articles (web-only)
- Template includes example article: `vignettes/articles/article.Rmd`

---

### Pkgdown Website (2 functions)

#### `build_website()`
**When to use:** After documentation updates
**What it does:** Builds pkgdown website with `pkgdown::build_site()`
**Time:** 10-30 seconds
**Output:** `docs/` directory with HTML site

**Notes:**
- Configure appearance in `_pkgdown.yml`
- Template includes example article in `vignettes/articles/article.Rmd`
- Articles are web-only (not in package installation)
- Replace example article with your own documentation

---

#### `help_customize_website()`
**When to use:** Setting up or customizing package website
**What it does:** Interactive guide to pkgdown customization
**Time:** Educational/reference (doesn't modify files)

**Provides:**
- Templates for common configurations
- Theme options (20+ Bootswatch themes)
- Navigation customization
- Function reference organization
- Social media & SEO setup
- Custom CSS/JS guidance
- GitHub Pages deployment options
- Complete example configuration

**Notes:**
- Shows current `_pkgdown.yml` configuration
- Provides copy-paste templates
- Must edit `_pkgdown.yml` manually to apply changes

---

### Analysis Tools (5 functions)

#### `report_dependencies()`
**When to use:** Understanding package architecture
**What it does:** Creates visual dependency network with `pkgnet::CreatePackageReport()`
**Time:** 1-2 minutes
**Output:** `dev/dependency_report.html`
**Notes:** Useful for identifying tightly coupled functions.

---

#### `report_package_structure()`
**When to use:** Reviewing package metrics
**What it does:** Counts functions, files, documentation coverage
**Time:** Few seconds
**Notes:** Helps identify documentation gaps.

---

#### `template_benchmarking()`
**When to use:** Benchmarking and profiling
**What it does:** Provides templates for `microbenchmark` and `profvis`
**Time:** Depends on benchmarks
**Notes:** **TEMPLATE FUNCTION**—won't do anything until you customize it for your functions!

---

#### `report_code_quality()`
**When to use:** Static code analysis
**What it does:** Checks for coding issues with `codetools::checkUsagePackage()`
**Time:** Few seconds
**Notes:** May report false positives for globals and NSE. Use `@autoglobal` to fix.

---

### Development Helpers (2 functions)

#### `template_create_dataset()`
**When to use:** Creating example datasets for documentation or testing
**What it does:** Template function for generating and documenting datasets
**Time:** Few seconds (plus time to create your data)

**How to use:**
1. Run: `template_create_dataset()`
2. Modify data generation code for your actual dataset
3. Document in `R/data.R` with roxygen2 comments
4. Run `devtools::document()` to generate help file

**What it creates:**
- `data/dummy_df.rda` (compressed with xz)
- Requires documentation in `R/data.R`

**Notes:**
- Template creates 1000-row dataframe for demonstration
- Uses `set.seed(42)` for reproducibility
- Keep datasets small (< 1 MB recommended)
- Document all variables clearly

---

#### `template_create_function()`
**When to use:** Creating new functions with proper documentation structure
**What it does:** Template function for generating well-documented functions
**Time:** Few seconds

**How to use:**
1. Run: `template_create_function()`
2. Review generated function in `R/lm_model.R`
3. Modify for your needs
4. Run `devtools::document()` to generate help files

**What it creates:**
- `R/lm_model.R` with complete roxygen2 documentation
- Includes all standard tags: `@param`, `@return`, `@details`, `@export`, `@autoglobal`, `@examples`

---

## Testing and Quality Assurance

Testing is where you build confidence that your package works correctly. Here's how to test thoroughly and catch issues early.

### Running Tests

**Quick test run (during development):**
```r
test_run()
```

This runs your test suite quickly using `devtools::test()`. Use this constantly while writing tests.

**Comprehensive test with coverage:**
```r
test_coverage_report()
```

This:
1. Runs all tests with `covr::package_coverage()`
2. Generates interactive HTML coverage report
3. Opens report in browser
4. Shows exactly which lines are tested (green) vs. untested (red)

**Aim for >80% coverage.** But use judgment—not all code needs tests:
- Simple getters/setters: Low priority
- Complex logic, edge cases: High priority
- Error handling: Must test
- Examples in documentation: Must work

### Code Quality Checks

### Checking Suite (3 functions)

**Local R CMD check (the big one):**
```r
dev_check_complete()
```

This runs `devtools::check(cran = TRUE)` with CRAN-level standards. **Must pass with 0 errors, 0 warnings, 0 notes** (or acceptable notes like "New submission").

**What it checks:**
- Code runs without errors
- Examples in documentation work
- Tests pass
- No undefined global variables
- No missing documentation
- No syntax errors
- CRAN policy compliance

**If it fails:** Read the error messages carefully. They tell you exactly what to fix.

**Best practices analysis:**
```r
dev_best_practices()
```

This uses `goodpractice::gp()` to analyze your package and provide recommendations:
- Code complexity
- Cyclomatic complexity (how many paths through your code)
- Line length
- T/F instead of TRUE/FALSE usage
- 1:length() instead of seq_along()
- attach() usage (bad!)

**Notes:** Recommendations are suggestions. Use judgment. Some "bad practices" are fine in context.

**Static code analysis:**
```r
report_code_quality()
```

This uses `codetools::checkUsagePackage()` to find:
- Undefined variables
- Unused local variables
- Global variables (false positives if you use `@autoglobal`)
- Suspicious code patterns

**Fix real issues, ignore false positives.**

**Package structure analysis:**
```r
report_package_structure()
```

This counts:
- Number of functions exported vs. internal
- Number of files in R/
- Documentation coverage (which functions lack help files)
- Test coverage (which functions lack tests)

Use this to identify documentation gaps.

### Multi-Platform Checking

**20+ platforms via R-Hub:**
```r
dev_check_all_platforms()
```

**First time:** Run `rhub::rhub_setup()` and `rhub::rhub_doctor()` before using R-Hub.

**Check spam folder!** Remote check results often land there.

### Spell Checking

**Check all documentation for typos:**
```r
test_spelling()
```

**Add valid words to `inst/WORDLIST`:**
```r
# One word per line
ggplot2
dplyr
eigenvector
permutations
```

**Required for CRAN submission.** No typos allowed in documentation.

---

## Building Documentation

Great code deserves great documentation. Here's how to build README files, vignettes, and a beautiful package website.

### Package Website with pkgdown

**Build your website:**
```r
build_website()
```

This runs `pkgdown::build_site()` and creates a complete website in the `docs/` directory.

**What it includes:**
- Home page (from README.md)
- Function reference (from man/ files)
- Articles (from vignettes/articles/)
- News (from NEWS.md)
- Changelog (from git history if configured)

**Customize appearance:**
```r
help_customize_website()
```

This interactive guide shows you how to customize `_pkgdown.yml`:

**Example customization:**
```yaml
template:
  bootstrap: 5
  bootswatch: flatly  # or: darkly, sandstone, spacelab, etc.

navbar:
  structure:
    left:  [home, reference, articles, news]
    right: [github]

reference:
- title: "Data Processing"
  desc: "Functions for cleaning and transforming data"
  contents:
  - starts_with("data_")

- title: "Plotting"
  desc: "Visualization functions"
  contents:
  - starts_with("plot_")
```

**Deploy to GitHub Pages:**

1. Build site: `build_website()`
2. Commit `docs/` directory to git
3. GitHub repo → Settings → Pages
4. Source: Deploy from `docs/` folder on main branch
5. Save

Your website will be live at `https://YOUR-USERNAME.github.io/YOUR-PACKAGE/`

### Vignettes and Articles

**What's the difference?**
- **Vignettes:** Long-form documentation included with package installation. Users can access offline with `vignette("intro", package = "yourpackage")`.
- **Articles:** Web-only documentation for pkgdown site. Not included in package installation. Great for tutorials, case studies, detailed examples.

**The template includes an example article:**
```
vignettes/articles/article.Rmd
```

**Replace it with your own:**

1. Delete example: `file.remove("vignettes/articles/article.Rmd")`
2. Create new article: `usethis::use_article("your-topic")`
3. Edit the created R Markdown file
4. Build website: `build_website()`

**Add standard vignettes (if needed):**

```r
usethis::use_vignette("intro-to-yourpackage")
```

This creates `vignettes/intro-to-yourpackage.Rmd`. Edit it, then:

```r
build_vignettes()
```

Vignettes install with the package. Keep them concise and focused.

### README and NEWS

**README.Rmd:**

Edit `README.Rmd`, then render to Markdown:
```r
build_readme()
```

This runs code chunks and creates `README.md`.

**Never edit README.md directly.** Always edit README.Rmd and re-render.

**NEWS.md:**

Track changes in `NEWS.md`:

```markdown
# yourpackage (development version)

## New Features
* Added `new_function()` to do X

## Bug Fixes
* Fixed issue where `old_function()` failed on edge case Y

## Breaking Changes
* Removed deprecated `ancient_function()`
```

Update before each release.

---

## Preparing for CRAN (Optional)

**IMPORTANT:** CRAN submission is entirely optional. The template works perfectly for GitHub-only packages. Only use these steps if you plan to submit to CRAN.

### Pre-Release Checklist

Before starting the release workflow, ensure:

**Code quality checks (all must pass):**
```r
dev_check_complete()         # 0 errors, 0 warnings, 0 notes
check_best_practices()       # Review recommendations
test_spelling()              # Fix all typos
test_coverage_report()       # Check >80% coverage
```

**Documentation completeness:**
- All functions documented with roxygen2
- README.md accurate and up-to-date
- NEWS.md includes all changes since last release
- Vignettes/articles build without errors

**Metadata correctness:**
- DESCRIPTION has valid email (CRAN will contact you here)
- URL and BugReports point to correct repository
- License is correct
- Version number follows semantic versioning

### 4-Step CRAN Release Workflow

**CRITICAL: Follow these steps IN ORDER.** Do not skip steps. Each validates the previous one.

---

#### Step 1: Prepare

```r
release_01_prepare()
```

**What it does:**
- Displays preparation checklist
- Runs `spelling::spell_check_package()`
- Reminds you to update version and NEWS.md

**Manual tasks (do these BEFORE proceeding):**

1. **Update version in DESCRIPTION:**
   ```
   Version: 0.1.0.9000  →  Version: 0.1.0
   ```
   Remove the `.9000` development suffix.

2. **Update NEWS.md:**
   ```markdown
   # yourpackage 0.1.0

   ## Initial Release
   * Implemented feature X
   * Added function Y
   * Fixed bug Z
   ```

3. **Review DESCRIPTION completeness:**
   - Title is descriptive (not placeholder)
   - Description explains what package does
   - Authors correct with email
   - URL and BugReports point to your repo

4. **Run documentation:**
   ```r
   devtools::document()
   ```

**Proceed to Step 2 when all tasks complete.**

---

#### Step 2: Local Checks

```r
release_02_local_checks()
```

**What it does:**
- Runs full R CMD check with `devtools::check(cran = TRUE)`
- Runs `goodpractice::gp()` analysis
- Reports pass/fail status

**Requirements:**
- **Must pass:** 0 errors, 0 warnings, 0 notes (or acceptable notes)
- Acceptable notes: "New submission", "Maintainer email"
- Unacceptable notes: Anything about undefined globals, missing documentation, broken examples

**Time:** 2-5 minutes

**If checks fail:** Fix the issues, return to Step 1, update NEWS.md if needed, run Step 2 again.

**Only proceed to Step 3 if all checks pass.**

---

#### Step 3: Remote Checks

```r
release_03_remote_checks()
```

**What it does:**
- Submits to Windows R-devel builder via `devtools::check_win_devel()`
- Submits to macOS R-release builder via `devtools::check_mac_release()`
- Provides confirmation prompts

**Requirements:**
- Interactive confirmation required (prevents accidental submissions)
- Results emailed in 15-60 minutes
- **Check spam folder!**

**Wait for both emails, then:**

1. Review Windows R-devel results: Must pass (0 errors, 0 warnings)
2. Review macOS R-release results: Must pass (0 errors, 0 warnings)

**If checks fail:**
- Fix the issues
- Return to Step 2
- Run local checks again
- Only return to Step 3 when local checks pass

**Only proceed to Step 4 when remote checks pass.**

---

#### Step 4: Submit to CRAN

```r
release_04_submit_to_cran()
```

**What it does:**
- Displays final submission checklist
- Confirms you're ready
- Runs `devtools::release()` (interactive)

**Requirements:**
- All previous steps complete and passing
- Version and NEWS.md updated (no `.9000` suffix)
- All code committed to git (clean working directory)

**The script will ask:**
- Have you run all checks?
- Is NEWS.md updated?
- Is version number correct?
- Is DESCRIPTION complete?

Answer "yes" to all, then `devtools::release()` runs.

**Follow the interactive prompts:**
- Confirm package details
- Confirm you've read CRAN policies
- Confirm submission

**After submission:**

1. **Tag release in git:**
   ```bash
   git tag -a v0.1.0 -m "Release 0.1.0"
   git push origin v0.1.0
   ```

2. **Wait for CRAN confirmation email** (usually within 24 hours)

3. **Respond to any CRAN requests promptly** (within 2 weeks)

4. **If accepted:** Celebrate! 🎉

5. **If rejected:** Read the feedback carefully, fix issues, return to Step 2, resubmit.

**After successful CRAN publication:**

1. **Update version to development:**
   ```
   Version: 0.1.0  →  Version: 0.1.0.9000
   ```

2. **Commit version bump:**
   ```bash
   git commit -am "Bump version to 0.1.0.9000 for development"
   git push
   ```

---

## Advanced Topics

### Claude Code AI Agents

The template includes specialized AI agents in the `.claude/` folder for use with Claude Code CLI.

#### roxygen-doc-reviewer Agent

**Purpose:** Reviews roxygen2 documentation for completeness, accuracy, and clarity.

**When to use:**
- After writing new functions with roxygen documentation
- After modifying existing function documentation
- Before running `devtools::document()`
- During code review to catch documentation issues early

**What it checks:**
- Grammatical correctness and clarity
- Accuracy of parameter descriptions relative to function code
- Completeness of `@param`, `@return`, `@examples` tags
- Consistency between documentation and implementation
- Appropriate use of `@export`, `@autoglobal`, etc.

**Usage with Claude Code CLI:**
```bash
# Review specific function
claude code "Review the roxygen documentation in R/my_function.R"

# Review all documentation
claude code "Review all roxygen documentation in R/ folder"
```

**Development stages:**
- **Active development:** Use after writing/modifying functions
- **Before commits:** Verify documentation quality
- **Pre-release:** Ensure all documentation is publication-ready

---

#### cran-submission-expert Agent

**Purpose:** Assists with CRAN submission preparation and policy compliance.

**When to use:**
- When preparing for initial CRAN submission
- Before running the `release_*` workflow scripts
- After receiving CRAN review feedback
- When updating package for resubmission

**What it checks:**
- CRAN policy compliance (file structure, licensing, examples)
- R CMD check results interpretation
- DESCRIPTION file requirements
- Documentation standards
- Code quality issues affecting CRAN acceptance
- Common CRAN rejection reasons

**Usage with Claude Code CLI:**
```bash
# Full compliance check
claude code "Check if this package is ready for CRAN submission"

# Address specific feedback
claude code "CRAN reviewer said 'Examples with CPU time > 5 sec'. Help me fix this."

# Pre-submission verification
claude code "Review CRAN requirements before I run release_04_submit_to_cran.R"
```

**Development stages:**
- **Pre-release:** Before starting `release_01_prepare.R`
- **After remote checks:** Interpret rhub/win-builder results
- **Post-rejection:** Address CRAN maintainer feedback
- **Resubmission:** Verify all issues resolved

---

#### Integration with Development Workflow

The agents complement but don't replace the development scripts:

```r
# 1. Write/modify function
# 2. Ask roxygen-doc-reviewer to check documentation
# 3. Run quick check
dev_check_quick()

# ... later, preparing for CRAN ...

# 1. Ask cran-submission-expert for pre-check
# 2. Run release workflow
release_01_prepare()
release_02_local_checks()
# 3. Ask cran-submission-expert to interpret results
release_03_remote_checks()
# 4. Ask cran-submission-expert for final verification
release_04_submit_to_cran()
```

**Best practices:**
1. Use roxygen-doc-reviewer proactively—catch issues before `devtools::check()` fails
2. Use cran-submission-expert early—don't wait until submission
3. Provide context—tell the agent what stage you're at
4. Iterate—use feedback to improve, then ask for re-review
5. Combine with scripts—agents provide guidance, scripts do the work

---

### Adding C++ Code with Rcpp

Need to speed things up? Add C++ code to your package.

**Run the setup:**
```r
setup_cpp_support()
```

**What it does:**
1. Checks for C++ compiler (prevents cryptic errors)
2. Runs `usethis::use_rcpp()`
3. Creates `src/` directory
4. Creates example C++ functions:
   - `cpp_square()` - Simple scalar function
   - `cpp_vectorized_example()` - Vectorized function
5. Updates DESCRIPTION with Rcpp dependencies
6. Provides comprehensive guidance on writing C++ code

**After running setup:**
```r
devtools::document()  # Compile C++ code, update documentation
devtools::load_all()  # Load package with compiled code
```

**Test the example functions:**
```r
cpp_square(5)  # Returns 25
cpp_vectorized_example(1:10)  # Returns squared vector
```

**Write your own C++ functions:**

Create `src/your_function.cpp`:

```cpp
#include <Rcpp.h>
using namespace Rcpp;

//' Your Function Title
//'
//' @param x Numeric vector
//' @return Transformed numeric vector
//' @export
// [[Rcpp::export]]
NumericVector your_function(NumericVector x) {
  int n = x.size();
  NumericVector result(n);
  for(int i = 0; i < n; i++) {
    result[i] = x[i] * 2;  // Your logic here
  }
  return result;
}
```

**Compile and test:**
```r
devtools::document()
devtools::load_all()
your_function(1:5)
```

**Performance tips:**
- Use C++ for loops, vectorization, numerical algorithms
- Don't use C++ for simple operations (overhead isn't worth it)
- Profile first with `profvis::profvis()` to identify bottlenecks
- Benchmark with `microbenchmark::microbenchmark()` to verify speedup

---

### Code Organization Tools

#### roxygen2Comment - Toggle Roxygen2 Comments

**When to use:** Writing or editing roxygen2 documentation, especially code examples

**What it does:** RStudio addin that toggles roxygen2 comment markers (`#'`) on/off

**How to use:**
- RStudio Addin: Select code lines → Addins menu → "Roxygen2 Comment"
- Toggle behavior:
  - Standard code → Adds `#'` prefix (converts to roxygen2 comment)
  - Roxygen2 comments → Removes `#'` prefix (converts back to code)

**Typical workflow:** Write example code normally, then toggle to roxygen2 format for `@examples`.

**Assign keyboard shortcut:** Tools → Modify Keyboard Shortcuts → Search "Roxygen2 Comment"

---

#### todor - Find TODO Comments

**When to use:** During code review, before releases, cleaning up technical debt

**What it does:** Scans R project for TODO, FIXME, CHANGED, and other marker comments

**How to use:**
- RStudio: Addins menu → "Find TODO comments"
- Programmatically: `todor::todor_package()` in R console
- Results appear in RStudio's Markers pane for easy navigation

**Common markers searched:**
- TODO - Tasks to complete
- FIXME - Code that needs fixing
- CHANGED - Recent modifications
- IDEA - Future improvements
- HACK - Temporary workarounds
- NOTE - Important comments
- REVIEW - Code needing review

---

## Troubleshooting

### Pre-commit hook not installing?

**Symptoms:** No message about "Pre-commit hook installed successfully" when starting R

**Solutions:**
1. Manually run: `source(".Rprofile")` in R session
2. Check `.git/hooks/pre-commit` exists
3. Verify you're in the package root directory (not a subdirectory)
4. Ensure `.git/` directory exists (run `git init` if needed)

---

### R CMD check failing?

**Run detailed check to see full error messages:**
```r
dev_check_complete()
```

**Common issues:**

**Missing `@autoglobal` tags:**
```
Error: object 'variable_name' not found
NOTE: Undefined global functions or variables: variable_name
```
**Fix:** Add `@autoglobal` to the function that uses `variable_name`.

**Undocumented functions:**
```
WARNING: Undocumented code objects: 'function_name'
```
**Fix:** Add roxygen2 documentation to `function_name` or make it internal (don't export).

**Examples fail:**
```
ERROR: Error in running code in documentation
```
**Fix:** Test examples in `@examples` section interactively. Make sure they work.

**Missing imports:**
```
Error: could not find function "package_function"
```
**Fix:** Add package to DESCRIPTION `Imports:` and use `package::function()` syntax.

---

### GitHub Actions failing?

**Check Actions tab on GitHub for detailed logs.**

**Common issues:**

**Badge URLs still point to template:**
```
404 Not Found: username/blankpkg
```
**Fix:** Update badge URLs in README.Rmd to your actual GitHub username and repository name.

**Dependencies not listed:**
```
Error: package 'packagename' is not available
```
**Fix:** Add package to DESCRIPTION under `Imports:` or `Suggests:`.

**Platform-specific issues:**
```
Error on Windows: ...
```
**Fix:** Test locally on that platform, or submit to win-builder/rhub for diagnostics.

---

### Tests failing after customization?

**Symptoms:** Tests that worked before customization now fail

**Common cause:** Template includes tests for example functions (`lm_model.R`, `dummy_df.rda`)

**Fix:**
```r
file.remove("tests/testthat/test-lm_model.R")
```

Delete tests for example code you've removed.

**Ensure test file naming:**
- Correct: `test-yourfunction.R`
- Incorrect: `yourfunction-test.R`

**Run tests to verify:**
```r
test_run()
```

---

### Remote checks don't arrive?

**Symptoms:** Submitted to win-builder or macOS builder, no email after 60 minutes

**Solutions:**
1. **Check spam folder** (seriously, do this first!)
2. Verify email in DESCRIPTION is correct
3. Wait up to 60 minutes (builders can be slow during peak times)
4. If still no email after 2 hours, resubmit

---

### Check has notes about global variables?

**Symptoms:**
```
NOTE: Undefined global functions or variables:
  variable_name
```

**Fix:** Add `@autoglobal` tag to the function:
```r
#' Your Function
#' @autoglobal
#' @export
your_function <- function() {
  variable_name <- "something"  # Now detected automatically
}
```

**After adding `@autoglobal`:**
```r
devtools::document()
dev_check_complete()
```

---

### Performance scripts have errors?

**Symptoms:** `template_benchmarking()` fails when run

**Cause:** It's a TEMPLATE function—won't work until you customize it

**Fix:**
1. Run `template_benchmarking()` to see the templates
2. Copy the relevant template code
3. Replace example functions with your actual functions
4. Run the customized code

**Template functions are starting points, not ready-to-run.**

---

## What to Keep vs. Replace

When customizing the template, here's what to preserve vs. what to make your own.

### Keep These (they work for any package)

**Infrastructure files (don't modify):**
- `dev/` folder and all scripts (auto-detect your package name)
- `.claude/` folder (AI agents for documentation review and CRAN submission)
- `.Rprofile` (auto-installs pre-commit hook)
- `dev/pre_commit_hook` (git hook script)
- `air.toml` (formatter configuration)
- `.Rbuildignore` (tells R what to ignore during build)
- `NAMESPACE` (auto-managed by roxygen2—never edit manually)

**Test infrastructure:**
- `tests/testthat.R` (testthat entry point)
- `tests/testthat/` folder (but replace individual test files)

**GitHub configuration:**
- `.github/workflows/R-CMD-check.yaml` (GitHub Actions workflow)

---

### Replace These (make them yours)

**Package-specific documentation:**
- **README.Rmd** (THIS FILE—replace with your package documentation)
- **NEWS.md** (document your package changes, not template changes)
- **DESCRIPTION** (update with your package details)
- **_pkgdown.yml** (customize for your package website)

**Example code (delete or replace):**
- `R/lm_model.R` (example function—replace with your functions)
- `data/dummy_df.rda` (example data—replace with your data or delete)
- `R/data.R` (example data documentation—replace or delete)
- `tests/testthat/test-lm_model.R` (example test—replace with your tests)
- `vignettes/articles/article.Rmd` (example article—replace with your documentation)

**License file:**
- `LICENSE` (update copyright holder to your name)

**Your actual code:**
- Everything in `R/` (your package functions)
- Everything in `tests/testthat/` (your tests)
- Everything in `man/` (auto-generated from roxygen2, but based on your code)
- Everything in `vignettes/` (your vignettes and articles)

---

## Best Practices and Tips

### Coding Style

**Follow these conventions for consistency:**

1. **Use snake_case consistently** — All functions, arguments, internal variables
2. **Organize functions into prefix-based families** — Group related functions under common prefixes (`data_*`, `plot_*`, `utils_*`)
3. **Provide main entry point with accessible internals** — One primary function for typical workflow; individual steps exported for advanced users
4. **Maintain consistent parameter names** — Identical argument names across related functions
5. **Delegate parallelization to `future`** and progress to `progressr` — Let users configure externally
6. **Use standard R data structures** — Accept/return data frames, lists, vectors; avoid custom S4/R6 unless necessary
7. **Use explicit namespace calls** — Always use `package::function()` syntax instead of `@importFrom`; makes dependencies explicit
8. **Keep functions simple and streamlined** — Minimize function arguments; use sensible defaults; prioritize speed and simplicity

---

### Workflow Best Practices

**Autocomplete discovery:**

Type prefix + TAB to discover scripts:
- `daily_` + TAB → all daily workflow scripts
- `test_` + TAB → all testing scripts
- `check_` + TAB → all checking scripts
- `release_` + TAB → all release scripts

**Common workflows:**

**Before committing code:**
```r
dev_check_complete()
test_spelling()
```

**Before pushing to remote:**
```r
dev_check_complete()
test_run()
```

**After documentation changes:**
```r
build_website()
build_readme()
```

**Periodic quality checks (weekly/monthly):**
```r
check_best_practices()
report_code_quality()
test_coverage_report()
```

---

### Testing Best Practices

**Aim for >80% test coverage.** But use judgment:
- Simple getters/setters: Low priority
- Complex logic, edge cases: High priority
- Error handling: Must test
- Examples in documentation: Must work

**Write tests as you write functions.** Don't wait until the end.

**Test edge cases:**
```r
test_that("function handles empty input", {
  expect_equal(your_function(numeric(0)), numeric(0))
})

test_that("function handles NA values", {
  expect_equal(your_function(c(1, NA, 3)), c(2, NA, 6))
})

test_that("function errors on invalid input", {
  expect_error(your_function("not a number"))
})
```

---

### Documentation Best Practices

**Add roxygen2 documentation to EVERY exported function:**
```r
#' Title (One Line, Title Case)
#'
#' @description
#' One paragraph describing what the function does.
#'
#' @param x Description of parameter x
#' @param y Description of parameter y
#'
#' @return What the function returns (be specific)
#'
#' @export
#' @autoglobal
#'
#' @examples
#' your_function(x = 1, y = 2)
your_function <- function(x, y) {
  # Code here
}
```

**Required tags:**
- `@title` and `@description` (or combine as first paragraph)
- `@param` for each parameter
- `@return` explaining return value
- `@export` if users should access the function
- `@autoglobal` for automatic global variable detection

**Optional but recommended:**
- `@details` for implementation notes
- `@examples` showing how to use the function
- `@seealso` linking to related functions
- `@references` for academic papers or external resources

---

### Git and Version Control

**Commit frequently:**
```bash
git add .
git commit -m "Add feature X"
```

**Use descriptive commit messages:**
- Good: "Add data_clean() function for missing value imputation"
- Bad: "Update code"

**The pre-commit hook ensures quality** before each commit. If it fails:
1. Read the error messages
2. Fix the issues
3. Commit again

**Never skip the hook unless you're making a WIP commit:**
```bash
git commit --no-verify -m "WIP: testing new approach"
```

**Before pushing to remote, always:**
```r
dev_check_complete()
```

**Tag releases:**
```bash
git tag -a v0.1.0 -m "Release 0.1.0"
git push origin v0.1.0
```

---

### Performance Optimization

**Profile first, optimize second:**
```r
profvis::profvis({
  your_function(large_input)
})
```

**Benchmark to verify speedup:**
```r
microbenchmark::microbenchmark(
  old_approach = old_function(x),
  new_approach = new_function(x),
  times = 100
)
```

**Consider C++ for:**
- Loops over large vectors
- Numerical algorithms
- Operations repeated millions of times

**Don't use C++ for:**
- Simple operations (overhead isn't worth it)
- One-time computations
- Code that's already fast enough

---

## Acknowledgements

This template would have been impossible without the outstanding effort of the R community and the developers of the following excellent packages:

- **devtools** (Wickham et al., 2025) - Tools to make developing R packages easier. The backbone of modern R package development. https://devtools.r-lib.org/

- **usethis** (Wickham et al., 2025) - Automates package and project setup tasks, making package infrastructure setup painless. https://usethis.r-lib.org

- **testthat** (Wickham, 2011) - Unit testing framework that makes testing R packages straightforward and enjoyable. https://testthat.r-lib.org/

- **covr** (Hester, 2023) - Test coverage analysis to identify untested code and improve package quality. https://covr.r-lib.org/

- **spelling** (Ooms & Hester, 2025) - Spell checking tools that catch typos in documentation before they reach users. https://docs.ropensci.org/spelling/

- **goodpractice** - Package quality analyzer that provides actionable recommendations for improving R packages.

- **rhub** (Csárdi & Salmon, 2025) - Multi-platform package checking infrastructure for validating packages across different systems. https://r-hub.github.io/rhub/

- **pkgdown** (Wickham et al., 2025) - Creates beautiful static HTML documentation websites from R packages. https://pkgdown.r-lib.org/

- **pkgnet** (Burns et al., 2024) - Network analysis and visualization of package dependencies and structure. https://github.com/uptake/pkgnet

- **codetools** (Tierney, 2024) - Static code analysis tools for identifying potential issues in R code. https://CRAN.R-project.org/package=codetools

- **microbenchmark** (Mersmann, 2024) - Accurate timing functions for performance benchmarking and optimization. https://github.com/joshuaulrich/microbenchmark/

- **profvis** (Wickham et al., 2024) - Interactive visualizations for profiling R code and identifying performance bottlenecks. https://profvis.r-lib.org

- **roxyglobals** (North, 2023) - Automatic global variable declarations for roxygen2, eliminating manual NAMESPACE management. https://github.com/anthonynorth/roxyglobals

- **cli** (Csárdi, 2025) - Powerful helpers for creating beautiful command line interfaces with rich formatting. https://cli.r-lib.org

- **desc** (Csárdi et al., 2023) - Tools for reading, writing, and manipulating DESCRIPTION files programmatically. https://CRAN.R-project.org/package=desc

Without these packages and their dedicated maintainers, modern R package development would be far more tedious. This template simply brings them together in a streamlined workflow.

---

## Summary Checklist

Quick verification that you've completed key steps:

**Initial Setup:**
- [ ] Forked/cloned repository
- [ ] Ran `setup_install_tools()`
- [ ] Pre-commit hook installed (message appears when starting R)
- [ ] Optionally installed jarl and air

**Core Customization:**
- [ ] DESCRIPTION fully customized (no placeholder text)
- [ ] Package name updated throughout
- [ ] Maintainer email correct (CRAN will contact you here)
- [ ] LICENSE copyright holder updated
- [ ] URL and BugReports point to your repository

**Documentation:**
- [ ] README.Rmd rewritten for your package (template explanation deleted)
- [ ] README badge URLs point to your repository
- [ ] NEWS.md includes your package changes
- [ ] Example article (vignettes/articles/article.Rmd) deleted or replaced

**Code Replacement:**
- [ ] Example functions (lm_model.R) deleted or replaced
- [ ] Example data (dummy_df.rda) deleted or replaced
- [ ] Example tests (test-lm_model.R) deleted or replaced
- [ ] Your own functions added with roxygen2 documentation
- [ ] All functions have `@autoglobal` tag

**Quality Assurance:**
- [ ] Tests written for your functions
- [ ] `dev_check_complete()` passes (0/0/0)
- [ ] `test_spelling()` passes
- [ ] Test coverage reviewed (>80% recommended)

**Git and GitHub:**
- [ ] All changes committed to git
- [ ] Pushed to GitHub
- [ ] GitHub Actions workflow runs and passes
- [ ] Pre-commit hook tested and working

**Optional (if building website):**
- [ ] `_pkgdown.yml` customized for your package
- [ ] Website built with `build_website()`
- [ ] GitHub Pages configured to deploy from `docs/` folder

**Optional (if submitting to CRAN):**
- [ ] Followed 4-step release workflow (`release_01_prepare()` through `release_04_submit_to_cran()`)
- [ ] All remote checks passed (Windows, macOS)
- [ ] Submitted to CRAN via `devtools::release()`

---

## Next Steps

After completing this tutorial, establish these development patterns:

### Daily Development Rhythm

1. **Start each session:**
   ```r
   dev_load()
   ```

2. **After changes:**
   ```r
   dev_check_quick()
   ```

3. **Before commits:**
   ```r
   dev_check_complete()
   test_spelling()
   ```

4. **Commit regularly:**
   ```bash
   git add .
   git commit -m "Descriptive message"
   ```

### Weekly/Monthly Maintenance

**Review code quality:**
```r
check_best_practices()
report_code_quality()
```

**Check test coverage:**
```r
test_coverage_report()
```

**Update documentation:**
```r
build_website()
```

### Before Each Release

**Follow the 4-step CRAN workflow** (if submitting to CRAN):
```r
release_01_prepare()
release_02_local_checks()
release_03_remote_checks()
release_04_submit_to_cran()
```

**Or for GitHub-only packages, just:**
```r
dev_check_complete()
build_website()
```

Then tag the release:
```bash
git tag -a v0.1.0 -m "Release 0.1.0"
git push origin v0.1.0
```

### Monitor GitHub Actions

Every push runs R CMD check on multiple platforms. If it fails:
1. Check Actions tab for detailed logs
2. Fix the issues locally
3. Run `dev_check_complete()` to verify fix
4. Commit and push again

### Engage with Users

**When users report bugs:**
1. Write a failing test that reproduces the bug
2. Fix the code to make the test pass
3. Thank the user and close the issue

**When users request features:**
1. Consider if it fits the package scope
2. If yes: implement, document, test
3. If no: politely decline and explain why

### Keep Learning

**Read package development resources:**
- [R Packages (2e)](https://r-pkgs.org/) by Hadley Wickham and Jenny Bryan
- [Writing R Extensions](https://cran.r-project.org/doc/manuals/r-release/R-exts.html) (official CRAN documentation)
- [rOpenSci Packages Guide](https://devguide.ropensci.org/)

**Study well-designed packages:**
- How do they organize functions?
- How do they write documentation?
- How do they handle errors?
- What testing patterns do they use?

**Contribute to the R community:**
- Answer questions on Stack Overflow
- Share your package on Twitter/Mastodon
- Present at R user groups
- Write blog posts about your package

---

**Happy developing!** You now have everything you need to create, maintain, and release professional R packages. The template handles the tedious infrastructure—you focus on writing great code.

Questions? Issues? See `dev/README.md` for comprehensive documentation on all development scripts.

**Now go build something amazing.** 📦✨
