library(tidyr)
library(ggplot2)
library(dplyr)
library(patchwork)
library(tikzDevice)
library(stringr)
library(formattable)
library(ggpubr)
library(scales)

theme_set(theme_bw())

# Read command line arguments.
args <- commandArgs(trailingOnly = TRUE)
plot_output_dir <- args[1]

latex_percent <- function(x) {
    x <- plyr::round_any(x, scales:::precision(x) / 100)
    stringr::str_c(format(x * 100), "\\%")
}

ks <- function(x) {
    number_format(
        accuracy = 1,
        scale = 1 / 1000,
        suffix = "k",
    )(digits(x, 0))
}

#### PART I: Comparing Voronoi Vertices

## read the table
precision_voronoi_tbl <- read.csv("experiments/results/diagrams-groundtruth-comparisons.csv", sep = ",")
cgal_voronoi_tbl <- read.csv("experiments/results/diagrams-cgal-comparisons.csv", sep = ",")
precision_column <- rep("CGAL", nrow(cgal_voronoi_tbl))
cgal_voronoi_tbl$Precision <- factor(precision_column)

selected_columns <- c("DiskRadius", "DiagramID", "Precision", "MatchingPercentage", "NonMatchingAbsolute")
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

voronoi_tbl <- filter(voronoi_tbl, Precision == "16" | Precision == "CGAL" | Precision == "64")

axis_cut <- 0.925

colors <- c(
    "#EA4840",
    "#2C5396",
    "#009E73"
)

light_colors <- c(
    "#FBDADA",
    "#DFE8F6",
    "#D6FFF4"
)


precision_levels <- c("CGAL", "16", "64")
precision_labels <- c(
    "CGAL (Converted)",
    "Native (Double)",
    "Native (64)"
)

width <- 5.3
height <- 2.7


voronoi_tex_output_path <- paste(plot_output_dir,
    "voronoi-vertex-comparisons.tex",
    sep = "/"
)

tikz(file = voronoi_tex_output_path, width = width, height = height)

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
    ),
    outlier.shape = 1,
    outlier.size = 0.75,
    ) +
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
        y = "Matching Voronoi Vertices",
        color = "Technique"
    ) +
    theme(
        legend.position = c(0.175, 0.35),
        legend.key.height = unit(0.4, "cm"),
        legend.key.width = unit(0.25, "cm"),
        legend.title = element_blank(),
        legend.text = element_text(size = 7),
        axis.text = element_text(color = "black"),
        axis.text.x = element_text(
            size = 7,
            color = "black",
            angle = 90,
            vjust = 0.5,
            hjust = 1
        ),
        axis.text.y = element_text(size = 6, color = "black"),
        axis.title.y = element_text(margin = margin(t = 0.0, r = 0.0, b = 0.0, l = 0.0)),
        axis.title = element_text(size = 9),
        legend.margin = margin(5, 0, 0, 0),
    ) +
    scale_y_continuous(
        labels = latex_percent,
        limits = c(axis_cut, 1.0)
    )

voronoi_plot_output_path <- paste(plot_output_dir,
    "voronoi-vertex-comparisons.pdf",
    sep = "/"
)

ggsave(voronoi_plot_output_path,
    height = height,
    width = width
)

# This line is only necessary if you want to preview the plot right after compiling
print(voronoi_plot)
# Necessary to close or the tikxDevice .tex file will not be written
dev.off()


#### PART I A: Comparting Voronoi Vertices Absolute

breaks <- c(0, 10, 100, 1000, 10000, 100000)
labels <- c("0", "10", "100", "1k", "10k", "100k")
limits <- c(0, 100005)

absolute_axis_cut <- 10000
absolute_voronoi_plot <- ggplot(
    voronoi_tbl,
    aes(
        x = reorder(
            DiskRadius,
            sort(as.numeric(DiskRadius))
        ),
        y = NonMatchingAbsolute
    )
) +
    geom_boxplot(aes(
        fill = factor(Precision,
            levels = precision_levels
        ),
        color = factor(Precision,
            levels = precision_levels
        )
    ),
    outlier.shape = 1,
    outlier.size = 0.75,
    ) +
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
        y = "Voronoi Vertex Mismatches",
        color = "Technique"
    ) +
    theme(
        legend.position = c(0.175, 0.35),
        legend.key.height = unit(0.4, "cm"),
        legend.key.width = unit(0.25, "cm"),
        legend.title = element_blank(),
        legend.text = element_text(size = 7),
        axis.text = element_text(color = "black"),
        axis.text.x = element_text(
            size = 7,
            color = "black",
            angle = 90,
            vjust = 0.5,
            hjust = 1
        ),
        axis.text.y = element_text(size = 6, color = "black"),
        axis.title.y = element_text(margin = margin(t = 0.0, r = 0.0, b = 0.0, l = 0.0)),
        axis.title = element_text(size = 9),
        legend.margin = margin(5, 0, 0, 0),
    ) +
    scale_y_continuous(
        trans = scales::pseudo_log_trans(base = 10),
        breaks = breaks,
        labels = labels,
        limits = limits
    )

absolute_voronoi_plot_output_path <- paste(plot_output_dir,
    "voronoi-vertex-comparisons-absolute.pdf",
    sep = "/"
)

ggsave(absolute_voronoi_plot_output_path,
    height = height,
    width = width
)

## print(filter(voronoi_tbl, NonMatchingAbsolute > absolute_axis_cut))


