#include <Rcpp.h>
#include <cmath>
#include <algorithm>
using namespace Rcpp;

//' (C++) Generate Contiguous Training Fold Using Spherical Geometry
//' @description Generates contiguous training folds on a sphere using angular
//'   distance from a center point. This method correctly handles data near the
//'   dateline (longitude +-180) and poles (latitude +-90) where planar geometry
//'   fails. The fold grows as a spherical cap centered on the specified point.
//' @param xyz (required, numeric matrix) Three-column matrix with Cartesian
//'   coordinates (x, y, z) on a unit sphere. Use `cast_xy_to_xyz()` to convert
//'   from longitude/latitude. Default: `NULL`
//' @param center (required, integer) Index of the training fold center (1-based
//'   indexing as in R). Default: `NULL`
//' @param angular_step (required, numeric) Angular growth increment in radians.
//'   Controls the precision of the binary search. Typical values: 0.001 to 0.01
//'   radians (0.06 to 0.6 degrees). Default: `NULL`
//' @param target (required, integer) Number of records to include in the
//'   training fold. Default: `NULL`.
//' @return logical vector with length equal to nrow(xyz), where TRUE indicates
//'   a record is in the training fold and FALSE indicates it is in the testing
//'   fold.
//' @details
//' This function uses binary search to efficiently find the angular radius:
//' \enumerate{
//'   \item Extracts center point coordinates from xyz matrix
//'   \item Binary searches for angular radius that yields target count
//'   \item Angular distance calculated via dot product: acos(dot(p1, p2))
//'   \item For unit sphere points, dot product equals cosine of angular distance
//'   \item Returns logical vector marking points within final radius
//' }
//'
//' The spherical cap approach ensures:
//' \itemize{
//'   \item Points near the dateline are correctly identified as neighbors
//'   \item Points near poles are correctly grouped regardless of longitude
//'   \item The fold shape is circular on the sphere surface
//' }
//'
//' Complexity: O(n log iterations) where iterations is typically 10-15
//'
//' @examples
//' # Create polar test data
//' polar_xy <- cbind(
//'   x = runif(1000, -180, 180),
//'   y = runif(1000, 75, 90)
//' )
//' xyz <- cast_xy_to_xyz(polar_xy)
//'
//' training <- method_contiguous_spherical(
//'   xyz = xyz,
//'   center = 1,
//'   angular_step = 0.01,
//'   target = 500
//' )
//'
//' sum(training)  # Should be close to 500
//'
//' @family contiguous
//' @export
// [[Rcpp::export]]
LogicalVector method_contiguous_spherical(
    NumericMatrix xyz,
    int center,
    double angular_step,
    double target
) {

  int n = xyz.nrow();

  // Check for empty input
  if (n == 0) {
    return LogicalVector(0);
  }

  // Validate center index bounds (catches NA which becomes NA_INTEGER)
  if (center < 1 || center > n) {
    stop("method_contiguous_spherical: center index %d out of bounds [1, %d]", center, n);
  }

  // Convert R's 1-based indexing to C++'s 0-based indexing
  int center_idx = center - 1;

  // Extract coordinate columns
  NumericVector x_coords = xyz(_, 0);
  NumericVector y_coords = xyz(_, 1);
  NumericVector z_coords = xyz(_, 2);

  // Get center point coordinates
  double cx = x_coords[center_idx];
  double cy = y_coords[center_idx];
  double cz = z_coords[center_idx];

  // Find maximum angular distance from center to any point
  // This establishes the search bounds
  double max_angular_dist = 0.0;
  for (int i = 0; i < n; i++) {
    // Dot product for unit sphere points equals cos(angular_distance)
    double dot = x_coords[i] * cx + y_coords[i] * cy + z_coords[i] * cz;
    // Clamp to [-1, 1] to handle numerical precision issues
    dot = std::max(-1.0, std::min(1.0, dot));
    double angular_dist = std::acos(dot);
    max_angular_dist = std::max(max_angular_dist, angular_dist);
  }

  // Binary search for angular radius that captures target count
  double radius_min = 0.0;
  double radius_max = max_angular_dist + angular_step;
  double final_radius = radius_max;

  // Use tolerance based on angular_step for convergence
  // Ensure minimum tolerance to prevent infinite loop when angular_step is 0 or very small
  double tolerance = std::max(angular_step / 100.0, 1e-9);

  while (radius_max - radius_min > tolerance) {
    double radius_mid = (radius_min + radius_max) / 2.0;

    // Precompute cos(radius) for faster comparison
    // cos(angular_dist) >= cos(radius) means angular_dist <= radius
    double cos_radius = std::cos(radius_mid);

    // Count points within angular radius
    int count = 0;
    for (int i = 0; i < n; i++) {
      double dot = x_coords[i] * cx + y_coords[i] * cy + z_coords[i] * cz;
      // dot >= cos_radius means point is within radius (closer = higher dot product)
      if (dot >= cos_radius) {
        count++;
      }
    }

    if (count < target) {
      radius_min = radius_mid;
    } else {
      radius_max = radius_mid;
      final_radius = radius_mid;
    }
  }

  // Final selection with found radius
  double cos_final_radius = std::cos(final_radius);

  LogicalVector result(n, false);
  for (int i = 0; i < n; i++) {
    double dot = x_coords[i] * cx + y_coords[i] * cy + z_coords[i] * cz;
    if (dot >= cos_final_radius) {
      result[i] = true;
    }
  }

  return result;
}
