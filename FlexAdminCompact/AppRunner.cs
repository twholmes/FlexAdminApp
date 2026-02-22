using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.IO.Compression;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using System.Xml;
using System.Xml.Serialization;

using Microsoft.CSharp;
using System.Threading;
using System.Threading.Tasks;
using System.CodeDom.Compiler;
using System.Diagnostics;
using System.Reflection;

namespace Crayon
{
  #region Class AppRunner
  /// <summary>
  /// Summary description for AppRunner class
  /// </summary>    
  static class AppRunner
  {
    #region Data    
    // ******************************************************
    // protected data
    // ******************************************************
   
    // ******************************************************
    // public data
    // ******************************************************

    // the working folder contaiing all source files
    public static string workingFolder = String.Empty;
    //
    // run context
    public enum RunContext { ImplFiles, CMD, PowerShell, SQL, Events };
    public static RunContext Context;
    //
    // run actions
    public static string scriptArgs = String.Empty;    
    //
    // dropped
    public static string droppedSqlContentName = String.Empty;
    public static string droppedScriptName = String.Empty;
    //
    // status 
    public static string error = String.Empty;

    #endregion

    #region Initialise
    // ******************************************************
    // initialise
    // ******************************************************

    public static void Initialise()
    {
      Initialise(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location));
    }

    public static void Initialise(string folder)
    {
      workingFolder = folder;
    }
    
    #endregion

    #region Main methods
    // ******************************************************
    // main methods
    // ******************************************************
     
    public static void OpenWorkingFileWithShellApp(string shellapp, string filename, bool wait=false)
    {
      bool found = false;
      string [] fileEntries = Directory.GetFiles(AppSettings.workingFolder, filename);
      if (fileEntries.Length > 0) found = true;
      if (!found) found = AppFiler.CheckUnpackScript(filename, false);        
      if (found)
      {
        try
        {   
          Logger.WriteLog(String.Format("run {0} ... {1}", shellapp, filename));
          using (Process myProcess = new Process())
          {
            myProcess.StartInfo.UseShellExecute = true;
            myProcess.StartInfo.FileName = shellapp;
            myProcess.StartInfo.Arguments = String.Format("\"{0}\\{1}\"", AppSettings.workingFolder, filename);
            myProcess.StartInfo.CreateNoWindow = false;
            myProcess.Start();
            if (wait) myProcess.WaitForExit();
          }
        }
        catch (Exception ex)
        {
          MessageBox.Show(ex.Message, AppSettings.appName, MessageBoxButtons.OK, MessageBoxIcon.Error);
        }       
      }
    }
     
    public static void OpenFileWithShellApp(string shellapp, string filename, bool wait=false)
    {
      bool found = File.Exists(filename);
      if (!found) found = AppFiler.CheckUnpackScript(filename, false);        
      if (found)
      {
        try
        {   
          Logger.WriteLog(String.Format("run {0} ... {1}", shellapp, filename));
          using (Process myProcess = new Process())
          {
            myProcess.StartInfo.UseShellExecute = true;
            myProcess.StartInfo.FileName = shellapp;
            myProcess.StartInfo.Arguments = String.Format("\"{0}\"", filename);
            myProcess.StartInfo.CreateNoWindow = false;
            myProcess.Start();
            if (wait) myProcess.WaitForExit();
          }
        }
        catch (Exception ex)
        {
          MessageBox.Show(ex.Message, AppSettings.appName, MessageBoxButtons.OK, MessageBoxIcon.Error);
        }       
      }
    }
 
    #endregion

    #region Processing methods
    // ******************************************************
    // processing methods
    // ******************************************************

    public static void Run(bool redirect=false, string outFileName="flexadmin.out")
    {
      if (!AppSettings.bEventsOnly)
      {
        if (!redirect)
          Run(AppSettings.scriptFileName, AppRunner.scriptArgs);
        else
          RunRedirect(AppSettings.scriptFileName, AppRunner.scriptArgs, outFileName);
      }
    }
    
