# NESP 5.9 Analysis Notebooks

## Companion Videos
Video walkthroughs accompanying these notebooks are available on the [IMOS Australia YouTube channel](https://www.youtube.com/@IMOS_AUS/playlists).

## Pre-requisites
Python package and environment manager. We highly recommend [uv](https://docs.astral.sh/uv/#installation).

## Usage
1. Navigate to the NESP directory of the repo

2. Create and activate the python environment

```bash
uv venv \
&& source .venv/bin/activate \
&& uv pip install .
```

3. Launch the jupyter server

```bash
jupyter notebook
```

## Notebooks

| Notebook | Dataset | Scope | Key Analyses |
| -------- | ------- | ----- | ------------ |
| [`amsa_2025.ipynb`](amsa_2025.ipynb) | AMSA Vessel Tracking | **2025 only** | Global H3 density map (res 8), Sydney Harbour deep-dive (res 12), fleet volume / unique vessels / tracking intensity, South-east Commonwealth Marine Region filter |
| [`dugong.ipynb`](dugong.ipynb) | Dugong Surveys | All years | Calf-to-adult demographic ratios, year-over-year temporal trends, monthly survey seasonality, Beaufort / turbidity survey conditions, population density maps (res 4 & 6), habitat distribution by marine region |
| [`seabird.ipynb`](seabird.ipynb) | Seabird Observations & Tracking | All years | Observation effort, organism quantity & species richness over time, IMCRA mesoscale water-type breakdown, H3 density mapping, dataset-level spatial extent, offshore wind-farm overlap analysis |
| [`seagrass.ipynb`](seagrass.ipynb) | Seagrass Surveys | All years | Observation effort, occurrence & richness by mesoscale water type, H3 density mapping, tropical waters regional filter, dataset-level mapping (Great Barrier Reef focus), multi-year trend site identification |

> **Note — AMSA year scope:** `amsa_2025.ipynb` is intentionally scoped to a single pre-selected year (`TARGET_YEAR = 2025`). To analyse a different year, update that variable and re-run the notebook top to bottom. The other three notebooks load all available years.

## NESP 5.9 Datasets

| Dataset name | Description | S3 URL |
| ------------ | ----------- | ------ |
| AMSA               | AMSA Vessel Tracking               | [link](s3://aodn-cloud-optimised/aggregated_amsa_nonqc.parquet/)            |
| Kelp               | Squidle+ Kelp Annotations          | [link](s3://aodn-cloud-optimised/aggregated_kelp_nonqc.parquet/)            |
| Seabird            | Seabird Observations and Tracking  | [link](s3://aodn-cloud-optimised/aggregated_seabird_nonqc.parquet/)         |
| Seagrass           | Seagrass Surveys                   | [link](s3://aodn-cloud-optimised/aggregated_seagrass_nonqc.parquet/)        |
| Dugong             | Dugong Surveys                     | [link](s3://aodn-cloud-optimised/aggregated_dugong_nonqc.parquet/)          |
| Diver Photoquadrat | Diver Photoquadrat Scores          | [link](s3://aodn-cloud-optimised/diver_photoquadrat_score_qc.parquet/)      |

### S3 Details
NESP 5.9 datasets are stored in the `aodn-cloud-optimised` S3 bucket (ap-southeast-2, public anonymous access) as hive-partitioned Parquet:

| Bucket                 | Key                                              | Partitioned |
| ---------------------- | ------------------------------------------------ | ----------- |
| `aodn-cloud-optimised` | `aggregated_amsa_nonqc.parquet/`                 | [x] hive    |
| `aodn-cloud-optimised` | `aggregated_kelp_nonqc.parquet/`                 | [x] hive    |
| `aodn-cloud-optimised` | `aggregated_seabird_nonqc.parquet/`              | [x] hive    |
| `aodn-cloud-optimised` | `aggregated_seagrass_nonqc.parquet/`             | [x] hive    |
| `aodn-cloud-optimised` | `aggregated_dugong_nonqc.parquet/`               | [x] hive    |
| `aodn-cloud-optimised` | `diver_photoquadrat_score_qc.parquet/`           | [x] hive    |
