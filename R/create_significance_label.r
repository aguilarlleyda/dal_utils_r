#' Create Significance Labels from P-values
#'
#' This function converts p-values into common significance labels
#' (e.g., `"***"`, `"**"`, `"*"`, `"."`, `"n.s."`).
#' It is vectorized, so it can be applied directly to numeric vectors
#' of p-values without needing a loop.
#'
#' @param p A numeric vector of p-values.
#'
#' @return A character vector with the corresponding significance labels:
#' \itemize{
#'   \item `p < 0.001` → `"***"`
#'   \item `p < 0.01`  → `"**"`
#'   \item `p < 0.05`  → `"*"`
#'   \item `p < 0.1`   → `"."`
#'   \item otherwise   → `"n.s."`
#' }
#'
#' @examples
#' # Example p-values
#' df <- data.frame(p = c(0.0005, 0.02, 0.07, 0.3))
#' df$signif <- create_significance_label(df$p)
#' df
#'
#' # Directly on a vector
#' create_significance_label(c(0.001, 0.04, 0.2))
#'
#' @export
create_significance_label <- Vectorize(function(p) {
  if (p < 0.001) {
    label <- "***"
  } else if (p < 0.01) {
    label <- "**"
  } else if (p < 0.05) {
    label <- "*"
  } else if (p < 0.1) {
    label <- "."
  } else {
    label <- "n.s."
  }
  return(label)
})
