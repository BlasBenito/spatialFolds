#include <Rcpp.h>
#include <algorithm>
#include <random>
#include <vector>
using namespace Rcpp;

//' (C++) Generate Blocks-Based Training Fold from Pre-computed Cell IDs
//' @description Randomly selects entire grid cells until target count reached. Cell assignments must be pre-computed in R via sf_to_grid().
//' @param xy (required, numeric matrix) Two columns matrix with locations. Used only for dimension checking (nrow must equal length of cell_id). Default: `NULL`
//' @param cell_id (required, integer vector) Pre-computed cell assignment for each point (0-based cell IDs from sf_to_grid()). Default: `NULL`
//' @param seed (required, integer) Random seed for reproducibility. Default: `NULL`
//' @param target (required, integer) Number of records to include in training fold. Default: `NULL`
//' @return logical vector with length equal to nrow(xy), where TRUE indicates training fold record
//' @details
//' Algorithm:
//' \enumerate{
//'   \item Count points per cell from cell_id vector (O(n) pass)
//'   \item Determine number of unique cells
//'   \item Shuffle cell IDs using Mersenne Twister RNG
//'   \item Select cells sequentially until cumulative count >= target
//'   \item Mark all points in selected cells as TRUE (O(n) pass)
//' }
//'
//' **Important**: Cell IDs must be pre-computed in R using sf_to_grid() before calling this function.
//' This optimization avoids recalculating cell assignments for each fold iteration.
//' For 1000 folds, this provides ~1.5x speedup by computing assignments once instead of 1000 times.
//'
//' Complexity: O(n + C log C) where C = number of unique cells
//' Memory: O(C) - minimal overhead
//'
//' @examples
//' # Cell IDs must be computed by sf_to_grid() in R first
//' cell_id <- sf_to_grid(xy_matrix, grid_rows = 10, grid_columns = 10)
//'
//' training <- method_blocks(
//'   xy = xy_matrix,
//'   cell_id = cell_id,
//'   seed = 123,
//'   target = 15000
//' )
//' @export
// [[Rcpp::export]]
LogicalVector method_blocks(
    NumericMatrix xy,
    IntegerVector cell_id,
    int seed,
    double target
) {

  int n = xy.nrow();
  int target_int = static_cast<int>(target);

  // Validate dimensions
  if (cell_id.size() != n) {
    stop("spatialFolds::method_blocks(): cell_id length must equal nrow(xy)");
  }

  // Find maximum cell ID to determine number of cells
  int max_cell_id = 0;
  for (int i = 0; i < n; i++) {
    if (cell_id[i] > max_cell_id) {
      max_cell_id = cell_id[i];
    }
  }
  int total_cells = max_cell_id + 1;  // Assuming 0-based cell IDs

  // Pass 1: Count points per cell from pre-computed cell_id
  std::vector<int> cell_counts(total_cells, 0);
  for (int i = 0; i < n; i++) {
    cell_counts[cell_id[i]]++;
  }

  // Create and shuffle cell IDs (follow method_random pattern)
  std::vector<int> cells(total_cells);
  for (int i = 0; i < total_cells; i++) {
    cells[i] = i;
  }

  std::mt19937 rng(seed);
  std::shuffle(cells.begin(), cells.end(), rng);

  // Select cells until target reached
  std::vector<bool> selected_cells(total_cells, false);
  int total_selected = 0;

  for (int cell_idx : cells) {
    if (cell_counts[cell_idx] > 0 && total_selected < target_int) {
      selected_cells[cell_idx] = true;
      total_selected += cell_counts[cell_idx];
    }

    // Stop once target reached (OK to exceed per spec)
    if (total_selected >= target_int) break;
  }

  // Pass 2: Mark points in selected cells
  LogicalVector result(n, false);
  for (int i = 0; i < n; i++) {
    if (selected_cells[cell_id[i]]) {
      result[i] = true;
    }
  }

  return result;
}
