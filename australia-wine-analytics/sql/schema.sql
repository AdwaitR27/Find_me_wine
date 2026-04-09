-- ============================================================
-- Australia Wine Analytics — Database Schema
-- ============================================================

-- ── Schemas ──────────────────────────────────────────────────
CREATE SCHEMA IF NOT EXISTS dw;
CREATE SCHEMA IF NOT EXISTS staging;

-- ============================================================
-- DIMENSION TABLES
-- ============================================================

-- ── dim_region ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS dw.dim_region (
    region_id       SERIAL PRIMARY KEY,
    state           VARCHAR(100)    NOT NULL,
    region_name     VARCHAR(100)    NOT NULL UNIQUE,
    climate_type    VARCHAR(100),
    latitude        NUMERIC(8, 5),
    longitude       NUMERIC(8, 5),
    created_at      TIMESTAMP       DEFAULT NOW()
);

-- ── dim_variety ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS dw.dim_variety (
    variety_id      SERIAL PRIMARY KEY,
    variety_name    VARCHAR(100)    NOT NULL UNIQUE,
    color           VARCHAR(10)     CHECK (color IN ('red', 'white', 'rose', 'sparkling')),
    style_tags      TEXT,
    created_at      TIMESTAMP       DEFAULT NOW()
);

-- ============================================================
-- FACT TABLE
-- ============================================================

-- ── fact_region_variety_profile ──────────────────────────────
CREATE TABLE IF NOT EXISTS dw.fact_region_variety_profile (
    profile_id          SERIAL PRIMARY KEY,
    region_id           INT             NOT NULL REFERENCES dw.dim_region(region_id),
    variety_id          INT             NOT NULL REFERENCES dw.dim_variety(variety_id),
    suitability_score   NUMERIC(5, 2)   CHECK (suitability_score BETWEEN 0 AND 100),
    reason              TEXT,
    source              VARCHAR(200),
    load_ts             TIMESTAMP       DEFAULT NOW(),
    UNIQUE (region_id, variety_id)
);

-- ============================================================
-- STAGING TABLE (raw CSV data lands here before transform)
-- ============================================================

CREATE TABLE IF NOT EXISTS staging.raw_wine_data (
    state               VARCHAR(100),
    region_name         VARCHAR(100),
    climate_type        VARCHAR(100),
    variety_name        VARCHAR(100),
    color               VARCHAR(20),
    style_tags          TEXT,
    suitability_score   NUMERIC(5, 2),
    reason              TEXT,
    source              VARCHAR(200),
    load_ts             TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- INDEXES
-- ============================================================

-- Region indexes
CREATE INDEX IF NOT EXISTS idx_dim_region_state
    ON dw.dim_region(state);

CREATE INDEX IF NOT EXISTS idx_dim_region_climate
    ON dw.dim_region(climate_type);

-- Variety indexes
CREATE INDEX IF NOT EXISTS idx_dim_variety_color
    ON dw.dim_variety(color);

-- Fact indexes
CREATE INDEX IF NOT EXISTS idx_fact_region
    ON dw.fact_region_variety_profile(region_id);

CREATE INDEX IF NOT EXISTS idx_fact_variety
    ON dw.fact_region_variety_profile(variety_id);

CREATE INDEX IF NOT EXISTS idx_fact_score
    ON dw.fact_region_variety_profile(suitability_score DESC);

-- ============================================================
-- END OF SCHEMA
-- ============================================================