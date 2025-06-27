WITH target_stop AS (
  SELECT 
    d.ticker,
    d.window_end,
    MIN(CASE WHEN b.high > d.window_end_close + 5 * d.window_avg_atr THEN b.date_d END) AS target_date,
    MIN(CASE WHEN b.low < d.window_low THEN b.date_d END) AS stop_date
  FROM ml.dataset d
  JOIN ml.base_data b
    ON d.ticker = b.ticker
   AND b.date_d > d.window_end
   AND b.date_d <= d.window_end + INTERVAL '5 day'
   WHERE d.window_end BETWEEN '2023-01-01' AND '2023-01-31'
  GROUP BY d.ticker, d.window_end
)
SELECT *,
  CASE 
    WHEN target_date IS NOT NULL AND (stop_date IS NULL OR target_date <= stop_date) THEN 1
    ELSE 0
  END AS outcome
FROM target_stop
WHERE target_date IS NOT NULL;

