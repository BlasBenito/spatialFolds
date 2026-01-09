#include <Rcpp.h>
#include <algorithm>
#include <random>
using namespace Rcpp;

//' (C++) Generate Random Training Fold
//' @description Randomly selects training samples without replacement until target count is reached.
//' @param xy (required, numeric matrix) Two columns matrix with the locations. The first column is interpreted as "x" (longitude) and the second as "y" (latitude). Default: `NULL`
//' @param seed (required, integer) Random seed for reproducibility. Default: `NULL`
//' @param target (required, integer) Number of records to include in the training fold. Default: `NULL`.
//' @return logical vector with length equal to nrow(xy), where TRUE indicates a record is in the training fold and FALSE indicates it is in the testing fold.
//' @details
//' This function implements random sampling without replacement:
//' \enumerate{
//'   \item Creates vector of all indices (0 to n-1)
//'   \item Sets random seed for reproducibility
//'   \item Shuffles indices using Fisher-Yates algorithm
//'   \item Marks first target indices as training samples (TRUE)
//'   \item Returns logical vector
//' }
//'
//' Complexity: O(n) for shuffling
//' Memory: O(n) for index vector
//'
//' @examples
//' training <- method_random(
//'   xy = xy_matrix,
//'   seed = 123,
//'   target = 15000
//' )
//' @export
// [[Rcpp::export]]
LogicalVector method_random(
    NumericMatrix xy,
    int seed,
    double target
) {

  int n = xy.nrow();
  int target_int = static_cast<int>(target);

  // Ensure target doesn't exceed sample size
  if (target_int > n) {
    target_int = n;
  }

  // Create index vector
  std::vector<int> indices(n);
  for (int i = 0; i < n; i++) {
    indices[i] = i;
  }

  // Set random seed and shuffle
  std::mt19937 rng(seed);
  std::shuffle(indices.begin(), indices.end(), rng);

  // Create result vector (all FALSE initially)
  LogicalVector result(n, false);

  // Mark first target_int indices as training
  for (int i = 0; i < target_int; i++) {
    result[indices[i]] = true;
  }

  return result;
}
