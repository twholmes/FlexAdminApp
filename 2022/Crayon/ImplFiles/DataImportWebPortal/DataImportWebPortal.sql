-- Copyright (C) 2015-2017 Flexera Software

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CustomBusinessDataUploadTask' AND TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE')
BEGIN
	-- Migrate from old single-tenanted DataImportWebPortal schema
	
	-- Constraints/indexes will be re-created later
	ALTER TABLE dbo.CustomBusinessDataUploadTask DROP CONSTRAINT PK_CustomBusinessDataUploadTask
	DROP INDEX IX_CustomBusinessDataUploadTaskByComplianceOperatorID ON dbo.CustomBusinessDataUploadTask
	DROP INDEX IX_CustomBusinessDataUploadTaskByStatusStartTime ON dbo.CustomBusinessDataUploadTask

	EXEC sp_rename 'dbo.CustomBusinessDataUploadTask', 'CustomBusinessDataUploadTask_MT'

	ALTER TABLE dbo.CustomBusinessDataUploadTask_MT ADD TenantID SMALLINT NOT NULL DEFAULT dbo.GetTenantID()
END
ELSE IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CustomBusinessDataUploadTask_MT' AND TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE')
BEGIN
	CREATE TABLE dbo.CustomBusinessDataUploadTask_MT(
		CustomBusinessDataUploadTaskID INT IDENTITY NOT NULL,
		Adapter NVARCHAR(256) NOT NULL, -- Display name of the adapter to be used to import file
		DataImportDirectory NVARCHAR(1024) NOT NULL, -- Path to where files for the adapter have been saved, relative to the DataImportDirectory
		DataSourceFileName NVARCHAR(256) NOT NULL,
		ComplianceOperatorID INT NOT NULL, -- The operator that created the task
		StartTime DATETIME NOT NULL DEFAULT GETUTCDATE(), -- UTC time that the task was originally registered
		LastUpdateTime DATETIME NOT NULL DEFAULT GETUTCDATE(), -- UTC time that the task was last updated registered
		Status INT NOT NULL DEFAULT 1, -- Current task status: 1 = task queued for import, 2 = import in progress, 3 = completed successfully, 4 = completed with failure, 5 = canceled
		StatusHidden BIT NOT NULL DEFAULT 0, -- Indicates whether to hide status from reporting to end user
		UniqueImportName NVARCHAR(256), -- Unique name assigned to run this import
		LogFilePath NVARCHAR(512), -- Path to the log file from the import, relative to the DataImportDirectory
		SummaryMessage NVARCHAR(4000), -- Summary message detailing outcome from running the task
		TenantID SMALLINT NOT NULL DEFAULT dbo.GetTenantID()
	)
END
GO

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CustomBusinessDataUploadTask' AND TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'VIEW')
	DROP VIEW dbo.CustomBusinessDataUploadTask
GO

CREATE VIEW dbo.CustomBusinessDataUploadTask AS
SELECT
	CustomBusinessDataUploadTaskID
	, Adapter
	, DataImportDirectory
	, DataSourceFileName
	, ComplianceOperatorID
	, StartTime
	, LastUpdateTime
	, Status
	, StatusHidden
	, UniqueImportName
	, LogFilePath
	, SummaryMessage
FROM dbo.CustomBusinessDataUploadTask_MT
	CROSS APPLY dbo.TableFilter_MT(TenantID)

GO


-----------------------------------------------------------------------------------
-- Configure indexes

IF NOT EXISTS (SELECT * FROM sysindexes WHERE name = N'PK_CustomBusinessDataUploadTask' AND id = OBJECT_ID(N'dbo.CustomBusinessDataUploadTask_MT'))
BEGIN
	ALTER TABLE dbo.CustomBusinessDataUploadTask_MT
	ADD CONSTRAINT PK_CustomBusinessDataUploadTask
		PRIMARY KEY CLUSTERED(CustomBusinessDataUploadTaskID)
END

