WITH target_and_stop AS (
    SELECT
        d.ticker,
        d.window_end,
        d.window_start_close,
        d.window_end_close,
    
   -- часть кода скрыто
    
    window_end_close,
    window_low,
    window_avg_atr,
    trend_score,
    window_length,
    CASE
        WHEN target_hit_date IS NOT NULL
            AND (stop_hit_date IS NULL OR target_hit_date <= stop_hit_date) THEN 1
        ELSE 0
    END AS outcome
FROM target_and_stop
WHERE window_length > 3
  AND window_length < 14;


