#' Convert logical fold vector to rsplit object
#'
#' @param fold Logical vector where TRUE = training (analysis), FALSE = testing (assessment)
#' @param data The original data frame
#' @return An rsplit object
#' @noRd
fold_to_rsplit <- function(fold, data) {
  rsample::make_splits(
    x = list(
      analysis = which(fold),
      assessment = which(!fold)
    ),
    data = data
  )
}

#' Create rset with custom spatial classes
#'
#' @param splits List of rsplit objects
#' @param ids Character vector of fold identifiers
#' @param subclass Character string for the method-specific class
#' @return An rset object with spatial classes
#' @noRd
make_spatial_rset <- function(splits, ids, subclass) {
  rset <- rsample::manual_rset(splits = splits, ids = ids)
  class(rset) <- c(subclass, "spatial_rset", class(rset))
  rset
}
