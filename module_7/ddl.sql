DROP TABLE IF EXISTS processed_green_trips_5min;

CREATE TABLE processed_green_trips_5min (
    window_start TIMESTAMP,
    PULocationID INTEGER,
    num_trips BIGINT,
    PRIMARY KEY (window_start, PULocationID)
);

DROP TABLE IF EXISTS processed_green_trips_sessions;

CREATE TABLE processed_green_trips_sessions (
    session_start TIMESTAMP,
    session_end TIMESTAMP,
    pu_location_id INTEGER,
    do_location_id INTEGER,
    num_trips BIGINT,
    PRIMARY KEY (session_start, session_end, pu_location_id, do_location_id)
);

DROP TABLE IF EXISTS processed_green_trips_hourly_tips;

CREATE TABLE processed_green_trips_hourly_tips (
    window_start TIMESTAMP,
    total_tip_amount DOUBLE PRECISION,
    PRIMARY KEY (window_start)
);
