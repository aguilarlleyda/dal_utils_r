#' Create Correlation Annotations
#'
#' This function computes pairwise correlations between a set of variables,
#' optionally within groups, and returns a tidy data frame with correlation
#' coefficients, p-values, and significance annotations.
#'
#' @param data A data frame or tibble containing the variables of interest.
#' @param vars A character vector of variable names to compute correlations on.
#' @param method Correlation method to use. Options are `"pearson"` (default),
#'   `"spearman"`, or `"kendall"`.
#' @param group_var Optional. A character vector of one or more grouping
#'   variables. If provided, correlations are computed separately for each group.
#'
#' @return A data frame with the following columns:
#' \itemize{
#'   \item `pair` — variable pair name (e.g., `"Sepal.Length_Sepal.Width"`)
#'   \item `r` — correlation coefficient (rounded to 2 decimals)
#'   \item `p` — p-value of the correlation test (rounded to 2 decimals)
#'   \item `anot` — annotation string (e.g., `"r = 0.85, ***"`)
#'   \item grouping columns — included if `group_var` is specified
#' }
#'
#' @examples
#' # Example: correlations by iris species
#' create_cor_anot(
#'   iris,
#'   vars = c("Sepal.Length", "Sepal.Width", "Petal.Length"),
#'   group_var = "Species"
#' )
#'
#' @export
create_cor_anot <- function(data, vars, method = "pearson", group_var = NULL) {
  var_pairs <- combn(vars, 2, simplify = FALSE)
  
  # If no grouping, wrap in list so loop still works
  if (is.null(group_var)) {
    groups <- list(data)
    group_names <- list(NULL)
  } else {
    # split by multiple grouping variables
    grouped <- dplyr::group_by(data, dplyr::across(all_of(group_var)))
    groups <- dplyr::group_split(grouped, .keep = TRUE)
    group_names <- dplyr::group_keys(grouped)
  }
  
  results <- purrr::map2(groups, seq_along(groups), function(df, i) {
    res_pairs <- lapply(var_pairs, function(pair) {
      x <- df[[pair[1]]]
      y <- df[[pair[2]]]
      
      test <- cor.test(x, y, method = method)
      
      r_val <- round(test$estimate, 2)
      p_val <- round(test$p.value, 2)
      sig   <- create_significance_label(test$p.value)
      
      data.frame(
        pair = paste(pair, collapse = "_"),
        r = r_val,
        p = p_val,
        anot = paste0("r = ", sprintf("%.2f", r_val), ", ", sig),
        stringsAsFactors = FALSE
      )
    })
    
    out <- do.call(rbind, res_pairs)
    if (!is.null(group_var)) {
      out <- cbind(group_names[i, ], out)  # prepend grouping columns
    }
    out
  })
  
  results_df <- do.call(rbind, results)
  rownames(results_df) <- NULL
  return(as_tibble(results_df))
}