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

namespace BlackBox
{
  #region Class AppBuilder
  /// <summary>
  /// Summary description for AppBuilder class
  /// </summary>    
  static class AppBuilder
  {
    #region AppBuilder data    
    // ******************************************************
    // protected data
    // ******************************************************
   
    // Source file of standalone exe (local = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)
    private static string sourceName0 = String.Empty;    
    private static string sourceName1 = String.Empty;
    private static string sourceName2 = String.Empty;
    private static string sourceName3 = String.Empty;
    private static string sourceName4 = String.Empty;
    private static string sourceName5 = String.Empty;
    private static string sourceName6 = String.Empty;
    private static string sourceName7 = String.Empty;
    private static string sourceName8 = String.Empty;
    private static string sourceName9 = String.Empty;
    private static string sourceName10 = String.Empty;
    private static string sourceName11 = String.Empty;
    private static string sourceName12 = String.Empty;
    private static string sourceName13 = String.Empty;
    private static string sourceName14 = String.Empty;
    private static string sourceName15 = String.Empty;
    private static string sourceName16 = String.Empty;
    private static string sourceName17 = String.Empty;
    private static string sourceName18 = String.Empty;
    private static string sourceName19 = String.Empty;

    // Compressed files ready to embed as resource
    private static List<string> filenames = new List<string>();
    
    // ******************************************************
    // public data
    // ******************************************************

    public static bool bBuildLocked = true;
    public static bool bRequirePassword = false;
    public static string unlockPassword = "crayon"; 
    //    
    public static bool bRunFromTemp = true;
    public static string runFromLocation = "local"; 
    //    
    public static bool bUnpackSource = true;   
    
    // ******************************************************
    // public data
    // ******************************************************

    // the working folder contaiing all source files
    public static string compilerFolder = String.Empty;
    public static string outputAssembly = String.Empty;
    //
    // status 
    public static string Error = String.Empty;

    #endregion

    #region AppBuilder initialise
    // ******************************************************
    // initialise
    // ******************************************************

    public static void Initialise()
    {
      Initialise(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location));
    }

    public static void Initialise(string folder)
    {
      AppBuilder.compilerFolder = folder;
      AppBuilder.outputAssembly = String.Empty;
      //
      AppBuilder.sourceName0 = Path.Combine(AppBuilder.compilerFolder, "Program.cs");
      AppBuilder.sourceName1 = Path.Combine(AppBuilder.compilerFolder, "AppCompact.cs");
      AppBuilder.sourceName2 = Path.Combine(AppBuilder.compilerFolder, "AppCompact.Designer.cs");
      //
      AppBuilder.sourceName3 = Path.Combine(AppBuilder.compilerFolder, "AppSettings.cs");      
      AppBuilder.sourceName4 = Path.Combine(AppBuilder.compilerFolder, "AppLogger.cs");
      AppBuilder.sourceName5 = Path.Combine(AppBuilder.compilerFolder, "AppRunner.cs");
      AppBuilder.sourceName6 = Path.Combine(AppBuilder.compilerFolder, "AppActions.cs");
      AppBuilder.sourceName7 = Path.Combine(AppBuilder.compilerFolder, "AppEvents.cs");      
      AppBuilder.sourceName8 = Path.Combine(AppBuilder.compilerFolder, "AppFiler.cs");
      AppBuilder.sourceName9 = Path.Combine(AppBuilder.compilerFolder, "AppSQL.cs");
      
      AppBuilder.sourceName10 = Path.Combine(AppBuilder.compilerFolder, "AppBuilder.cs");
      AppBuilder.sourceName11 = Path.Combine(AppBuilder.compilerFolder, "AppConsole.cs");      
      //      
      AppBuilder.sourceName12 = Path.Combine(AppBuilder.compilerFolder, "AppSettingsForm.cs");
      AppBuilder.sourceName13 = Path.Combine(AppBuilder.compilerFolder, "AppSettingsForm.Designer.cs");
      AppBuilder.sourceName14 = Path.Combine(AppBuilder.compilerFolder, "AppFilerForm.cs");
      AppBuilder.sourceName15 = Path.Combine(AppBuilder.compilerFolder, "AppFilerForm.Designer.cs");
      //
      AppBuilder.sourceName16 = Path.Combine(AppBuilder.compilerFolder, "AppEnterForm.cs");
      AppBuilder.sourceName17 = Path.Combine(AppBuilder.compilerFolder, "AppEnterForm.Designer.cs");
      //
      AppBuilder.sourceName18 = Path.Combine(AppBuilder.compilerFolder, "AppBuilderForm.cs");
      AppBuilder.sourceName19 = Path.Combine(AppBuilder.compilerFolder, "AppBuilderForm.Designer.cs");
    }

