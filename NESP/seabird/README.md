# Seabird — Observations and Tracking

## Description
Seabird observation and tracking records aggregated from Australian monitoring programs. Covers species occurrence, movement, and spatial distribution across Australian marine environments.

## Dataset Details

| Property    | Value |
|-------------|-------|
| Bucket      | `data-uplift-public` |
| Key         | `stored/datauplift/seabird/seabird.parquet` |
| Partitioned | No |
| Format      | Parquet |

## Notebooks

| Notebook | Language | Description |
|----------|----------|-------------|
| `seabird.ipynb` | Python | Data exploration, H3 spatial aggregation, and mapping of seabird distribution |
| `seabird.Rmd`   | R       | Equivalent analysis using the `arrow`, `h3`, and `ggplot2` R packages |

## Authors
- Thomas Galindo (Python notebook)
- Denisse Fierro Arcos (R translation)
