

-- ===========================================================
-- BASE_DATA: формируем основный датасет
-- ===========================================================
WITH base_data AS (
    SELECT
        ticker,
        date_d,
        "open",
        high,
        low,
        close,
        vol,
        (high::NUMERIC + low) / 2 AS avg_price,
        (high::NUMERIC - low) AS atr,
        AVG(high::NUMERIC - low) OVER (
            PARTITION BY ticker
            ORDER BY date_d
            ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
        ) AS atr_14
    FROM research.market_data
),
___________________________________


--CREATE TABLE ml.dataset_all AS 
WITH window_aggregate AS (
    SELECT
        a.ticker,
        a.date_d AS window_end,
        MIN(a2.low) AS window_low,
        MAX(a2.high) AS window_high,
        COUNT(a2.*) AS window_length,
        AVG(a2.atr) AS window_avg_atr
    FROM ml.base_data a
    JOIN ml.base_data a2 
        ON a2.ticker = a.ticker
       AND a2.date_d BETWEEN a.date_d - INTERVAL '14 days' AND a.date_d
       GROUP BY a.ticker, a.date_d    
), window_values AS (
    SELECT DISTINCT
        a.ticker,
        a.date_d AS window_end,
        FIRST_VALUE(a2.close) OVER (
            PARTITION BY a.ticker, a.date_d
            ORDER BY a2.date_d
        ) AS window_start_close,
        LAST_VALUE(a2.close) OVER (
            PARTITION BY a.ticker, a.date_d
            ORDER BY a2.date_d
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS window_end_close
    FROM ml.base_data a
    JOIN ml.base_data a2
        ON a2.ticker = a.ticker
       AND a2.date_d BETWEEN a.date_d - INTERVAL '14 days' AND a.date_d
)
SELECT
    agg.*,
    vals.window_start_close,
    vals.window_end_close,
    (CASE
        WHEN vals.window_start_close = 0 THEN NULL
        ELSE (vals.window_end_close - vals.window_start_close) / vals.window_start_close
     END) AS trend_score
FROM window_aggregate agg
LEFT JOIN window_values vals
    ON vals.ticker = agg.ticker
   AND vals.window_end = agg.window_end;  


