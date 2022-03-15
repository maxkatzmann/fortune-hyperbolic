library(tidyr)
library(ggplot2)
library(dplyr)
theme_set(theme_bw())

# Read command line arguments.
args <- commandArgs(trailingOnly = TRUE)
plot_output_dir <- args[1]


## read the table
precision_tbl <- read.csv("experiments/results/diagrams-groundtruth-comparison.csv",
    sep = ","
)
cgal_tbl <- read.csv("experiments/results/diagrams-cgal-comparison.csv",
    sep = ","
)
precision_column <- rep("CGAL", nrow(cgal_tbl))
cgal_tbl$Precision <- factor(precision_column)

selected_columns <- c("DiskRadius", "DiagramID", "Precision", "MatchingPercentage")
tbl <- precision_tbl[selected_columns]
cgal_addendum <- cgal_tbl[selected_columns]
tbl <- rbind(tbl, cgal_addendum)

## Round disk radii
specify_decimal <- function(x, k) trimws(format(round(x, k), nsmall = k))
tbl <- tbl %>% mutate_at(vars(DiskRadius), ~ specify_decimal(., 3))

tbl$Precision <- as.factor(tbl$Precision)

axis_cut <- 0.925

precision_levels <- c("CGAL", "16", "32", "48", "64", "80", "96", "112")
ggplot(tbl, aes(x = reorder(DiskRadius, sort(as.numeric(DiskRadius))), y = MatchingPercentage)) +
    geom_boxplot(aes(
        fill = factor(Precision, levels = precision_levels),
        color = factor(Precision, levels = precision_levels)
    )) +
    scale_fill_hue(c = 30, l = 100, guide = "none") +
    labs(
        x = "Disk Radius",
        y = "Matching Voronoi Vetices",
        color = "Technique"
    ) +
    scale_color_hue(labels = c(
        "CGAL (Converted)",
        "Native (Double)",
        "Native (32)",
        "Native (48)",
        "Native (64)",
        "Native (80)",
        "Native (96)",
        "Native (112)"
    )) +
    theme(
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        legend.position = c(0.16, 0.225)
    ) +
    scale_y_continuous(labels = scales::percent, limits = c(axis_cut, 1.0))

plot_output_path <- paste(plot_output_dir, "voronoi-vertex-comparisons-only.pdf", sep = "/")
ggsave(plot_output_path)

print(filter(tbl, MatchingPercentage < axis_cut))
