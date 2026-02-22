using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.IO.Compression;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using Microsoft.Win32;
using Microsoft.CSharp;
using System.CodeDom.Compiler;
using System.Diagnostics;
using System.Reflection;

namespace Crayon
{
  #region Class AppSettings
  /// <summary>
  /// Summary description for AppSettings static class
  /// </summary>    
  public static partial class AppSettings
  {
    #region Constants
    // ******************************************************
    // public constants
    // ******************************************************

    private const string c_RegistryKey = @"SOFTWARE\Crayon\FlexAdmin";
    private const string c_FlexeraFlexAdminRegistryKey = @"SOFTWARE\Flexera Software";    

    #endregion

    #region Enums
    // ******************************************************
    // public static enums
    // ******************************************************
    //
    public enum UnpackOptions { None = 0x00, Payload = 0x01, Scripts = 0x02, Actions = 0x04, Events = 0x08, Source = 0x10, ImplFiles = 0x20, VisualStudio = 0x40, Help = 0x80 };
    public static UnpackOptions unpackOptions = UnpackOptions.Payload | UnpackOptions.Scripts | UnpackOptions.Actions | UnpackOptions.Events;

    public enum EventOptions { None = 0x00, Pre = 0x01, Post = 0x02, Build = 0x10, Unpack = 0x20, DragAndDrop = 0x40, Exit = 0x80 };
    public static EventOptions eventOptions = EventOptions.None;

    #endregion

    #region Data    
    // ******************************************************
    // public static data
    // ******************************************************
        
    public static string appName = "Crayon";
    public static string appVersion = "1.0.0.0";    

    // ******************************************************
    // public static data
    // ******************************************************
    
    public static string tempFolder = String.Empty;    
    public static string workingFolder = String.Empty;
    public static string implFilesFolder = "C:\\ImplFiles";    
    //
    public static string flexAdminScriptFileName = "flexadmin.ps1";
    public static string scriptFileName = "script.ps1";
    public static string cmdFileName = "script.cmd";
    public static string sqlFileName = "script.sql";
    public static string contentFileName = String.Empty;
    //
    public static string settingsFileName = "fnms.settings";

    // ******************************************************
    // public static data
    // ******************************************************
    
    public static bool bLocked = c_Locked;
    public static bool bRequirePassword = c_RequirePassword;
    public static string unlockPassword = c_Password;
    //
    public static bool bCheckPayload = c_CheckPayload;    
    //
    public static bool bRunFromTemp = c_RunFromTemp;
    public static string runFromLocation = c_RunFromLocation;    
    //  
    //public static bool bUnpackSource = c_UnpackSource;
    //public static bool bUnpackSource = c_UnpackSource;
    //public static bool bUnpackScripts = c_UnpackScripts;
    //public static bool bUnpackPayload = c_UnpackPayload;
    //public static bool bUnpackVisualStudio = c_UnpackVisualStudio;
    //public static bool bUnpackActions = c_UnpackActions;
    //public static bool bUnpackEvents = c_UnpackEvents;    
    //
    public static bool bUnpackUnzip = c_UnpackUnzip;
    //
    public static string Editor = "notepad.exe";        
    public static bool bRedirectOutput = false;
    
    // ******************************************************
    // public static data
    // ******************************************************
    
    public static bool bEventsOnly = c_EventsOnly;
    public static bool bEventsHidden = true;    
    //
    public static bool bEventBUILD = c_EventBUILD;
    public static bool bEventUNPACK = c_EventUNPACK;    
    public static bool bEventPRE = c_EventPRE;
    public static bool bEventDROP = c_EventDROP;
    public static bool bEventPOST = c_EventPOST;
    public static bool bEventEXIT = c_EventEXIT;

    // ******************************************************
    // public static data
    // ******************************************************

    public static bool bPromptOverwrite = true;
    //
    //public static bool bSafeZip = false;

    // ******************************************************
    // public static data
    // ******************************************************

    public static string appLogFolder = c_LogFolder;
    public static string appLogFile = c_LogFile;

    // ******************************************************
    // public static data
    // ******************************************************

