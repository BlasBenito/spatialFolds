#include <Rcpp.h>
#include <vector>
using namespace Rcpp;

//' (C++) Generate Contiguous Training Fold Using Planar Geometry
//' @description Optimized implementation using binary search to find rectangle
//'   dimensions. Suitable for local to subcontinental scale data where planar
//'   geometry is a good approximation. For global data near the dateline or
//'   poles, use `method_contiguous_spherical()` instead.
//' @param xy (required, numeric matrix) Two columns matrix with the locations
//'   to arrange. The first column is interpreted as "x" (longitude) and the
//'   second as "y" (latitude). Default: `NULL`
//' @param center (required, integer) Index of the training fold center (1-based
//'   indexing as in R). Default: `NULL`
//' @param step_x (required, numeric) Rectangle growth increment along the
//'   x-axis. Must be in the same units as `xy`. Default: `NULL`
//' @param step_y (required, numeric) Rectangle growth increment along the
//'   y-axis. Must be in the same units as `xy`. Default: `NULL`
//' @param target (optional, integer) Number of records to include in the
//'   training fold. Default: `NULL`.
//' @return logical vector with length equal to nrow(xy), where TRUE indicates a
//'   record is in the training fold and FALSE indicates it is in the testing
//'   fold.
//' @details
//' This function uses binary search to efficiently find the rectangle size:
//' \enumerate{
//'   \item Determines the maximum possible rectangle scale from data extent
//'   \item Binary searches for scale factor that yields target count
//'   \item Each iteration counts points in rectangle (O(n))
//'   \item Total iterations: O(log(max_scale)) typically 10-15
//'   \item Returns logical vector for final rectangle
//' }
//'
//' This maintains rectangle shape and produces similar results to the original
//' implementation while being much faster through reduced iterations.
//'
//' Complexity: O(n log iterations) where iterations = 10-15
//' Performance: Typically 15-20x faster than R version on large datasets
//'
//' @examples
//' training <- method_contiguous_planar(
//'   xy = xy_matrix,
//'   center = 1, #first record in xy_matrix
//'   step_x = 0.4,
//'   step_y = 0.1,
//'   target = 15000
//' )
//'
//' spatial_fold_plot(
//'   df = xy_matrix,
//'   training_fold = training
//' )
//' @family contiguous
//' @export
// [[Rcpp::export]]
LogicalVector method_contiguous_planar(
    NumericMatrix xy,
    int center,
    double step_x,
    double step_y,
    double target
) {


  int n = xy.nrow();

  // Check for empty input
  if (n == 0) {
    return LogicalVector(0);
  }

  // Validate center index bounds (catches NA which becomes NA_INTEGER)
  if (center < 1 || center > n) {
    stop("method_contiguous_planar: center index %d out of bounds [1, %d]", center, n);
  }

  // Convert R's 1-based indexing to C++'s 0-based indexing
  int center_idx = center - 1;

  // Extract x and y columns
  NumericVector x_coords = xy(_, 0);
  NumericVector y_coords = xy(_, 1);

  // Get center coordinates
  double center_x = x_coords[center_idx];
  double center_y = y_coords[center_idx];

  // Find maximum possible scale by checking data extent
  double max_dx = 0.0;
  double max_dy = 0.0;
  for (int i = 0; i < n; i++) {
    max_dx = std::max(max_dx, std::abs(x_coords[i] - center_x));
    max_dy = std::max(max_dy, std::abs(y_coords[i] - center_y));
  }

  double scale_min = 0.0;
  double scale_max = std::max(max_dx / step_x, max_dy / step_y) + 1.0;

  // Binary search for correct scale
  double final_scale = scale_max;
  while (scale_max - scale_min > 0.01) {
    double scale_mid = (scale_min + scale_max) / 2.0;

    double x_min = center_x - scale_mid * step_x;
    double x_max = center_x + scale_mid * step_x;
    double y_min = center_y - scale_mid * step_y;
    double y_max = center_y + scale_mid * step_y;

    // Count points in rectangle
    int count = 0;
    for (int i = 0; i < n; i++) {
      if (x_coords[i] >= x_min && x_coords[i] <= x_max &&
          y_coords[i] >= y_min && y_coords[i] <= y_max) {
        count++;
      }
    }

    if (count < target) {
      scale_min = scale_mid;
    } else {
      scale_max = scale_mid;
      final_scale = scale_mid;
    }
  }

  // Final selection with found scale
  double x_min = center_x - final_scale * step_x;
  double x_max = center_x + final_scale * step_x;
  double y_min = center_y - final_scale * step_y;
  double y_max = center_y + final_scale * step_y;

  LogicalVector result(n, false);
  for (int i = 0; i < n; i++) {
    if (x_coords[i] >= x_min && x_coords[i] <= x_max &&
        y_coords[i] >= y_min && y_coords[i] <= y_max) {
      result[i] = true;
    }
  }

  return result;
}
