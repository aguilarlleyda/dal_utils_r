#ensure tidyverse is installed and loaded
if (!requireNamespace("tidyverse", quietly = TRUE)) {
  stop("The 'tidyverse' package is required but not installed. Please install it with install.packages('tidyverse').")
}
library(tidyverse)

#define global graphical parameters
axeswidth <- 0.5 #axes width
size_sumdot <- 4 #size for summary points
size_indivdot <- 1.5 #size for smaller, individual points
size_indivline <- 0.2 #size for individual lines
stroke_sumdot <- 0.5 #stroke width for summary points
jitter_seed <- 12345 #random seed for jittered points

#create custom plotting theme
theme_set (theme_classic(14) + theme(axis.line.x = element_line(colour = 'black', linewidth=axeswidth, linetype='solid'),
                                     axis.line.y = element_line(colour = 'black', linewidth=axeswidth, linetype='solid'),
                                     axis.ticks = element_line(color="black", linewidth=axeswidth),
                                     axis.text.x = element_text(color="black"),
                                     axis.text.y = element_text(color="black"),
                                     text = element_text(family = "Helvetica")))