    public static bool sqlEnabled = false;
    //
    public static string sqlServer = c_Server;
    public static string sqlDatabase = c_Database;
    public static string sqlConnectionString = c_ConnectionString;
    //
    public static bool sqlMultiTenant = false;
    public static bool sqlUseTenantUID = false;
    public static int sqlTenantID = 0;
    public static string sqlTenantUID = "0000000000000000";
    
       
    // ******************************************************
    // public data
    // ******************************************************

    #endregion

    #region Accessors    
    // ******************************************************
    // data accessors
    // ******************************************************
  
    public static bool bUnpackPayload
    {
      get
      {
        bool value = ((int)unpackOptions & (int)UnpackOptions.Payload) > 0 ? true : false;
        return value;
      }
      set
      {
        if (value)
          unpackOptions = unpackOptions | UnpackOptions.Payload;
        else
          unpackOptions = (UnpackOptions)((int)unpackOptions & 0xFE);  // FE 1111-1110
      }
    }
   
    public static bool bUnpackScripts
    {
      get
      {
        bool value = ((int)unpackOptions & (int)UnpackOptions.Scripts) > 0 ?  true : false;
        return value;
      }
      set
      {
        if (value)
          unpackOptions = unpackOptions | UnpackOptions.Scripts;
        else
          unpackOptions = (UnpackOptions)((int)unpackOptions & 0xFD);   // FD 1111-1101
      }
    }
    
    public static bool bUnpackActions
    {
      get
      {
        bool value = ((int)unpackOptions & (int)UnpackOptions.Actions) > 0 ? true : false;
        return value;
      }
      set
      {
        if (value)
          unpackOptions = unpackOptions | UnpackOptions.Actions;
        else
          unpackOptions = (UnpackOptions)((int)unpackOptions & 0xFB);   // FB 1111-1011
      }
    }
   
    public static bool bUnpackEvents
    {
      get
      {
        bool value = ((int)unpackOptions & (int)UnpackOptions.Events) > 0 ? true : false;
        return value;
      }
      set
      {
        if (value)
          unpackOptions = unpackOptions | UnpackOptions.Events;
        else
          unpackOptions = (UnpackOptions)((int)unpackOptions & 0xF7);   // F7 1111-0111          
      }
    }
   
    public static bool bUnpackSource
    {
      get
      {
        bool value = ((int)unpackOptions & (int)UnpackOptions.Source) > 0 ? true : false;
        return value;
      }
      set
      {
        if (value)
          unpackOptions = unpackOptions | UnpackOptions.Source;
        else
          unpackOptions = (UnpackOptions)((int)unpackOptions & 0xEF);   // EF 1110-1111
      }
    }
   
    public static bool bUnpackImplFiles
    {
      get
      {
        bool value = ((int)unpackOptions & (int)UnpackOptions.ImplFiles) > 0 ? true : false;
        return value;
      }
      set
      {
        if (value)
          unpackOptions = unpackOptions | UnpackOptions.ImplFiles;
        else
          unpackOptions = (UnpackOptions)((int)unpackOptions & 0xDF);  // DF 1101-1111          
      }
    }
  
    public static bool bUnpackVisualStudio
    {
      get
      {
        bool value = ((int)unpackOptions & (int)UnpackOptions.VisualStudio) > 0 ? true : false;
        return value;
      }
      set
      {
        if (value)
          unpackOptions = unpackOptions | UnpackOptions.VisualStudio;
        else
          unpackOptions = (UnpackOptions)((int)unpackOptions & 0xBF);  // BF 1011-1111
      }
    }    
   
    public static bool bUnpackHelp
    {
      get
      {
        bool value = ((int)unpackOptions & (int)UnpackOptions.Help) > 0 ?  true : false;
        return value;
      }
      set
      {
        if (value)
          unpackOptions = unpackOptions | UnpackOptions.Help;
        else
          unpackOptions = (UnpackOptions)((int)unpackOptions & 0x7F);   // FD 0111-1111
      }
    }

    // ******************************************************
    // data accessors
    // ******************************************************

    public static string AssemblyName
    {
      get
      {
        // Name
        Assembly ass = Assembly.GetExecutingAssembly();
        string[] res = ass.GetManifestResourceNames();
        string[] nameparts = ass.GetName().Name.ToString().Split('_');      
        string name = nameparts[0]; 
        return name;
      }
    }

