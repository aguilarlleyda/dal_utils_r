#' Summarise a Variable with Mean, SD, SE, and 95% Confidence Interval
#'
#' This function computes descriptive statistics for a single variable:
#' mean, standard deviation, standard error, and 95% confidence interval.
#' The results are returned with dynamically named columns (e.g.,
#' `Petal.Length`, `sd_Petal.Length`, `se_Petal.Length`, `low_ci_Petal.Length`,
#' `up_ci_Petal.Length`).
#'
#' @param data A data frame or tibble containing the variable of interest.
#' @param var A numeric variable to summarise (unquoted).
#'
#' @return A tibble with the following columns:
#' \itemize{
#'   \item `var` — mean of the variable
#'   \item `sd_var` — standard deviation
#'   \item `n_var` — sample size
#'   \item `se_var` — standard error
#'   \item `low_ci_var` — lower bound of the 95% confidence interval
#'   \item `up_ci_var` — upper bound of the 95% confidence interval
#' }
#' where `var` is replaced by the name of the input variable.
#'
#' @examples
#' # Summarise Petal.Length for each iris Species
#' iris %>%
#'   group_by(Species) %>%
#'   summarise_with_ci(Petal.Length)
#'
#' @export
summarise_with_ci <- function(data, var) {
  var <- enquo(var) # convert variable to quosure
  var_name <- quo_name(var) # convert quosure to string to create new variable names
  
  data %>%
    summarise(
      !!paste0("sd_", var_name) := sd(!!var, na.rm = TRUE),  # standard deviation
      !!var_name := mean(!!var, na.rm = TRUE),               # mean
      !!paste0("n_", var_name) := n()                        # sample size
    ) %>%
    mutate(
      !!paste0("se_", var_name) := !!sym(paste0("sd_", var_name)) /
        sqrt(!!sym(paste0("n_", var_name))), # standard error
      !!paste0("low_ci_", var_name) := !!sym(var_name) -
        qt(1 - (0.05 / 2), !!sym(paste0("n_", var_name)) - 1) *
        !!sym(paste0("se_", var_name)),     # lower 95% CI
      !!paste0("up_ci_", var_name) := !!sym(var_name) +
        qt(1 - (0.05 / 2), !!sym(paste0("n_", var_name)) - 1) *
        !!sym(paste0("se_", var_name))      # upper 95% CI
    )
}
