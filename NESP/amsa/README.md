# AMSA — Vessel Tracking

## Description
AIS (Automatic Identification System) vessel tracking records collected by the Australian Maritime Safety Authority (AMSA), covering Australian waters from 2012 to 2025.

## Dataset Details

| Property    | Value |
|-------------|-------|
| Bucket      | `data-uplift-public` |
| Key         | `stored/datauplift/amsa/year=*/source=*/*.parquet` |
| Partitioned | Yes (by year and source) |
| Format      | Parquet |

## Notebooks

| Notebook | Language | Description |
|----------|----------|-------------|
| `amsa.ipynb` | Python | Vessel density mapping with H3 aggregation, longitudinal data health analysis, and regional deep-dives (e.g. Sydney Harbour) |
| `amsa.Rmd`   | R       | Equivalent analysis using the `arrow`, `h3`, and `ggplot2` R packages |

## Dataset-Specific Notes
- The full dataset exceeds typical RAM limits. The Python notebook uses a Polars `LazyFrame` and streaming aggregation to avoid loading all data into memory.
- Vessel density follows a power-law distribution. The Python notebook applies a log₁₀ transform before coloring to make both busy ports and open-ocean routes visible.
- Records include an `australianMarineRegionsTags` column for pre-computed spatial region labels.
- The AMSA dataset is already indexed at H3 Resolution 8 (`h3Index` column). For finer-grained regional analysis, re-index to Resolution 9–12.