    public static string AssemblyTitle
    {
      get
      {
        // Title
        Assembly ass = Assembly.GetExecutingAssembly();
        System.Reflection.AssemblyTitleAttribute titleAttribute = (System.Reflection.AssemblyTitleAttribute) Attribute.GetCustomAttribute(ass, typeof(System.Reflection.AssemblyTitleAttribute));
        string title = titleAttribute.Title;
        return title;
      }
    }

    public static string AssemblyCompany
    {
      get
      {
        // Company
        Assembly ass = Assembly.GetExecutingAssembly();
        System.Reflection.AssemblyCompanyAttribute companyAttribute = (System.Reflection.AssemblyCompanyAttribute) Attribute.GetCustomAttribute(ass, typeof(System.Reflection.AssemblyCompanyAttribute));
        string company = companyAttribute.Company;
        return company;
      }
    }

    public static string AssemblyCopyright
    {
      get
      {
        // Copyright
        Assembly ass = Assembly.GetExecutingAssembly();
        System.Reflection.AssemblyCopyrightAttribute copyrightAttribute = (System.Reflection.AssemblyCopyrightAttribute) Attribute.GetCustomAttribute(ass, typeof(System.Reflection.AssemblyCopyrightAttribute));  
        string copyright = copyrightAttribute.Copyright;
        return copyright;
      }
    }

    public static string AssemblyVersion
    {
      get
      {
        // Version
        Assembly ass = Assembly.GetExecutingAssembly();
        string version = Assembly.GetExecutingAssembly().GetName().Version.ToString();
        return version;
      }
    }

    #endregion

    #region Registry Accessors (1)
    // ******************************************************
    // data accessors
    // ******************************************************

    public static bool rbLocked
    {
      get
      {
        bool value = GetRegKeyBoolValue("Locked", c_Locked);
        return value;
      }
      set
      {
        SetRegKeyBoolValue("Locked", value);        
      }
    }

    public static bool rbRequirePassword
    {
      get
      {
        bool value = GetRegKeyBoolValue("RequirePassword", c_RequirePassword);
        return value;
      }
      set
      {
        SetRegKeyBoolValue("RequirePassword", value); 
      }
    }

    public static string rstrUnlockPassword
    {
      get
      {
        string value = GetRegKeyStringValue("UnlockPassword", c_Password);
        return value;
      }
      set
      {
        SetRegKeyStringValue("UnlockPassword", value); 
      }
    }

    public static string rstrRunFromLocation
    {
      get
      {
        string value = GetRegKeyStringValue("RunFromLocation", "local");
        return value;
      }
      set
      {
        SetRegKeyStringValue("RunFromLocation", value); 
      }
    }

    // ******************************************************
    // data accessors
    // ******************************************************

    public static string rstrEditor
    {
      get
      {
        string value = GetRegKeyStringValue("Editor", "notepad.exe");
        return value;
      }
      set
      {
        SetRegKeyStringValue("Editor", value); 
      }
    }

    public static bool rbRedirectOutput
    {
      get
      {
        bool value = GetRegKeyBoolValue("RedirectOutput", false);
        return value;
      }
      set
      {
        SetRegKeyBoolValue("RedirectOutput", value); 
      }
    }

    // ******************************************************
    // data accessors
    // ******************************************************

    public static bool rbRunFromTemp
    {
      get
      {
        bool value = GetRegKeyBoolValue("RunFromTemp", c_RunFromTemp);
        return value;
      }
      set
      {
        SetRegKeyBoolValue("RunFromTemp", value);
      }
    }

    // ******************************************************
    // data accessors
    // ******************************************************

    public static bool rbUnpackSource
    {
      get
      {
        bool value = GetRegKeyBoolValue("UnpackSource", c_UnpackSource);
        return value;
      }
      set
      {
        SetRegKeyBoolValue("UnpackSource", value);   
      }
    }

    public static bool rbUnpackHelp
    {
      get
      {
        bool value = GetRegKeyBoolValue("UnpackHelp", c_UnpackHelp);
        return value;
      }
      set
      {
        SetRegKeyBoolValue("UnpackHelp", value);
      }
    }

