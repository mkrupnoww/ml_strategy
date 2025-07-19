

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
    
 -- часть кода скрыто
    
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


