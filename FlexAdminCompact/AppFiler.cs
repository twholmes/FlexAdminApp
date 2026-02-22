using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.IO.Compression;
//using System.IO.Compression.FileSystem;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using System.Xml;
using System.Xml.Serialization;

using Microsoft.CSharp;
using System.CodeDom.Compiler;
using System.Diagnostics;
using System.Reflection;

namespace Crayon
{ 
  #region Class AppFiler

  /// <summary>
  /// Summary description for AppFiler class
  /// </summary>    
  public static class AppFiler
  {
    #region Data    
    // ******************************************************
    // public static data
    // ******************************************************
        
    public static bool bSource = false;
    public static bool bHelp = false;
    public static bool bScripts = false;    
    public static bool bImplFiles = false;
    public static bool bPayload = false;    
    public static bool bEvents = false;
    public static bool bActions = false;    
    public static bool bVisualStudio = false;
 
    #endregion
 
    #region Accessors   
    // ******************************************************
    // public accessors
    // ******************************************************
    

    #endregion

    #region Write code methods
    // ******************************************************
    // write code methods
    // ******************************************************

    public static bool WriteProgramSource(string appName, string appVersion, bool bLocked, bool full=true)
    {
      try
      {
        string source = String.Empty;
        source += "using System;\n";
        source += "using System.Collections.Generic;\n";
        source += "using System.Linq;\n";
        source += "using System.Threading.Tasks;\n";
        source += "using System.Windows.Forms;\n";
        source += "using System.Reflection;\n";
        source += "\n";
        source += String.Format("[assembly: AssemblyTitle(\"{0}\")]\n", appName);
        
        source += String.Format("[assembly: AssemblyVersion(\"{0}\")]\n", appVersion);
        source += String.Format("[assembly: AssemblyFileVersion(\"{0}\")]\n", appVersion);      
        
        source += "[assembly: AssemblyDescription(\"Run FlexAdmin scripting Framework\")]\n";
        source += "[assembly: AssemblyConfiguration(\"\")]\n";
        source += "[assembly: AssemblyCompany(\"Crayon Australia\")]\n";
        source += String.Format("[assembly: AssemblyProduct(\"{0}\")]\n", appName);
        source += "[assembly: AssemblyCopyright(\"Copyright ©  2019 Crayon Auatralia\")]\n";
        source += "[assembly: AssemblyTrademark(\"\")]\n";
        source += "[assembly: AssemblyCulture(\"\")]\n";
        source += "\n";
        source += "namespace Crayon\n";
        source += "{\n";
        source += "  static class Program\n";
        source += "  {\n";
        source += "    [STAThread]\n";
        source += "    static void Main()\n";
        source += "    {\n";
        source += "      try\n";
        source += "      {\n";
        source += "        Assembly ass = Assembly.GetExecutingAssembly();\n";
        source += "        string[] nameparts = ass.GetName().Name.ToString().Split('_');\n";
        source += "        string appname = nameparts[0];\n";
        source += "        //\n";
        source += "        Application.EnableVisualStyles();\n";
        source += "        Application.SetCompatibleTextRenderingDefault(false);\n";
        if (full) source += "        Application.Run(new AppForm(appname));\n";
        else source += "        Application.Run(new AppSmallForm(appname));\n";
        source += "      }\n";
        source += "      catch (Exception ex)\n";
        source += "      {\n";
        source += "        MessageBox.Show(ex.Message, \"FlexAdmin(main)\", MessageBoxButtons.OK, MessageBoxIcon.Error);\n";        
        source += "      }\n";        
        source += "    }\n";
        source += "  }\n";
        source += "\n";        
        source += "  static partial class AppSettings\n";
        source += "  {\n";       
        source += "    // locking\n";
        source += String.Format("    public const bool c_Locked = {0};\n", bLocked.ToString().ToLower());
        source += String.Format("    public const bool c_RequirePassword = {0};\n", AppSettings.bRequirePassword.ToString().ToLower());
        source += String.Format("    public const string c_Password = \"{0}\";\n", AppSettings.unlockPassword.ToString().ToLower());                
        source += "\n";
        source += "    // modes\n";
        source += String.Format("    public const bool c_RunFromTemp = {0};\n", AppSettings.bRunFromTemp.ToString().ToLower());
        source += String.Format("    public const string c_RunFromLocation = \"{0}\";\n", AppSettings.runFromLocation);        
        source += "\n";
        source += "    // unpack\n";
        source += String.Format("    public const bool c_UnpackHelp = {0};\n", AppSettings.bUnpackHelp.ToString().ToLower());
        source += String.Format("    public const bool c_UnpackSource = {0};\n", AppSettings.bUnpackSource.ToString().ToLower());
        source += String.Format("    public const bool c_UnpackScripts = {0};\n", AppSettings.bUnpackScripts.ToString().ToLower());
        source += String.Format("    public const bool c_UnpackPayload = {0};\n", AppSettings.bUnpackPayload.ToString().ToLower());
        source += String.Format("    public const bool c_UnpackImplFiles = {0};\n", AppSettings.bUnpackImplFiles.ToString().ToLower());        
        source += String.Format("    public const bool c_UnpackVisualStudio = {0};\n", AppSettings.bUnpackVisualStudio.ToString().ToLower());
        source += String.Format("    public const bool c_UnpackEvents = {0};\n", AppSettings.bUnpackEvents.ToString().ToLower());        
        source += "\n";        
        source += String.Format("    public const bool c_UnpackUnzip = {0};\n", AppSettings.bUnpackUnzip.ToString().ToLower());
        source += "\n";
        source += "    // events\n";
        source += String.Format("    public const bool c_EventsOnly = {0};\n", AppSettings.bEventsOnly.ToString().ToLower());        
        source += String.Format("    public const bool c_EventBUILD = {0};\n", AppSettings.bEventBUILD.ToString().ToLower());
        source += String.Format("    public const bool c_EventUNPACK = {0};\n", AppSettings.bEventUNPACK.ToString().ToLower());
        source += String.Format("    public const bool c_EventDROP = {0};\n", AppSettings.bEventDROP.ToString().ToLower());                
        source += String.Format("    public const bool c_EventPRE = {0};\n", AppSettings.bEventPRE.ToString().ToLower());
        source += String.Format("    public const bool c_EventPOST = {0};\n", AppSettings.bEventPOST.ToString().ToLower());
        source += String.Format("    public const bool c_EventEXIT = {0};\n", AppSettings.bEventEXIT.ToString().ToLower());
        source += "\n";        
        source += "    // logging constants\n";
        source += String.Format("    public const string c_LogFolder = @\"{0}\";\n", AppSettings.appLogFolder);
        source += String.Format("    public const string c_LogFile = @\"{0}\";\n", AppSettings.appLogFile);        
        source += "\n";        
        source += "    // sql constants\n";
        source += String.Format("    public const string c_Server = \"{0}\";\n", AppSettings.sqlServer);
        source += String.Format("    public const string c_Database = \"{0}\";\n", AppSettings.sqlDatabase);     
        source += String.Format("    public const string c_ConnectionString = \"{0}\";\n", AppSettings.sqlConnectionString);
        source += "\n";        
        source += "  }\n";
        source += "}\n";        
        System.IO.File.WriteAllText(String.Format("{0}\\Program.cs", AppSettings.workingFolder), source);
      }
      catch (Exception ex)
      {
        MessageBox.Show(ex.Message, appName, MessageBoxButtons.OK, MessageBoxIcon.Error);
        return false;
      }
      return true;
    }