    public static bool rbUnpackScripts
    {
      get
      {
        bool value = GetRegKeyBoolValue("UnpackScripts", c_UnpackScripts);
        return value;
      }
      set
      {
        SetRegKeyBoolValue("UnpackScripts", value);   
      }
    }

    public static bool rbUnpackPayload
    {
      get
      {
        bool value = GetRegKeyBoolValue("UnpackPayload", c_UnpackPayload);
        return value;
      }
      set
      {
        SetRegKeyBoolValue("UnpackPayload", value);   
      }
    }

    public static bool rbUnpackImplFiles
    {
      get
      {
        bool value = GetRegKeyBoolValue("UnpackImplFiles", c_UnpackImplFiles);
        return value;
      }
      set
      {
        SetRegKeyBoolValue("UnpackImplFiles", value);   
      }
    }

    public static bool rbUnpackVisualStudio
    {
      get
      {
        bool value = GetRegKeyBoolValue("UnpackVisualStudio", c_UnpackVisualStudio);
        return value;
      }
      set
      {
        SetRegKeyBoolValue("UnpackVisualStudio", value);   
      }
    }

    public static bool rbUnpackEvents
    {
      get
      {
        bool value = GetRegKeyBoolValue("UnpackEvents", c_UnpackEvents);
        return value;
      }
      set
      {
        SetRegKeyBoolValue("UnpackEvents", value);   
      }
    }

    // ******************************************************
    // data accessors
    // ******************************************************

    public static bool rbUnpackUnzip
    {
      get
      {
        bool value = GetRegKeyBoolValue("UnpackUnzip", c_UnpackUnzip);
        return value;
      }
      set
      {
        SetRegKeyBoolValue("UnpackUnzip", value);       
      }
    }

    #endregion

    #region Registry Accessors (2)
    // ******************************************************
    // data accessors
    // ******************************************************

    public static string rstrAppLogFile
    {
      get
      {
        string value = GetRegKeyStringValue("AppLogFile", String.Empty);
        return value;
      }
      set
      {
        SetRegKeyStringValue("AppLogFile", value);   
      }
    }

    public static string rstrAppLogFolder
    {
      get
      {
        string value = GetRegKeyStringValue("AppLogFolder", String.Empty);
        return value;
      }
      set
      {
        SetRegKeyStringValue("AppLogFolder", value);
      }
    }

    // ******************************************************
    // data accessors
    // ******************************************************

    public static string rstrImplFilesFolder
    {
      get
      {
        string value = GetRegKeyStringValue("ImplFilesFolder", "C:\\ImplFiles");
        return value;
      }
      set
      {
        SetRegKeyStringValue("ImplFilesFolder", value);
      }
    }

    #endregion

    #region Registry Accessors (3)
    // ******************************************************
    // data accessors
    // ******************************************************

    public static string rstrSettingsFileName
    {
      get
      {
        string value = GetRegKeyStringValue("SettingsFileName", "fnms.settings");
        return value;
      }
      set
      {
        SetRegKeyStringValue("SettingsFileName", value);   
      }
    }

    // ******************************************************
    // data accessors
    // ******************************************************

    public static string rstrScriptFileName
    {
      get
      {
        string value = GetRegKeyStringValue("ScriptFileName", "script.ps1");
        return value;
      }
      set
      {
        SetRegKeyStringValue("ScriptFileName", value);
      }
    }

    public static string rstrCmdFileName
    {
      get
      {
        string value = GetRegKeyStringValue("CmdFileName", "script.cmd");
        return value;
      }
      set
      {
        SetRegKeyStringValue("CmdFileName", value);
      }
    }

    public static string rstrSqlFileName
    {
      get
      {
        string value = GetRegKeyStringValue("SqlFileName", "script.sql");
        return value;
      }
      set
      {
        SetRegKeyStringValue("SqlFileName", value);
      }
    }

    public static string rstrFlexAdminScriptFileName
    {
      get
      {
        string value = GetRegKeyStringValue("FlexAdminScriptFileName", "flexadmin.ps1");
        return value;
      }
      set
      {
        SetRegKeyStringValue("FlexAdminScriptFileName", value);
      }
    }

