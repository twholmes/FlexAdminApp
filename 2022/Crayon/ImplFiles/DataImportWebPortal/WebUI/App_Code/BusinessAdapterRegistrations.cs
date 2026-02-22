// Copyright (C) 2015 Flexera Software

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml.Serialization;

/// <summary>
/// This class holds the details of a business adapter to be registered with
/// the business adapter portal module.
/// </summary>
public class BusinessAdapterRegistration
{
	#region Public Properties
	/// <summary>
	/// The name of the business adapter import definition.  This name is passed
	/// to MGSBI.
	/// </summary>
	[XmlElement("ImportName")]
	public string ImportName = string.Empty;

	/// <summary>
	/// The name of the MGSBI XML configuration file in which the import
	/// is defined.
	/// </summary>
	[XmlElement("ConfigFile")]
	public string ConfigFile = string.Empty;

	/// <summary>
	/// The name of the template import file. This file must exist
	/// in the same folder as the business adapter registration XML file.
	/// </summary>
	[XmlElement("TemplateFileName")]
	public string TemplateFileName = string.Empty;

	/// <summary>
	/// Gets the full path to the adapter template data file.
	/// </summary>
	public string TemplateFileFullPath
	{
		get { return string.IsNullOrEmpty(this.TemplateFileName) ? null : Path.Combine(this.AdapterFullPath, this.TemplateFileName); }
	}

	/// <summary>
	/// The text to be displayed on the portal that describes the template
	/// file.
	/// </summary>
	[XmlElement("TemplateFileHyperlinkDescription")]
	public string TemplateFileHyperlinkDescription = string.Empty;

	/// <summary>
	/// The expected file extension. For example: "xls". This is used to validate whether the uploaded
	/// file is of the correct type.
	/// </summary>
	[XmlElement("UploadFileType")]
	public string UploadFileType = string.Empty;

	/// <summary>
	/// A friendly name for the import.  This is displayed in the import selection
	/// drop down list box.
	/// </summary>
	[XmlElement("DisplayName")]
	public string DisplayName = string.Empty;

	/// <summary>
	/// A detailed description of the importer to be displayed on the portal page.
	/// </summary>
	[XmlElement("DisplayDescription")]
	public string DisplayDescription = string.Empty;

	/// <summary>
	/// Text to be displayed on the import button. For example: "Update" or "Import"
	/// </summary>
	[XmlElement("ImportButtonText")]
	public string ImportButtonText = string.Empty;

	/// <summary>
	/// The label text that is displayed next to the file upload text box.
	/// </summary>
	[XmlElement("SelectFileLabel")]
	public string SelectFileLabel = string.Empty;

	/// <summary>
	/// The full path of the adapter folder. This is automatically populated with the folder
	/// that the BusinessAdapterRegistration.xml file is found in.
	/// </summary>
	[XmlIgnoreAttribute]
	public string AdapterFullPath = string.Empty;

	/// <summary>
	/// The relative path of the adapter folder below the Adapters folder.
	/// This is automatically populated with the folder that the BusinessAdapterRegistration.xml
	/// file is found in.
	/// </summary>
	[XmlIgnoreAttribute]
	public string AdapterSubdirectory = string.Empty;
	#endregion
}

public class BusinessAdapterRegistrations: List<BusinessAdapterRegistration>
{
	private const string cBusinessAdaptersFolder = "Adapters";
	public const string BusinessAdapterRegistrationConfigFile = "AdapterRegistration.xml";
	private const string cAllRegistrationsCacheKey = "BusinessAdapterRegistrations";

	private static readonly Flexera.Common.Logging.ILogger mLogger = Flexera.Common.Logging.LogManager.GetLogger("Flexera.Custom.BusinessDataUploads");

	private static string FullBusinessAdaptersFolderPath
	{
		get { return System.Web.HttpContext.Current.Server.MapPath("~/" + cBusinessAdaptersFolder); }
	}

	public static BusinessAdapterRegistrations AllRegistrations
	{
		get
		{
			BusinessAdapterRegistrations rs = System.Web.HttpContext.Current.Cache[cAllRegistrationsCacheKey] as BusinessAdapterRegistrations;

			if (rs == null) {
				rs = LoadAllFromDirectory(FullBusinessAdaptersFolderPath);

				// Cache the registration list, with a dependency on the registration XML files
				// so that the cached value is refreshed after any registration XML file is changed.

				var cd = new System.Web.Caching.AggregateCacheDependency();
				foreach (var r in rs)
					cd.Add(new System.Web.Caching.CacheDependency(Path.Combine(r.AdapterFullPath, BusinessAdapterRegistrationConfigFile)));

				System.Web.HttpContext.Current.Cache.Insert(
					cAllRegistrationsCacheKey, rs, cd,
					System.Web.Caching.Cache.NoAbsoluteExpiration,
					System.Web.Caching.Cache.NoSlidingExpiration,
					System.Web.Caching.CacheItemPriority.Normal,
					null
				);
			}

			return rs;
		}
	}

	private static BusinessAdapterRegistrations LoadAllFromDirectory(string directory)
	{
		var registrations = new BusinessAdapterRegistrations();

		if (Directory.Exists(directory))
		{
			mLogger.Info(string.Format("Searching for business adapters under {0}", directory));
			foreach (string subFolder in Directory.GetDirectories(directory))
			{
				string configFile = Path.Combine(subFolder, BusinessAdapterRegistrationConfigFile);

				if (File.Exists(configFile))
				{
					DirectoryInfo subFolderInfo = new DirectoryInfo(subFolder);
					mLogger.Info("Retrieving adapter registration information from {0}\\{1}", subFolderInfo.Name, BusinessAdapterRegistrationConfigFile);

					using (FileStream xmlFile = File.OpenRead(configFile))
					{
						XmlSerializer ser = new XmlSerializer(typeof(BusinessAdapterRegistration));
						BusinessAdapterRegistration newBAR = (BusinessAdapterRegistration)ser.Deserialize(xmlFile);
						xmlFile.Close();

						newBAR.AdapterFullPath = subFolder;
						newBAR.AdapterSubdirectory = subFolderInfo.Name;

						registrations.Add(newBAR);
					}
				}
			}

			mLogger.Info("Searching complete");
		}

		return registrations;
	}

	public BusinessAdapterRegistration this[string adapterSubdirectory]
	{
		get { return this.Where(r => r.AdapterSubdirectory == adapterSubdirectory).FirstOrDefault(); }
	}
}
