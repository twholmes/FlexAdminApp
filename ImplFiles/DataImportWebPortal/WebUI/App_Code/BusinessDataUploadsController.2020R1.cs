// Copyright (C) 2015-2018 Flexera

// Access to this controller and its actions is restricted to accounts that have the
// "Data inputs: business and inventory imports > Import business data" (CMBusinessImport/execute) right

[Flexera.Web.Core.AccessResource("CMBusinessImport")]
public class BusinessDataUploadsController: System.Web.Mvc.Controller
{
	private static readonly Flexera.Common.Logging.ILogger mLogger = Flexera.Common.Logging.LogManager.GetLogger("Flexera.Custom.BusinessDataUploads");

	static BusinessDataUploadsController()
	{
		// Augment the method access rights with details from this assembly upon first load.
		// This is required so that the access rights checking knows about this controller
		// to allow it to be invoked.

		System.Web.HttpContext.Current.Cache.Remove("MethodAccessRightCache");

		Flexera.Web.Core.MethodAccessRightsCache.CacheControllerMethodAccessRights(
			System.Reflection.Assembly.GetAssembly(typeof(Flexera.Web.Presentation.Controllers.DataInputsController)),
			System.Reflection.Assembly.GetExecutingAssembly()
		);
	}

	// Example URL: http://server/Suite/BusinessDataUploads/DownloadTemplate?adapterSubdirectory=LeasedAssetsAdapter
	[Flexera.Web.Core.AccessRight("execute")]
	public System.Web.Mvc.ActionResult DownloadTemplate(string adapterSubdirectory)
	{
		BusinessAdapterRegistration r = BusinessAdapterRegistrations.AllRegistrations[adapterSubdirectory];

		return
			r == null || string.IsNullOrEmpty(r.TemplateFileName)
			? null
			: this.File(r.TemplateFileFullPath, "application/octet-stream", r.TemplateFileName);
	}

	// Example URL: http://server/Suite/BusinessDataUploads/DownloadLog?id=1046
	[Flexera.Web.Core.AccessRight("execute")]
	public System.Web.Mvc.ActionResult DownloadLog(int id)
	{
		string fileName
			= System.IO.Path.Combine(
				DataImportDirectory,
				BusinessDataDatabaseLayer.ExecuteQuerySingleValue(
					"EXEC dbo.CustomBusinessDataUploadGetTaskLogFilePath @OperatorLogin, @CustomBusinessDataUploadTaskID",
					new System.Collections.Generic.Dictionary<string, object>{
						{ "@OperatorLogin", ManageSoft.Identity.SystemIdentity.UserName },
						{ "@CustomBusinessDataUploadTaskID", id },
					}
				) as string
			);

		return System.IO.File.Exists(fileName)
			? (System.Web.Mvc.ActionResult)this.File(fileName, "application/octet-stream", System.IO.Path.GetFileName(fileName))
			: (System.Web.Mvc.ActionResult)HttpNotFound();
	}

	// Example URL: http://server/Suite/BusinessDataUploads/DownloadDataSourceFile?id=1046
	[Flexera.Web.Core.AccessRight("execute")]
	public System.Web.Mvc.ActionResult DownloadDataSourceFile(int id)
	{
		string fileName
			= System.IO.Path.Combine(
				DataImportDirectory,
				BusinessDataDatabaseLayer.ExecuteQuerySingleValue(
					"EXEC dbo.CustomBusinessDataUploadGetTaskDataSourceFilePath @OperatorLogin, @CustomBusinessDataUploadTaskID",
					new System.Collections.Generic.Dictionary<string, object>{
						{ "@OperatorLogin", ManageSoft.Identity.SystemIdentity.UserName },
						{ "@CustomBusinessDataUploadTaskID", id },
					}
				) as string
			);

		return System.IO.File.Exists(fileName)
			? (System.Web.Mvc.ActionResult)this.File(fileName, "application/octet-stream", System.IO.Path.GetFileName(fileName))
			: (System.Web.Mvc.ActionResult)HttpNotFound();
	}

	// Example URL: http://server/Suite/BusinessDataUploads/RemoveTask?id=1046
	[Flexera.Web.Core.AccessRight("execute")]
	public System.Web.Mvc.ActionResult RemoveTask(int id)
	{
		BusinessDataDatabaseLayer.ExecuteQuery(
			"EXEC dbo.CustomBusinessDataUploadHideTask @OperatorLogin, @CustomBusinessDataUploadTaskID",
			new System.Collections.Generic.Dictionary<string, object>{
				{ "@OperatorLogin", ManageSoft.Identity.SystemIdentity.UserName },
				{ "@CustomBusinessDataUploadTaskID", id },
			}
		);

		return Content("hidden");
	}

