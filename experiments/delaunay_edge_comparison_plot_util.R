library(tidyr)
library(ggplot2)
library(dplyr)
theme_set(theme_bw())

# Read command line arguments.
args <- commandArgs(trailingOnly = TRUE)
plot_output_dir <- args[1]


## read the table
tbl <- read.csv("experiments/results/triangulation-edge-comparison.csv",
    sep = ","
)
str(tbl)

## Round disk radii
specify_decimal <- function(x, k) trimws(format(round(x, k), nsmall = k))
tbl <- tbl %>% mutate_at(vars(DiskRadius), ~ specify_decimal(., 3))

tbl$Precision <- as.factor(tbl$Precision)

tbl <- filter(tbl, Precision != "128")

axis_cut <- 0.925

precision_levels <- c("CGAL", "16", "32", "48", "64", "80", "96", "112")
ggplot(tbl, aes(
    x = reorder(DiskRadius, sort(as.numeric(DiskRadius))),
    y = PreciseCoveredByTechnique
)) +
    geom_boxplot(aes(
        fill = factor(Precision, levels = precision_levels),
        color = factor(Precision, levels = precision_levels)
    )) +
    scale_fill_hue(c = 30, l = 100, guide = "none") +
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
    labs(
        x = "Disk Radius",
        y = "Matching Delaunay Edges",
        color = "Technique"
    ) +
    theme(
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        legend.position = c(0.85, 0.225)
    ) +
    scale_y_continuous(labels = scales::percent, limits = c(axis_cut, 1.0))

plot_output_path <- paste(plot_output_dir, "delaunay-edge-comparisons.pdf", sep = "/")
ggsave(plot_output_path)

print(filter(tbl, PreciseCoveredByTechnique < axis_cut))
