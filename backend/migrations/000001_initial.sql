CREATE TABLE healthcheck_records (
    healthcheck_record_id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status_text TEXT NOT NULL
);