PRINT 'Deleting business adapter logs older than $(DaysToKeepBusinessAdapterLogs) days'

DELETE bils
FROM dbo.BusinessImportLogSummary bils
WHERE DATEDIFF(day, bils.StartDate, GETDATE()) < $(DaysToKeepBusinessAdapterLogs)
	AND
	-- Only delete automated adapter logs.   Data import web portal adapters are managed through the data import web portal
	bils.ImportName IN (
		'AgedInventory',
		'BusinessUnit',
		'Location',
		'HRUsers',
		'HRUsersTerminationDetails',
		'UnifyPOs',
		'AssetBusinessRules'
	)

GO
