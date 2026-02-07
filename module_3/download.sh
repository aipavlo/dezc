
#!/usr/bin/bash

BASE_URL="https://d37ci6vzurychx.cloudfront.net/trip-data"


for month in $(seq -w 1 12); do
  file="yellow_tripdata_2024-${month}.parquet"
  echo "Downloading $file"
  curl -L --fail -o "data/$file" "$BASE_URL/$file"
done

echo "Done"