    public static void Run(string scriptFileName, string args)
    {
      if (!String.IsNullOrEmpty(scriptFileName) && scriptFileName.Length > 0)
      {
        Logger.WriteLog(String.Format("run script: {0}", scriptFileName));
        try
        {   
          //string content = System.IO.File.ReadAllText(Path.Combine(AppSettings.workingFolder,scriptFileName));
          //if (content.Length > 0)
          //{
          //  System.IO.File.WriteAllText(Path.Combine(AppSettings.workingFolder, String.Format("script{0}", AppSettings.scriptFileType)), content);
          //}
          //
          string commandline = Path.Combine(AppSettings.workingFolder, "generated.cmd");
          string allArgs = String.Format("{0}", args);
          allArgs.Trim();
          //
          Logger.WriteLog(String.Format("run SHELL execute:{0}", commandline));
          using (Process myProcess = new Process())
          {
            myProcess.StartInfo.UseShellExecute = true;
            myProcess.StartInfo.WorkingDirectory = AppSettings.workingFolder; 
            myProcess.StartInfo.Verb = "runas";
            myProcess.StartInfo.FileName = commandline;
            myProcess.StartInfo.Arguments = allArgs;         
            myProcess.StartInfo.CreateNoWindow = false;
            myProcess.Start();
            myProcess.WaitForExit();
          }
          //MessageBox.Show(this, String.Format("Performed {0}", scriptFileName), AppSettings.AppName, MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
        catch (Exception ex)
        {
          MessageBox.Show(ex.Message, AppSettings.appName, MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
      }
    }
    
    public static void RunRedirect(string scriptFileName, string args, string outFileName)
    {
      if (!String.IsNullOrEmpty(scriptFileName) && scriptFileName.Length > 0)
      {
        Logger.WriteLog(String.Format("run script: {0}", scriptFileName));
        try
        {   
          string commandline = Path.Combine(AppSettings.workingFolder, "generated.cmd");
          string allArgs = String.Format("{0}", args);
          allArgs.Trim();
          //
          Logger.WriteLog(String.Format("run SHELL execute with redirect: {0}", commandline));
          using (Process myProcess = new Process())
          {
            myProcess.StartInfo.UseShellExecute = false;
            myProcess.StartInfo.WorkingDirectory = AppSettings.workingFolder; 
            myProcess.StartInfo.Verb = "runas";
            myProcess.StartInfo.FileName = commandline;
            myProcess.StartInfo.Arguments = allArgs;         
            myProcess.StartInfo.CreateNoWindow = true;
            myProcess.StartInfo.RedirectStandardOutput = true;
            myProcess.Start();
            //
            string outfile = Path.Combine(AppSettings.workingFolder, outFileName);              
            string output = myProcess.StandardOutput.ReadToEnd();              
            System.IO.File.WriteAllText(outfile, output);              
            Logger.WriteLog(String.Format("redirected output sent to ", outfile));
            //
            myProcess.WaitForExit();
          }
          //MessageBox.Show(this, String.Format("Performed {0}", scriptFileName), AppSettings.AppName, MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
        catch (Exception ex)
        {
          MessageBox.Show(ex.Message, AppSettings.appName, MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
      }
    }

    #endregion 

    #region Base64 methods
    // ******************************************************
    // base64 encryption methods
    // ******************************************************

    public static string Base64Encrypt(string filename)
    {     
      byte[] AsBytes = System.IO.File.ReadAllBytes(filename);
      String AsBase64String = Convert.ToBase64String(AsBytes);      
      string efile = Path.Combine(AppSettings.workingFolder, String.Format("{0}{1}", Path.GetFileName(filename), ".b64"));
      File.WriteAllText(efile, AsBase64String);
      return efile;
    }

    public static String Base64Decrypt(string filename)
    {   
      string AsBase64String = System.IO.File.ReadAllText(Path.Combine(AppSettings.workingFolder, filename));
      byte[] bytes = Convert.FromBase64String(AsBase64String);
      string efile = Path.Combine(AppSettings.workingFolder, Path.GetFileNameWithoutExtension(filename));
      System.IO.File.WriteAllBytes(efile, bytes);
      return efile;
    }

    // ******
    public static string Base64Encrypt2(string filename)
    {     
      FileStream fs = new FileStream(filename, FileMode.Open, FileAccess.Read);
      byte[] filebytes = new byte[fs.Length];
      fs.Read(filebytes, 0, Convert.ToInt32(fs.Length));
      string encodedData = Convert.ToBase64String(filebytes, Base64FormattingOptions.None);
      //
      string efile = Path.Combine(AppSettings.workingFolder, String.Format("{0}{1}", Path.GetFileName(filename), ".b64"));
      File.WriteAllText(efile, encodedData);
      return efile;
    }

    public static String Base64Decrypt2(string filename)
    {   
      string encodedData = System.IO.File.ReadAllText(Path.Combine(AppSettings.workingFolder, filename));
      byte[] filebytes = Convert.FromBase64String(encodedData);
      //
      string efile = Path.Combine(AppSettings.workingFolder, String.Format("New{0}",Path.GetFileNameWithoutExtension(filename)));
      FileStream fs = new FileStream(efile, FileMode.CreateNew, FileAccess.Write, FileShare.None);
      fs.Write(filebytes, 0, filebytes.Length);
      fs.Close(); 
      //
      return efile;
    }

    #endregion
 
    #region Support methods
    // ******************************************************
    // support methods
    // ******************************************************
 
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
