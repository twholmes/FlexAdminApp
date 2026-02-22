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

using Microsoft.Win32;
using Microsoft.CSharp;

using System.Threading;
using System.Threading.Tasks;
using System.CodeDom.Compiler;
using System.Diagnostics;
using System.Reflection;

namespace Crayon
{
  #region Class AppEvents
  /// <summary>
  /// Summary description for AppEvents class
  /// </summary>    
  static class AppEvents
  {
    #region Constants
    // ******************************************************
    // public constants
    // ******************************************************

    private const string c_RegistryKey = @"SOFTWARE\Crayon\FlexAdmin\Events";

    #endregion
    
    #region AppEvents data   
    // ******************************************************
    // public data
    // ******************************************************

    // the working folder contaiing all source files
    public static string workingFolder = String.Empty;

    // status 
    public static string error = String.Empty;

    // ******************************************************
    // public data
    // ******************************************************

    // properties
    public static string name = String.Empty;    

    // ******************************************************
    // public data
    // ******************************************************

    public static AppEvent eventBUILD;
    public static AppEvent eventUNPACK;
    public static AppEvent eventDROP;
    public static AppEvent eventPRE;
    public static AppEvent eventPOST;
    public static AppEvent eventEXIT;    

    #endregion

    #region AppEvents initialise
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

    #region AppEvents processing methods
    // ******************************************************
    // processing routines
    // ******************************************************

    public static bool RunEvent(string name, bool redirect=false)
    {
      string outFileName = String.Format("{0}.out", name);
      //
      AppEvent ev = new AppEvent(name.ToLower());
      switch (name)
      {
        // events
        case "BUILD":
          ev.script = eventBUILD.script;
          ev.enabled = AppSettings.bEventBUILD;
          break;
        case "UNPACK":
          ev.script = eventUNPACK.script;
          ev.enabled = AppSettings.bEventUNPACK;
          break;
        case "DROP":
          ev.script = eventDROP.script;
          ev.enabled = AppSettings.bEventDROP;
          break;
        case "PRE":
          ev.script = eventPRE.script;
          ev.enabled = AppSettings.bEventPRE;
          break;
        case "POST":
          ev.script = eventPOST.script;
          ev.enabled = AppSettings.bEventPOST;
          break;
        case "EXIT":
          ev.script = eventEXIT.script;
          ev.enabled = AppSettings.bEventEXIT;
          break;
      }
      bool eok = false;      
      if (ev.enabled) eok = ev.RunScript(redirect, outFileName);
      //
      return eok;
    }

    #endregion

    #region AppEvents read methods
    // ******************************************************
    // read routines
    // ******************************************************

    /// <summary>
    /// ReadEventsRegistry
    /// </summary>
    /// <param name="filename"></param>

    public static bool ReadEventsRegistry()
    {
      // Event BUILD
      eventBUILD = new AppEvent("BUILD");
      eventBUILD.ReadFromRegistry("BUILD");
      //
      // Event UNPACK
      eventUNPACK = new AppEvent("UNPACK");
      eventUNPACK.ReadFromRegistry("UNPACK");
      //
      // Event DROP
      eventDROP = new AppEvent("DROP");
      eventDROP.ReadFromRegistry("DROP");
      //
      // Event PRE
      eventPRE = new AppEvent("PRE");
      eventPRE.ReadFromRegistry("PRE");
      //
      // Event POST
      eventPOST = new AppEvent("POST");
      eventPOST.ReadFromRegistry("POST");
      //
      // Event EXIT
      eventEXIT = new AppEvent("EXIT");
      eventEXIT.ReadFromRegistry("EXIT");
      //
      return true;
    }

    /// <summary>
    /// ReadEventsFile
    /// </summary>
    /// <param name="filename"></param>