	// Example URL: http://server/Suite/BusinessDataUploads/CancelTask?id=1046
	// Returns { Canceled = true } if task was successfully canceled, or
	// { Canceled = false} if task was not successfully canceled (e.g. because it is being processed)
	[Flexera.Web.Core.AccessRight("execute")]
	public System.Web.Mvc.ActionResult CancelTask(int id)
	{
		bool result = (bool)BusinessDataDatabaseLayer.ExecuteQuerySingleValue(
			"EXEC dbo.CustomBusinessDataUploadCancelTask @OperatorLogin, @CustomBusinessDataUploadTaskID",
			new System.Collections.Generic.Dictionary<string, object>{
				{ "@OperatorLogin", ManageSoft.Identity.SystemIdentity.UserName },
				{ "@CustomBusinessDataUploadTaskID", id },
			}
		);

		return Json(new { Canceled = result }, System.Web.Mvc.JsonRequestBehavior.AllowGet);
	}

	private static string DataImportDirectory
	{
		get { return ManageSoft.Implementation.Configuring.ConfApi.ComplianceConf.ComplianceDataImportDirectory; }
	}

	private void SaveUploadedFile(BusinessAdapterRegistration adapter, System.IO.Stream inputFileStream, string fileName)
	{
		string uploadId = System.Guid.NewGuid().ToString();
		string dir = System.IO.Path.Combine(DataImportDirectory, uploadId);

		if (!System.IO.Directory.Exists(dir))
			System.IO.Directory.CreateDirectory(dir);

		// Save uploaded data file
		string savedFile = System.IO.Path.Combine(dir, fileName);

		mLogger.Info("Saving file uploaded by {0} to {1}", ManageSoft.Identity.SystemIdentity.UserName, savedFile);
		using (var outputFileStream = new System.IO.FileStream(savedFile, System.IO.FileMode.Create, System.IO.FileAccess.Write, System.IO.FileShare.Read))
			inputFileStream.CopyTo(outputFileStream);

		// Save adapter registration file and config file for use during later upload
		System.IO.File.Copy(System.IO.Path.Combine(adapter.AdapterFullPath, adapter.ConfigFile), System.IO.Path.Combine(dir, adapter.ConfigFile));

		System.IO.File.Copy(System.IO.Path.Combine(adapter.AdapterFullPath, BusinessAdapterRegistrations.BusinessAdapterRegistrationConfigFile), System.IO.Path.Combine(dir, BusinessAdapterRegistrations.BusinessAdapterRegistrationConfigFile));

		// Register task in the database to be queued for processing
		BusinessDataDatabaseLayer.ExecuteStoredProcedure(
			"dbo.CustomBusinessDataUploadRegisterTask",
			new System.Collections.Generic.Dictionary<string, object>{
				{ "@Adapter", adapter.DisplayName },
				{ "@DataImportDirectory", uploadId },
				{ "@DataSourceFileName", fileName },
				{ "@OperatorLogin", ManageSoft.Identity.SystemIdentity.UserName },
			}
		);

		// Signal any running monitoring process that a new task has been queued
		// The event name here must match the name in the DataImprotWebPortal-Execute.ps1 script
		var ewh = new System.Threading.EventWaitHandle(false, System.Threading.EventResetMode.AutoReset, "Global\\flexadmin-NewDataUploadTaskEvent");
		ewh.Set();
		ewh.Close();
	}

	[Flexera.Web.Core.AccessRight("execute")]
	public System.Web.Mvc.ActionResult HandleUpload(string adapterSubdirectory)
	{
		mLogger.Info("Handling file upload for {0}", adapterSubdirectory);

		BusinessAdapterRegistration r = BusinessAdapterRegistrations.AllRegistrations[adapterSubdirectory];

		if (r == null)
			mLogger.Warn("Ignoring attempt to upload data for non-existent adapter");
		else
		{
			string allowedExtension = r.UploadFileType;
			// Ensure extension starts with a leading "." (which is required by FileUploadHandler)
			if (!string.IsNullOrEmpty(allowedExtension) && allowedExtension[0] != '.')
				allowedExtension = "." + allowedExtension;

			Flexera.Web.Core.Display.FileUploadHelper.FileUploadHandler(
				"businessDataUploadControl", new string[] { allowedExtension },
				maximumFileSize: 20 * 1024 * 1024,
				uploadCompleteHandler: delegate(System.IO.Stream inputFileStream, string fileName) {
					SaveUploadedFile(r, inputFileStream, fileName);
					return string.Empty;
				}
			);
		}

		return null;
	}

