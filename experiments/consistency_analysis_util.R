library(dplyr)

# Read command line arguments.
args <- commandArgs(trailingOnly = TRUE)
output_dir <- args[1]

# Table about Voronoi vertices
cgal_voronoi_tbl <- read.csv("experiments/results/diagrams-cgal-comparisons.csv", sep = ",")

# Table about Delaunay edges
delaunay_tbl <- read.csv("experiments/results/triangulation-edge-comparisons.csv",
    sep = ","
)

delaunay_tbl <- filter(delaunay_tbl, Precision == "CGAL")

selected_columns <- c(
    "DiskRadius",
    "DiagramID",
    "PreciseCoveredByTechnique",
    "TechniqueCoveredByPrecise"
)
delaunay_tbl <- delaunay_tbl[selected_columns]

merged_tbl <- cgal_voronoi_tbl %>% right_join(delaunay_tbl,
    by = c("DiskRadius", "DiagramID")
)

total_rows <- nrow(merged_tbl)
cat("Total instances: ", total_rows, "\n")

disk_radii <- unique(merged_tbl$DiskRadius)
print(disk_radii)

matching_tbl <- data.frame(
    DiskRadius = numeric(),
    Instances = numeric(),
    PercentMatchingVertices = numeric(),
    PercentMatchingEdges = numeric(),
    PercentMatchingAll = numeric()
)

for (radius in disk_radii) {
    up_to_radius_tbl <- filter(merged_tbl, DiskRadius <= radius)

    up_to_instance_number <- nrow(up_to_radius_tbl)

    # Find the instances where the vertices matched
    up_to_matching_vertices <- nrow(filter(
        up_to_radius_tbl,
        MatchingPercentage == 1.0
    ))

    up_to_matching_edges <- nrow(filter(
        up_to_radius_tbl,
        PreciseCoveredByTechnique == 1.0
    ))

    up_to_matching_all <- nrow(filter(
        up_to_radius_tbl,
        VertexPercentage == 1.0 &
            MatchingPercentage == 1.0 &
            PreciseCoveredByTechnique == 1.0 &
            TechniqueCoveredByPrecise == 1.0
    ))

    cat(
        radius, ": ",
        up_to_instance_number, ", ",
        up_to_matching_vertices, ", ",
        up_to_matching_edges, ", ",
        up_to_matching_all, "\n"
    )

    matching_tbl <- rbind(
        matching_tbl,
        data.frame(
            DiskRadius = radius,
            Instances = up_to_instance_number,
            PercentMatchingVertices = up_to_matching_vertices / up_to_instance_number,
            PercentMatchingEdges = up_to_matching_edges / up_to_instance_number,
            PercentMatchingAll = up_to_matching_all / up_to_instance_number
        )
    )
}

output_path <- paste(output_dir,
    "consistancey-analsysis.csv",
    sep = "/"
)

write.csv(matching_tbl, output_path, row.names = FALSE)
