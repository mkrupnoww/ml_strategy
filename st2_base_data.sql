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
    ORDER BY ticker, date_d 
