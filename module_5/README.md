Bruin pipeline structure: A pipeline is defined by pipeline.yml and a set of assets under pipeline/assets


Time range configuration: I use the time_interval in the pipeline (--start-date/--end-date) to control the processing window.


Run only Yellow taxis:
bruin run pipeline.yml --var 'taxi_types=["yellow"]' --start-date 2022-01-01 --end-date 2022-02-01


Run an asset and everything downstream:
bruin run pipeline/assets/ingestion/trips.py --downstream --start-date 2022-01-01 --end-date 2022-02-01


Not-null check syntax: not_null (pickup_datetime: not_null).


Lineage command:
bruin lineage path_to_file.sql --full


Full rebuild (truncate & reingest/reprocess):
bruin run pipeline/pipeline.yml --full-refresh --start-date 2022-01-01 --end-date 2022-02-01