    #endregion

    #region Registry Accessors (4)
    // ******************************************************
    // data accessors
    // ******************************************************

    public static bool rbSqlEnabled
    {
      get
      {
        bool value = GetRegKeyBoolValue("SqlEnabled", false);
        return value;
      }
      set
      {
        SetRegKeyBoolValue("SqlEnabled", value);       
      }
    }

    public static bool rbSqlMultiTenant
    {
      get
      {
        bool value = GetRegKeyBoolValue("SqlMultiTenant", false);
        return value;
      }
      set
      {
        SetRegKeyBoolValue("SqlMultiTenant", value);       
      }
    }

    public static bool rbSqlUseTenantUID
    {
      get
      {
        bool value = GetRegKeyBoolValue("SqlUseTenantUID", false);
        return value;
      }
      set
      {
        SetRegKeyBoolValue("SqlUseTenantUID", value);       
      }
    }

    public static int rnSqlTenantID
    {
      get
      {
        string value = GetRegKeyStringValue("SqlTenantID", "0");
        return Int32.Parse(value);
      }
      set
      {
        SetRegKeyStringValue("SqlTenantID", value.ToString());
      }
    }


    public static string rstrSqlTenantUID
    {
      get
      {
        string value = GetRegKeyStringValue("SqlTenantUID", "0000000000000000");
        return value;
      }
      set
      {
        SetRegKeyStringValue("SqlTenantUID", value);
      }
    }

    #endregion

    #region Registry Accessors (5)
    // ******************************************************
    // data accessors
    // ******************************************************

    public static string rstrFlexeraFlexAdminSettings
    {
      get
      {
        string value = GetHKCURegStringValue("FlexAdminSettings", "C:\\ImplFiles\fnms.settings", c_FlexeraFlexAdminRegistryKey);
        return value;
      }
      set
      {
        SetHKCURegStringValue("FlexAdminSettings", value, c_FlexeraFlexAdminRegistryKey);   
      }
    }
    
    #endregion
 
    #region Methods
    // ******************************************************
    // methods
    // ******************************************************
    
    public static void initialise()
    {
      AppSettings.CreateRegKeyHive(c_RegistryKey);
      AppSettings.CreateRegKeyHive(c_FlexeraFlexAdminRegistryKey);
      AppSettings.InitialiseFlexAdminSettingsKey("flexadmin.settings");
      //
      AppSettings.bLocked = AppSettings.rbLocked;
      AppSettings.bRedirectOutput = AppSettings.rbRedirectOutput;
      AppSettings.Editor = AppSettings.rstrEditor;
      //
      AppSettings.bRunFromTemp = AppSettings.rbRunFromTemp;
      AppSettings.runFromLocation = AppSettings.rstrRunFromLocation;      
      //
      AppSettings.bUnpackHelp = AppSettings.rbUnpackHelp;      
      AppSettings.bUnpackSource = AppSettings.rbUnpackSource;
      AppSettings.bUnpackScripts = AppSettings.rbUnpackScripts;
      AppSettings.bUnpackPayload = AppSettings.rbUnpackPayload;      
      AppSettings.bUnpackImplFiles = AppSettings.rbUnpackImplFiles;
      AppSettings.bUnpackVisualStudio = AppSettings.rbUnpackVisualStudio;
      AppSettings.bUnpackEvents = AppSettings.rbUnpackEvents;      
      //                  
      AppSettings.bUnpackUnzip = AppSettings.rbUnpackUnzip;                  
      //
      AppSettings.scriptFileName = AppSettings.rstrScriptFileName;
      //
      AppSettings.appLogFolder = AppSettings.rstrAppLogFolder;
      AppSettings.appLogFile = AppSettings.rstrAppLogFolder;
      //
      AppSettings.settingsFileName = AppSettings.rstrSettingsFileName;
      AppSettings.implFilesFolder = AppSettings.rstrImplFilesFolder;
      AppSettings.scriptFileName = AppSettings.rstrScriptFileName;
      AppSettings.cmdFileName = AppSettings.rstrCmdFileName;
      AppSettings.sqlFileName = AppSettings.rstrSqlFileName;      
      AppSettings.flexAdminScriptFileName = AppSettings.rstrFlexAdminScriptFileName;
      //
      AppSettings.sqlConnectionString = "";
      AppSettings.sqlEnabled = AppSettings.rbSqlEnabled;      
      AppSettings.sqlMultiTenant = AppSettings.rbSqlMultiTenant;
      AppSettings.sqlUseTenantUID = AppSettings.rbSqlUseTenantUID;
      AppSettings.sqlTenantID = AppSettings.rnSqlTenantID;
      AppSettings.sqlTenantUID = AppSettings.rstrSqlTenantUID;      
    }

