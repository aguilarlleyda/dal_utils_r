#' Create Violin Plots with Individual Observations and Summary Statistics
#'
#' This function generates violin plots with optional individual observations,
#' connecting lines for dependent observations, and summary statistics with
#' error bars (standard error or 95% confidence interval).
#'
#' @param df A data frame or tibble containing the data.
#' @param variable_x The categorical variable for the x-axis (unquoted).
#' @param variable_y The numeric variable for the y-axis (unquoted).
#' #' @param error_type Character string indicating the type of error bars to draw:
#'   \itemize{
#'     \item `"SE"` (default): standard error of the mean
#'     \item `"CI"`: 95% confidence interval
#'   }
#' @param dep_obs Logical. If TRUE, connects repeated measures across
#'   conditions with lines. Defaults to FALSE.
#' @param variable_longit The ID variable linking repeated measures across
#'   x-axis levels (required if `dep_obs = TRUE`).
#' @param col_palette Optional ggplot2 scale for point/line colors.
#' @param fill_palette Optional ggplot2 scale for violin fill colors.
#' @param plot_scalex Optional ggplot2 x-axis scale.
#' @param plot_scaley Optional ggplot2 y-axis scale.
#' @param plot_xlab Optional x-axis label.
#' @param plot_ylab Optional y-axis label.
#'
#' @return A ggplot object.
#'
#' @examples
#' # Example 1: independent observations (iris dataset)
#'
#' create_violin(
#'   df = iris,
#'   variable_x = Species,
#'   variable_y = Petal.Length,
#'   error_type = "CI"
#' )
#'
#' # Example 2: dependent observations (ChickWeight dataset)
#'
#' create_violin(
#'   df = ChickWeight %>% filter(Time < 10),
#'   variable_x = Time,
#'   variable_y = weight,
#'   error_type = "SE",
#'   dep_obs = TRUE,
#'   variable_longit = Chick
#' )
#'
#' @export
create_violin <- function(df,
                          variable_x,
                          variable_y,
                          error_type = "SE",
                          dep_obs = FALSE,
                          variable_longit = NULL,
                          col_palette = NULL,
                          fill_palette = NULL,
                          plot_scalex = NULL,
                          plot_scaley = NULL,
                          plot_xlab = NULL,
                          plot_ylab = NULL) {
  
  # capture variable names
  var_name <- quo_name(enquo(variable_y))
  longit_var <- enquo(variable_longit)
  
  # summarise data
  summary_df <- df %>%
    group_by({{ variable_x }}) %>%
    summarise_with_ci({{ variable_y }})
  
  # violin base
  p <- ggplot(summary_df, aes(x = {{ variable_x }}, y = !!sym(var_name))) +
    geom_violin(
      data = df,
      aes(x = {{ variable_x }},
          y = {{ variable_y }},
          group = {{ variable_x }},
          col = factor({{ variable_x }}),
          fill = factor({{ variable_x }})),
      size = stroke_sumdot, alpha = 0.5
    )
  
  # dependent lines if dep_obs = TRUE
  if (dep_obs) {
    if (rlang::quo_is_null(longit_var)) stop("variable_longit must be provided if dep_obs = TRUE")
    
    p <- p +
      geom_path(
        data = df,
        aes(x = {{ variable_x }},
            y = {{ variable_y }},
            group = !!longit_var),
        position = position_jitter(width = 0.2, seed = jitter_seed),
        color = "grey", size = size_indivline
      )
  }
  
  # individual dots
  if (rlang::quo_is_null(longit_var)) {
    p <- p +
      geom_point(
        data = df,
        aes(x = {{ variable_x }}, y = {{ variable_y }},
            col = factor({{ variable_x }})),
        position = position_jitter(width = 0.2, seed = jitter_seed),
        shape = 21, fill = "white", size = size_indivdot
      )
  } else {
    p <- p +
      geom_point(
        data = df,
        aes(x = {{ variable_x }}, y = {{ variable_y }},
            group = !!longit_var,
            col = factor({{ variable_x }})),
        position = position_jitter(width = 0.2, seed = jitter_seed),
        shape = 21, fill = "white", size = size_indivdot
      )
  }
  
  # summary error bars, either based on SE or 95% CI
  if (error_type == "SE") {
    p <- p +
      geom_errorbar(
        aes(
          ymin = !!sym(var_name) - !!sym(paste0("se_", var_name)),
          ymax = !!sym(var_name) + !!sym(paste0("se_", var_name))
        ),
        width = 0, size = 0.75, color = "black",
        data = summary_df
      )
  } else if (error_type == "CI") {
    p <- p +
      geom_errorbar(
        aes(
          ymin = !!sym(paste0("low_ci_", var_name)),
          ymax = !!sym(paste0("up_ci_", var_name))
        ),
        width = 0, size = 0.75, color = "black",
        data = summary_df
      )
  } else {
    stop('error_type must be either "SE" or "CI".')
  }
  
  # summary dots
  p <- p +
    geom_point(
      data = summary_df,
      aes(x = {{ variable_x }}, y = !!sym(var_name)),
      size = size_sumdot * 0.75, stroke = stroke_sumdot,
      shape = 19, color = "black"
    ) +
    theme(legend.position = "none")
  
  # add optional scales / labels
  if (!is.null(col_palette))   p <- p + col_palette
  if (!is.null(fill_palette)) p <- p + fill_palette
  if (!is.null(plot_scalex))  p <- p + plot_scalex
  if (!is.null(plot_scaley))  p <- p + plot_scaley
  if (!is.null(plot_xlab))    p <- p + xlab(plot_xlab)
  if (!is.null(plot_ylab))    p <- p + ylab(plot_ylab)
  
  return(p)
}