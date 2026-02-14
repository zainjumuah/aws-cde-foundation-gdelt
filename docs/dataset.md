# Dataset

This repository uses the following dataset as the main source for the foundation pipeline.

## Dataset Identity
- Name: `GDELT 2.1 Events`
- Provider / Publisher: `GDELT Project`
- Official source: `http://data.gdeltproject.org/events/index.html`

## What We Use in Week 1
To keep Week 1 focused on SQL and ingestion fundamentals, we start with a single-day slice.

- Slice type: daily export
- Slice date: `2024-01-01`
- Local raw artifact (zip): `data/raw/source/20240101.export.CSV.zip`
- Local raw artifact (unzipped): `data/raw/unzipped/20240101.export.CSV`

## File Structure Expectation in This Repo
- Downloaded archives live in `data/raw/source/`.
- Unzipped flat files live in `data/raw/unzipped/`.
- SQL loading for Week 1 targets the `raw` schema in Postgres.

Minimal setup for local files:

```bash
mkdir -p data/raw/source data/raw/unzipped
curl -L "http://data.gdeltproject.org/events/20240101.export.CSV.zip" -o data/raw/source/20240101.export.CSV.zip
unzip -o data/raw/source/20240101.export.CSV.zip -d data/raw/unzipped
```

## File Format Notes (Important for Loading)
- Compression: `zip`
- Delimiter: `tab` (the file is named CSV but is tab-delimited)
- Header row: `no`
- Encoding: `UTF-8` (verify if you observe character issues)
- Null representation: empty string

Any format detail that impacts `COPY` or `\copy` should be updated here first.

## Minimal Column Notes
- Expected column count: `58` (validate on first load)
- Key fields for early SQL: `GLOBALEVENTID`, `SQLDATE`, `EventCode`

## How We Use It (Foundation Context)
Week 1:
- Load raw slice into Postgres (`raw` schema)
- Run sanity checks (row counts, null density, basic distributions)
- Produce SQL query set answering basic analytical questions

Later (not Week 1):
- Expand slices and partitions
- Add typed staging layer
- Transform to Parquet
- PySpark transformations (local)
