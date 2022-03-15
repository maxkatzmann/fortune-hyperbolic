library(tidyr)
library(ggplot2)
library(dplyr)
library(patchwork)
library(tikzDevice)
library(stringr)
library(formattable)

theme_set(theme_bw())

# Read command line arguments.
args <- commandArgs(trailingOnly = TRUE)
plot_output_dir <- args[1]

latex_percent <- function(x) {
    x <- plyr::round_any(x, scales:::precision(x) / 100)
    stringr::str_c(comma(x * 100), "\\%")
}

#### PART I: Comparing Voronoi Vertices

## read the table
precision_voronoi_tbl <- read.csv("experiments/results/diagrams-groundtruth-comparison.csv", sep = ",")
cgal_voronoi_tbl <- read.csv("experiments/results/diagrams-cgal-comparison.csv", sep = ",")
precision_column <- rep("CGAL", nrow(cgal_voronoi_tbl))
cgal_voronoi_tbl$Precision <- factor(precision_column)

selected_columns <- c("DiskRadius", "DiagramID", "Precision", "MatchingPercentage")
voronoi_tbl <- precision_voronoi_tbl[selected_columns]
cgal_addendum <- cgal_voronoi_tbl[selected_columns]
voronoi_tbl <- rbind(voronoi_tbl, cgal_addendum)

## Round disk radii
specify_decimal <- function(x, k) trimws(format(round(x, k), nsmall = k))
voronoi_tbl <- voronoi_tbl %>% mutate_at(
    vars(DiskRadius),
    ~ specify_decimal(., 3)
)

voronoi_tbl$Precision <- as.factor(voronoi_tbl$Precision)

axis_cut <- 0.925

colors <- c(
    "#EA4840",
    "#2C5396",
    "#009E73",
    "#00B887",
    "#00CC96",
    "#00E0A5",
    "#00F5B4",
    "#0AFFBE"
)

light_colors <- c(
    "#FBDADA",
    "#DFE8F6",
    "#D6FFF4",
    "#D6FFF4",
    "#D6FFF4",
    "#D6FFF4",
    "#D6FFF4",
    "#D6FFF4"
)


precision_levels <- c("CGAL", "16", "32", "48", "64", "80", "96", "112")
precision_labels <- c(
    "CGAL (Converted)",
    "Native (Double)",
    "Native (32)",
    "Native (48)",
    "Native (64)",
    "Native (80)",
    "Native (96)",
    "Native (112)"
)

# Create tex file that will contain the plot.
tex_output_path <- paste(plot_output_dir, "merged-comparisons.tex", sep = "/")
tikz(file = tex_output_path, width = 4.9, height = 3.0)

voronoi_plot <- ggplot(
    voronoi_tbl,
    aes(
        x = reorder(
            DiskRadius,
            sort(as.numeric(DiskRadius))
        ),
        y = MatchingPercentage
    )
) +
    geom_boxplot(aes(
        fill = factor(Precision,
            levels = precision_levels
        ),
        color = factor(Precision,
            levels = precision_levels
        )
    )) +
    scale_fill_manual(
        values = light_colors,
        guide = "none"
    ) +
    scale_color_manual(
        values = colors,
        labels = precision_labels
    ) +
    labs(
        x = "Disk Radius",
        y = "Matching Voronoi Vetices",
        color = "Technique"
    ) +
    theme(
        axis.text.x = element_text(
            angle = 90,
            vjust = 0.5,
            hjust = 1
        ),
        legend.position = c(
            0.16,
            0.225
        )
    ) +
    scale_y_continuous(
        labels = latex_percent,
        limits = c(axis_cut, 1.0)
    )

#### PART II: Comparing Delaunay Edges

delaunay_tbl <- read.csv("experiments/results/triangulation-edge-comparison.csv",
    sep = ","
)

delaunay_tbl <- delaunay_tbl %>% mutate_at(
    vars(DiskRadius),
    ~ specify_decimal(., 3)
)

delaunay_tbl$Precision <- as.factor(delaunay_tbl$Precision)

delaunay_tbl <- filter(delaunay_tbl, Precision != "128")

delaunay_plot <- ggplot(
    delaunay_tbl,
    aes(
        x = reorder(
            DiskRadius,
            sort(as.numeric(DiskRadius))
        ),
        y = PreciseCoveredByTechnique
    )
) +
    geom_boxplot(aes(
        fill = factor(Precision,
            levels = precision_levels
        ),
        color = factor(Precision,
            levels = precision_levels
        )
    )) +
    scale_fill_manual(
        values = light_colors,
        guide = "none"
    ) +
    scale_color_manual(
        values = colors,
        labels = precision_labels
    ) +
    labs(
        x = "Disk Radius",
        y = "Matching Delaunay Edges",
        color = "Technique"
    ) +
    theme(
        axis.text.x = element_text(
            angle = 90,
            vjust = 0.5,
            hjust = 1
        ),
        legend.position = c(
            0.85,
            0.225
        )
    ) +
    scale_y_continuous(
        labels = latex_percent,
        limits = c(axis_cut, 1.0)
    )


combined <- voronoi_plot + delaunay_plot & theme(legend.position = "bottom")
combined + plot_layout(guides = "collect")

height <- 5
aspect_ratio <- 2

plot_output_path <- paste(plot_output_dir, "merged-comparisons.pdf", sep = "/")

ggsave(plot_output_path,
    height = height,
    width = height * aspect_ratio
)

# This line is only necessary if you want to preview the plot right after compiling
print(combined)
# Necessary to close or the tikxDevice .tex file will not be written
dev.off()

print("Voronoi Discarded Values")
print(filter(voronoi_tbl, MatchingPercentage < axis_cut))

print("Delaunay Discarded Values")
print(filter(delaunay_tbl, PreciseCoveredByTechnique < axis_cut))
