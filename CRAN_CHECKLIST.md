# CRAN Submission Checklist

A comprehensive checklist for preparing and submitting R packages to CRAN, based on [ThinkR's CRAN preparation guide](https://github.com/ThinkR-open/prepare-for-cran) and best practices from the R community.

**Key principle:** CRAN maintainers are volunteers (can be counted on one hand). Thorough pre-submission validation respects their time and increases acceptance rates.

---

## Table of Contents

- [Before You Start](#before-you-start)
- [Phase 1: Pre-Release Preparation](#phase-1-pre-release-preparation)
- [Phase 2: Local Validation](#phase-2-local-validation)
- [Phase 3: Cross-Platform Testing](#phase-3-cross-platform-testing)
- [Phase 4: Final Review](#phase-4-final-review)
- [Phase 5: Submission](#phase-5-submission)
- [Post-Submission](#post-submission)
- [Common Rejection Reasons](#common-rejection-reasons)
- [Helpful Resources](#helpful-resources)

---

**Note on Function Syntax:** Development functions are auto-loaded by `.Rprofile` when you start R in the package directory. You can call them directly (e.g., `dev_check_complete()`) without using `source()`. If you've disabled `.Rprofile`, use `source("dev/function_name.R")` instead.

---

## Before You Start

**Timing requirements:**
- [ ] **30-day minimum** between CRAN releases (unless fixing critical bugs)
- [ ] All planned features complete and tested
- [ ] All bugs from previous version addressed
- [ ] Breaking changes documented in NEWS.md

**First-time submissions:**
- [ ] Expect longer review times (1-2 weeks vs 1-3 days for updates)
- [ ] Be extra thorough - first impressions matter
- [ ] Have `cran-comments.md` ready to explain your package

---

## Phase 1: Pre-Release Preparation

### 1.1 Version Management

- [ ] Update version number in `DESCRIPTION`
  - Major.Minor.Patch (e.g., 1.0.0, 1.1.0, 1.0.1)
  - Remove `.9000` development suffix
  - Follow [semantic versioning](https://semver.org/)

- [ ] Update `NEWS.md` with all changes
  ```bash
  # Script: Manual editing required
  # Group changes by: New features, Bug fixes, Breaking changes, Deprecations
  ```

### 1.2 DESCRIPTION File Validation

**Critical formatting (CRAN is strict about this!):**

- [ ] **Title** (line 3):
  - Use Title Case
  - NO period at end
  - Remove "in R" or "with R" (redundant on CRAN)
  - Max ~65 characters
  - Example: `Title: Fast Data Processing for Large Datasets`

- [ ] **Description** (line 4+):
  - Multiple complete sentences with elaboration
  - NO "This package..." opening
  - NO package name as first word
  - Capitalize software/package names correctly
  - Use parentheses after function names: `function()`
  - Quote external packages with correct casing: `'shiny'`, `'ggplot2'`
  - Example:
    ```
    Description: Provides efficient algorithms for processing large datasets.
        Implements parallel computing techniques to reduce computation time.
        Includes visualization tools for exploring results.
    ```

- [ ] **Authors** field:
  - All contributors listed with correct roles
  - At least one `cre` (maintainer) with valid email
  - Include `cph` (copyright holder) if applicable
  - Roles: `aut` (author), `cre` (maintainer), `ctb` (contributor), `cph` (copyright holder)

- [ ] **License**:
  - Valid CRAN license (MIT, GPL-3, etc.)
  - If MIT: ensure `LICENSE` file exists

- [ ] **URL and BugReports** (if present):
  - Use HTTPS exclusively (not HTTP)
  - Format URLs with angle brackets in Description: `<https://...>`
  - Canonical CRAN package links: `https://CRAN.R-project.org/package=pkgname`
  - Example:
    ```
    URL: https://github.com/username/pkgname, https://username.github.io/pkgname/
    BugReports: https://github.com/username/pkgname/issues
    ```

- [ ] **Dependencies**:
  - All used packages listed in `Imports` or `Suggests`
  - No unnecessary dependencies
  - Minimum R version specified if using recent features
  - Consider using `{attachment}` package: `attachment::att_amend_desc()`

### 1.3 Documentation Standards

- [ ] **Run spell check**
  ```r
  test_spelling()
  # Or directly: spelling::spell_check_package()
  ```
  - Add technical terms to `inst/WORDLIST` (one per line)
  - Package names in quotes match exact casing
  - No typos in titles, descriptions, or documentation

- [ ] **Function documentation completeness**
  - Every exported function has `@return` tag (required!)
  - All `@param` tags have descriptions
  - No empty documentation fields
  - Internal functions use `#' @noRd` if partially documented
  - Check with: `checkhelper::find_missing_tags()` (if package installed)

- [ ] **Examples quality**
  - All examples run successfully
  - Replace `\dontrun{}` with `if (interactive()) {}` for interactive-only code
  - Use `\donttest{}` for slow examples (>5 seconds)
  - Examples should demonstrate typical use cases
  - Avoid examples requiring external resources (APIs, databases)

- [ ] **Vignettes/Articles** (if present):
  - All code chunks execute without errors
  - No absolute file paths
  - No references to local files
  - Build successfully:
    ```r
    build_vignettes()
    ```

### 1.4 Code Quality

- [ ] **Run local checks**
  ```r
  dev_check_complete()
  # Must return: 0 errors, 0 warnings, 0 notes
  ```

- [ ] **Good practice analysis**
  ```r
  dev_best_practices()
  # Review and address recommendations
  ```

- [ ] **Code coverage** (aim for >80%)
  ```r
  test_coverage_report()
  # Or: covr::package_coverage()
  ```

- [ ] **Test suite**
  ```r
  test_run()
  # All tests must pass
  ```

- [ ] **File system hygiene**
  - Never write to user's home directory or package installation directory
  - Write only to temporary directories: `tempfile()` or `tempdir()`
  - Clean up temporary files in examples/tests
  - Example:
    ```r
    # Good
    tmp <- tempfile(fileext = ".csv")
    write.csv(data, tmp)
    unlink(tmp)

    # Bad
    write.csv(data, "output.csv")  # Don't write to working directory!
    ```

---

## Phase 2: Local Validation

**Run comprehensive local checks before remote testing.**

### 2.1 R CMD check (Local)

- [ ] **Full check with CRAN standards**
  ```r
  release_02_local_checks()
  # This runs both devtools::check() and goodpractice::gp()
  ```

- [ ] **Result must be:** `0 errors | 0 warnings | 0 notes`
  - **Errors**: Must fix all (submission will be rejected)
  - **Warnings**: Must fix all (submission will be rejected)
  - **Notes**: Must fix all if possible
    - Acceptable notes: package size, new maintainer (first submission)
    - Document any unavoidable notes in `cran-comments.md`

### 2.2 URL Validation

- [ ] **Check all URLs in package**
  ```r
  # Install urlchecker if needed: install.packages("urlchecker")
  urlchecker::url_check()
  ```
  - Fix all broken links
  - Update HTTP to HTTPS where available
  - Remove or update deprecated URLs

### 2.3 HTML/Rd Validation

- [ ] **HTML5 compliance** (if using HTML in documentation):
  - Remove deprecated attributes: `align`, `border`, `width` from `<img>` tags
  - Use CSS instead of inline HTML attributes
  - Validate with: Tools → Check Package → Check for HTML issues

---

## Phase 3: Cross-Platform Testing

**CRAN tests on multiple platforms. You should too.**

### 3.1 Windows Testing

- [ ] **Submit to win-builder (R-devel)**
  ```r
  devtools::check_win_devel()
  ```
  - Results arrive via email (15-60 minutes)
  - Check spam folder if delayed
  - Must show: 0 errors, 0 warnings

### 3.2 macOS Testing

- [ ] **Submit to Mac builder (R-release)**
  ```r
  devtools::check_mac_release()
  ```
  - Results arrive via email (15-60 minutes)
  - Particularly important for packages with compiled code
  - Must show: 0 errors, 0 warnings

### 3.3 Comprehensive Multi-Platform Testing (Optional but Recommended)

- [ ] **R-Hub multi-platform checks**
  ```r
  dev_check_all_platforms()
  # Tests 20+ platforms - very thorough but slow
  ```
  - First time: Run `rhub::rhub_setup()` for configuration
  - Set `GITHUB_PAT` in `.Renviron` (never in code!)
  - Not required for all submissions, but good for:
    - First-time submissions
    - Packages with C/C++ code
    - Packages with complex dependencies
    - Major version updates

### 3.4 Reverse Dependency Checks (If Applicable)

- [ ] **Check packages that depend on yours**
  ```r
  # Only if other CRAN packages list yours in Depends/Imports/Suggests
  # install.packages("revdepcheck")
  revdepcheck::revdep_check(num_workers = 4)
  ```
  - Ensure your updates don't break dependent packages
  - Document any intentional breaking changes
  - Contact maintainers of affected packages before submission

---

## Phase 4: Final Review

### 4.1 Pre-Submission Checklist

**Go through this systematically:**

- [ ] Package passes local `R CMD check`: **0 | 0 | 0**
- [ ] Windows check passed
- [ ] macOS check passed
- [ ] All URLs validated and working
- [ ] Spell check passed (0 errors)
- [ ] NEWS.md updated with all changes
- [ ] Version number incremented
- [ ] All tests passing
- [ ] Examples run without errors (and quickly)
- [ ] No `\dontrun{}` without good reason
- [ ] DESCRIPTION file formatted correctly
- [ ] All function documentation complete (`@return` tags!)
- [ ] No writing to user directories (only `tempdir()`)
- [ ] Code committed to version control

### 4.2 Create Submission Materials

- [ ] **Create `cran-comments.md`**
  ```r
  usethis::use_cran_comments()
  ```
  Edit to include:
  - R CMD check results (0 errors | 0 warnings | 0 notes)
  - Test environment details (R version, OS)
  - Win-builder results
  - Mac builder results
  - Explanation of any unavoidable notes
  - For resubmissions: what changed since last version

  Example `cran-comments.md`:
  ```markdown
  ## R CMD check results

  0 errors | 0 warnings | 0 notes

  ## Test environments

  - Local: Ubuntu 22.04, R 4.3.2
  - Win-builder: R-devel (2024-01-15)
  - Mac builder: R 4.3.1
  - R-hub: 20 platforms (all passed)

  ## Reverse dependencies

  There are currently no reverse dependencies for this package.
  ```

- [ ] **Update README** (if using README.Rmd)
  ```r
  build_readme()
  # Or: devtools::build_readme()
  ```

- [ ] **Build package website** (if using pkgdown)
  ```r
  build_website()
  # Or: pkgdown::build_site()
  ```

### 4.3 Final Package Build

- [ ] **Build source tarball**
  ```r
  devtools::build()
  # Creates pkgname_x.y.z.tar.gz in parent directory
  ```

- [ ] **Verify tarball integrity**
  ```r
  # Check the built tarball
  pkgbuild::check_build_tools()
  ```

---

## Phase 5: Submission

### 5.1 Submit to CRAN

**Choose one method:**

#### Method A: Interactive Submission (Recommended)

```r
release_04_submit_to_cran()
# Or directly: devtools::release()
```

- Answer all questions carefully and honestly
- Read each prompt before responding
- Confirms submission automatically
- Uploads tarball to CRAN

#### Method B: Manual Submission

1. Go to: https://cran.r-project.org/submit.html
2. Upload your `.tar.gz` file
3. Fill in submission form
4. Submit
5. **IMPORTANT:** Check email for confirmation link
6. Click confirmation link within 24 hours

### 5.2 Confirm Submission

- [ ] **Check confirmation email**
  - Sent to maintainer email from DESCRIPTION
  - Subject: "CRAN submission [package] [version]"
  - **Click confirmation link** (critical step!)
  - Submission invalid without confirmation

- [ ] **Wait for initial automated checks** (usually minutes)
  - CRAN runs automated checks first
  - May receive auto-rejection for obvious issues
  - Address and resubmit quickly if auto-rejected

---

## Post-Submission

### While Waiting for Review

- [ ] **Monitor status**
  - Check CRAN incoming dashboard: https://cransays.github.io/
  - Or use: `cransays::take_snapshot()` (if package installed)
  - Typical review time:
    - Updates: 1-3 days
    - New submissions: 1-2 weeks

- [ ] **Do NOT email CRAN** asking about status
  - They will contact you when review is complete
  - Unnecessary emails slow down the process

### If Accepted

- [ ] **Celebrate!** 🎉 Your package is on CRAN!

- [ ] **Tag the release in git**
  ```bash
  git tag -a v1.0.0 -m "CRAN release 1.0.0"
  git push --tags
  ```

- [ ] **Update development version**
  - Increment version in DESCRIPTION (add `.9000`)
  - Example: `1.0.0` → `1.0.0.9000`
  - Add new development section to NEWS.md

- [ ] **Announce release**
  - Social media (Twitter/Mastodon with #rstats)
  - R-bloggers (if you have a blog post)
  - Relevant mailing lists
  - Package website

- [ ] **Update package website**
  ```r
  build_website()
  # Deploy to GitHub Pages if configured
  ```

### If Changes Requested

- [ ] **Respond promptly** (within 2-4 weeks)
  - CRAN gives limited time for resubmission
  - Respond to all points raised
  - Be polite and professional
  - Thank reviewers for their time

- [ ] **Make requested changes**
  - Address every item in the review
  - Increment patch version if resubmitting (1.0.0 → 1.0.1)
  - Document changes in `cran-comments.md`

- [ ] **Resubmit through normal process**
  - Start from Phase 2 (local validation)
  - Include "This is a resubmission" in `cran-comments.md`
  - Explain what changed in response to review

### If Rejected

- [ ] **Don't panic** - it happens to everyone
- [ ] **Read rejection reasons carefully**
- [ ] **Fix all issues** (may require substantial changes)
- [ ] **Wait appropriate time** before resubmitting (usually stated in rejection)
- [ ] **Start fresh** from Phase 1

---

## Common Rejection Reasons

Learn from others' mistakes:

### 1. DESCRIPTION File Issues

**Problem:** Improper formatting
```
# Bad
Title: An R Package for Data Analysis.
Description: This package analyzes data.

# Good
Title: Fast Data Analysis Tools
Description: Provides efficient algorithms for analyzing large datasets.
    Implements parallel computing techniques to reduce computation time.
```

**Problem:** URLs not in angle brackets
```
# Bad (in Description field)
See https://example.com for details.

# Good
See <https://example.com> for details.
```

**Problem:** Package names not quoted correctly
```
# Bad
Uses the Shiny framework...

# Good
Uses the 'shiny' framework...
```

### 2. Documentation Issues

**Problem:** Missing `@return` tags
```r
# Bad
#' Calculate mean
#' @param x numeric vector
foo <- function(x) mean(x)

# Good
#' Calculate mean
#' @param x numeric vector
#' @return The arithmetic mean of x
foo <- function(x) mean(x)
```

**Problem:** Overuse of `\dontrun{}`
```r
# Bad
#' @examples
#' \dontrun{
#'   foo(1:10)
#' }

# Good
#' @examples
#' foo(1:10)
#'
#' # For interactive-only code:
#' if (interactive()) {
#'   foo(1:10)
#' }
```

### 3. File System Issues

**Problem:** Writing to user directories
```r
# Bad - will be rejected!
write.csv(data, "~/output.csv")
write.csv(data, "output.csv")

# Good - write to temporary directory
tmp <- tempfile(fileext = ".csv")
write.csv(data, tmp)
# ... use file ...
unlink(tmp)  # Clean up
```

### 4. Check Results

**Problem:** Submitting with warnings/notes
- **Solution:** Must be 0 errors, 0 warnings, 0 notes (or documented acceptable notes)

**Problem:** Examples take too long
- **Solution:** Use `\donttest{}` for slow examples, keep under 5 seconds when possible

### 5. Resubmission Too Soon

**Problem:** Submitting updates too frequently
- **Solution:** Wait minimum 30 days between versions (unless critical bug fix)
- **Exception:** Resubmissions after requested changes are exempt

### 6. URL Issues

**Problem:** Broken or HTTP links
```
# Bad
http://example.com  # HTTP instead of HTTPS
http://dead-link.com  # Broken link

# Good
https://example.com  # HTTPS
# Run urlchecker::url_check() to verify all links
```

---

## Helpful Resources

### CRAN Policies and Documentation

- [CRAN Repository Policy](https://cran.r-project.org/web/packages/policies.html)
- [Writing R Extensions](https://cran.r-project.org/doc/manuals/r-release/R-exts.html)
- [R Packages Book (2nd ed)](https://r-pkgs.org/) by Hadley Wickham & Jennifer Bryan

### Useful R Packages

- `{devtools}` - Essential development workflow tools
- `{usethis}` - Automate package setup tasks
- `{goodpractice}` - Automated advice for better packages
- `{spelling}` - Spell checking for documentation
- `{urlchecker}` - Validate all URLs in package
- `{rhub}` - Multi-platform package checking
- `{revdepcheck}` - Check reverse dependencies
- `{attachment}` - Manage package dependencies
- `{checkhelper}` - Find missing documentation tags
- `{cransays}` - Monitor CRAN submission status

### Community Guides

- [ThinkR's CRAN Preparation Guide](https://github.com/ThinkR-open/prepare-for-cran)
- [rOpenSci Packaging Guide](https://devguide.ropensci.org/)
- [Tidyverse Style Guide](https://style.tidyverse.org/)

### Getting Help

- [R-package-devel mailing list](https://stat.ethz.ch/mailman/listinfo/r-package-devel)
- Stack Overflow: Tag `[r]` and `[cran]`
- [RStudio Community](https://community.rstudio.com/)

---

## Quick Reference: Dev Scripts Mapping

| Phase | Task | Function |
|-------|------|----------|
| **Daily Development** | Document & check (quick) | `dev_check_quick()` |
| | Document & check (complete) | `dev_check_complete()` |
| | Load package | `dev_load()` |
| | Run tests | `test_run()` |
| **Pre-Release** | Spell check | `test_spelling()` |
| | Code coverage | `test_coverage_report()` |
| | Code quality | `report_code_quality()` |
| | Best practices | `dev_best_practices()` |
| | Build README | `build_readme()` |
| | Build vignettes | `build_vignettes()` |
| **Release Process** | **Step 1:** Prepare | `release_01_prepare()` |
| | **Step 2:** Local checks | `release_02_local_checks()` |
| | **Step 3:** Remote checks | `release_03_remote_checks()` |
| | **Step 4:** Submit | `release_04_submit_to_cran()` |
| **Platform Checks** | Local check | `dev_check_complete()` |
| | Windows check | `devtools::check_win_devel()` |
| | macOS check | `devtools::check_mac_release()` |
| | Multi-platform | `dev_check_all_platforms()` |
| **Website** | Build site | `build_website()` |
| | Customize site | `help_customize_website()` |

---

## Final Wisdom

> "The easiest way to get your package accepted by CRAN is to submit a package that deserves to be accepted."
> — Hadley Wickham

**Remember:**
- CRAN maintainers are volunteers doing this in their spare time
- Thorough preparation = faster acceptance = less back-and-forth
- Follow the checklist, be patient, be polite
- Most rejections are for fixable issues - don't give up!

**Good luck with your submission! 🚀**
