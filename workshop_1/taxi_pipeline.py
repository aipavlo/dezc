import dlt
import requests

BASE_URL = "https://us-central1-dlthub-analytics.cloudfunctions.net/data_engineering_zoomcamp_api"

@dlt.resource(
    name="trips",
    write_disposition="replace",
    columns={
        "rate_code": {"data_type": "bigint"},
        "mta_tax": {"data_type": "double"},
    },
)
def trips():
    page = 1
    with requests.Session() as s:
        while True:
            r = s.get(BASE_URL, params={"page": page}, timeout=60)
            r.raise_for_status()
            rows = r.json()
            if not rows:
                break
            yield rows
            page += 1

def main():
    pipeline = dlt.pipeline(
        pipeline_name="taxi_pipeline",
        destination="duckdb",
        dataset_name="taxi",
    )
    load_info = pipeline.run(trips())
    print(load_info)

if __name__ == "__main__":
    main()