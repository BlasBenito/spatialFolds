#' Set up Rcpp infrastructure for your R package
#'
#' Configures your R package to use C++ code via Rcpp. Checks for a C++
#' compiler, configures the package infrastructure, and creates example C++
#' functions to help you get started.
#'
#' @return Invisibly returns TRUE on success.
#'
#' @details
#' This function performs the following steps:
#' \enumerate{
#'   \item Checks that a C++ compiler is available on your system
#'   \item Runs \code{usethis::use_rcpp()} to configure package infrastructure
#'         (updates DESCRIPTION, creates src/ directory, configures build system)
#'   \item Creates example C++ functions in \code{src/rcpp_examples.cpp}
#'   \item Provides guidance on next steps
#' }
#'
#' After running this function, you must run \code{devtools::document()} to
#' compile the C++ code and generate R wrappers.
#'
#' @section Prerequisites:
#' You need a C++ compiler installed:
#' \itemize{
#'   \item Windows: Install Rtools from \url{https://cran.r-project.org/bin/windows/Rtools/}
#'   \item macOS: Install Xcode Command Line Tools (\code{xcode-select --install})
#'   \item Linux: Install g++ (usually pre-installed)
#' }
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' setup_cpp_support()
#' devtools::document()
#' }
setup_cpp_support <- function() {
  # Check prerequisites
  if (!requireNamespace("usethis", quietly = TRUE)) {
    utils::install.packages('usethis')
  }

  if (!requireNamespace("Rcpp", quietly = TRUE)) {
    utils::install.packages('Rcpp')
  }

  if (!requireNamespace("pkgbuild", quietly = TRUE)) {
    utils::install.packages('pkgbuild')
  }

  if (!requireNamespace("cli", quietly = TRUE)) {
    utils::install.packages('cli')
  }

  # Print header
  cli::cli_rule(center = "SETUP RCPP INFRASTRUCTURE")

  # Check for C++ compiler
  cli::cli_h2("Checking for C++ compiler")

  if (!pkgbuild::has_compiler()) {
    cli::cli_alert_danger("C++ compiler not found!")
    cli::cli_text("")
    cli::cli_text("You need a C++ compiler to use Rcpp. Here's how to get one:")
    cli::cli_text("")
    cli::cli_h3("Windows")
    cli::cli_text("  Download and install Rtools:")
    cli::cli_text("  {.url https://cran.r-project.org/bin/windows/Rtools/}")
    cli::cli_text("")
    cli::cli_h3("macOS")
    cli::cli_text("  Install Xcode Command Line Tools:")
    cli::cli_code("xcode-select --install")
    cli::cli_text("")
    cli::cli_h3("Linux")
    cli::cli_text("  Install g++:")
    cli::cli_code("sudo apt-get install g++  # Debian/Ubuntu")
    cli::cli_code("sudo yum install gcc-c++  # RedHat/CentOS")
    cli::cli_text("")
    cli::cli_abort("C++ compiler required", call = NULL)
  } else {
    cli::cli_alert_success("C++ compiler found")
  }

  # Run usethis::use_rcpp()
  cli::cli_h2("STEP 1: Running usethis::use_rcpp()")

  cli::cli_alert_info("Running {.code usethis::use_rcpp()} ...")
  usethis::use_rcpp()

  cli::cli_alert_success("Rcpp infrastructure configured")

  # Create example C++ file
  cli::cli_h2("STEP 2: Creating example C++ function")

  example_cpp <- '
#include <Rcpp.h>
using namespace Rcpp;

/\' Example C++ function using Rcpp
/\'
/\' This is an example function that squares a numeric vector element-wise.
/\' Replace this with your actual C++ code.
/\'
/\' @param x A numeric vector
/\' @return A numeric vector with each element squared
/\' @export
/\' @examples
/\' cpp_square(c(1, 2, 3, 4, 5))
// [[Rcpp::export]]
NumericVector cpp_square(NumericVector x) {
  int n = x.size();
  NumericVector result(n);

  for(int i = 0; i < n; i++) {
    result[i] = x[i] * x[i];
  }

  return result;
}


/\' Example function demonstrating vectorized operations
/\'
/\' Uses Rcpp sugar for more concise code (similar to R vectorization).
/\'
/\' @param x A numeric vector
/\' @param y A numeric vector
/\' @return Sum of x and y squared, element-wise
/\' @export
/\' @examples
/\' cpp_vectorized_example(1:5, 6:10)
// [[Rcpp::export]]
NumericVector cpp_vectorized_example(NumericVector x, NumericVector y) {
  // Rcpp sugar allows vectorized operations
  return pow(x + y, 2.0);
}
'

  # Write example file
  writeLines(example_cpp, "src/rcpp_examples.cpp")

  cli::cli_alert_success("Created example file: {.file src/rcpp_examples.cpp}")

  # Create RcppExports.R placeholder
  cli::cli_h2("STEP 3: Preparing for compilation")

  cli::cli_text("")
  cli::cli_text(
    "Next, you need to compile the C++ code and generate R wrappers."
  )
  cli::cli_text(
    "This happens automatically when you run {.code devtools::document()} or {.code devtools::load_all()}"
  )
  cli::cli_text("")
  cli::cli_text("Run now:")
  cli::cli_code("devtools::document()")
  cli::cli_text("")
  cli::cli_text("This will:")
  cli::cli_ul(c(
    "Compile your C++ code",
    "Generate R/RcppExports.R with R wrappers",
    "Generate src/RcppExports.cpp with C++ wrappers",
    "Update NAMESPACE with exports"
  ))

  # Provide usage guidance
  cli::cli_text("")
  cli::cli_rule(center = "RCPP SETUP COMPLETE - NEXT STEPS")

  cli::cli_h3("1. COMPILE AND DOCUMENT")
  cli::cli_text("   Run this now to compile C++ code:")
  cli::cli_code("     devtools::document()")
  cli::cli_text("")

  cli::cli_h3("2. TEST THE EXAMPLE FUNCTIONS")
  cli::cli_text("   After documenting, load and test:")
  cli::cli_code("     devtools::load_all()")
  cli::cli_code("     cpp_square(c(1, 2, 3, 4, 5))")
  cli::cli_code("     cpp_vectorized_example(1:5, 6:10)")
  cli::cli_text("")

  cli::cli_h3("3. ADD YOUR OWN C++ CODE")
  cli::cli_text("   Edit or create new .cpp files in src/")
  cli::cli_text("   Use this template for new functions:")
  cli::cli_text("")
  cli::cli_code("   //' Function description")
  cli::cli_code("   //' @param x Description of parameter")
  cli::cli_code("   //' @return Description of return value")
  cli::cli_code("   //' @export")
  cli::cli_code("   // [[Rcpp::export]]")
  cli::cli_code("   NumericVector your_function(NumericVector x) {")
  cli::cli_code("     // Your C++ code here")
  cli::cli_code("     return x;")
  cli::cli_code("   }")
  cli::cli_text("")

  cli::cli_h3("4. IMPORTANT NOTES")
  cli::cli_ul(c(
    "Always add @export to make functions available to users",
    "Use roxygen2 comments (//' not //) for documentation",
    "Run devtools::document() after changing .cpp files (every time!)",
    "Use // [[Rcpp::export]] attribute for each exported function",
    "C++ code is compiled when package is installed or loaded"
  ))
  cli::cli_text("")

  cli::cli_h3("5. RCPP RESOURCES")
  cli::cli_ul(c(
    "Rcpp documentation: {.url https://www.rcpp.org/}",
    "Rcpp Gallery: {.url https://gallery.rcpp.org/}",
    "Advanced R (Rcpp chapter): {.url https://adv-r.hadley.nz/rcpp.html}",
    "Rcpp book: 'Seamless R and C++ Integration with Rcpp'"
  ))
  cli::cli_text("")

  cli::cli_h3("6. COMMON PATTERNS")
  cli::cli_text("")

  cli::cli_text("   Scalar input/output:")
  cli::cli_code("     // [[Rcpp::export]]")
  cli::cli_code("     double multiply(double x, double y) { return x * y; }")
  cli::cli_text("")

  cli::cli_text("   Vector operations:")
  cli::cli_code("     // [[Rcpp::export]]")
  cli::cli_code(
    "     NumericVector times_two(NumericVector x) { return x * 2; }"
  )
  cli::cli_text("")

  cli::cli_text("   Matrix operations:")
  cli::cli_code("     // [[Rcpp::export]]")
  cli::cli_code(
    "     NumericMatrix transpose(NumericMatrix x) { return Rcpp::transpose(x); }"
  )
  cli::cli_text("")

  cli::cli_text("   Using R's RNG:")
  cli::cli_code("     // [[Rcpp::export]]")
  cli::cli_code(
    "     NumericVector rcpp_rnorm(int n) { return Rcpp::rnorm(n); }"
  )
  cli::cli_text("")

  cli::cli_h3("7. DEBUGGING")
  cli::cli_ul(c(
    "Use Rcpp::Rcout for printing (like std::cout)",
    "Example: Rcpp::Rcout << 'Debug message' << std::endl;",
    "Check compilation errors carefully - they reference line numbers",
    "Use devtools::load_all() to recompile during development"
  ))
  cli::cli_text("")

  cli::cli_h3("8. PERFORMANCE")
  cli::cli_ul(c(
    "Rcpp is best for loops and operations not vectorizable in R",
    "For simple operations, R's vectorized functions are often faster (no, really!)",
    "Profile before optimizing: Rprof() or profvis::profvis()",
    "Benchmark with microbenchmark package (see dev/analyze_performance.R)"
  ))
  cli::cli_text("")

  cli::cli_text("")
  cli::cli_rule()
  cli::cli_text("")
  cli::cli_alert_info("Ready to compile! Run:")
  cli::cli_code("  devtools::document()")
  cli::cli_text("")

  invisible(TRUE)
}
