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
    
      -- часть кода скрыто
    
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
WHERE window_length > -- 
  AND NOT EXISTS (
      SELECT 1
      FROM grouped_windows g
      WHERE g.ticker = a.ticker
        AND g.window_id = a.window_id
        AND g.atr > -- * a.avg_atr14
  )
ORDER BY ticker, window_start;

