---------------------------------------------------------------------------
-- This file contains various sample queries illustrating ways that IIS
-- log data might be analysed.
--
-- Copyright (C) 2017 Flexera Software
---------------------------------------------------------------------------

-- # of requests and timing details of user-facing URLs over the last month
SELECT csUriStemWithoutTrailingDigits
	, RequestCount = COUNT(*)
	, AverageTimeTaken = AVG(timeTaken)
	, MinTimeTaken = MIN(timeTaken)
	, MaxTimeTaken = MAX(timeTaken)
	, TimeTakenStdDev = STDEV(timeTaken)
FROM dbo.CustomIISLogsEx
WHERE [date] >= DATEADD(m, -1, GETUTCDATE())
	AND csUriStem like '/Suite%'
GROUP BY csUriStemWithoutTrailingDigits
ORDER BY AVG(timeTaken) DESC


-- # of requests per hour and timing details of user-facing URLs over the last month
SELECT
	[Date] = CAST([date] AS DATE)
	, Hour = DATEPART(hh, [time])
	, RequestCount = COUNT(*)
	, AverageTimeTaken = AVG(timeTaken)
	, MinTimeTaken = MIN(timeTaken)
	, MaxTimeTaken = MAX(timeTaken)
	, TimeTakenStdDev = STDEV(timeTaken)
FROM dbo.CustomIISLogs 
WHERE [date] >= DATEADD(m, -1, GETUTCDATE())
	AND csUriStem like '/Suite%'
GROUP BY CAST([date] AS DATE), DATEPART(hh, [time])
ORDER BY CAST([date] AS DATE), DATEPART(hh, [time])


-- Get counts of requests made to URLs over the last month that returned an error status code (except for 401 Unauthorized)
SELECT csUriStemWithoutTrailingDigits, scStatus, RequestCount = COUNT(*)
FROM dbo.CustomIISLogsEx
WHERE [date] >= DATEADD(m, -1, GETUTCDATE())
	AND csUriStem like '/Suite%'
	AND scStatus BETWEEN 400 AND 599
	AND scStatus != 401 /* Unauthorized */
GROUP BY csUriStemWithoutTrailingDigits, scStatus
ORDER BY COUNT(*) DESC


-- Get number of requests made from each csUsername over the last month
SELECT csUsername, RequestCount = COUNT(*), AverageRequestTime = AVG(timeTaken)
FROM dbo.CustomIISLogs 
WHERE [date] >= DATEADD(m, -1, GETUTCDATE())
GROUP BY csUsername
ORDER BY COUNT(*) DESC


-- Get number of requests made from each csUserAgent over the last month
SELECT csUserAgent, RequestCount = COUNT(*)
FROM dbo.CustomIISLogs 
WHERE [date] >= DATEADD(m, -1, GETUTCDATE())
GROUP BY csUserAgent
ORDER BY COUNT(*) DESC
