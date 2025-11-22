# Minimal test without renv
suppressPackageStartupMessages({
  library(tibble)
  library(dplyr)
  library(glue)
})

source("datasets.R")

cat("Successfully loaded datasets.R\n")
cat("Number of datasets:", nrow(datasets), "\n")

# Test filtering
ice_current <- get_datasets("ICE", "current")
cat("ICE current datasets:", nrow(ice_current), "\n")

# Test prepare_for_display (basic structure test)
cat("Testing prepare_for_display...\n")
result <- ice_current %>% head(1) %>% prepare_for_display()
cat("Columns:", paste(names(result), collapse=", "), "\n")
cat("SUCCESS!\n")
