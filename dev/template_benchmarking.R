#' Performance Analysis Template for Benchmarking
#'
#' Provides interactive templates and examples for benchmarking and profiling
#' package functions. This is a TEMPLATE function that must be customized.
#'
#' @return Microbenchmark results from demonstration example, returned invisibly.
#'
#' @details
#' **IMPORTANT: This is a TEMPLATE function - you must customize it!**
#'
#' This function won't do anything useful for your package until you edit it.
#' It provides templates and examples for:
#'
#' 1. Benchmarking function execution time with microbenchmark
#' 2. Profiling code execution with profvis
#' 3. Comparing alternative implementations
#' 4. Identifying performance bottlenecks
#'
#' The function loads your package and displays template code that you should
#' copy, modify, and run interactively to analyze your specific functions.
#'
#' @section Template Usage:
#' 1. Run this function to see the templates
#' 2. Copy the relevant template code
#' 3. Modify it for your specific functions
#' 4. Replace placeholder function calls with your actual functions
#' 5. Create realistic test data (not toy examples)
#' 6. Run the customized code in your R session
#' 7. Analyze results and optimize as needed
#'
#' @section Typical Runtime:
#' <1 second (just displays templates and runs simple demo)
#'
#' @section Prerequisites:
#' - Must be run from package root directory
#' - microbenchmark package will be installed if missing
#' - profvis package will be installed if missing
#' - devtools package will be installed if missing
#'
#' @section Important Notes:
#' - Replace ALL placeholder function calls with your actual functions
#' - Use realistic data sizes that match production use
#' - Profile on representative workloads, not tiny test cases
#' - Consider trade-offs: speed vs readability
#' - Don't optimize prematurely - profile first!
#' - Document why you chose each optimization
#' - Faster isn't always better if it hurts maintainability
#'
#' @export
#' @autoglobal
#'
#' @examples
#' \dontrun{
#' # Display benchmarking templates
#' template_benchmarking()
#'
#' # Then customize the templates for your functions:
#' # benchmark_result <- microbenchmark::microbenchmark(
#' #   small = your_function(small_data),
#' #   large = your_function(large_data),
#' #   times = 100
#' # )
#' # print(benchmark_result)
#' }
template_benchmarking <- function() {
  # Check and install dependencies
  required_packages <- c("microbenchmark", "profvis", "devtools")
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      cli::cli_alert_info("Installing required package: {.pkg {pkg}}")
      utils::install.packages(pkg)
    }
  }

  # Print header
  cli::cli_rule(
    left = "PERFORMANCE ANALYSIS TEMPLATE"
  )
  cli::cli_text()

  cli::cli_alert_warning(
    "This is a TEMPLATE script. You need to customize it for your package functions."
  )
  cli::cli_text("(It won't do anything useful until you do!)")
  cli::cli_text()

  # Load package
  cli::cli_alert_info("Loading package...")
  devtools::load_all(quiet = TRUE)
  cli::cli_alert_success("Package loaded")
  cli::cli_text()

  # Benchmarking template
  cli::cli_h2("BENCHMARKING TEMPLATE")
  cli::cli_text()
  cli::cli_text("Example: Benchmark a function with microbenchmark")
  cli::cli_text()
  cli::cli_code("# Uncomment and modify this template:")
  cli::cli_code("# benchmark_result <- microbenchmark::microbenchmark(")
  cli::cli_code("#   small_input = your_function(small_data),")
  cli::cli_code("#   medium_input = your_function(medium_data),")
  cli::cli_code("#   large_input = your_function(large_data),")
  cli::cli_code("#   times = 100")
  cli::cli_code("# )")
  cli::cli_code("# print(benchmark_result)")
  cli::cli_code("# plot(benchmark_result)")
  cli::cli_text()

  # Profiling template
  cli::cli_h2("PROFILING TEMPLATE")
  cli::cli_text()
  cli::cli_text("Example: Profile a function with profvis")
  cli::cli_text()
  cli::cli_code("# Uncomment and modify this template:")
  cli::cli_code("# profvis::profvis({")
  cli::cli_code("#   result <- your_function(test_data)")
  cli::cli_code("# })")
  cli::cli_code("# ")
  cli::cli_code("# The interactive profiler will open in your browser")
  cli::cli_code("# It shows:")
  cli::cli_code("#   - Time spent in each function")
  cli::cli_code("#   - Memory allocations")
  cli::cli_code("#   - Call stack visualization")
  cli::cli_text()

  # Comparison template
  cli::cli_h2("COMPARISON TEMPLATE")
  cli::cli_text()
  cli::cli_text("Example: Compare alternative implementations")
  cli::cli_text()
  cli::cli_code("# Uncomment and modify this template:")
  cli::cli_code("# comparison <- microbenchmark::microbenchmark(")
  cli::cli_code("#   approach_1 = implementation_1(data),")
  cli::cli_code("#   approach_2 = implementation_2(data),")
  cli::cli_code("#   approach_3 = implementation_3(data),")
  cli::cli_code("#   times = 100")
  cli::cli_code("# )")
  cli::cli_code("# print(comparison)")
  cli::cli_code("# ")
  cli::cli_code("# Use this to choose the fastest implementation")
  cli::cli_text()

  # Demonstration example
  cli::cli_h2("DEMONSTRATION EXAMPLE")
  cli::cli_text()
  cli::cli_alert_info(
    "Running {.code microbenchmark::microbenchmark()} demo ..."
  )
  cli::cli_text()

  # Simple example with base R functions
  demo_result <- microbenchmark::microbenchmark(
    sqrt_loop = {
      x <- numeric(1000)
      for (i in 1:1000) {
        x[i] <- sqrt(i)
      }
    },
    sqrt_vectorized = {
      x <- sqrt(1:1000)
    },
    times = 100
  )

  print(demo_result)

  cli::cli_text()
  cli::cli_rule("PERFORMANCE ANALYSIS TEMPLATE COMPLETE")
  cli::cli_text()

  cli::cli_h3("NEXT STEPS:")
  cli::cli_ol(c(
    "Identify functions that need performance analysis (the slow ones!)",
    "Create representative test data (use realistic sizes)",
    "Uncomment and customize the templates above",
    "Run benchmarks and profiling",
    "Optimize bottlenecks if needed (but only if needed)",
    "Compare performance before/after changes"
  ))
  cli::cli_text()

  cli::cli_h3("TIPS:")
  cli::cli_ul(c(
    "Profile with realistic data sizes (not toy examples)",
    "Consider memory usage, not just speed (memory matters!)",
    "Balance performance with code readability (don't sacrifice clarity)",
    "Document why optimizations were chosen (explain the trade-offs)"
  ))
  cli::cli_rule()

  invisible(demo_result)
}