	// Example URL: http://server/Suite/BusinessDataUploads/CurrentStatus (gets status of all jobs)
	// Example URL: http://server/Suite/BusinessDataUploads/CurrentStatus?maxTasks=10 (gets status of last 10 jobs)
	// Example URL: http://server/Suite/BusinessDataUploads/CurrentStatus?id=1046 (get status of identified job)
	[Flexera.Web.Core.AccessRight("execute")]
	public System.Web.Mvc.ActionResult CurrentStatus(int? id, int? maxTasks)
	{
		System.Data.DataSet statusSummary = BusinessDataDatabaseLayer.ExecuteQuery(
			"EXEC dbo.CustomBusinessDataUploadTaskStatusSummary @OperatorLogin, @CustomBusinessDataUploadTaskID, @MaxTasks",
			new System.Collections.Generic.Dictionary<string, object>{
				{ "@OperatorLogin", ManageSoft.Identity.SystemIdentity.UserName },
				{ "@CustomBusinessDataUploadTaskID", id == null ? (object) System.DBNull.Value : (object) id },
				{ "@MaxTasks", maxTasks == null ? 99999 : (object) maxTasks },
			}
		);

		System.Data.DataTable uploadsTable = statusSummary.Tables[0];
		System.Data.DataTable statusDetailsTable = statusSummary.Tables[1];
		System.Data.DataTable accessTable = statusSummary.Tables[2];

		/*
		 * Build an object which can be converted to a useful JSON structure for returning
		 *
		 * Example shape of the object that is ultimately returned:
		 *	{
		 *		Uploads: [
		 *			{
		 *				CustomBusinessDataUploadTaskID: 1026,
		 *				Adapter: "Asset spreadsheet (sample)",
		 *				DataImportDirectory: "b5056b49-3a78-48f5-b3e7-1a4ff7892191",
		 *				DataSourceFileName:"SampleAssetImportTemplate.xlsx",
		 *				ComplianceOperatorID:1,
		 *				StartTime: "7/24/2015 1:17:44 AM",
		 *				LastUpdateTime: "7/24/2015 1:19:32 AM/",
		 *				Status: 3,
		 *				LogFilePath: "b5056b49-3a78-48f5-b3e7-1a4ff7892191\ReceiveAssets-1005_20170517_235304.log",
		 *				SummaryMessage:null,
		 *				UniqueImportName: "SampleAssetImport-161002fe-d3a7-4b2a-8e6f-bead6e3a754c",
		 *				StatusHidden: false,
		 *				QueuePosition: 15,
		 *				StatusDetails: [
		 *					{
		 *						ObjectName: "Create & Update Assets",
		 *						StartDate: "7/24/2015 1:17:58 AM",
		 *						Processed: 2,
		 *						Matched: 0,
		 *						Rejected: 0,
		 *						Updated: 0,
		 *						Created: 2,
		 *						Deleted:0
		 *					},
		 *					...
		 *				],
		 *			},
		 *			...
		 *		],
		 *		HasAccessToOtherOperatorsTasks: true,
		 *		MonitorTaskRunning: true,
		 *	}
		 */
		var result = GetAnonymousObject(uploadsTable);
		
		foreach (var task in result)
		{
			// Convert times to operator's time zone & display format
			task["StartTime"] = Flexera.Web.Core.Conversion.ToFriendlyString(Flexera.Web.Core.Conversion.FromTimeZone((System.DateTime)task["StartTime"], System.DateTimeKind.Utc), showTime: true);
			task["LastUpdateTime"] = Flexera.Web.Core.Conversion.ToFriendlyString(Flexera.Web.Core.Conversion.FromTimeZone((System.DateTime)task["LastUpdateTime"], System.DateTimeKind.Utc), showTime: true);

			// Only link to log file if it exists
			if (task["LogFilePath"] != System.DBNull.Value && !System.IO.File.Exists(System.IO.Path.Combine(DataImportDirectory, (string)task["LogFilePath"])))
				task["LogFilePath"] = null;

			var statusDetails = statusDetailsTable.Select("CustomBusinessDataUploadTaskID = " + task["CustomBusinessDataUploadTaskID"].ToString(), "StartDate");
			if (statusDetails != null && statusDetails.Length > 0)
			{
				var statusDetailsList = new System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>>();
				task.Add("StatusDetails", statusDetailsList);
				foreach (var d in statusDetails)
				{
					var da = GetAnonymousObject(d);
					da["StartDate"] = Flexera.Web.Core.Conversion.ToFriendlyString(Flexera.Web.Core.Conversion.FromTimeZone((System.DateTime)da["StartDate"], System.DateTimeKind.Local), showTime: true);
					statusDetailsList.Add(da);
				}
			}
		}

		bool hasAccessToOtherOperatorsTasks = false;
		// Set flag based on value from the first column in the first row of the returned table
		if (accessTable != null && accessTable.Rows.Count > 0)
			hasAccessToOtherOperatorsTasks = ((int)accessTable.Rows[0][0] != 0);

		return
			Json(
				new { 
					Uploads = result, 
					HasAccessToOtherOperatorsTasks = hasAccessToOtherOperatorsTasks,
					MonitorTaskRunning = IsMonitorTaskRunning
				}, 
				System.Web.Mvc.JsonRequestBehavior.AllowGet
			);
	}