    #endregion

    #region Write script methods
    // ******************************************************
    // write script methods
    // ******************************************************

    public static void WriteShellScriptForCommandShell(string scriptFileName, string args, bool pause=true)
    {
      string sourceFileName = Path.Combine(AppSettings.workingFolder, scriptFileName);      
      string generatedFileName = Path.Combine(AppSettings.workingFolder, "generated.cmd");
      Logger.WriteLog(String.Format("write generated script from ... {0}", scriptFileName));
      if (pause)
        System.IO.File.Copy(sourceFileName, generatedFileName, true);
      else
      {    
        string content = System.IO.File.ReadAllText(sourceFileName);
        if (content.Length > 0)
        {
          content = content.Replace("pause","");
          System.IO.File.WriteAllText(generatedFileName, content);
        }
      }
    }

    // ******************************************************
    // write script methods
    // ******************************************************

    public static void WriteShellScriptForPowerShell(string scriptFileName, string args, bool pause=true)
    {
      // make sure the WorkingFolder doesnt have a trailing "\"
      string workingFolder = AppSettings.workingFolder;
      if (workingFolder.EndsWith("\\")) workingFolder = workingFolder.Remove(workingFolder.Length - 1, 1);
      //
      string content = String.Empty;
      content += "@ECHO OFF\n";
      content += "REM Autogenerated by FlexAdmin to run a used supplied script\n";
      content += String.Format("REM Source script was {0}\n", scriptFileName);
      content += String.Format("REM Working Folder was {0}\n", workingFolder);      
      content += String.Format("REM Created at {0}\n", DateTime.Now.ToString(@"dd/MM/yyyy HH:mm"));      
      content += "\n";
      content += "REM Change to directory containing this file\n";
      content += "CD /D %~dp0\n";
      content += "\n";
      content += "REM Run the PowerShell command line as Admin\n";
      content += String.Format("PowerShell -NoProfile -ExecutionPolicy Bypass \"& .\\{0} {1} -FlexAdminPath {2}\"\n", scriptFileName, args, workingFolder);
      content += "\n";
      if (pause) content += "pause\n";
      //
      string generatedFileName = Path.Combine(AppSettings.workingFolder, "generated.cmd");
      Logger.WriteLog(String.Format("write generated script from ... {0}", scriptFileName));
      System.IO.File.WriteAllText(generatedFileName, content);
    }

    // ******************************************************
    // write script methods
    // ******************************************************

