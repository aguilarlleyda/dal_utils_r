# dal_utils_r

A collection of R utility functions for data wrangling, analysis and visualization.

## Usage

Clone the repository and source the loader script:

```r
source("load_all.R")
```  
Although individual functions can be accessed in their .R files, please mind that they often use other helper functions. Most functions also rely on tidyverse packages, and visualization functions also rely on some predefined graphic parameters. These can be found in `globals.R`, which is automatically loaded by the loader script.

## Function Index
- `create_cor_anot()` — compute correlations across variable pairs and return r, p, and annotation strings.
- `create_significance_label()` — convert p-values to significance stars (***, **, *, ., n.s.) commonly used in statistical reporting.
- `create_violin()` — custom violin plots with individual dots, error bars, and optional longitudinal connections.
- `summarise_with_ci()` — summarise a variable with mean, sd, se, and 95% CI.

## Examples

### `create_violin()`
Custom violin plots with individual dots, error bars, and optional longitudinal connections.



#### Example 1: independent observations for each violin (iris dataset)

```r
create_violin(
  df = iris,
  variable_x = Species,
  variable_y = Petal.Length,
  error_type = "CI"
)
```  
<img src="figs/violin_indep.png" height="400"/>

#### Example 2: dependent observations connected with lines (ChickWeight dataset)

```r
create_violin(
  df = ChickWeight %>% filter(Time < 10),
  variable_x = Time,
  variable_y = weight,
  error_type = "SE",
  dep_obs = TRUE,
  variable_longit = Chick
)
```  

<img src="figs/violin_dep.png" height="400"/>

