WITH target_and_stop AS (
    SELECT
        d.ticker,
        d.window_end,
        d.window_start_close,
        d.window_end_close,
        d.window_low,
        d.window_avg_atr,
        d.trend_score,
        d.window_length,
        MIN(CASE 
                WHEN b.high > d.window_end_close + 4 * d.window_avg_atr THEN b.date_d 
            END) AS target_hit_date,
        MIN(CASE 
                WHEN b.low < d.window_low THEN b.date_d 
            END) AS stop_hit_date
    FROM ml.dataset d
    JOIN ml.base_data b
      ON b.ticker = d.ticker
     AND b.date_d > d.window_end
     AND b.date_d <= d.window_end + INTERVAL '14 days'
     --WHERE b.date_d BETWEEN '2024-12-01' AND '2024-12-20'
    GROUP BY d.ticker, d.window_end, d.window_start_close, d.window_end_close,
             d.window_low, d.window_avg_atr, d.trend_score, d.window_length
)
SELECT
    ticker,
    window_end,
    window_start_close,
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


