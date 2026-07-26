#' Compare Multiple Diagnostic Tests
#'
#' Compares the performance of multiple diagnostic tests side-by-side.
#'
#' @param actual Vector of actual disease status (0/1 or FALSE/TRUE)
#' @param tests List of test results. Each element should be a vector of
#'   predicted/test results (0/1 or FALSE/TRUE). Names are used for labels.
#'
#' @return Data frame with comparison metrics for each test
#'
#' @details
#' This function calculates all diagnostic performance metrics for each test
#' and returns them in a comparative format that makes it easy to identify
#' which test performs best for your needs.
#'
#' @examples
#' \dontrun{
#'   actual <- c(1, 1, 0, 0, 1, 1, 0, 0)
#'   test1 <- c(1, 1, 0, 1, 1, 0, 0, 0)
#'   test2 <- c(1, 1, 0, 0, 1, 0, 0, 1)
#'   test3 <- c(1, 1, 0, 1, 1, 1, 0, 0)
#'
#'   comparison <- compare_tests(
#'     actual = actual,
#'     tests = list(
#'       "Test A" = test1,
#'       "Test B" = test2,
#'       "Test C" = test3
#'     )
#'   )
#'   print(comparison)
#' }
#'
#' @export
compare_tests <- function(actual, tests) {
  if (!is.list(tests)) {
    stop("'tests' must be a list of test result vectors")
  }

  if (is.null(names(tests))) {
    names(tests) <- paste0("Test_", seq_along(tests))
  }

  # Calculate metrics for each test
  results <- lapply(tests, function(test_results) {
    calculate_metrics(actual, test_results)
  })

  # Convert to data frame
  comparison_df <- as.data.frame(do.call(rbind, results))
  comparison_df$Test <- names(tests)

  # Reorder columns
  comparison_df <- comparison_df[, c("Test", setdiff(names(comparison_df), "Test"))]

  # Round numeric columns
  numeric_cols <- sapply(comparison_df, is.numeric)
  comparison_df[numeric_cols] <- round(comparison_df[numeric_cols], 4)

  # Add row names
  rownames(comparison_df) <- NULL

  return(comparison_df)
}