    // ******************************************************
    // methods
    // ******************************************************
    
    public static void finalise()
    {
      AppSettings.rbLocked = AppSettings.bLocked;
      AppSettings.rbRedirectOutput = AppSettings.bRedirectOutput;
      AppSettings.rstrEditor = AppSettings.Editor;      
      //
      AppSettings.rbRunFromTemp = AppSettings.bRunFromTemp;
      AppSettings.rstrRunFromLocation = AppSettings.runFromLocation;
      //
      AppSettings.rbUnpackHelp = AppSettings.bUnpackHelp;      
      AppSettings.rbUnpackSource = AppSettings.bUnpackSource;
      AppSettings.rbUnpackScripts = AppSettings.bUnpackScripts;
      AppSettings.rbUnpackPayload = AppSettings.bUnpackPayload;
      AppSettings.rbUnpackImplFiles = AppSettings.bUnpackImplFiles;      
      AppSettings.rbUnpackVisualStudio = AppSettings.bUnpackVisualStudio;
      AppSettings.rbUnpackEvents = AppSettings.bUnpackEvents;      
      //                  
      AppSettings.rbUnpackUnzip = AppSettings.bUnpackUnzip;                  
      //
      AppSettings.rstrScriptFileName = AppSettings.scriptFileName;
      //
      AppSettings.rstrAppLogFolder = AppSettings.appLogFolder;
      AppSettings.rstrAppLogFile = AppSettings.appLogFolder;
      //
      AppSettings.rstrSettingsFileName = AppSettings.settingsFileName;
      AppSettings.rstrImplFilesFolder = AppSettings.implFilesFolder;
      AppSettings.rstrScriptFileName = AppSettings.scriptFileName;
      AppSettings.rstrCmdFileName = AppSettings.cmdFileName;
      AppSettings.rstrSqlFileName = AppSettings.sqlFileName;      
      AppSettings.rstrFlexAdminScriptFileName = AppSettings.flexAdminScriptFileName;
      //
      AppSettings.rbSqlEnabled = AppSettings.sqlEnabled;      
      AppSettings.rbSqlMultiTenant = AppSettings.sqlMultiTenant;
      AppSettings.rbSqlUseTenantUID = AppSettings.sqlUseTenantUID;
      AppSettings.rnSqlTenantID = AppSettings.sqlTenantID;      
      AppSettings.rstrSqlTenantUID = AppSettings.sqlTenantUID;
    }

    // ******************************************************
    // methods
    // ******************************************************