    public static void WriteShellScriptForSQL(string server, string database, string scriptFileName, string args, bool pause=true)
    {
      string content = String.Empty;
      content += "@ECHO OFF\n";
      content += "REM Autogenerated by ScriptRunner to run a used supplied script\n";
      content += String.Format("REM Source script was {0}\n", scriptFileName);      
      content += String.Format("REM Created at {0}\n", DateTime.Now.ToString(@"dd/MM/yyyy HH:mm"));
      content += "\n";
      content += "REM Change to directory containing this file\n";
      content += "CD /D %~dp0\n";
      content += "\n";
      content += "REM Run the SQL command line as Admin\n";
      content += String.Format("sqlcmd.exe -S {0} -d {1} -e -i {2}\n", server, database, scriptFileName, args);
      content += "\n";
      if (pause) content += "pause\n";
      //
      string generatedFileName = Path.Combine(AppSettings.workingFolder, "generated.cmd");
      Logger.WriteLog(String.Format("write generated script from ... {0}", scriptFileName));
      System.IO.File.WriteAllText(generatedFileName, content);
    }

    #endregion

    #region Write test methods
    // ******************************************************
    // write test methods
    // ******************************************************

    public static void WriteShellScriptForTest(string scriptFileName, string args, bool pause=true)
    {
      string content = String.Empty;
      content += "@ECHO OFF\n";
      content += "REM Autogenerated by FlexAdmin to run a used supplied script\n";
      content += "REM Source script was [Test]\n";
      content += String.Format("REM Created at {0}\n", DateTime.Now.ToString(@"dd/MM/yyyy HH:mm"));      
      content += "\n";
      content += "REM Change to directory containing this file\n";
      content += "CD /D %~dp0\n";
      content += "\n";
      content += ":Loop\n";
      content += "IF \"%1\"==\"\" GOTO Continue\n";
      content += "ECHO arg1 = %1\n";
      content += "\n";
      content += "IF \"%2\"==\"\" GOTO Continue\n";
      content += "ECHO arg2 = %2\n";
      content += "\n";
      content += "IF \"%3\"==\"\" GOTO Continue\n";
      content += "ECHO arg3 = %3\n";
      content += "\n";
      content += ":Continue\n";
      content += "\n";      
      content += "REM Run the PowerShell command line as Admin\n";
      content += String.Format("PowerShell -NoProfile -ExecutionPolicy Bypass \"& .\\{0} {1}\"\n", scriptFileName, args);
      content += "\n";
      if (pause) content += "pause\n";
      //
      string generatedFileName = Path.Combine(AppSettings.workingFolder, "script.cmd");
      Logger.WriteLog("write generated script from ... [Test]");
      System.IO.File.WriteAllText(generatedFileName, content);
    }

    // ******************************************************
    // write test methods
    // ******************************************************

    public static void WritePowerShellScriptForTest(string scriptFileName, string args)
    {
      string content = String.Empty;
      content += "###########################################################################\n";
      content += "# Copyright (C) 2020 Crayon Australia\n";
      content += "###########################################################################\n";
      content += "\n";
      content += "param (\n";
      content += "  [string]$arg1 = \"*.*\"\n";
      content += ")\n";
      content += "\n";
      content += "$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path\n";
      content += "\n";
      content += "###########################################################################\n";
      content += "# Mainline: demo script\n";
      content += "#\n";
      content += "\n";
      content += "dir $($arg1)\n";
      content += "\n";
      //
      string generatedFileName = Path.Combine(AppSettings.workingFolder, scriptFileName);
      Logger.WriteLog("write generated script from ... [Default]");
      System.IO.File.WriteAllText(generatedFileName, content);
    }

    // ******************************************************
    // write test methods
    // ******************************************************

    public static void WriteSqlScriptForTest(string args)
    {
      string content = String.Empty;
      content += "---------------------------------------------------------------------------\n";
      content += "-- Copyright (C) 2020 Crayon Australia\n";
      content += "---------------------------------------------------------------------------\n";
      content += "\n";
      content += "PRINT 'SQL Server Version is: ' + @@version\n";
      content += "\n";
      content += "DECLARE @FnmsVersion nvarchar(10)\n";
      content += "SELECT @FnmsVersion = Value FROM DataBaseConfiguration where Property like 'CMSchemaVersion'\n";
      content += "PRINT 'FNMS Version is: ' + @FnmsVersion\n";
      content += "PRINT ''\n";      
      content += "\n";
      content += "-- cursor to print list of tenants\n";
      content += "DECLARE @TenantID int\n";
      content += "DECLARE @TenantUID nvarchar(20)\n";
      content += "DECLARE @TenantName nvarchar(256)\n";
      content += "DECLARE @TenantComment nvarchar(128)\n";
      content += "\n";
      content += "DECLARE c CURSOR FOR SELECT TenantID, TenantUID, TenantName, Comments FROM dbo.Tenant\n";
      content += "OPEN c\n";
      content += "\n";
      content += "FETCH NEXT FROM c INTO @TenantID, @TenantUID, @TenantName, @TenantComment\n";
      content += "WHILE @@FETCH_STATUS = 0\n";
      content += "BEGIN\n";
      content += "  PRINT N'TENANT-' + convert(nvarchar(2),@TenantID) + N' UID=' + ISNULL(@TenantUID,'') + N' COMMENTS=' + ISNULL(@TenantComment,'')\n";      
      content += "  PRINT @TenantName\n";
      content += "  PRINT ''\n";
      content += "  --EXEC dbo.SetTenantID @TenantID\n";
      content += "\n";
      content += "  FETCH NEXT FROM c INTO @TenantID, @TenantUID, @TenantName, @TenantComment\n";
      content += "END\n";
      content += "\n";
      content += "CLOSE c\n";
      content += "DEALLOCATE c\n";
      content += "\n";
      //
      string generatedFileName = Path.Combine(AppSettings.workingFolder, "script.sql");
      Logger.WriteLog("write generated script from ... [Default]");
      System.IO.File.WriteAllText(generatedFileName, content);
    }

