WITH ibm_data_tab AS (
    SELECT
        ticker,
        date_d, 
        open,
        high,
        low,
        close,
        vol,
        (high::NUMERIC + low) / 2 AS avg_price,
        (high::NUMERIC - low) AS atr
    FROM ml.market_data
    WHERE ticker = 'IBM' 
    ORDER BY ticker, date_d 
),
ma_atr14_tab AS (
    SELECT
        ticker,
        date_d, 
        open,
        high,
        low,
        close,
        vol,
        avg_price,
        atr,
        AVG(atr) OVER (
            PARTITION BY ticker 
            ORDER BY date_d ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
        ) AS atr_14
    FROM ibm_data_tab
),
filtered_rows AS (
    SELECT
        m.*,
        LAG(avg_price) OVER (PARTITION BY ticker ORDER BY date_d) AS prev_avg_price
    FROM ma_atr14_tab m
),
consecutive_flagged AS (
    SELECT
        *,
        CASE 
            WHEN prev_avg_price IS NULL THEN 1
            WHEN ABS(avg_price - prev_avg_price) <= 0.3 * atr_14 THEN 1 
            ELSE 0
        END AS is_in_range
    FROM filtered_rows
),
grouped_windows AS (
    SELECT
        *,
        SUM(CASE WHEN is_in_range = 0 THEN 1 ELSE 0 END) 
            OVER (PARTITION BY ticker ORDER BY date_d) AS window_id
    FROM consecutive_flagged
),
window_length_tab AS (
    SELECT
        ticker,
        window_id,
        MIN(date_d) AS window_start,
        MAX(date_d) AS window_end,
        COUNT(*) AS window_length,
        SUM(atr_14) AS sum_atr14
    FROM grouped_windows
    GROUP BY ticker, window_id
),
avg_atr14_tab AS (
    SELECT
        ticker,
        window_id,
        window_start,
        window_end,
        window_length,
        (sum_atr14 / window_length) AS avg_atr14
    FROM window_length_tab
)
SELECT *
FROM avg_atr14_tab a
WHERE window_length > 5 
  AND NOT EXISTS (
      SELECT 1
      FROM grouped_windows g
      WHERE g.ticker = a.ticker
        AND g.window_id = a.window_id
        AND g.atr > 0.8 * a.avg_atr14
  )
ORDER BY ticker, window_start;

