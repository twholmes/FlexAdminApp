-- Copyright (C) 2015-2018 Flexera

PRINT 'Deleting computers inactive for more than $(DaysToKeepInactiveComputerInventory) days'

-- Delete computer inventory records where no data has been received for at least $(DaysToKeepInactiveComputerInventory) days

DECLARE @OldestDataDate DATE
SET @OldestDataDate = DATEADD(d, -$(DaysToKeepInactiveComputerInventory), GETDATE())

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET DEADLOCK_PRIORITY LOW

DECLARE @TenantID INT
DECLARE @TenantName NVARCHAR(256)

DECLARE c CURSOR FOR SELECT TenantID, TenantName FROM dbo.Tenant
OPEN c

FETCH NEXT FROM c INTO @TenantID, @TenantName
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT N'Deleting inactive computers in tenant ' + @TenantName
	EXEC dbo.SetTenantID @TenantID

	WHILE 1 = 1
	BEGIN
		IF OBJECT_ID('tempdb..#Computer') IS NOT NULL
			DROP TABLE #Computer

		SELECT TOP 100 c.ComputerID -- Delete in small batches to avoid locking too much data for too long
		INTO #Computer
		FROM dbo.Computer c
			LEFT OUTER JOIN dbo.ComputerResourceData AS crd ON crd.ComputerUID = c.ComputerUID
		WHERE
			(	-- Computer is not in Active Directory
				c.GUID IS NULL
				-- Or some data has been received about the computer
				OR crd.ComputerResourceID IS NOT NULL
				OR EXISTS(SELECT 1 FROM dbo.InventoryReport inr WHERE inr.ComputerID = c.ComputerID)
				OR EXISTS(SELECT 1 FROM dbo.Installation i WHERE i.ComputerID = c.ComputerID AND i.OrganizationID = c.ComputerOUID)
				OR EXISTS(SELECT 1 FROM dbo.ComputerUsage cu WHERE cu.ComputerID = c.ComputerID)
			)
			-- But the data is old
			AND (crd.ComputerUID IS NULL OR NOT(crd.LastUpdated >= @OldestDataDate))
			AND NOT EXISTS(
				SELECT 1
				FROM dbo.InventoryReport inr
				WHERE inr.ComputerID = c.ComputerID
					AND (
						HWDate >= @OldestDataDate
						OR SWDate >= @OldestDataDate
						OR FilesDate >= @OldestDataDate
						OR ServicesDate >= @OldestDataDate
						OR VMwareServicesDate >= @OldestDataDate
						OR OVMMDate >= @OldestDataDate
						OR AccessDate >= @OldestDataDate
					)
			)
			AND NOT EXISTS(
				SELECT 1
				FROM dbo.ServiceProvider sp
				WHERE sp.ComputerID = c.ComputerID
					AND LastInventoryDate >= @OldestDataDate
			)
			AND NOT EXISTS(
				SELECT 1
				FROM dbo.Installation i
				WHERE i.ComputerID = c.ComputerID
					AND i.OrganizationID = c.ComputerOUID
					AND Received >= @OldestDataDate
			)
			AND NOT EXISTS(
				SELECT 1
				FROM dbo.ComputerUsage cu
				WHERE cu.ComputerID = c.ComputerID
					AND LastReported >= @OldestDataDate
			)

		DECLARE @Count INT
		SET @Count = @@ROWCOUNT

		IF @Count = 0
			BREAK

		PRINT 'Deleting ' + CAST(@Count AS VARCHAR) + ' computers'

		EXEC dbo.DeleteComputers
	END

	PRINT 'No more computers found to delete'

	FETCH NEXT FROM c INTO @TenantID, @TenantName
END

CLOSE c
DEALLOCATE c

GO