    public static bool ReadEventsFile(string filename)
    {
      try
      {  
        // create the XmlDocument
        XmlDocument doc = new XmlDocument();
        doc.Load(filename); 
        //
        // read events settings
        XmlNode eventsnode = doc.DocumentElement.SelectSingleNode("/Crayon/events");
        if (eventsnode != null)
        {
           string value = eventsnode.Attributes["name"].Value;
           if (value != null) name = value;          
        }
        // read event script settings
        XmlNode nodeBUILD = doc.DocumentElement.SelectSingleNode("/Crayon/events/BUILD");
        if (nodeBUILD != null)
        {         
          eventBUILD = new AppEvent("BUILD");
          //
          string value = nodeBUILD.InnerText.Trim();
          if (value != null) eventBUILD.script = value.Trim();          
          eventBUILD.type = ".ps1";
          eventBUILD.enabled = true;          
        }                
        // read event script settings
        XmlNode nodeUNPACK = doc.DocumentElement.SelectSingleNode("/Crayon/events/UNPACK");
        if (nodeUNPACK != null)
        {         
          eventUNPACK = new AppEvent("UNPACK");
          //
          string value = nodeUNPACK.InnerText.Trim();
          if (value != null) eventUNPACK.script = value.Trim();          
          eventUNPACK.type = ".ps1";
          eventUNPACK.enabled = true;          
        }                
        // read event script settings
        XmlNode nodeDROP = doc.DocumentElement.SelectSingleNode("/Crayon/events/DROP");
        if (nodeDROP != null)
        {         
          eventDROP = new AppEvent("DROP");
          //
          string value = nodeDROP.InnerText.Trim();
          if (value != null) eventDROP.script = value.Trim();          
          eventDROP.type = ".ps1";
          eventDROP.enabled = true;          
        }                
        // read event script settings
        XmlNode nodePRE = doc.DocumentElement.SelectSingleNode("/Crayon/events/PRE");
        if (nodePRE != null)
        {         
          eventPRE = new AppEvent("PRE");
          //
          string value = nodePRE.InnerText.Trim();
          if (value != null) eventPRE.script = value.Trim();          
          eventPRE.type = ".ps1";
          eventPRE.enabled = true;          
        }                
        // read event script settings
        XmlNode nodePOST = doc.DocumentElement.SelectSingleNode("/Crayon/events/POST");
        if (nodePOST != null)
        {         
          eventPOST = new AppEvent("POST");
          //
          string value = nodePOST.InnerText.Trim();
          if (value != null) eventPOST.script = value.Trim();
          eventPOST.type = ".ps1";
          eventPOST.enabled = true;          
        }                
        // read event script settings
        XmlNode nodeEXIT = doc.DocumentElement.SelectSingleNode("/Crayon/events/EXIT");
        if (nodeEXIT != null)
        {         
          eventEXIT = new AppEvent("EXIT");
          //
          string value = nodeEXIT.InnerText.Trim();
          if (value != null) eventEXIT.script = value.Trim();
          eventEXIT.type = ".ps1";
          eventEXIT.enabled = true;          
        }                
      }
      catch (Exception ex) 
      {
        System.Windows.Forms.MessageBox.Show(ex.Message, "ReadEventsFile", MessageBoxButtons.OK, MessageBoxIcon.Error);       
        return false;
      }
      return true;
    }

    #endregion

    #region AppEvents write methods   
    // ******************************************************
    // write routines
    // ******************************************************

    /// <summary>
    /// WriteEventsFile
    /// </summary>
    /// <param name="name"></param>

