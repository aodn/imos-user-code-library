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