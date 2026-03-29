# NESP 5.9 — User Code Library

This directory contains notebooks and utilities for loading, exploring, and analysing the **NESP 5.9 marine datasets** stored in AWS S3.

Each dataset has its own subdirectory with a dedicated README, a Python notebook (`.ipynb`), and an R notebook (`.Rmd`).

---

## Datasets

| Dataset | Description | Folder | S3 Key |
|---------|-------------|--------|--------|
| AMSA | AIS Vessel Tracking (2012–2025) | [`amsa/`](amsa/) | `stored/datauplift/amsa/year=*/source=*/*.parquet` |
| Kelp | Squidle+ Kelp Annotations | [`kelp/`](kelp/) | `stored/datauplift/kelp/kelp.parquet` |
| NRMN | NRMN Reef Life Surveys | [`nrmn/`](nrmn/) | `stored/datauplift/nrmn/nrmn.parquet` |
| Seabird | Seabird Observations and Tracking | [`seabird/`](seabird/) | `stored/datauplift/seabird/seabird.parquet` |
| Seagrass | Seagrass Surveys | [`seagrass/`](seagrass/) | `stored/datauplift/seagrass/seagrass.parquet` |
| Dugongs | Dugong Sightings and Distribution | [`dugongs/`](dugongs/) | `stored/datauplift/dugongs/dugongs.parquet` |

All datasets are publicly accessible in the `data-uplift-public` S3 bucket (region: `ap-southeast-2`).

---

## Repository Structure

```
NESP/
├── nesp/
│   ├── __init__.py
│   └── util.py              # Shared utilities (H3 mapping, color scales, schema display)
├── h3.md                    # H3 hexagonal indexing reference
├── pyproject.toml           # Python project and dependency definition
├── requirements.txt         # Pinned Python dependencies
├── uv.lock                  # uv lockfile
├── OffshoreRenewable_Energy_Infrastructure_Regions.zip  # Shapefile used in spatial analyses
│
├── amsa/
│   ├── README.md
│   ├── amsa.ipynb
│   └── amsa.Rmd
├── kelp/
│   └── README.md
├── nrmn/
│   └── README.md
├── seabird/
│   ├── README.md
│   ├── seabird.ipynb
│   └── seabird.Rmd
├── seagrass/
│   ├── README.md
│   ├── seagrass.ipynb
│   └── seagrass.Rmd
└── dugongs/
    └── README.md
```

---

## Python Environment Setup

Python 3.12 or later is required. We recommend [uv](https://docs.astral.sh/uv/) for environment and package management.

### With `uv` (recommended)

```bash
# From the NESP/ directory:
uv venv && source .venv/bin/activate && uv pip install .
```

### With `pip`

```bash
python -m venv .venv && source .venv/bin/activate && pip install .
```

### Running notebooks

```bash
jupyter notebook
```

Or open any `.ipynb` in your IDE and select the `.venv` as the kernel.

### Key Python packages

| Package | Purpose |
|---------|---------|
| `pyarrow` | Parquet I/O and S3 dataset connection |
| `polars` | DataFrame and LazyFrame computation |
| `polars-h3` | H3 spatial indexing within Polars |
| `polars-st` | Spatial (geometry) operations in Polars |
| `pydeck` | GPU-accelerated H3 hexagon map rendering |
| `h3` | H3 indexing for polygon-to-cell conversion |
| `geopandas` | Shapefile loading and CRS handling |
| `matplotlib` / `seaborn` | Statistical plotting |
| `rich` | Schema and table display in notebooks |

> **Note:** Shared utilities live in the `nesp` package (`nesp/util.py`) and are installed when you run `uv pip install .` or `pip install .`. Notebooks import them as `from nesp import util` — no path manipulation needed.

---

## R Environment Setup

R 4.x or later is required. Install the following packages from CRAN and GitHub before running any `.Rmd` notebook.

### CRAN packages

```r
install.packages(c(
  "arrow",      # S3 dataset connection and Parquet I/O
  "sf",         # Spatial features
  "dplyr",      # Data manipulation
  "tidyr",      # Data reshaping
  "stringr",    # String operations
  "lubridate",  # Date/time handling
  "ggplot2",    # Plotting
  "leaflet"     # Interactive maps
))
```

### H3 for R (from GitHub)

The `h3-r` package is recommended as it bundles the underlying C library automatically:

```r
# install.packages("remotes")
remotes::install_github("crazycapivara/h3-r")
```

> See the [h3-r documentation](https://crazycapivara.github.io/h3-r/articles/h3.html) for usage examples.

### Running notebooks

Open any `.Rmd` file in RStudio and click **Knit**, or run chunks interactively.

---

## H3 Spatial Indexing

All datasets are spatially aggregated using the [Uber H3](https://h3geo.org/) hexagonal grid system. See [`h3.md`](h3.md) for an overview of H3 concepts, resolution levels, and why hexagons are used over traditional grids.
