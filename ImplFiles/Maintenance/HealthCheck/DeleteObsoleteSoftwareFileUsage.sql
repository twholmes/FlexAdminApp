-- Copyright (C) 2015-2017 Flexera Software
--
-- This script implements a workaround to the problem FNMS-49750: Obsolete SoftwareFileUsage records are not cleaned up in Inventory database and grow indefinitely

PRINT 'Deleting obsolete SoftwareFileUsage_MT records'

IF OBJECT_ID('tempdb..#d') IS NOT NULL
	DROP TABLE #d

GO

DECLARE @rows INT
DECLARE @min BIGINT
DECLARE @max BIGINT
DECLARE @batchSize BIGINT

CREATE TABLE #d(
	SoftwareFileUsageID INT, 
	CONSTRAINT UQ_#d UNIQUE CLUSTERED(SoftwareFileUsageID)
)

INSERT #d(SoftwareFileUsageID)
SELECT SoftwareFileUsageID
FROM dbo.SoftwareFileUsage_MT sfu
WHERE NOT EXISTS(SELECT 1 FROM dbo.SoftwareUsagePerWeek_MT supw WHERE supw.SoftwareFileUsageID = sfu.SoftwareFileUsageID)

SET @rows = @@ROWCOUNT

SELECT @min = MIN(SoftwareFileUsageID), @max = MAX(SoftwareFileUsageID) FROM #d

SET @batchSize = CAST(1000000 AS BIGINT) * (@max - @min + 1) / @rows -- Chunk into batch size that will delete ~1M rows per batch on average

PRINT 'Identified ' + CAST(@rows AS VARCHAR) + ' rows to be deleted'

IF @rows > 0
	PRINT 'IDs between ' + CAST(@min AS VARCHAR) + ' and ' + CAST(@max AS VARCHAR) + ' to be deleted in batches of ' + CAST(@batchSize AS VARCHAR)

WHILE @min <= @max
BEGIN
	PRINT '	Deleting rows with IDs between ' + CAST(@min AS VARCHAR) + ' and ' + CAST(@min + @batchSize - 1 AS VARCHAR)

	DELETE sfu
	FROM dbo.SoftwareFileUsage_MT sfu
		JOIN #d ON #d.SoftwareFileUsageID = sfu.SoftwareFileUsageID
	WHERE #d.SoftwareFileUsageID BETWEEN @min AND (@min + @batchSize - 1)

	PRINT '	Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows'

	SET @min = @min + @batchSize
END

DROP TABLE #d

PRINT 'Finished deleting obsolete SoftwareFileUsage_MT records'

GO