    public static bool InitialiseFlexAdminSettingsKey(string filename, string key=c_FlexeraFlexAdminRegistryKey, bool bit64=true)
    {
      RegistryView bit = RegistryView.Registry32;
      if (bit64) bit = RegistryView.Registry64;
      //
      RegistryKey bkcu = RegistryKey.OpenBaseKey(Microsoft.Win32.RegistryHive.CurrentUser, bit);
      RegistryKey rkcu = bkcu.OpenSubKey(key, true);
      if (rkcu != null)
      {      
        // the key already exists but has a value been set?
        string value = (string)rkcu.GetValue("FlexAdminSettings");
        if (value != null)
        {
          // a value exists so just return
          rkcu.Close();          
          return true;
        }
      }
      else
      {
        // check if the key hive needs to be created first
        rkcu = Registry.CurrentUser.OpenSubKey(key);
        if (rkcu == null)
        {
          rkcu = Registry.CurrentUser.CreateSubKey(key);
          if (rkcu == null)
          {
            throw new Exception(string.Format("Registry key '{0}' does not exist", key));
          }
        }
      }
      // so we now have a key but no setting value
      // see if there is one set in the local machine registry
      RegistryKey bklm = RegistryKey.OpenBaseKey(Microsoft.Win32.RegistryHive.LocalMachine, bit);
      RegistryKey rklm = bklm.OpenSubKey(key, true);
      if (rklm == null)
      {
        // a local machine key does not exist so create a default current user key
        rkcu.SetValue("FlexAdminSettings", Path.Combine(workingFolder, filename));
      }
      else
      {
        // a local machine key exists so lets see if we can get a value
        string value = (string)rklm.GetValue("FlexAdminSettings");
        if (value != null)
        {
          // a value was found so lets use it
          rkcu.SetValue("FlexAdminSettings", value);
        }
        else
        {
          // a key value does not exist in either context so create a default
          rkcu.SetValue("FlexAdminSettings", Path.Combine(workingFolder, filename));
        }
      }          
      rklm.Close();
      rkcu.Close();
      //
      return true;
    }

    #endregion
 
    #region Registry methods (1)
    // ******************************************************
    // registry bool methods
    // ******************************************************

    public static bool GetRegKeyBoolValue(string name, bool def=false)
    {
      bool value = def;
      string sv = AppSettings.GetRegKeyStringValue(name, def.ToString());
      value = Boolean.Parse(sv);
      return value;
    }

    public static void SetRegKeyBoolValue(string name, bool value)
    {
      AppSettings.SetRegKeyStringValue(name, value.ToString());
    }

    // ******************************************************
    // registry string methods
    // ******************************************************

    public static string GetRegKeyStringValue(string name, string defaultvalue="")
    {
      RegistryKey rk = Registry.CurrentUser.OpenSubKey(c_RegistryKey, true);
      if (rk == null)
      {
        throw new Exception(string.Format("Registry key '{0}' does not exist", c_RegistryKey));
      }
      string value = (string)rk.GetValue(name);
      if (value == null)
      {
        rk.SetValue(name, defaultvalue);
        AppSettings.SetRegKeyStringValue(name, defaultvalue);
        value = defaultvalue;
      }
      rk.Close();
      //
      return value;
    }

    public static void SetRegKeyStringValue(string name, string value)
    {
      RegistryKey rk = Registry.CurrentUser.OpenSubKey(c_RegistryKey, true);
      if (rk == null)
      {
        throw new Exception(string.Format("Registry key '{0}' does not exist", c_RegistryKey));
      }
      rk.SetValue(name, value);
      rk.Close();
    }

    public static void DeleteRegKeyValue(string name)
    {
      RegistryKey rk = Registry.CurrentUser.OpenSubKey(c_RegistryKey, true);
      if (rk == null)
      {
        throw new Exception(string.Format("Registry key '{0}' does not exist", c_RegistryKey));
      }
      rk.DeleteValue(name);
      rk.Close();
    }

    #endregion
 
    #region Registry methods (2)
    // ******************************************************
    // registry string methods
    // ******************************************************

    public static string GetHKCURegStringValue(string name, string defaultvalue="", string key=c_RegistryKey, bool bit64=true)
    {
      RegistryView bit = RegistryView.Registry32;
      if (bit64) bit = RegistryView.Registry64;
      //
      RegistryKey bk = RegistryKey.OpenBaseKey(Microsoft.Win32.RegistryHive.CurrentUser, bit);
      RegistryKey rk = bk.OpenSubKey(key, true);
      if (rk == null)
      {
        throw new Exception(string.Format("Registry key '{0}' does not exist", key));
      }
      string value = (string)rk.GetValue(name);
      if (value == null)
      {
        rk.SetValue(name, defaultvalue);
        AppSettings.SetRegKeyStringValue(name, defaultvalue);
        value = defaultvalue;
      }
      rk.Close();
      //
      return value;
    }