    public static void Dispose()
    {
      foreach (string path in filenames)
      {
        File.Delete(path);
      }
      filenames.Clear();
    }
    
    #endregion

    #region AppBuilder main methods
    // ******************************************************
    // main methods
    // ******************************************************
 
    public static bool PrepareSource(bool bBuildLocked)
    {
      try
      {
        // include app icons
        AppBuilder.AddFileAsEmbeddedResource("crayon.png", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("file.png", AppBuilder.compilerFolder);          
        AppBuilder.AddFileAsEmbeddedResource("cmd.png", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("ps.png", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("sql.png", AppBuilder.compilerFolder); 
        //
        // include 
        AppBuilder.AddFileAsEmbeddedResource("AppSettings.cs", AppBuilder.compilerFolder);        
        AppBuilder.AddFileAsEmbeddedResource("AppLogger.cs", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("AppConsole.cs", AppBuilder.compilerFolder);           
        AppBuilder.AddFileAsEmbeddedResource("AppRunner.cs", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("AppActions.cs", AppBuilder.compilerFolder);        
        AppBuilder.AddFileAsEmbeddedResource("AppEvents.cs", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("AppFiler.cs", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("AppSQL.cs", AppBuilder.compilerFolder);   
        //
        // include other UI elements
        AppBuilder.AddFileAsEmbeddedResource("AppCompact.cs", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("AppCompact.Designer.cs", AppBuilder.compilerFolder);      
        //
        AppBuilder.AddFileAsEmbeddedResource("AppFilerForm.cs", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("AppFilerForm.Designer.cs", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("AppBuilderForm.cs", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("AppBuilderForm.Designer.cs", AppBuilder.compilerFolder);
        //
        AppBuilder.AddFileAsEmbeddedResource("AppSettingsForm.cs", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("AppSettingsForm.Designer.cs", AppBuilder.compilerFolder);
        //
        AppBuilder.AddFileAsEmbeddedResource("AppEnterForm.cs", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("AppEnterForm.Designer.cs", AppBuilder.compilerFolder);
        //
        // additional full app elements
        AppBuilder.AddFileAsEmbeddedResource("AppBuilder.cs", AppBuilder.compilerFolder);                  
        //
        AppBuilder.WriteProgramSource(AppSettings.appName, AppSettings.appVersion, AppBuilder.bBuildLocked);
        //
        // include events processing
        AppBuilder.AddFileAsEmbeddedResource("actions.xml", AppBuilder.compilerFolder);        
        AppBuilder.AddFileAsEmbeddedResource("events.xml", AppBuilder.compilerFolder);
        //
        // include initial scripts and content
        AppBuilder.AddFileAsEmbeddedResource("script.cmd", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("script.ps1", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("script.sql", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("readme.txt", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("runner.txt", AppBuilder.compilerFolder);          
        AppBuilder.AddFileAsEmbeddedResource("payload.zip", AppBuilder.compilerFolder);
        AppBuilder.AddFileAsEmbeddedResource("implfiles.zip", AppBuilder.compilerFolder);        
        //
        // include visual studio source
        AppBuilder.AddFileAsEmbeddedResource("visualstudio.zip", AppBuilder.compilerFolder);
      }
      catch (Exception ex)
      {
        System.Windows.Forms.MessageBox.Show(ex.Message, "Compile", MessageBoxButtons.OK, MessageBoxIcon.Error);
        return false;
      }
      return true;
    }

    // ******************************************************
    // main methods - full build
    // ******************************************************

    public static bool Build(string appName, string appVersion, string runOption="script")
    {
      string appShortVersion = appVersion.Replace(".","");
      string outputFolder = Directory.GetCurrentDirectory(); 
      //
      Assembly ass = Assembly.GetExecutingAssembly();
      outputFolder = Path.GetDirectoryName(ass.Location);       
      //      
      CodeDomProvider csc = new CSharpCodeProvider();
      CompilerParameters cp = new CompilerParameters();
      //
      cp.GenerateExecutable = true;
      cp.OutputAssembly = String.Format("{0}_rev{1}.exe", appName, appShortVersion);
      cp.CompilerOptions = "/target:winexe";
      //
      // Generate debug information.
      cp.IncludeDebugInformation = true;
      //      
      // Custom option to run a script embdedded in the manifest definitions after extraction  
      if (runOption.ToLower() == "script")
      {
        cp.CompilerOptions += " /define:RUN_SCRIPT";
      }
      //if (!string.IsNullOrEmpty(iconFilename))
      //{
      //  cp.CompilerOptions += " /win32icon:" + iconFilename;
      //}
      cp.ReferencedAssemblies.Add("System.dll");
      cp.ReferencedAssemblies.Add("System.Core.dll");      
      cp.ReferencedAssemblies.Add("System.Windows.Forms.dll");
      cp.ReferencedAssemblies.Add("System.ComponentModel.dll");
      cp.ReferencedAssemblies.Add("System.Text.Encoding.dll");      
      cp.ReferencedAssemblies.Add("System.Drawing.dll");      
      cp.ReferencedAssemblies.Add("System.Data.dll");
      cp.ReferencedAssemblies.Add("System.Xml.dll");
      cp.ReferencedAssemblies.Add("System.Xml.Linq.dll");      
      cp.ReferencedAssemblies.Add("System.Deployment.dll");
      cp.ReferencedAssemblies.Add("System.IO.Compression.dll");      
      cp.ReferencedAssemblies.Add("System.IO.Compression.ZipFile.dll");
      cp.ReferencedAssemblies.Add("System.IO.Compression.FileSystem.dll");
      //
      cp.ReferencedAssemblies.Add("Microsoft.CSharp.dll");        
      //
      // Add compressed files as resource
      cp.EmbeddedResources.AddRange(filenames.ToArray()); 
      //
      // Compile standalone executable with input files embedded as resource
      string[] sourcefiles = new string[] 
      { 
        sourceName0, sourceName1, sourceName2, sourceName3, sourceName4, sourceName5, sourceName6, sourceName7, sourceName8, sourceName9, sourceName10,
        sourceName11, sourceName12, sourceName13, sourceName14, sourceName15, sourceName16, sourceName17, sourceName18, sourceName19
      };
      foreach (string sf in sourcefiles)
      {
        bool exists = File.Exists(sf);
        if (!exists) 
        {
          AppBuilder.Error = String.Format("source file {0} not found", sf);          
          return false;
        }
      }
      CompilerResults cr = csc.CompileAssemblyFromFile(cp, sourcefiles);
      //
      // yell if compilation error
      if (cr.Errors.Count > 0)
      {
        string msg = "Errors building " + cr.PathToAssembly;
        foreach (CompilerError ce in cr.Errors)
        {
          msg += Environment.NewLine + ce.ToString();
        }
        throw new ApplicationException(msg);
      }
      AppBuilder.outputAssembly = cp.OutputAssembly;      
      return true;
    }

    // ******************************************************
    // main methods - zipper
    // ******************************************************
 
    public static bool SafeZipApplication(string appName)
    {
      Assembly ass = Assembly.GetExecutingAssembly();
      string outputFolder = Path.GetDirectoryName(ass.Location);       
      if (File.Exists(AppBuilder.outputAssembly))
      {
        // first copy the output assembly to a .txt filename
        string first = String.Format("{0}.exe.txt", appName);
        File.Copy(AppBuilder.outputAssembly, first);
        // then zip it
        string second = String.Format("{0}.exe.txt.zip", appName);
        ZipSingleFile(first, second);    
        // again rename it
        string third = String.Format("{0}.exe.txt.zip.txt", appName);
        File.Copy(second, third);
        // then zip it again
        string fourth = String.Format("{0}.zip.zip", appName);
        ZipSingleFile(third, fourth);
        //
        // finally clean up
        File.Delete(first);
        File.Delete(second);
        File.Delete(third);        
      }      
      return true;
    }

    #endregion

    #region AppBuilder write methods
    // ******************************************************
    // write methods
    // ******************************************************

    public static bool WriteProgramSource(string appName, string appVersion, bool bBuildLocked)
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
        source += "namespace BlackBox\n";
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
        source += "        Application.Run(new AppCompactForm(appname));\n";
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
        source += String.Format("    public const bool c_Locked = {0};\n", bBuildLocked.ToString().ToLower());
        source += String.Format("    public const bool c_RequirePassword = {0};\n", bRequirePassword.ToString().ToLower());
        source += String.Format("    public const string c_Password = \"{0}\";\n", unlockPassword.ToString().ToLower());                
        source += "\n";
        source += "    // general\n";
        source += String.Format("    public const bool c_CheckPayload = {0};\n", AppSettings.bCheckPayload.ToString().ToLower());
        source += "\n";
        source += "    // modes\n";
        source += String.Format("    public const bool c_RunFromTemp = {0};\n", bRunFromTemp.ToString().ToLower());
        source += String.Format("    public const string c_RunFromLocation = \"{0}\";\n", runFromLocation);
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
        System.IO.File.WriteAllText(String.Format("{0}\\Program.cs", compilerFolder), source);
      }
      catch (Exception ex)
      {
        MessageBox.Show(ex.Message, appName, MessageBoxButtons.OK, MessageBoxIcon.Error);
        return false;
      }
      return true;
    }

    private static bool CopyAllWorkingSource(bool update)
    {
      // copy key source from working to compiler temp
      CopyWorkingSource("visualstudio.zip", true);      
      CopyWorkingSource("implfiles.zip", true);      
      CopyWorkingSource("payload.zip", true);
      CopyWorkingSource("actions.xml", true);
      CopyWorkingSource("events.xml", true);      
      CopyWorkingSource("script.cmd", true);
      CopyWorkingSource("script.ps1", true);
      CopyWorkingSource("script.sql", true);
      CopyWorkingSource("readme.txt", true);
      CopyWorkingSource("runner.txt", true);
      return true;
    }

    private static bool CopyWorkingSource(string filename, bool update)
    {
      // copy single source from working to compiler temp
      if (update) File.Copy(Path.Combine(AppSettings.workingFolder, filename), Path.Combine(AppBuilder.compilerFolder, filename));
      //
      return true;
    }

    #endregion

    #region AppBuilder unpack methods
    // ******************************************************
    // unpack methods
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
      return true;
    }

    public static bool UnpackScripts()
    {
      // unpack script resources
      bool available1 = UnpackAppSourceResource("script.cmd");      
      if (!available1)
      {
        available1 = UnpackZippedResource("script.cmd");       
      }      
      bool available2 = UnpackAppSourceResource("script.ps1");      
      if (!available2)
      {
        available2 = UnpackZippedResource("script.ps1");       
      }      
      bool available3 = UnpackAppSourceResource("script.sql"); 
      if (!available3)
      {
        available3 = UnpackZippedResource("script.sql");
      }      
      if (!available1 || !available2 || !available3)
      {
        System.Windows.Forms.MessageBox.Show("One or more of the Script files are not available", "AppBuilder", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
      }
      return true;
    }

    public static bool UnpackSource(bool bBuildLocked)
    {
      // unpack binary resources
      bool available0 = UnpackAppSourceResource("crayon.png");
      if (!available0)
      {
        available0 = UnpackZippedResource("crayon.png");
      }      
      bool available1 = UnpackAppSourceResource("crayon.png");
      if (!available1)
      {
        available1 = UnpackZippedResource("crayon.png");
      }      
      bool available2 = UnpackAppSourceResource("file.png");
      if (!available2)
      {
        available2 = UnpackZippedResource("file.png");
      }      
      bool available3 = UnpackAppSourceResource("cmd.png");
      if (!available3)
      {
        available3 = UnpackZippedResource("cmd.png");
      }
      bool available4 = UnpackAppSourceResource("ps.png");
      if (!available4)
      {
        available4 = UnpackZippedResource("ps.png");
      }
      bool available5 = UnpackAppSourceResource("sql.png");
      if (!available5)
      {
        available5 = UnpackZippedResource("sql.png");
      }
      // create the prograce source file
      bool available6 = WriteProgramSource(AppSettings.appName, AppSettings.appVersion, AppBuilder.bBuildLocked);
      //
      // unpack app source resources
      bool available7 = false, available8 = false, available9 = false, available10 = false, available11 = false;
      bool available12 = false, available13 = false, available14 = false, available15 = false, available16 = false;
      bool available17 = false, available18 = false, available19 = false, available20 = false, available21 = false;
      bool available22 = false;
      bool available = UnpackZippedResource("AppCompact.cs");
      if (available) 
      { 
        // updates source is available so unpack the other files
        available7 = UnpackZippedResource("AppCompact.Designer.cs");
        available8 = UnpackZippedResource("AppSettingsForm.cs");
        available9 = UnpackZippedResource("AppSettingsForm.Designer.cs");
        available10 = UnpackZippedResource("AppFilerForm.cs");
        available11 = UnpackZippedResource("AppFilerForm.Designer.cs");
        available12 = UnpackZippedResource("AppBuilderForm.cs");
        available13 = UnpackZippedResource("AppBuilderForm.Designer.cs");
        available14 = UnpackZippedResource("AppSettings.cs");        
        available15 = UnpackZippedResource("AppLogger.cs");
        available16 = UnpackZippedResource("AppRunner.cs");
        available17 = UnpackZippedResource("AppActions.cs");
        available18 = UnpackZippedResource("AppEvents.cs");                
        available19 = UnpackZippedResource("AppFiler.cs");
        available20 = UnpackZippedResource("AppConcole.cs");        
        available21 = UnpackZippedResource("AppBuilder.cs");        
        available22 = UnpackZippedResource("AppSQL.cs");        
      }
      else
      {
        // need to use origional source by unzipping the visualstudio.zip package
        available = UnpackVisualStudio(true);
      }      
      if (!available || !available0 || !available1 || !available2 || !available3 || !available4 || !available5 || !available6)
      {
        System.Windows.Forms.MessageBox.Show("One or more of the Source files are not available", "AppBuilder", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
      }
      return true;
    }

    public static bool UnpackPayload(bool unzip=false)
    {
      // unpack payload resources
      bool available1 = UnpackAppSourceResource("payload.zip");      
      if (!available1)
      {
        available1 = UnpackZippedResource("payload.zip");
      } 
      if (available1)
      {
        string zipPath = Path.Combine(AppBuilder.compilerFolder, "payload.zip");
        //if (unzip || AppSettings.bUnpackUnzip) ZipFile.ExtractToDirectory(zipPath, AppBuilder.compilerFolder);
        if (unzip || AppSettings.bUnpackUnzip) AppBuilder.ExtractToDirectory(zipPath, AppBuilder.compilerFolder, true);
     }
      else      
      {
        System.Windows.Forms.MessageBox.Show("One or more of the Payload files are not available", "AppBuilder", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
      }
      return true;
    }

    public static bool UnpackImplFiles(bool unzip=false)
    {
      // unpack payload resources
      bool available1 = UnpackAppSourceResource("implfiles.zip");      
      if (!available1)
      {
        available1 = UnpackZippedResource("implfiles.zip");
      } 
      if (available1)
      {
        string zipPath = Path.Combine(AppBuilder.compilerFolder, "implfiles.zip");
        if (unzip || AppSettings.bUnpackUnzip) AppBuilder.ExtractToDirectory(zipPath, AppBuilder.compilerFolder, true);
     }
      else      
      {
        System.Windows.Forms.MessageBox.Show("One or more of the ImplFiles files are not available", "AppBuilder", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
      }
      return true;
    }

    public static bool UnpackEvents(bool read=false)
    {
      // unpack payload resources
      bool available = UnpackAppSourceResource("events.xml");      
      if (!available)
      {
        available = UnpackZippedResource("events.xml");
      } 
      if (!available)
      {
        System.Windows.Forms.MessageBox.Show("The Events file is not available", "AppBuilder", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
      }
      return true;
    }

    public static bool UnpackActions(bool read=false)
    {
      // unpack payload resources
      bool available = UnpackAppSourceResource("actions.xml");      
      if (!available)
      {
        available = UnpackZippedResource("actions.xml");
      } 
      if (!available)
      {
        System.Windows.Forms.MessageBox.Show("The Actions file is not available", "AppBuilder", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
      }
      return true;
    }

    public static bool UnpackVisualStudio(bool unzip=false)
    {
      // unpack VisualStudio resources
      bool available1 = UnpackAppSourceResource("VisualStudio.zip");      
      if (!available1)
      {
        available1 = UnpackZippedResource("VisualStudio.zip");
      } 
      if (available1)
      {
        string zipPath = Path.Combine(AppBuilder.compilerFolder, "VisualStudio.zip");
        if (unzip || AppSettings.bUnpackUnzip) AppBuilder.ExtractToDirectory(zipPath, AppBuilder.compilerFolder, true);
      }
      else      
      {
        System.Windows.Forms.MessageBox.Show("One or more of the VisualStudio files are not available", "AppBuilder", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
      }
      return true;
    }

    // ******************************************************
    // unpack methods
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
        foreach (ZipArchiveEntry file in archive.Entries)
        {
          string completeFileName = Path.GetFullPath(Path.Combine(destinationDirectoryFullPath, file.FullName));
          if (!completeFileName.StartsWith(destinationDirectoryFullPath, StringComparison.OrdinalIgnoreCase))
          {
            throw new IOException("Trying to extract file outside of destination directory. See this link for more info: https://snyk.io/research/zip-slip-vulnerability");
           }
           if (file.Name == "")
           { // Assuming Empty for Directory
             Directory.CreateDirectory(Path.GetDirectoryName(completeFileName));
             continue;
           }
           file.ExtractToFile(completeFileName, true);
         }
      }
    }

    #endregion
  
    #region AppBuilder resource methods
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
        string resname = String.Format("BlackBox.{0}", name);
        Stream rs = ass.GetManifestResourceStream(resname);
        if (rs == null)
        {
          if (!quiet) MessageBox.Show(String.Format("Resource {0} not found", resname), ass.GetName().Name, MessageBoxButtons.OK, MessageBoxIcon.Error);
          return false;
        }
        string path = Path.Combine(AppBuilder.compilerFolder, Path.GetFileName(name));
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
        string resname = String.Format("BlackBox.{0}.gz", name);
        Stream rs = ass.GetManifestResourceStream(resname);
        if (rs == null)
        {
          if (!quiet) MessageBox.Show(String.Format("Resource {0} not found", resname), ass.GetName().Name, MessageBoxButtons.OK, MessageBoxIcon.Error);
          return false;
        }
        using (Stream gzip = new GZipStream(rs, CompressionMode.Decompress, true))
        {
          string path = Path.Combine(AppBuilder.compilerFolder, name); 
          path.Replace("BlackBox.","");
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

    #endregion

    #region AppBuilder support methods
    // ******************************************************
    // support methods
    // ******************************************************
 
    public static void AddFileAsEmbeddedResource(string filename, string compilerFolder)
    {
      // Compress input file using System.IO.Compression
      string resname = String.Format("BlackBox.{0}.gz", filename);
      string respath = Path.Combine(compilerFolder, resname);
      GZipSingleFile(Path.Combine(compilerFolder, filename), respath); 
      //
      // Store filename so we can embed it on CompileArchive() call
      filenames.Add(respath);
    }
 
    public static void GZipSingleFile(string fileName, string zipFileName)
    {
      // Compress input file using System.IO.Compression
      using (Stream file = File.OpenRead(fileName))
      {
        byte[] buffer = new byte[file.Length];
        if (file.Length != file.Read(buffer, 0, buffer.Length))
        {
          throw new IOException("Unable to read " + fileName);
        }
        using (Stream gzFile = File.Create(zipFileName))
        {
          using (Stream gzip = new GZipStream(gzFile, CompressionMode.Compress))
          {
            gzip.Write(buffer, 0, buffer.Length);
          }
        }
      }
    }

    public static void ZipSingleFile(string fileName, string zipFileName)
    {
      // Compress input file using System.IO.Compression
      using (var archive = ZipFile.Open(zipFileName, ZipArchiveMode.Create))
      {
        archive.CreateEntryFromFile(fileName, Path.GetFileName(fileName));
      }      
    }
    
    #endregion
  }
  
  #endregion

}
