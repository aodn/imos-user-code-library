# Intro

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

 ## NESP 5.9 Datasets

| Dataset name | Description | Metadata | S3 URL |
| ------------ | ----------- | -------- | ------ |
| AMSA         | AMSA Vessel Tracking               | -     | [link](s3://data-uplift-public/stored/datauplift/amsa/)                                   |
| Kelp         | Squidle+ Kelp Annotations          | -     | [link](s3://data-uplift-public/stored/datauplift/kelp/kelp.parquet)                       |
| NRMN         | NRMN Reef Life Surveys             | -     | [link](s3://data-uplift-public/stored/datauplift/nrmn/nrmn.parquet)    |
| Seabird      | Seabird Observations and Tracking  | -     | [link](s3://data-uplift-public/stored/datauplift/seabird/seabird.parquet)                 |
| Seagrass     | Seagrass Surveys                   | -     | [link](s3://data-uplift-public/stored/datauplift/seagrass/seagrass.parquet)               |
  
### S3 Details\n"
NESP 5.9 datasets are currently stored in S3 and are publicly available as per the following table:\n"

| Bucket               | Key                                                      | Partitioned |
| -------------------- | -------------------------------------------------------- | ----------- |
| `data-uplift-public` | `stored/datauplift/amsa/year=*/source=*/*.parquet`       | [x]         |
| `data-uplift-public` | `stored/datauplift/kelp/kelp.parquet`                    | [ ]         |
| `data-uplift-public` | `stored/datauplift/nrmn/nrmn.parquet` | [ ]         |\n",
| `data-uplift-public` | `stored/datauplift/seabird/seabird.parquet`              | [ ]         |
| `data-uplift-public` | `stored/datauplift/seagrass/seagrass.parquet`            | [ ]         |