    public static void SetHKCURegStringValue(string name, string value, string key=c_RegistryKey, bool bit64=true)
    {
      RegistryView bit = RegistryView.Registry32;
      if (bit64) bit = RegistryView.Registry64;
      //
      RegistryKey bk = RegistryKey.OpenBaseKey(Microsoft.Win32.RegistryHive.CurrentUser, bit);
      RegistryKey rk = bk.OpenSubKey(key, true);
      if (rk == null)
      {
        throw new Exception(string.Format("Registry key '{0}' does not exist", key));
      }
      rk.SetValue(name, value);
      rk.Close();
    }

    public static void DeleteHKCURegValue(string name, string key=c_RegistryKey, bool bit64=true)
    {
      RegistryView bit = RegistryView.Registry32;
      if (bit64) bit = RegistryView.Registry64;
      //
      RegistryKey bk = RegistryKey.OpenBaseKey(Microsoft.Win32.RegistryHive.CurrentUser, bit);
      RegistryKey rk = bk.OpenSubKey(key, true);
      if (rk == null)
      {
        throw new Exception(string.Format("Registry key '{0}' does not exist", key));
      }
      rk.DeleteValue(name);
      rk.Close();
    }

    #endregion
 
    #region Registry methods (3)
    // ******************************************************
    // registry string methods
    // ******************************************************

    public static string GetHKLMRegStringValue(string name, string defaultvalue="", string key=c_RegistryKey, bool bit64=true)
    {
      RegistryView bit = RegistryView.Registry32;
      if (bit64) bit = RegistryView.Registry64;
      //
      RegistryKey bk = RegistryKey.OpenBaseKey(Microsoft.Win32.RegistryHive.LocalMachine, bit);
      RegistryKey rk = bk.OpenSubKey(key, true);
      if (rk == null)
      {
        throw new Exception(string.Format("Registry key '{0}' does not exist", key));
      }
      string value = (string)rk.GetValue(name);
      if (value == null)
      {
        rk.SetValue(name, defaultvalue);
        AppSettings.SetRegKeyStringValue(name, defaultvalue);
        value = defaultvalue;
      }
      rk.Close();
      //
      return value;
    }

    public static void SetHKLMRegStringValue(string name, string value, string key=c_RegistryKey, bool bit64=true)
    {
      RegistryView bit = RegistryView.Registry32;
      if (bit64) bit = RegistryView.Registry64;
      //
      RegistryKey bk = RegistryKey.OpenBaseKey(Microsoft.Win32.RegistryHive.LocalMachine, bit);
      RegistryKey rk = bk.OpenSubKey(key, true);
      if (rk == null)
      {
        throw new Exception(string.Format("Registry key '{0}' does not exist", key));
      }
      rk.SetValue(name, value);
      rk.Close();
    }

    public static void DeleteHKLMRegValue(string name, string key=c_RegistryKey, bool bit64=true)
    {
      RegistryView bit = RegistryView.Registry32;
      if (bit64) bit = RegistryView.Registry64;
      //
      RegistryKey bk = RegistryKey.OpenBaseKey(Microsoft.Win32.RegistryHive.LocalMachine, bit);
      RegistryKey rk = bk.OpenSubKey(key, true);
      if (rk == null)
      {
        throw new Exception(string.Format("Registry key '{0}' does not exist", key));
      }
      rk.DeleteValue(name);
      rk.Close();
    }

    #endregion
 
    #region Registry methods (4)
    // ******************************************************
    // registry key methods
    // ******************************************************

    public static void CreateRegKeyHive(string key=c_RegistryKey)
    {
      RegistryKey rk = Registry.CurrentUser.OpenSubKey(key);
      if (rk == null)
      {
        rk = Registry.CurrentUser.CreateSubKey(key);
        if (rk == null)
        {
          throw new Exception(string.Format("Registry key '{0}' does not exist", key));
        }
      }
    }

    public static void CreateRegKeySubKey(string subkeyname, string key=c_RegistryKey)
    {
      string subkey = String.Format("{0}\\{1}", key, subkeyname);
      RegistryKey rk = Registry.CurrentUser.OpenSubKey(subkey);
      if (rk == null)
      {
        rk = Registry.CurrentUser.CreateSubKey(subkey);
        if (rk == null)
        {
          throw new Exception(string.Format("Registry key '{0}' does not exist", subkey));
        }
      }
    }

    #endregion
  }
  
  #endregion

}
