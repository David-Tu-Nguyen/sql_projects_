USE mavenfuzzyfactory;
-- PART 1: Analyzing Traffic Sources
-- I. Analyzing Traffic Sources 
SELECT 
	utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS number_of_sessions
FROM website_sessions
WHERE created_At < '2012-04-12'
GROUP BY 
	utm_source,
    utm_campaign,
    http_referer
ORDER BY number_of_sessions DESC;

-- II. Traffic Source Conversion Rates  (CVR)

SELECT 
	COUNT(DISTINCT w.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT w.website_session_id) AS session_to_order_conv_rt
FROM website_sessions w
LEFT JOIN orders o
	ON o.website_session_id = w.website_session_id
WHERE w.created_At < '2012-04-14'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
    
-- III. Traffic Source Trending
SELECT
    WEEK(created_at) AS wk,
    YEAR(created_at) AS yr,
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_At < '2012-05-12'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	YEAR(created_at), WEEK(created_at)
    
-- IV. Bid Optimization for Paid Traffic

SELECT 
	w.device_type, 
    COUNT(DISTINCT w.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT w.website_session_id) AS session_to_order_conv_rt
FROM website_sessions w
LEFT JOIN orders o 
	ON o.website_session_id = w.website_session_id
WHERE w.created_at < '2012-05-11'
	AND w.utm_source = 'gsearch'
    AND w.utm_campaign = 'nonbrand'
GROUP BY w.device_type

-- V.Trending w/ Granular Segments

SELECT 
	YEAR(created_at) AS yr, 
    WEEK(created_at) AS wk, 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS desktop_sessions, 
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions
    -- COUNT(DISTINCT website_session_id) AS total_sessions
FROM website_sessions w
WHERE w.created_at < '2012-06-09'
	AND w.created_at > '2012-04-15'
	AND w.utm_source = 'gsearch'
    AND w.utm_campaign = 'nonbrand'
GROUP BY 1,2 

-- PART 2: Analyzing Website Performance