    #endregion

    #region Write default methods
    // ******************************************************
    // write default methods
    // ******************************************************

    public static void WriteDefaultShellScript(string scriptFileName, string args, bool pause=true)
    {
      string content = String.Empty;
      content += "@ECHO OFF\n";
      content += "REM Autogenerated by FlexAdmin to run the default flexadmin.ps1 script\n";
      content += "REM Source script was [Default]\n";
      content += String.Format("REM Created at {0}\n", DateTime.Now.ToString(@"dd/MM/yyyy HH:mm"));      
      content += "\n";
      content += "REM Change to directory containing this file\n";
      content += "CD /D %~dp0\n";
      content += "\n";
      content += ":Loop\n";
      content += "IF \"%1\"==\"\" GOTO Continue\n";
      content += "ECHO arg1 = %1\n";
      content += "\n";
      content += "IF \"%2\"==\"\" GOTO Continue\n";
      content += "ECHO arg2 = %2\n";
      content += "\n";
      content += "IF \"%3\"==\"\" GOTO Continue\n";
      content += "ECHO arg3 = %3\n";
      content += "\n";
      content += ":Continue\n";
      content += "\n";      
      content += "REM Run the PowerShell command line as admin\n";
      content += String.Format("PowerShell -NoProfile -ExecutionPolicy Bypass \"& .\\{0} {1}\"\n", scriptFileName, args);
      content += "\n";
      if (pause) content += "pause\n";
      //
      string generatedFileName = Path.Combine(AppSettings.workingFolder, "script.cmd");
      Logger.WriteLog("write generated script from ... [Default]");
      System.IO.File.WriteAllText(generatedFileName, content);
    }

    // ******************************************************
    // write default methods
    // ******************************************************

    public static void WriteDefaultPowerShellScript(string scriptFileName, string args)
    {
      string content = String.Empty;
      content += "###########################################################################\n";
      content += "# Copyright (C) 2020 Crayon Australia\n";
      content += "###########################################################################\n";
      content += "\n";
      content += "param (\n";
      content += "  [string]$arg1 = \"*.*\"\n";
      content += ")\n";
      content += "\n";
      content += "$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path\n";
      content += "\n";
      content += "###########################################################################\n";
      content += "# Mainline: demo script\n";
      content += "#\n";
      content += "\n";
      content += "dir $($arg1)\n";
      content += "\n";
      //
      string generatedFileName = Path.Combine(AppSettings.workingFolder, scriptFileName);
      Logger.WriteLog("write generated script from ... [Test]");
      System.IO.File.WriteAllText(generatedFileName, content);
    }

    // ******************************************************
    // write default methods
    // ******************************************************

    public static void WriteDefaultSqlScript(string args)
    {
      string content = String.Empty;
      content += "---------------------------------------------------------------------------\n";
      content += "-- Copyright (C) 2020 Crayon Australia\n";
      content += "---------------------------------------------------------------------------\n";
      content += "\n";
      content += "select @@version\n";
      content += "\n";
      //
      string generatedFileName = Path.Combine(AppSettings.workingFolder, "script.sql");
      Logger.WriteLog("write generated script from ... [Default]");
      System.IO.File.WriteAllText(generatedFileName, content);
    }

    #endregion

    #region Unpack methods
    // ******************************************************
    // unpack main methods
    // ******************************************************

    public static bool Clear()
    {
      if (AppSettings.bRunFromTemp)
      {
        Directory.Delete(AppSettings.tempFolder,true);
        Directory.CreateDirectory(AppSettings.tempFolder);
      }
      bSource = false;
      bHelp = false;      
      bScripts = false;
      bPayload = false;
      bEvents = false; 
      bImplFiles = false;           
      bVisualStudio = false;
      //
      return true;
    }

    // ******************************************************
    // unpack main methods
    // ******************************************************