	private bool IsMonitorTaskRunning
	{
		get
		{
			// Check monitor timestamp file has been touched in the last hour.
			// NB. If an import happens to run for more than an hour, the task will start to be reported as not running.
			string monitorRunningFile = System.IO.Path.Combine(DataImportDirectory, "MonitorAndProcessDataImportTasks.txt");
			return System.IO.File.GetLastWriteTime(monitorRunningFile) >= System.DateTime.Now.AddHours(-1);
		}
	}

	// Example URL: http://server/Suite/BusinessDataUploads/TaskStatusDetail?id=1046&r=true
	//
	// The value of r should be "true" (to show only rejected rows) or "false" (to show all rows)
	[Flexera.Web.Core.AccessRight("execute")]
	public System.Web.Mvc.ActionResult TaskStatusDetail(int id, bool r)
	{
		System.Data.DataSet statusSummary = BusinessDataDatabaseLayer.ExecuteQuery(
			"EXEC dbo.CustomBusinessDataUploadTaskStatusDetail @OperatorLogin, @CustomBusinessDataUploadTaskID, @RejectedOnly",
			new System.Collections.Generic.Dictionary<string, object>{
				{ "@OperatorLogin", ManageSoft.Identity.SystemIdentity.UserName },
				{ "@CustomBusinessDataUploadTaskID", id },
				{ "@RejectedOnly", r},
			}
		);

		System.Data.DataTable statusDetailTable = statusSummary.Tables[0];

		/*  
		 * Build an object which can be converted to a useful JSON structure for returning
		 * Example object shape:
		 *	[
		 *		{
		 *			ObjectName: "Create & Update Assets",
		 *			ObjectType: "Asset",
		 *			RecordNumber: 1,
		 *			RecordDescription: "Serial number XDZ62D",
		 *			Message: "Short description not specified",
		 *			Action: "Rejected",
		 *		},
		 *		...
		 *	]
		 */

		return Json(GetAnonymousObject(statusDetailTable), System.Web.Mvc.JsonRequestBehavior.AllowGet);
	}

	private static System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>> GetAnonymousObject(System.Data.DataTable dataTable)
	{
		var rows = new System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>>();
		foreach (System.Data.DataRow row in dataTable.Rows)
			rows.Add(GetAnonymousObject(row));

		return rows;
	}
	
	private static System.Collections.Generic.Dictionary<string, object> GetAnonymousObject(System.Data.DataRow row)
	{
		var d = new System.Collections.Generic.Dictionary<string, object>();
		foreach (System.Data.DataColumn col in row.Table.Columns)
			d.Add(col.ColumnName, row[col]);
			
		return d;
	}
	
	[Flexera.Web.Core.AccessRight("execute")]
	public System.Web.Mvc.ActionResult UploadDetails(int id)
	{
		return View("~/Views/DataInputs/UploadDetails.cshtml", id);
	}
	
	[Flexera.Web.Core.AccessRight("execute")]
	public System.Web.Mvc.ActionResult RenderUploadStatusSummary(System.Tuple<string, string> modelVariable)
	{
		return PartialView("~/Views/DataInputs/BusinessDataUploadStatusSummary.cshtml", modelVariable);
	}
}