#### PART II: Comparing Delaunay Edges

delaunay_tbl <- read.csv("experiments/results/triangulation-edge-comparisons.csv",
    sep = ","
)

delaunay_tbl <- delaunay_tbl %>% mutate_at(
    vars(DiskRadius),
    ~ specify_decimal(., 3)
)

delaunay_tbl$Precision <- as.factor(delaunay_tbl$Precision)

delaunay_tbl <- filter(delaunay_tbl, Precision == "16" | Precision == "CGAL" | Precision == "64")


# Create tex file that will contain the plot.
delaunay_tex_output_path <- paste(plot_output_dir,
    "delaunay-edge-comparisons.tex",
    sep = "/"
)
tikz(file = delaunay_tex_output_path, width = width, height = height)

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
    ),
    outlier.shape = 1,
    outlier.size = 0.75
    ) +
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
        legend.position = c(0.175, 0.35),
        legend.key.height = unit(0.4, "cm"),
        legend.key.width = unit(0.25, "cm"),
        legend.title = element_blank(),
        legend.text = element_text(size = 7),
        axis.text = element_text(color = "black"),
        axis.text.x = element_text(
            size = 7,
            color = "black",
            angle = 90,
            vjust = 0.5,
            hjust = 1
        ),
        axis.text.y = element_text(size = 6, color = "black"),
        axis.title.y = element_text(margin = margin(t = 0.0, r = 0.0, b = 0.0, l = 0.0)),
        axis.title = element_text(size = 9),
    ) +
    scale_y_continuous(
        labels = latex_percent,
        limits = c(axis_cut, 1.0)
    )


delaunay_plot_output_path <- paste(plot_output_dir,
    "delaunay-edge-comparisons.pdf",
    sep = "/"
)

ggsave(delaunay_plot_output_path,
    height = height,
    width = width
)

# This line is only necessary if you want to preview the plot right after compiling
print(delaunay_plot)
# Necessary to close or the tikxDevice .tex file will not be written
dev.off()

#### Part II A: Delaunay Absolute

absolute_delaunay_plot <- ggplot(
    delaunay_tbl,
    aes(
        x = reorder(
            DiskRadius,
            sort(as.numeric(DiskRadius))
        ),
        y = AbsoluteMissingInTechnique
    )
) +
    geom_boxplot(aes(
        fill = factor(Precision,
            levels = precision_levels
        ),
        color = factor(Precision,
            levels = precision_levels
        )
    ),
    outlier.shape = 1,
    outlier.size = 0.75
    ) +
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
        y = "Delaunay Edge Mismatches",
        color = "Technique"
    ) +
    theme(
        legend.position = c(0.175, 0.35),
        legend.key.height = unit(0.4, "cm"),
        legend.key.width = unit(0.25, "cm"),
        legend.title = element_blank(),
        legend.text = element_text(size = 7),
        axis.text = element_text(color = "black"),
        axis.text.x = element_text(
            size = 7,
            color = "black",
            angle = 90,
            vjust = 0.5,
            hjust = 1
        ),
        axis.text.y = element_text(size = 6, color = "black"),
        axis.title.y = element_text(margin = margin(t = 0.0, r = 0.0, b = 0.0, l = 0.0)),
        axis.title = element_text(size = 9),
    ) +
    scale_y_continuous(
        trans = scales::pseudo_log_trans(base = 10),
        breaks = breaks,
        labels = labels,
        limits = limits
    )


absolute_delaunay_plot_output_path <- paste(plot_output_dir,
    "delaunay-edge-comparisons-absolute.pdf",
    sep = "/"
)

ggsave(absolute_delaunay_plot_output_path,
    height = height,
    width = width
)


#### Part III: Merge

merged_tex_output_path <- paste(plot_output_dir,
    "merged-comparisons.tex",
    sep = "/"
)
tikz(file = merged_tex_output_path, width = width, height = height)

merged_plot <- ggarrange(voronoi_plot, delaunay_plot, ncol = 2, common.legend = TRUE)

merged_plot_output_path <- paste(plot_output_dir,
    "merged-comparisons.pdf",
    sep = "/"
)

ggsave(merged_plot_output_path,
    height = height,
    width = width
)


# This line is only necessary if you want to preview the plot right after compiling
print(merged_plot)
# Necessary to close or the tikxDevice .tex file will not be written
dev.off()


print("Voronoi Discarded Values")
print(filter(voronoi_tbl, MatchingPercentage < axis_cut))

print("Delaunay Discarded Values")
print(filter(delaunay_tbl, PreciseCoveredByTechnique < axis_cut))


#### Part III A: Merge Absolute

merged_absolute_tex_output_path <- paste(plot_output_dir,
    "merged-absolute-comparisons.tex",
    sep = "/"
)
tikz(file = merged_absolute_tex_output_path, width = width, height = height)

merged_absolute_plot <- ggarrange(absolute_voronoi_plot,
    absolute_delaunay_plot,
    ncol = 2,
    common.legend = TRUE
)

merged_absolute_plot_output_path <- paste(plot_output_dir,
    "merged-absolute-comparisons.pdf",
    sep = "/"
)

ggsave(merged_absolute_plot_output_path,
    height = height,
    width = width
)

# This line is only necessary if you want to preview the plot right after compiling
print(merged_absolute_plot)
# Necessary to close or the tikxDevice .tex file will not be written
dev.off()