    public static bool WriteEventsFile(string name, string filename="events.xml")
    {
      try
      {
        string generatedFileName = Path.Combine(AppSettings.workingFolder, filename);
        using (System.IO.StreamWriter file = new System.IO.StreamWriter(generatedFileName))
        {
          file.WriteLine("<?xml version=\"1.0\" standalone=\"yes\"?>");
          file.WriteLine(@"<Crayon>");
          file.WriteLine(String.Format("  <events name=\"{0}\" updated=\"{1}\">", name, DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss")));
          //
          string[] sep = { "\r\n" };
          string[] lines;
          //          
          file.WriteLine(@"    <BUILD>");
          file.WriteLine(@"      <![CDATA[");
          lines = eventBUILD.script.Split(sep,5000,0);
          foreach (string line in lines)
          {
            file.WriteLine(String.Format("{0}", line)); 
          }          
          file.WriteLine(@"      ]]>");
          file.WriteLine(@"    </BUILD>");
          //
          file.WriteLine(@"    <UNPACK>");
          file.WriteLine(@"      <![CDATA[");
          lines = eventUNPACK.script.Split(sep,5000,0);
          foreach (string line in lines)
          {
            file.WriteLine(String.Format("{0}", line)); 
          }          
          file.WriteLine(@"      ]]>");
          file.WriteLine(@"    </UNPACK>");
          //
          file.WriteLine(@"    <DROP>");
          file.WriteLine(@"      <![CDATA[");
          lines = eventDROP.script.Split(sep,5000,0);
          foreach (string line in lines)
          {
            file.WriteLine(String.Format("{0}", line)); 
          }          
          file.WriteLine(@"      ]]>");
          file.WriteLine(@"    </DROP>");
          //
          file.WriteLine(@"    <PRE>");
          file.WriteLine(@"      <![CDATA[");
          lines = eventPRE.script.Split(sep,5000,0);
          foreach (string line in lines)
          {
            file.WriteLine(String.Format("{0}", line)); 
          }          
          file.WriteLine(@"      ]]>");
          file.WriteLine(@"    </PRE>");
          //
          file.WriteLine(@"    <POST>");
          file.WriteLine(@"      <![CDATA[");
          lines = eventPOST.script.Split(sep,5000,0);
          foreach (string line in lines)
          {
            file.WriteLine(String.Format("{0}", line)); 
          }          
          file.WriteLine(@"      ]]>");
          file.WriteLine(@"    </POST>");
          //
          file.WriteLine(@"    <EXIT>");
          file.WriteLine(@"      <![CDATA[");
          lines = eventEXIT.script.Split(sep,5000,0);
          foreach (string line in lines)
          {
            file.WriteLine(String.Format("{0}", line)); 
          }          
          file.WriteLine(@"      ]]>");
          file.WriteLine(@"    </EXIT>");
          //
          file.WriteLine(@"  </events>");
          file.WriteLine(@"</Crayon>");
        }
      }
      catch (Exception ex) 
      {
        System.Windows.Forms.MessageBox.Show(ex.Message, "WriteEventsFile", MessageBoxButtons.OK, MessageBoxIcon.Error);
        return false;
      }
      return true;
    }

    #endregion

    #region AppEvents support methods
    // ******************************************************
    // support methods
    // ******************************************************

    /// <summary>
    /// Convert an XmlNode to a string
    /// </summary>
    /// <param name="node"></param>
    /// <param name="indentation"></param>
    /// <returns></returns>

    private static string NodeToString(System.Xml.XmlNode node, int indentation)
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

    #endregion

  }
  #endregion

  #region Class AppEvent
  /// <summary>
  /// Summary description for AppEvent class
  /// </summary>    
  class AppEvent
  {
    #region Constants
    // ******************************************************
    // public constants
    // ******************************************************

    private const string c_RegistryKey = @"SOFTWARE\Crayon\FlexAdmin\Events";

    #endregion
    
    #region AppEvent data   
    // ******************************************************
    // public data
    // ******************************************************

    // status 
    public string error = String.Empty;

    // properties
    public string _name = String.Empty;    
    public string _script = String.Empty;
    public string _type = ".ps1";    
    //
    public bool _enabled = false;

    #endregion

    #region AppEvent constructors
    // ******************************************************
    // constructors
    // ******************************************************
          
    public AppEvent()
    {
      CreateHKLMRegKeyHive(c_RegistryKey);
    }
          
    public AppEvent(string name)
    {
      CreateHKLMRegKeyHive(c_RegistryKey);
      CreateHKLMRegKeySubKey(name, c_RegistryKey);   
      this.name = name;
    }

    #endregion

    #region AppEvent accessors    
    // ******************************************************
    // data accessors
    // ******************************************************
   
    public string name
    {
      get
      {
        string value = this._name;
        return value;
      }
      set
      {
        this._name = value;
      }
    }

    public string script
    {
      get
      {
        string value = this._script;
        return value;
      }
      set
      {
        this._script = value;
        this.rstrScript = value;        
      }
    }

    public string type
    {
      get
      {
        string value = this._type;
        return value;
      }
      set
      {
        this._type = value;
        this.rstrType = value;        
      }
    }
   
    public bool enabled
    {
      get
      {
        bool value = this._enabled;
        return value;
      }
      set
      {
        this._enabled = value;
        this.rbEnabled = value;       
      }
    }   

    #endregion

    #region AppEvent registry accessors
    // ******************************************************
    // data accessors
    // ******************************************************

    public string rstrScript
    {
      get
      {
        string value = RegGetStringItemValue("Script", "");
        return value;
      }
      set
      {
        RegSetStringItemValue("Script", value); 
      }
    }

    public string rstrType
    {
      get
      {
        string value = RegGetStringItemValue("Type", "");
        return value;
      }
      set
      {
        RegSetStringItemValue("Type", value); 
      }
    }

    public bool rbEnabled
    {
      get
      {
        string svalue = RegGetStringItemValue("Enabled", "False");
        bool value = Boolean.Parse(svalue);
        return value;
      }
      set
      {
        RegSetStringItemValue("Enabled", value.ToString()); 
      }
    }

    #endregion

    #region AppEvent main methods
    // ******************************************************
    // main routines
    // ******************************************************

    public bool ReadFromRegistry(string name)
    {   
      this._name = name;
      this._script = this.rstrScript;
      this._type = this.rstrType;
      this._enabled = this.rbEnabled;
      //
      return true;
    }

    #endregion

    #region AppEvent processing methods
    // ******************************************************
    // processing routines
    // ******************************************************

    public bool RunScript(bool redirect, string outFileName)
    {
      bool runOK = false;
      if (String.IsNullOrEmpty(this.script))
        return true;
      else
      {
        Logger.WriteLog(String.Format("process event ... {0}", this.name));
        try
        {   
          string content = GetPowerShellScriptHeader(this.name);
          content += String.Format("{0}\n", this.script);
          content += "\n";
          //
          System.IO.File.WriteAllText(Path.Combine(AppSettings.workingFolder, String.Format("{0}.ps1", this.name)), content);
          WriteShellScript(!redirect);  // pause = !redirect
          //
          string commandline;
          if (redirect)
          {
            commandline = Path.Combine(AppSettings.workingFolder, "event.cmd");
            runOK = RunWithRedirection(name, commandline, outFileName, "event");
          }
          else
          {
            commandline = Path.Combine(AppSettings.workingFolder, "event.cmd");
            runOK = RunWithShell(name, commandline, "event");
          }
        }
        catch (Exception ex)
        {
          MessageBox.Show(ex.Message, String.Format("Event({0})", this.name), MessageBoxButtons.OK, MessageBoxIcon.Error);
          return false;
        }
      }
      return runOK;
    }
    
    // ******************************************************
    // processing methods
    // ******************************************************

    private bool RunWithShell(string trigger, string commandline, string occurance="event")
    {
      Logger.WriteLog(String.Format("run {0} ... {1}", occurance, commandline));
      try
      {   
        using (Process myProcess = new Process())
        {
          myProcess.StartInfo.UseShellExecute = true;
          myProcess.StartInfo.Verb = "runas";
          myProcess.StartInfo.FileName = commandline;
          myProcess.StartInfo.Arguments = "";         
          myProcess.StartInfo.CreateNoWindow = false;
          myProcess.Start();
          myProcess.WaitForExit();
        }
      }
      catch (Exception ex)
      {
        MessageBox.Show(ex.Message, String.Format("{0}({1})", occurance, trigger), MessageBoxButtons.OK, MessageBoxIcon.Error);
        return false;
      }
      return true;      
    }

    private bool RunWithRedirection(string trigger, string commandline, string outFileName, string occurance="event")
    {
      Logger.WriteLog(String.Format("run {0} with redirection ... {1}", occurance, commandline));     
      try
      {   
        using (Process myProcess = new Process())
        {
          myProcess.StartInfo.UseShellExecute = false;
          myProcess.StartInfo.Verb = "runas";
          myProcess.StartInfo.FileName = commandline;
          myProcess.StartInfo.Arguments = "";         
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
      }
      catch (Exception ex)
      {
        MessageBox.Show(ex.Message, String.Format("{0}({1})", occurance, trigger), MessageBoxButtons.OK, MessageBoxIcon.Error);
        return false;
      }
      return true;      
    }

    // ******************************************************
    // write methods
    // ******************************************************

    public void WriteShellScript(bool bPause=false)
    {
      string content = String.Empty;
      content += "@ECHO OFF\n";
      content += "REM Autogenerated by FlexAdmin to run an event script\n";
      content += String.Format("REM Source event was {0}\n", this.name);
      content += String.Format("REM Created at {0}\n", DateTime.Now.ToString(@"dd/MM/yyyy HH:mm"));      
      content += "\n";
      content += "REM Change to directory containing this file\n";
      content += "CD /D %~dp0\n";
      content += "\n";
      content += "REM Run the PowerShell command line as Admin\n";
      content += String.Format("PowerShell -NoProfile -ExecutionPolicy Bypass \"& .\\{0}.ps1\"\n", this.name);
      content += "\n";
      if (bPause) content += "pause\n";
      //
      string generatedFileName = Path.Combine(AppSettings.workingFolder, "event.cmd");
      Logger.WriteLog(String.Format("write generated script for event ... {0}", this.name));
      System.IO.File.WriteAllText(generatedFileName, content);
    }

    #endregion

    #region AppEvent support methods
    // ******************************************************
    // support methods
    // ******************************************************

    private string GetPowerShellScriptHeader(string name)
    {
      string content = String.Empty;
      content += "###########################################################################\n";
      content += "# Copyright (C) 2019 Crayon Australia\n";
      content += String.Format("# Created at {0}\n", DateTime.Now.ToString(@"dd/MM/yyyy HH:mm"));      
      content += "###########################################################################\n";
      content += "\n";
      return content;
    }

    private string GetSqlScriptHeader(string name)
    {
      string content = String.Empty;
      content += "---------------------------------------------------------------------------\n";
      content += "-- Copyright (C) 2019 Crayon Australia\n";
      content += String.Format("-- Created at {0}\n", DateTime.Now.ToString(@"dd/MM/yyyy HH:mm"));      
      content += "---------------------------------------------------------------------------\n";
      content += "\n";
      return content;
    }

    #endregion

    #region Registry Get-Set methods
    // ******************************************************
    // registry string methods
    // ******************************************************

    public string RegGetStringItemValue(string item, string defaultvalue="")
    {
      string key = String.Format("{0}\\{1}", c_RegistryKey, _name);        
      string value = GetHKLMRegStringValue(key, item, defaultvalue);
      return value;
    }

    public bool RegSetStringItemValue(string item, string value)
    {
      string key = String.Format("{0}\\{1}", c_RegistryKey, _name);        
      SetHKLMRegStringValue(key, item, value);
      return true;
    }

    #endregion

    #region Registry Get-Set methods
    // ******************************************************
    // registry string methods
    // ******************************************************

    public string GetHKLMRegStringValue(string key, string name, string defaultvalue="", bool bit64=true)
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
        SetHKLMRegStringValue(key, name, defaultvalue, bit64);
        value = defaultvalue;
      }
      rk.Close();
      //
      return value;
    }

    public void SetHKLMRegStringValue(string key, string name, string value, bool bit64=true)
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

    public void DeleteHKLMRegValue(string key, string name, bool bit64=true)
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
 
    #region Registry hive methods
    // ******************************************************
    // registry key methods
    // ******************************************************

    public void CreateHKCURegKeyHive(string key=c_RegistryKey)
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

    public void CreateHKCURegKeySubKey(string subkeyname, string key=c_RegistryKey)
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
    // ******************************************************
    // registry key methods
    // ******************************************************

    public void CreateHKLMRegKeyHive(string key=c_RegistryKey)
    {
      RegistryKey rk = Registry.LocalMachine.OpenSubKey(key);
      if (rk == null)
      {
        rk = Registry.LocalMachine.CreateSubKey(key);
        if (rk == null)
        {
          throw new Exception(string.Format("Registry key '{0}' does not exist", key));
        }
      }
    }

    public void CreateHKLMRegKeySubKey(string subkeyname, string key=c_RegistryKey)
    {
      string subkey = String.Format("{0}\\{1}", key, subkeyname);
      RegistryKey rk = Registry.LocalMachine.OpenSubKey(subkey);
      if (rk == null)
      {
        rk = Registry.LocalMachine.CreateSubKey(subkey);
        if (rk == null)
        {
          throw new Exception(string.Format("Registry sub-key '{0}' does not exist", subkey));
        }
      }
    }

    #endregion

  }
  #endregion

}