IF NOT EXISTS (SELECT * FROM sysindexes WHERE name = N'IX_CustomBusinessDataUploadTaskByComplianceOperatorID' AND id = OBJECT_ID(N'dbo.CustomBusinessDataUploadTask_MT'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_CustomBusinessDataUploadTaskByComplianceOperatorID
		ON dbo.CustomBusinessDataUploadTask_MT(ComplianceOperatorID) INCLUDE(TenantID)
END

IF NOT EXISTS (SELECT * FROM sysindexes WHERE name = N'IX_CustomBusinessDataUploadTaskByStatusStartTime' AND id = OBJECT_ID(N'dbo.CustomBusinessDataUploadTask_MT'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_CustomBusinessDataUploadTaskByStatusStartTime
		ON dbo.CustomBusinessDataUploadTask_MT(Status, StartTime) INCLUDE(TenantID)
END


-----------------------------------------------------------------------------------
-- dbo.CustomBusinessDataUploadTaskForOperator: Table-valued function returning
-- all dbo.CustomBusinessDataUploadTask records that the identified operator
-- has access to view and manipulate.

IF EXISTS(SELECT * FROM sysobjects WHERE name = 'CustomBusinessDataUploadTaskForOperator')
	DROP FUNCTION dbo.CustomBusinessDataUploadTaskForOperator
GO

CREATE FUNCTION dbo.CustomBusinessDataUploadTaskForOperator(@OperatorLogin NVARCHAR(256))
	RETURNS TABLE
AS
	RETURN
		WITH x AS (
			SELECT * FROM dbo.RightsHasAccessByOperatorLogin(@OperatorLogin, 'CMAdvTasks', 'execute') WHERE HasAccess = 1
		)
		SELECT * FROM dbo.CustomBusinessDataUploadTask
		WHERE EXISTS(SELECT 1 FROM x) -- Operator has access to all task deta
			
		UNION

		SELECT t.*
		FROM dbo.CustomBusinessDataUploadTask t
		WHERE
			-- Operator has access to only their own task details
			NOT EXISTS(SELECT 1 FROM x)
			AND EXISTS(SELECT 1 FROM dbo.TableCurrentOperator(@OperatorLogin) co WHERE co.ComplianceOperatorID = t.ComplianceOperatorID)
GO


-----------------------------------------------------------------------------------
-- dbo.CustomBusinessDataUploadRegisterTask: Registers a data upload task to be
-- executed.

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomBusinessDataUploadRegisterTask') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomBusinessDataUploadRegisterTask
GO

CREATE PROCEDURE dbo.CustomBusinessDataUploadRegisterTask
	@Adapter NVARCHAR(256),
	@DataImportDirectory NVARCHAR(1024),
	@DataSourceFileName NVARCHAR(256),
	@OperatorLogin NVARCHAR(512)
AS
	INSERT dbo.CustomBusinessDataUploadTask(Adapter, DataImportDirectory, DataSourceFileName, ComplianceOperatorID)
	SELECT @Adapter, @DataImportDirectory, @DataSourceFileName, co.ComplianceOperatorID
	FROM dbo.TableCurrentOperator(@OperatorLogin) co

	RETURN @@IDENTITY
GO


-----------------------------------------------------------------------------------
-- dbo.CustomBusinessDataUploadHideTask: Marks a task to be hidden from status
-- reporting to the user.

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomBusinessDataUploadHideTask') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomBusinessDataUploadHideTask
GO

CREATE PROCEDURE dbo.CustomBusinessDataUploadHideTask
	@OperatorLogin NVARCHAR(512),
	@CustomBusinessDataUploadTaskID INT
AS
	UPDATE t
	SET	StatusHidden = 1 -- NB. Hiding the task from status does *not* update its LastUpdateTime
	FROM dbo.CustomBusinessDataUploadTask t
		-- Check operator has access to the task
		JOIN dbo.CustomBusinessDataUploadTaskForOperator(@OperatorLogin) s ON s.CustomBusinessDataUploadTaskID = t.CustomBusinessDataUploadTaskID
	WHERE t.CustomBusinessDataUploadTaskID = @CustomBusinessDataUploadTaskID
GO


-----------------------------------------------------------------------------------
-- dbo.CustomBusinessDataUploadCancelTask: Cancel a task that is not yet processed.

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomBusinessDataUploadCancelTask') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomBusinessDataUploadCancelTask
GO

CREATE PROCEDURE dbo.CustomBusinessDataUploadCancelTask
	@OperatorLogin NVARCHAR(512),
	@CustomBusinessDataUploadTaskID INT
AS
	UPDATE t
	SET	Status = 5 /* canceled */
		, LastUpdateTime = GETUTCDATE()
	FROM dbo.CustomBusinessDataUploadTask t
		-- Check operator has access to the task
		JOIN dbo.CustomBusinessDataUploadTaskForOperator(@OperatorLogin) s ON s.CustomBusinessDataUploadTaskID = t.CustomBusinessDataUploadTaskID
	WHERE t.CustomBusinessDataUploadTaskID = @CustomBusinessDataUploadTaskID
		AND t.Status = 1 /* queued */

	SELECT SuccessfullyCanceled = CAST(CASE @@ROWCOUNT WHEN 1 THEN 1 ELSE 0 END AS BIT)
GO


-----------------------------------------------------------------------------------
-- dbo.CustomBusinessDataUploadTaskStatusSummary: Returns a summary of data upload
-- tasks for a specified operator.

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomBusinessDataUploadTaskStatusSummary') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomBusinessDataUploadTaskStatusSummary
GO

CREATE PROCEDURE dbo.CustomBusinessDataUploadTaskStatusSummary
	@OperatorLogin NVARCHAR(512),
	@CustomBusinessDataUploadTaskID INT = NULL,
	@MaxTasks INT = 99999
AS
	BEGIN TRANSACTION

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- Do not block if MGSBI is busy processing data

	-- Return task details
	SELECT visibleTask.*, task.QueuePosition, o.OperatorLogin
	FROM
		(
			SELECT TOP (@MaxTasks) *
			FROM dbo.CustomBusinessDataUploadTaskForOperator(@OperatorLogin) 
			WHERE StatusHidden = 0
				AND CustomBusinessDataUploadTaskID = ISNULL(@CustomBusinessDataUploadTaskID, CustomBusinessDataUploadTaskID)
			ORDER BY LastUpdateTime DESC
		) visibleTask
		JOIN (
			SELECT
				t.CustomBusinessDataUploadTaskID,
				QueuePosition = ROW_NUMBER() OVER(PARTITION BY t.Status ORDER BY t.StartTime, t.CustomBusinessDataUploadTaskID)
			FROM dbo.CustomBusinessDataUploadTask t
		) task
			ON task.CustomBusinessDataUploadTaskID = visibleTask.CustomBusinessDataUploadTaskID
		LEFT OUTER JOIN dbo.ComplianceOperator o ON o.ComplianceOperatorID = visibleTask.ComplianceOperatorID
	ORDER BY visibleTask.LastUpdateTime DESC

	-- Return import summary details
	SELECT t.CustomBusinessDataUploadTaskID, lo.*
	FROM
		(
			SELECT TOP (@MaxTasks) *
			FROM dbo.CustomBusinessDataUploadTaskForOperator(@OperatorLogin) 
			WHERE StatusHidden = 0
				AND CustomBusinessDataUploadTaskID = ISNULL(@CustomBusinessDataUploadTaskID, CustomBusinessDataUploadTaskID)
			ORDER BY LastUpdateTime DESC
		) t
		JOIN dbo.BusinessImportLogSummary ls ON ls.ImportName = t.UniqueImportName
		JOIN dbo.BusinessImportLogObject lo ON lo.ImportID = ls.ImportID
	ORDER BY lo.StartDate

	-- Return an indication of whether the operator can see other operator's tasks
	SELECT HasAccessToOtherOperatorsTasks = HasAccess
	FROM dbo.RightsHasAccessByOperatorLogin(@OperatorLogin, 'CMAdvTasks', 'execute')

	COMMIT TRANSACTION
GO


-----------------------------------------------------------------------------------
-- dbo.CustomBusinessDataUploadTaskStatusDetail: Returns row-by-row detail of how
-- data was processed.

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomBusinessDataUploadTaskStatusDetail') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomBusinessDataUploadTaskStatusDetail
GO

CREATE PROCEDURE dbo.CustomBusinessDataUploadTaskStatusDetail
	@OperatorLogin NVARCHAR(512),
	@CustomBusinessDataUploadTaskID INT,
	@RejectedOnly BIT
AS
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- Do not block if MGSBI is busy processing data

	-- Return import row-by-row details
	SELECT TOP 1000 /* avoid huge data problems - this figure must match the same hard-coded number in UploadDetails.cshtml */
		lo.ObjectName, lo.ObjectType, ld.RecordNumber, ld.RecordDescription, ld.Message, ld.Action
	FROM dbo.CustomBusinessDataUploadTaskForOperator(@OperatorLogin) t
		JOIN dbo.BusinessImportLogSummary ls ON ls.ImportName = t.UniqueImportName
		JOIN dbo.BusinessImportLogObject lo ON lo.ImportID = ls.ImportID
		JOIN dbo.BusinessImportLogDetail ld ON ld.ImportID = ls.ImportID AND ld.ImportObjectID = lo.ImportObjectID
	WHERE t.StatusHidden = 0
		AND t.CustomBusinessDataUploadTaskID = @CustomBusinessDataUploadTaskID
		AND (@RejectedOnly != 1 OR ld.Action = 'Rejected')
	ORDER BY ld.RecordNumber, lo.StartDate, ld.ImportDetailID
	OPTION (TABLE HINT(ld, FORCESEEK)) -- Force BusinessImportLogDetail records to be seek'ed rather than using a table scan
GO


-----------------------------------------------------------------------------------
-- dbo.CustomBusinessDataUploadGetTaskLogFilePath: Get the log file path for
-- a specified task.

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomBusinessDataUploadGetTaskLogFilePath') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomBusinessDataUploadGetTaskLogFilePath
GO

CREATE PROCEDURE dbo.CustomBusinessDataUploadGetTaskLogFilePath
	@OperatorLogin NVARCHAR(512),
	@CustomBusinessDataUploadTaskID INT
AS
	SELECT t.LogFilePath
	FROM dbo.CustomBusinessDataUploadTaskForOperator(@OperatorLogin) t
	WHERE t.CustomBusinessDataUploadTaskID = @CustomBusinessDataUploadTaskID
GO


-----------------------------------------------------------------------------------
-- dbo.CustomBusinessDataUploadGetTaskDataSourceFilePath: Get the log file path for
-- a specified task.

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomBusinessDataUploadGetTaskDataSourceFilePath') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomBusinessDataUploadGetTaskDataSourceFilePath
GO

CREATE PROCEDURE dbo.CustomBusinessDataUploadGetTaskDataSourceFilePath
	@OperatorLogin NVARCHAR(512),
	@CustomBusinessDataUploadTaskID INT
AS
	SELECT t.DataImportDirectory + '\' + t.DataSourceFileName -- '
	FROM dbo.CustomBusinessDataUploadTaskForOperator(@OperatorLogin) t
	WHERE t.CustomBusinessDataUploadTaskID = @CustomBusinessDataUploadTaskID
GO


-----------------------------------------------------------------------------------
-- dbo.CustomBusinessDataUploadClearInProgressStatuses: Resets the status of
-- any and all tasks with a status of "in progress" to "queued".

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomBusinessDataUploadClearInProgressStatuses') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomBusinessDataUploadClearInProgressStatuses
GO

CREATE PROCEDURE dbo.CustomBusinessDataUploadClearInProgressStatuses
AS
	UPDATE dbo.CustomBusinessDataUploadTask_MT
	SET
		Status = 1 /* queued */
		, UniqueImportName = NULL
		, LogFilePath = NULL
		, SummaryMessage = NULL
		, LastUpdateTime = GETUTCDATE()
	WHERE Status = 2 /* in progress */

	SELECT @@ROWCOUNT AS ResetTaskCount
GO


-----------------------------------------------------------------------------------
-- dbo.CustomBusinessDataUploadGetNextTaskToExecute: Return a single row data
-- set containing the next queued task to be executed. The status of the task
-- is set (atomically) by this procedure to "in progress".
--
-- The data set contains all the columns from the dbo.CustomBusinessDataUploadTask_MT
-- table, along with an "OperatorLogin" column (which will be NULL if the operator
-- who submitted the task has subsequently been deleted).
--
-- If there are no tasks to be executed, returns nothing.

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomBusinessDataUploadGetNextTaskToExecute') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomBusinessDataUploadGetNextTaskToExecute
GO

CREATE PROCEDURE dbo.CustomBusinessDataUploadGetNextTaskToExecute
AS
	BEGIN TRANSACTION -- Operate atomically

	DECLARE @CustomBusinessDataUploadTaskID INT

	-- Find a task to run
	SELECT TOP 1 @CustomBusinessDataUploadTaskID = CustomBusinessDataUploadTaskID
	FROM dbo.CustomBusinessDataUploadTask_MT t
	WHERE Status = 1 /* queued */
	ORDER BY StartTime, CustomBusinessDataUploadTaskID

	IF @CustomBusinessDataUploadTaskID IS NOT NULL
	BEGIN
		UPDATE dbo.CustomBusinessDataUploadTask_MT
		SET	Status = 2 /* in progress */
			, LastUpdateTime = GETUTCDATE()
		WHERE CustomBusinessDataUploadTaskID = @CustomBusinessDataUploadTaskID

		-- Return details of the task to be executed
		SELECT t.*, tn.TenantUID, tn.TenantName, o.OperatorLogin
		FROM dbo.CustomBusinessDataUploadTask_MT t
			JOIN dbo.Tenant tn ON tn.TenantID = t.TenantID
			LEFT OUTER JOIN dbo.ComplianceOperator o ON o.ComplianceOperatorID = t.ComplianceOperatorID
		WHERE t.CustomBusinessDataUploadTaskID = @CustomBusinessDataUploadTaskID
	END

	COMMIT TRANSACTION
GO


-----------------------------------------------------------------------------------
-- dbo.CustomBusinessDataUploadSetImportDetails: Set unique import name
-- and log file path details for a task.

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomBusinessDataUploadSetImportDetails') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomBusinessDataUploadSetImportDetails
GO

CREATE PROCEDURE dbo.CustomBusinessDataUploadSetImportDetails
	@CustomBusinessDataUploadTaskID INT,
	@UniqueImportName NVARCHAR(256),
	@LogFilePath NVARCHAR(512)
AS
	UPDATE dbo.CustomBusinessDataUploadTask_MT
	SET	UniqueImportName = @UniqueImportName
		, LogFilePath = @LogFilePath
		, LastUpdateTime = GETUTCDATE()
	WHERE CustomBusinessDataUploadTaskID = @CustomBusinessDataUploadTaskID
GO


-----------------------------------------------------------------------------------
-- dbo.CustomBusinessDataUploadCompleteTaskSuccessfully: Mark a task as completed
-- successfully.

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomBusinessDataUploadCompleteTaskSuccessfully') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomBusinessDataUploadCompleteTaskSuccessfully
GO

CREATE PROCEDURE dbo.CustomBusinessDataUploadCompleteTaskSuccessfully
	@CustomBusinessDataUploadTaskID INT,
	@SummaryMessage NVARCHAR(4000) = NULL
AS
	UPDATE dbo.CustomBusinessDataUploadTask_MT
	SET
		Status = 3 /* completed successfully */
		, SummaryMessage = @SummaryMessage
		, LastUpdateTime = GETUTCDATE()
	WHERE CustomBusinessDataUploadTaskID = @CustomBusinessDataUploadTaskID
GO


-----------------------------------------------------------------------------------
-- dbo.CustomBusinessDataUploadCompleteTaskWithFailure: Mark a task as completed
-- with a failure.

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomBusinessDataUploadCompleteTaskWithFailure') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomBusinessDataUploadCompleteTaskWithFailure
GO

CREATE PROCEDURE dbo.CustomBusinessDataUploadCompleteTaskWithFailure
	@CustomBusinessDataUploadTaskID INT,
	@SummaryMessage NVARCHAR(4000) = NULL
AS
	UPDATE dbo.CustomBusinessDataUploadTask_MT
	SET
		Status = 4 /* completed with failure */
		, SummaryMessage = @SummaryMessage
		, LastUpdateTime = GETUTCDATE()
	WHERE CustomBusinessDataUploadTaskID = @CustomBusinessDataUploadTaskID
GO


-----------------------------------------------------------------------------------
-- dbo.CustomBusinessDataUploadGetTasksToDelete: Returns IDs and directories of
-- tasks that should be deleted.
--
-- These are tasks which are complete, with a completion date more than <N> days
-- in the past, where <N> is the "Number of days to keep activity logs"
-- configuration setting exposed on the System Settings > Inventory page in
-- the web interface.

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomBusinessDataUploadGetTasksToDelete') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomBusinessDataUploadGetTasksToDelete
GO

CREATE PROCEDURE dbo.CustomBusinessDataUploadGetTasksToDelete
AS
	DECLARE @DaysToKeep INT
	SET @DaysToKeep = ISNULL((SELECT TOP 1 CAST(SettingValue AS INT) FROM dbo.ComplianceTenantSettingGetStringBySettingName('ActivityLogHistoryAgeDays')), 30)

	SELECT CustomBusinessDataUploadTaskID, DataImportDirectory
	FROM dbo.CustomBusinessDataUploadTask_MT
	WHERE Status IN (3, 4, 5) /* completed statuses */
		AND LastUpdateTime <= DATEADD(d, -@DaysToKeep, GETUTCDATE())
GO


-----------------------------------------------------------------------------------
-- dbo.CustomBusinessDataUploadDeleteTask: Delete details of an upload task.

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomBusinessDataUploadDeleteTask') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomBusinessDataUploadDeleteTask
GO

CREATE PROCEDURE dbo.CustomBusinessDataUploadDeleteTask
	@CustomBusinessDataUploadTaskID INT
AS
	DELETE ls -- Cascades to BusinessImportLogSummaryObject and BusinessImportLogSummaryDetail
	FROM dbo.CustomBusinessDataUploadTask_MT t
		JOIN dbo.BusinessImportLogSummary ls ON ls.ImportName = t.UniqueImportName
	WHERE t.CustomBusinessDataUploadTaskID = @CustomBusinessDataUploadTaskID

	DELETE dbo.CustomBusinessDataUploadTask_MT
	WHERE CustomBusinessDataUploadTaskID = @CustomBusinessDataUploadTaskID
GO


-----------------------------------------------------------------------------------
-- Schema and procedures to assist with data validation in adapters
-----------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CustomAdapterValidationRule' AND TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE')
BEGIN
	CREATE TABLE dbo.CustomAdapterValidationRule(
		CustomAdapterValidationRuleID INT IDENTITY NOT NULL,
		ImportObjectID INT NOT NULL, -- Rules are for this import object
		IsGlobalRule BIT NOT NULL, -- Is this a global rule that is not based on data from an individual source row (1), or is it a rule run on each row?
		ValidationRule NVARCHAR(MAX) NOT NULL, -- SQL expression to be evaluated to identify bad (invalid) records
		ErrorMessage NVARCHAR(3000) NOT NULL, -- Error message to be reported for user upon validation failure
		SourceColumn1Name NVARCHAR(256), -- Source column name being validated
		SourceColumn2Name NVARCHAR(256), -- Source column name being validated
	)
END
ELSE IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CustomAdapterValidationRule' AND COLUMN_NAME = 'CustomAdapterValidationRuleID')
BEGIN
	-- Add column that was not in old versions of this script
	ALTER TABLE dbo.CustomAdapterValidationRule ADD CustomAdapterValidationRuleID INT IDENTITY NOT NULL
END
GO


-----------------------------------------------------------------------------------
-- dbo.CustomAdapterValidationStartRules

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomAdapterValidationStartRules') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomAdapterValidationStartRules
GO

CREATE PROCEDURE dbo.CustomAdapterValidationStartRules
	@LogImportID INT,
	@StepName NVARCHAR(50)
AS
	-- Take the opportunity to clean up rules that have been orphaned from an associated BusinessImportLogObject record (e.g. from aborted previous imports)
	DELETE r
	FROM dbo.CustomAdapterValidationRule r
	WHERE NOT EXISTS(SELECT 1 FROM dbo.BusinessImportLogObject o WHERE o.ImportObjectID = r.ImportObjectID)

	INSERT dbo.BusinessImportLogObject(ImportID, ObjectName, ObjectType, StartDate, Status)
	VALUES (@LogImportID, @StepName, NULL, GETDATE(), 0 /* not completed */)

	RETURN SCOPE_IDENTITY()
GO


-----------------------------------------------------------------------------------
-- dbo.CustomAdapterValidationRegisterRule

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomAdapterValidationRegisterRule') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomAdapterValidationRegisterRule
GO

CREATE PROCEDURE dbo.CustomAdapterValidationRegisterRule
	@ImportObjectID INT,
	@ValidationRule NVARCHAR(MAX),
	@ErrorMessage NVARCHAR(3000),
	@SourceColumn1Name NVARCHAR(256) = NULL,
	@SourceColumn2Name NVARCHAR(256) = NULL,
	@IsGlobalRule BIT = 0
AS
	INSERT dbo.CustomAdapterValidationRule(ImportObjectID, IsGlobalRule, SourceColumn1Name, SourceColumn2Name, ValidationRule, ErrorMessage)
	VALUES (@ImportObjectID, @IsGlobalRule, @SourceColumn1Name, @SourceColumn2Name, @ValidationRule, @ErrorMessage)
GO


-----------------------------------------------------------------------------------
-- dbo.CustomAdapterValidationRuleRequired
--
-- Example usage:
-- EXEC dbo.CustomAdapterValidationRuleRequired [LOG_IMPORT_ID], '@SourceColumn1Name@ must be specified', 'id'

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomAdapterValidationRuleRequired') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomAdapterValidationRuleRequired
GO

CREATE PROCEDURE dbo.CustomAdapterValidationRuleRequired
	@ImportObjectID INT,
	@SourceColumn1Name NVARCHAR(256),
	@ErrorMessage NVARCHAR(3000) = '@SourceColumn1Name@ must be specified'
AS
	EXEC dbo.CustomAdapterValidationRegisterRule
		@ImportObjectID,
		'ISNULL(LTRIM(RTRIM(source.[@SourceColumn1Name@])), '''') = ''''',
		@ErrorMessage,
		@SourceColumn1Name
GO


-----------------------------------------------------------------------------------
-- dbo.CustomAdapterValidationExecuteRules

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomAdapterValidationExecuteRules') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomAdapterValidationExecuteRules
GO

CREATE PROCEDURE dbo.CustomAdapterValidationExecuteRules
	@ImportObjectID INT,
	@SourceTableName NVARCHAR(256),
	@TraceField NVARCHAR(256)
AS
	PRINT 'Executing data validation rules over table ' + @SourceTableName

	DECLARE @Command NVARCHAR(MAX)
	DECLARE @GloballyRejected BIT

	DECLARE @IsGlobalRule BIT
	DECLARE @SourceColumn1Name NVARCHAR(256)
	DECLARE @SourceColumn2Name NVARCHAR(256)
	DECLARE @ValidationRule NVARCHAR(MAX)
	DECLARE @ErrorMessage NVARCHAR(3000)

	DECLARE c CURSOR FOR
	SELECT
		IsGlobalRule,
		SourceColumn1Name, 
		SourceColumn2Name, 
		REPLACE(REPLACE(ValidationRule, '@SourceColumn1Name@', ISNULL(SourceColumn1Name, '@SourceColumn1Name@')), '@SourceColumn2Name@', ISNULL(SourceColumn2Name, '@SourceColumn2Name@')),
		REPLACE(REPLACE(ErrorMessage, '@SourceColumn1Name@', ISNULL(SourceColumn1Name, '@SourceColumn1Name@')), '@SourceColumn2Name@', ISNULL(SourceColumn2Name, '@SourceColumn2Name@'))
	FROM dbo.CustomAdapterValidationRule
	WHERE ImportObjectID = @ImportObjectID
	ORDER BY IsGlobalRule DESC /* Execute global rules first */, CustomAdapterValidationRuleID /* then in order of addition */

	SET @GloballyRejected = 0

	OPEN c
	FETCH NEXT FROM c INTO @IsGlobalRule, @SourceColumn1Name, @SourceColumn2Name, @ValidationRule, @ErrorMessage

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @IsGlobalRule = 1
		BEGIN
			SET @Command = '
				INSERT dbo.BusinessImportLogDetail(
					ImportID,
					RecordNumber,
					Action,
					ImportObjectID,
					RecordDescription,
					Message
				)
				SELECT
					lo.ImportID,
					0, /* No specific row */
					''Rejected'',
					lo.ImportObjectID,
					''All rows'',
					@ErrorMessage
				FROM dbo.BusinessImportLogObject lo
				WHERE (' + @ValidationRule + ')
					AND lo.ImportObjectID = @ImportObjectID

				IF @@ROWCOUNT = 0
					SET @Result = 0 /* Not globally rejected */
				ELSE
				BEGIN
					UPDATE source
					SET Rejected = 1
					FROM [' + @SourceTableName + '] source
					
					SET @Result = 1 /* All data has been globally rejected */
				END
			'
		END
		ELSE IF @GloballyRejected = 0 /* Only execute non-global validation if we have not had a global rejection of all incoming data */
		BEGIN
			DECLARE @SourceColumn1NameReference NVARCHAR(256)
			DECLARE @SourceColumn2NameReference NVARCHAR(256)
			SET @SourceColumn1NameReference = ISNULL('ISNULL(CONVERT(NVARCHAR(3000), source.[' + @SourceColumn1Name + ']), ''<NULL>'')', '''<No value>''')
			SET @SourceColumn2NameReference = ISNULL('ISNULL(CONVERT(NVARCHAR(3000), source.[' + @SourceColumn2Name + ']), ''<NULL>'')', '''<No value>''')

			SET @Command = '
				INSERT dbo.BusinessImportLogDetail(
					ImportID,
					RecordNumber,
					Action,
					ImportObjectID,
					RecordDescription,
					Message
				)
				SELECT
					lo.ImportID,
					source.RowNumber,
					''Rejected'',
					lo.ImportObjectID,
					LEFT(' + @TraceField + ', 255),
					LEFT(REPLACE(REPLACE(@ErrorMessage, ''@SourceColumn1Value@'', ' + @SourceColumn1NameReference + '), ''@SourceColumn2Value@'', ' + @SourceColumn2NameReference + '), 3000)
				FROM [' + @SourceTableName + '] source,
					dbo.BusinessImportLogObject lo
				WHERE (' + @ValidationRule + ')
					AND lo.ImportObjectID = @ImportObjectID

				UPDATE source
				SET Rejected = 1 
				FROM [' + @SourceTableName + '] source 
				WHERE (' + @ValidationRule + ')

				SET @Result = 0
			'
		END
		ELSE
		BEGIN
			SET @Command = NULL
		END

		IF @Command IS NOT NULL
		BEGIN
			PRINT 'Executing SQL: ' + @Command

			BEGIN TRY
				DECLARE @Result BIT

				EXEC sp_executesql @Command
					, N'@ImportObjectID INT, @ErrorMessage NVARCHAR(3000), @Result INT OUTPUT'
					, @ImportObjectID = @ImportObjectID, @ErrorMessage = @ErrorMessage, @Result = @Result OUTPUT

				IF @Result = 1
					SET @GloballyRejected = 1
			END TRY
			BEGIN CATCH
				DECLARE @m NVARCHAR(MAX)
				SET @m = 'Error executing validation rule: ' + ERROR_MESSAGE() + ' Line ' + CAST(ERROR_LINE() AS NVARCHAR(5))
				PRINT @m
				; THROW
			END CATCH
		END

		FETCH NEXT FROM c INTO @IsGlobalRule, @SourceColumn1Name, @SourceColumn2Name, @ValidationRule, @ErrorMessage
	END

	CLOSE c
	DEALLOCATE c

	SET @Command = '
		UPDATE dbo.BusinessImportLogObject
		SET	Processed = (SELECT COUNT(*) FROM [' + @SourceTableName + '])
			, Rejected = (SELECT COUNT(*) FROM [' + @SourceTableName + '] WHERE Rejected = 1)
		WHERE ImportObjectID = @ImportObjectID
		
		DELETE FROM [' + @SourceTableName + '] WHERE Rejected = 1
	'

	PRINT 'Executing SQL: ' + @Command
	EXEC sp_executesql @Command, N'@ImportObjectID INT', @ImportObjectID = @ImportObjectID

	DELETE FROM dbo.CustomAdapterValidationRule
	WHERE ImportObjectID = @ImportObjectID

	UPDATE dbo.BusinessImportLogObject
	SET Status = 1 /* Completed */, EndDate = GETDATE()
	WHERE ImportObjectID = @ImportObjectID
GO


-----------------------------------------------------------------------------------
-- dbo.CustomVerifyColumnTypeForAdapterImport

-- Example usage:
-- EXEC dbo.CustomVerifyColumnTypeForAdapterImport @ImportObjectID, '#Assets', 'Last IMAC Update Date', 'date'
-- EXEC dbo.CustomVerifyColumnTypeForAdapterImport @ImportObjectID, '#Assets', 'Location Path', 'text'
IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomVerifyColumnTypeForAdapterImport') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomVerifyColumnTypeForAdapterImport
GO

CREATE PROCEDURE dbo.CustomVerifyColumnTypeForAdapterImport
	@ImportObjectID INT,
	@SourceTableName NVARCHAR(128), -- Table name, excluding schema
	@ColumnName NVARCHAR(128),
	@ExpectedType VARCHAR(50), -- text, date, int, float
	@SourceTableSchema NVARCHAR(128) = 'dbo'
AS
	DECLARE @t NVARCHAR(128)
	
	IF LEFT(@SourceTableName, 1) <> '#'
		SELECT @t = DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @SourceTableName AND COLUMN_NAME = @ColumnName
	ELSE
	BEGIN
		SELECT @t = DATA_TYPE
		FROM tempdb.INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = (SELECT name FROM tempdb.sys.tables WHERE object_id = OBJECT_ID('tempdb.[' + @SourceTableSchema + '].[' + @SourceTableName + ']'))
			AND COLUMN_NAME = @ColumnName
	END
	
	DECLARE @sql NVARCHAR(1000)

	-- Add column if it does not exist
	IF @t IS NULL
	BEGIN
		SET @ExpectedType
			= CASE @ExpectedType
				WHEN 'text' THEN 'NVARCHAR(256) COLLATE DATABASE_DEFAULT'
				WHEN 'date' THEN 'DATETIME'
				ELSE @ExpectedType
			END

		SET @sql = 'ALTER TABLE [' + @SourceTableSchema + '].[' + @SourceTableName + '] ADD [' + @ColumnName + '] ' + @ExpectedType

		PRINT 'Executing SQL: ' + @sql
		EXEC sp_executesql @sql
	END

	-- If column exists, validate that its type matches what we expect
	ELSE IF
		(@ExpectedType = 'text' AND @t NOT IN ('char', 'nchar', 'ntext', 'nvarchar', 'varchar'))
		OR (@ExpectedType IN ('int', 'float') AND @t NOT IN ('int', 'smallint', 'tinyint', 'float', 'double', 'money', 'numeric'))
		OR (@ExpectedType = 'date' AND @t NOT IN ('datetime', 'smalldatetime', 'date'))
	BEGIN
		DECLARE @msg NVARCHAR(1000)
		SET @msg = 'Column ''' + @ColumnName + ''' has type ' + @t + ' but expected type ' + @ExpectedType

		EXEC dbo.CustomAdapterValidationRegisterRule
			@ImportObjectID
			, @IsGlobalRule = 1
			, @ValidationRule = '1 = 1'
			, @ErrorMessage = @msg
	END

	ELSE IF @ExpectedType = 'int' AND @t NOT IN ('int', 'smallint', 'tinyint')
	BEGIN
		EXEC dbo.CustomAdapterValidationRegisterRule
			@ImportObjectID
			, @SourceColumn1Name = @ColumnName
			, @ValidationRule = 'source.[@SourceColumn1Name@] != TRY_CONVERT(INT, source.[@SourceColumn1Name@])'
			, @ErrorMessage = '@SourceColumn1Name@ value @SourceColumn1Value@ must be a whole number'
	END
GO