    public static bool UnpackHelp()
    {
      // unpack help resources
      bool available1 = UnpackAppSourceResource("readme.txt");
      if (!available1)
      {
        available1 = UnpackZippedResource("readme.txt");       
      }      
      AppConsole.Write("... readme.txt");
      bool available2 = UnpackAppSourceResource("runner.txt");
      if (!available2)
      {
        available2 = UnpackZippedResource("runner.txt");       
      }
      AppConsole.Write("... runner.txt");      
      if (!available1 || !available2)
      {
        System.Windows.Forms.MessageBox.Show("One or more of the Help files are not available", "AppFiler", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
      }
      bHelp = true;
      return true;
    }

    public static bool UnpackScripts()
    {
      // unpack script resources
      bool available1 = CheckUnpackScript("script.cmd", true); AppConsole.Write("... script.cmd");
      bool available2 = CheckUnpackScript("script.ps1", true); AppConsole.Write("... script.ps1");
      bool available3 = CheckUnpackScript("script.sql", true); AppConsole.Write("... script.sql");
      if (!available1 || !available2 || !available3)
      {
        System.Windows.Forms.MessageBox.Show("One or more of the Script files are not available", "AppFiler", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
      }
      bScripts = true;
      return true;
    }

    public static bool UnpackEvents(bool read = false)
    {
      // unpack events resources
      bool available = UnpackAppSourceResource("events.xml");      
      if (!available)
      {
        available = UnpackZippedResource("events.xml");
      } 
      AppConsole.Write("... events.xml");
      if (!available)
      {
        System.Windows.Forms.MessageBox.Show("the events file is not available", "AppFiler", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
      }
      bEvents = true;      
      return true;
    }

    public static bool UnpackActions(bool read = false)
    {
      // unpack events resources
      bool available = UnpackAppSourceResource("actions.xml");      
      if (!available)
      {
        available = UnpackZippedResource("actions.xml");
      } 
      AppConsole.Write("... actions.xml");
      if (!available)
      {
        System.Windows.Forms.MessageBox.Show("the actions file is not available", "AppFiler", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
      }
      bActions = true;      
      return true;
    }

    public static bool UnpackSource()
    {
      // unpack binary resources
      bool available0 = UnpackAppSourceResource("crayon.png");
      if (!available0)
      {
        available0 = UnpackZippedResource("crayon.png");
      }      
      AppConsole.Write("... crayon.png");
      bool available1 = UnpackAppSourceResource("file.png");
      if (!available1)
      {
        available1 = UnpackZippedResource("file.png");
      }      
      AppConsole.Write("... file.png");      
      bool available2 = UnpackAppSourceResource("cmd.png");
      if (!available2)
      {
        available2 = UnpackZippedResource("cmd.png");
      }
      AppConsole.Write("... cmd.png");      
      bool available3 = UnpackAppSourceResource("ps.png");
      if (!available3)
      {
        available3 = UnpackZippedResource("ps.png");
      }
      AppConsole.Write("... ps.png");      
      bool available4 = UnpackAppSourceResource("sql.png");
      if (!available4)
      {
        available4 = UnpackZippedResource("sql.png");
      }
      AppConsole.Write("... sql.png");      
      // create the prograce source file
      bool available5 = AppFiler.WriteProgramSource(AppSettings.appName, AppSettings.appVersion, AppSettings.bLocked);
      //
      // unpack app source resources
      bool available6 = false, available7 = false, available8 = false, available9 = false, available10 = false, available11 = false, available12 = false;
      bool available13 = false, available14 = false, available15 = false, available16 = false;      
      available6 = UnpackZippedResource("AppCompact.cs");
      if (available6) 
      { 
        // updates source is available so unpack the other files
        available7 = UnpackZippedResource("AppCompact.Designer.cs");
        available8 = UnpackZippedResource("AppSettings.cs");
        available9 = UnpackZippedResource("AppSettings.Designer.cs");
        available10 = UnpackZippedResource("AppFiler.cs");
        available11 = UnpackZippedResource("AppFiler.Designer.cs");
        available12 = UnpackZippedResource("AppBuilder.cs");
        available13 = UnpackZippedResource("AppBuilder.Designer.cs");
        available14 = UnpackZippedResource("AppLogger.cs");
        available15 = UnpackZippedResource("AppEvents.cs");
        available16 = UnpackZippedResource("AppActions.cs");        
        //
        AppConsole.Write("... AppCompact.cs");
        AppConsole.Write("... AppCompact.Designer.cs");
        AppConsole.Write("... AppSettings.cs");
        AppConsole.Write("... AppSettings.Designer.cs");        
        AppConsole.Write("... AppFiler.cs");
        AppConsole.Write("... AppFiler.Designer.cs");        
        AppConsole.Write("... AppBuilder.cs");
        AppConsole.Write("... AppBuilder.Designer.cs");        
        AppConsole.Write("... AppLogger.cs");
        AppConsole.Write("... AppEvents.cs");
        AppConsole.Write("... AppActions.cs");                
      }
      else
      {
        // need to use origional source
        available6 = AppFiler.UnpackVisualStudio(true);
      }      
      if (!available0 || !available1 || !available2 || !available3 || !available4 || !available5 || !available6)
      {
        System.Windows.Forms.MessageBox.Show("One or more of the Source files are not available", "AppFiler", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
      }
      bSource = true;
      return true;
    }

    public static bool UnpackPayload(bool unzip = false)
    {
      // unpack payload resources
      bool available1 = UnpackAppSourceResource("payload.zip");      
      if (!available1)
      {
        available1 = UnpackZippedResource("payload.zip");
      } 
      AppConsole.Write("... payload.zip");
      if (available1)
      {
        string zipPath = Path.Combine(AppSettings.workingFolder, "payload.zip");
        if (unzip || AppSettings.bUnpackUnzip) AppFiler.ExtractToDirectory(zipPath, AppSettings.workingFolder, true);
      }
      else      
      {
        System.Windows.Forms.MessageBox.Show("One or more of the Payload files are not available", "AppFiler", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
      }
      bPayload = true;      
      return true;
    }

    public static bool UnpackImplFiles(bool unzip = false)
    {
      // unpack payload resources
      bool available1 = UnpackAppSourceResource("implfiles.zip");      
      if (!available1)
      {
        available1 = UnpackZippedResource("implfiles.zip");
      } 
      AppConsole.Write("... implfiles.zip");
      if (available1)
      {
        string zipPath = Path.Combine(AppSettings.workingFolder, "implfiles.zip");
        if (unzip || AppSettings.bUnpackUnzip) AppFiler.ExtractToDirectory(zipPath, AppSettings.workingFolder, true);
      }
      else      
      {
        System.Windows.Forms.MessageBox.Show("One or more of the ImplFiles files are not available", "AppFiler", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
      }
      bPayload = true;      
      return true;
    }

    public static bool UnpackVisualStudio(bool unzip = false)
    {
      // unpack VisualStudio resources
      bool available1 = UnpackAppSourceResource("visualstudio.zip");      
      if (!available1)
      {
        available1 = UnpackZippedResource("visualstudio.zip");
      } 
      if (available1)
      {
        string zipPath = Path.Combine(AppSettings.workingFolder, "visualstudio.zip");
        if (unzip || AppSettings.bUnpackUnzip) AppFiler.ExtractToDirectory(zipPath, AppSettings.workingFolder, true);        
      }
      else      
      {
        System.Windows.Forms.MessageBox.Show("One or more of the VisualStudio files are not available", "AppFiler", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
      }
      bVisualStudio = true;      
      return true;
    }

    // ******************************************************
    // unpack main methods
    // ******************************************************

    public static bool CheckUnpackScript(string script, bool checkOverwrite=false)
    {
      bool found = false;
      string [] fileEntries = Directory.GetFiles(AppSettings.workingFolder, script);
      if (fileEntries.Length > 0) found = true;
      if (found)
      {
        if (checkOverwrite)
        {
          DialogResult dialogResult = MessageBox.Show(String.Format("{0} found. Replace?", script), AppSettings.appName, MessageBoxButtons.YesNo);
          if (dialogResult == DialogResult.No)
          {
            return false;
          }
        }
      }
      // unpack script resource
      bool available = AppFiler.UnpackAppSourceResource(script);
      if (!available)
      {
        available = AppFiler.UnpackZippedResource(script);       
      }      
      return available;
    }

    // ******************************************************
    // unpack main methods
    // ******************************************************

    public static void ExtractToDirectory(string zipPath, string destinationDirectoryName, bool overwrite)
    {
      if (!overwrite)
      {
        ZipFile.ExtractToDirectory(zipPath, destinationDirectoryName);
        return;
      }
      DirectoryInfo di = Directory.CreateDirectory(destinationDirectoryName);
      string destinationDirectoryFullPath = di.FullName;
      using (System.IO.Compression.ZipArchive archive = ZipFile.Open(zipPath, ZipArchiveMode.Update))
      {          
        string destfolder = destinationDirectoryFullPath;
        foreach (ZipArchiveEntry file in archive.Entries)
        {
          string completeFileName = Path.GetFullPath(Path.Combine(destinationDirectoryFullPath, file.FullName));
          if (!completeFileName.StartsWith(destinationDirectoryFullPath, StringComparison.OrdinalIgnoreCase))
          {
            throw new IOException("Trying to extract file outside of destination directory. See this link for more info: https://snyk.io/research/zip-slip-vulnerability");
          }
          destfolder = Path.GetDirectoryName(completeFileName);
          if (String.IsNullOrEmpty(file.Name) || !Directory.Exists(destfolder))
          { // assuming Empty for Directory in the zip list, or the new target sub-directory does not exist
            Directory.CreateDirectory(destfolder);
            if (String.IsNullOrEmpty(file.Name)) continue;
          }
          file.ExtractToFile(completeFileName, true);
        }
      }
    }

    #endregion
       
    #region Unpack resource methods
    // ******************************************************
    // unpack resource methods
    // ******************************************************

    public static bool UnpackAppSourceResource(string name, bool quiet=true)
    {
      Assembly ass = Assembly.GetExecutingAssembly();
      string[] res = ass.GetManifestResourceNames();
      //
      try
      {
        string resname = String.Format("Crayon.{0}", name);
        Stream rs = ass.GetManifestResourceStream(resname);
        if (rs == null)
        {
          if (!quiet) MessageBox.Show(String.Format("Resource {0} not found", resname), ass.GetName().Name, MessageBoxButtons.OK, MessageBoxIcon.Error);
          return false;
        }
        string path = Path.Combine(AppSettings.workingFolder, Path.GetFileName(name));
        using (Stream file = File.Create(path))
        {
          for (int b = rs.ReadByte(); b != -1; b = rs.ReadByte())
          {
            file.WriteByte((byte)b);
          }
        }
      }
      catch (Exception ex)
      {
        MessageBox.Show(ex.Message, ass.GetName().Name, MessageBoxButtons.OK, MessageBoxIcon.Error);
        return false;
      }
      return true;
    }

    public static bool UnpackZippedResource(string name, bool quiet=true)
    {
      Assembly ass = Assembly.GetExecutingAssembly();
      string[] res = ass.GetManifestResourceNames();
      //
      try
      {
        string resname = String.Format("Crayon.{0}.gz", name);       
        Stream rs = ass.GetManifestResourceStream(resname);
        if (rs == null)
        {
          if (!quiet) MessageBox.Show(String.Format("Resource {0} not found", resname), ass.GetName().Name, MessageBoxButtons.OK, MessageBoxIcon.Error);
          return false;
        }
        using (Stream gzip = new GZipStream(rs, CompressionMode.Decompress, true))
        {
          string path = Path.Combine(AppSettings.workingFolder, name); 
          path.Replace("Crayon.","");
          //
          using (Stream file = File.Create(path))
          {
            for (int b = gzip.ReadByte(); b != -1; b = gzip.ReadByte())
            {
              file.WriteByte((byte)b);
            }
          }
        }
      }
      catch (Exception ex)
      {
        MessageBox.Show(ex.Message, ass.GetName().Name, MessageBoxButtons.OK, MessageBoxIcon.Error);
        return false;
      }
      return true;
    }

    // ******************************************************
    // unpack resource methods
    // ******************************************************
   
    public static void ExtractPicture(Assembly ass, PictureBox pb, string type="ps")
    {
      // must load this here or the recompile wont work
      string[] res = ass.GetManifestResourceNames();
      Stream rs = ass.GetManifestResourceStream(String.Format("Crayon.{0}.png", type));
      if (rs != null)
        pb.Image = new Bitmap(rs);
      else
      {
        // also try for a zipped resource
        rs = ass.GetManifestResourceStream(String.Format("Crayon.{0}.png.gz", type));
        if (rs == null)
        {
          MessageBox.Show(String.Format("Resource Crayon.{0}.png.gz not found", type), ass.GetName().Name, MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        else          
        {
          Stream gzip = new GZipStream(rs, CompressionMode.Decompress, true);
          if (gzip != null)          
            pb.Image = new Bitmap(gzip);      
          else
          {
            MessageBox.Show(String.Format("Resource Crayon.{0}.png.gz was not decompressed", type), ass.GetName().Name, MessageBoxButtons.OK, MessageBoxIcon.Error);
          }
        }
      }
    }

    #endregion
    
  }

  #endregion

  #region Class IconFileInfo
  /// <summary>
  /// Summary description for IconFileInfo class
  /// </summary>    
  public class IconFileInfo
  {
    // ******************************************************
    // private data
    // ******************************************************
        
    private FileInfo fi;
    private Icon icon;

    public bool IsSubFolder = false;
    public string BaseFolder = string.Empty;

    // ******************************************************
    // constructors
    // ******************************************************
    
    public IconFileInfo(string filename)
    {
      fi = new FileInfo(filename);
      if (!Directory.Exists(filename))
        icon = Icon.ExtractAssociatedIcon(filename);
      else
      {
        this.IsSubFolder = true;
      }
    }
    
    public IconFileInfo(string filename, string basefolder)
    {
      fi = new FileInfo(filename);
      if (!Directory.Exists(filename))
        icon = Icon.ExtractAssociatedIcon(filename);
      else
      {
        this.IsSubFolder = true;
      }
      this.BaseFolder = basefolder;
    }
        
    // ******************************************************
    // public accessors
    // ******************************************************
    
    public string Name { get { return fi.Name; } }
    public string Extension { get { return Path.GetExtension(fi.FullName); } }
    public string FullName { get { return fi.FullName; } }
    public string DirectoryName { get { return fi.DirectoryName; } }    
    public DateTime Date { get { return fi.LastWriteTime; } }
    //
    public long Size
    {
      get 
      { 
        if (this.IsSubFolder) return 0;
        return fi.Length; 
      } 
    }    
    //
    public bool IsFolder { get { return IsSubFolder; } }    
    public Icon Icon 
    { 
      get 
      { 
        if (IsFolder) return null;
        return icon;
      } 
    }    
  }

  #endregion

  #region Class ZipManifest

  /// <summary>
  /// Summary description for ZipManifest class
  /// </summary>    
  public class ZipManifest
  {
    #region ZipManifest data    
    // ******************************************************
    // public data
    // ******************************************************

    public string Name = String.Empty;
    public string zipFilename = String.Empty;
    //
    public BindingList<IconFileInfo> files = new BindingList<IconFileInfo>();
    
    // ******************************************************
    // private data
    // ******************************************************
   
 
    #endregion

    #region ZipManifest constructors
    // ******************************************************
    // constructors
    // ******************************************************
    
    public ZipManifest(string name)
    {
      this.Name = name;
      this.zipFilename = String.Format("{1}\\{0}.zip", name, Directory.GetCurrentDirectory());  
    }
 
    #endregion
 
    #region ZipManifest accessors   
    // ******************************************************
    // public accessors
    // ******************************************************
    
    #endregion
    
    #region ZipManifest methods
    // ******************************************************
    // CRUD routines
    // ******************************************************

    public void Add(string filename, string basefolder="")
    {
      files.Add(new IconFileInfo(filename, basefolder));
    }

    public void AddFilesFromFolder(string foldername)
    {
      string[] files = Directory.GetFiles(foldername, "*.*", SearchOption.AllDirectories);      
      foreach (string filename in files)
      {
        this.Add(filename, foldername);
      }
    }

    // ******************************************************
    // Read routines
    // ******************************************************

    /// <summary>
    /// ReadManifest
    /// </summary>
    /// <param name="filename"></param>

    public int ReadManifest(string filename)
    {
      int count = 0;
      try
      {  
        // create the XmlDocument
        XmlDocument doc = new XmlDocument();
        doc.Load(filename); 
        //
        // read archive settings
        XmlNode archivenode = doc.DocumentElement.SelectSingleNode("/Crayon/archive");
        if (archivenode != null)
        {
           string value = archivenode.Attributes["name"].Value;
           if (value != null) Name = value;          
        }
        DataSet ds = new DataSet("archive");
        //
        XmlNode root = doc.DocumentElement;
        XmlNode node = doc.SelectSingleNode(@"//files");       
        if (node == null)
        {
        }
        string outer = @"<?xml version=""1.0"" encoding=""utf-8""?>";
        outer += @"<files>";        
        outer += NodeToString(node, 2);
        outer += @"</files>";
        //
        XmlDocument filesdoc = new XmlDocument();
        filesdoc.Load(new StringReader(outer));
        //
        System.Data.XmlReadMode mode = ds.ReadXml(XmlReader.Create(new StringReader(outer)), XmlReadMode.InferSchema);
        //
        DataTable dt = ds.Tables[0];
        if (dt != null)
        {
          count = dt.Rows.Count;
          
          string fn = String.Empty;
          foreach (DataRow dr in dt.Rows)
          {
            fn = dr[3].ToString();
            this.Add(fn);
          }
        }        
        //
      }
      catch (Exception ex) 
      {
        System.Windows.Forms.MessageBox.Show(ex.Message, "ReadManifest", MessageBoxButtons.OK, MessageBoxIcon.Error);       
        return -1;
      }
      return count;
    }
    
    /// <summary>
    /// Convert an XmlNode to a string
    /// </summary>
    /// <param name="node"></param>
    /// <param name="indentation"></param>
    /// <returns></returns>

    public string NodeToString(System.Xml.XmlNode node, int indentation)
    {
      using (var sw = new System.IO.StringWriter())
      {
        using (var xw = new System.Xml.XmlTextWriter(sw))
        {
          xw.Formatting = System.Xml.Formatting.Indented;
          xw.Indentation = indentation;
          node.WriteContentTo(xw);
        }
        return sw.ToString();
      }
    }
    
    // ******************************************************
    // Write routines
    // ******************************************************

    /// <summary>
    /// WriteManifest
    /// </summary>
    /// <param name="nameArchive"></param>

    public int WriteManifest(string folder, string nameArchive="payload")
    {
      int count = 0;
      try
      {
        using (System.IO.StreamWriter file = new System.IO.StreamWriter(String.Format("{0}\\manifest.xml", folder)))
        {
          string line = String.Empty;
          file.WriteLine("<?xml version=\"1.0\" standalone=\"yes\"?>");
          file.WriteLine(@"<Crayon>");
          file.WriteLine(String.Format("  <archive name=\"{0}\" updated=\"{1}\">", nameArchive, DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss")));
          file.WriteLine(@"    <files>");
          foreach (IconFileInfo f in files)
          {
            count++;
            line = String.Format("      <file id=\"{0}\" name=\"{1}\" extension=\"{2}\" source=\"{3}\" size=\"{4}\" date=\"{5}\" />", count, f.Name, f.Extension, f.FullName, f.Size, f.Date);
            file.WriteLine(line);
          }
          file.WriteLine(@"    </files>");
          file.WriteLine(@"  </archive>");
          file.WriteLine(@"</Crayon>");
        }
      }
      catch (Exception ex) 
      {
        System.Windows.Forms.MessageBox.Show(ex.Message, "WriteManifest", MessageBoxButtons.OK, MessageBoxIcon.Error);
        return -1;
      }
      return count;
    }

    // ******************************************************
    // Pack routines
    // ******************************************************

    /// <summary>
    /// Pack Zip
    /// </summary>
    /// <param name="nameArchive"></param>

    public int Pack(string zipFileName, bool bCopySourceToWorking=false)
    { 
      int count = 0;
      try
      {
        string tempFolder = Path.Combine(Path.GetTempPath(), Path.GetRandomFileName());
        Directory.CreateDirectory(tempFolder);
        // 
        string zf = Path.Combine(AppSettings.workingFolder, zipFileName);        
        foreach (IconFileInfo f in files)
        {
          count++;
          if (f.BaseFolder == String.Empty)
          {
            // simple case of file copy to root folder
            string df = Path.Combine(tempFolder, f.Name);
            File.Copy(f.FullName, df);
          }
          else
          {
            // need to derive a sub-folder path
            string offset = f.DirectoryName.Replace(String.Format("{0}\\", f.BaseFolder), "");
            string dp = Path.Combine(tempFolder, offset);           
            string df = Path.Combine(dp, f.Name);
            Directory.CreateDirectory(dp);
            File.Copy(f.FullName, df);
          }
        }
        WriteManifest(tempFolder);
        //
        ZipFile.CreateFromDirectory(tempFolder, zf);        
        Directory.Delete(tempFolder, true);        
        System.Windows.Forms.MessageBox.Show(Path.GetFileName(this.zipFilename) + " packed successfully.", "Packed", MessageBoxButtons.OK, MessageBoxIcon.Information);
      }
      catch (Exception ex)
      {
        System.Windows.Forms.MessageBox.Show(ex.Message, "ZipPacker", MessageBoxButtons.OK, MessageBoxIcon.Error);
        return -1;
      }
      return 0;
    }

    #endregion
    
  }

  #endregion

}
