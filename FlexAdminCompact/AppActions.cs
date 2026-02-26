using System;
using System.Collections;
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

namespace BlackBox
{
  #region Class AppActions
  /// <summary>
  /// Summary description for AppActions class
  /// </summary>    
  static class AppActions
  {
    #region Constants
    // ******************************************************
    // public constants
    // ******************************************************

    private const string c_RegistryKey = @"SOFTWARE\Crayon\FlexAdmin\Actions";

    #endregion

    #region AppActions data   
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

    public static Hashtable groups;
    public static List<Hashtable> actionGroupsList = new List<Hashtable>();

    #endregion

    #region AppActions initialise
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
 
    #region Accessors    
   // ******************************************************
    // data accessors
    // ******************************************************
   
    public static AppAction appActionShellHelp
    {
      get
      {
        AppAction action = FindActionByName("ShellHelp");
        return action;
      }
    }
   
    public static AppAction appActionShellListModules
    {
      get
      {
        AppAction action = FindActionByName("ShellListModules");
        return action;
      }
    }
   
    public static AppAction appActionShellListTargets
    {
      get
      {
        AppAction action = FindActionByName("ShellListTargets");
        return action;
      }
    }
   
    public static AppAction appActionShellListInstalled
    {
      get
      {
        AppAction action = FindActionByName("ShellListInstalled");
        return action;
      }
    }
   
    public static AppAction appActionShellListTenants
    {
      get
      {
        AppAction action = FindActionByName("ShellListTenants");
        return action;
      }
    }

   // ******************************************************
    // data accessors
    // ******************************************************
   
    public static AppAction appSqlTest
    {
      get
      {
        AppAction action = FindActionByName("SQLTEST");
        return action;
      }
    }

    #endregion
  
    #region AppActions main methods
    // ******************************************************
    // main routines
    // ******************************************************

    public static bool RunAction(string name, bool redirect=false)
    {
      bool aok = false;
      string outFileName = String.Format("{0}.out", name);
      //
      AppAction action = FindActionByName(name);
      if (!String.IsNullOrEmpty(action.name))
      {
        aok = action.RunScript(redirect, outFileName);
      }
      return aok;
    }

    #endregion
  
    #region AppActions update methods
    // ******************************************************
    // main routines
    // ******************************************************

    public static bool UpdateAction(string name, bool enabled)
    {
      AppAction action = FindActionByName(name);
      if (!String.IsNullOrEmpty(action.name))
      {
        action.enabled = enabled;
        if (action.group == "custom")
        {
          AppActions.actionGroupsList[4].Remove(name);          
          AppActions.actionGroupsList[4].Add(name, action);
        }
        if (action.group == "maintenance")
        {
          AppActions.actionGroupsList[3].Remove(name);         
          AppActions.actionGroupsList[3].Add(name, action);
        }
        if (action.group == "bau")
        {
          AppActions.actionGroupsList[2].Remove(name);         
          AppActions.actionGroupsList[2].Add(name, action);
        }
        if (action.group == "standard")
        {
          AppActions.actionGroupsList[1].Remove(name);          
          AppActions.actionGroupsList[1].Add(name, action);
        }
        if (action.group == "shell")
        {
          AppActions.actionGroupsList[0].Remove(name);         
          AppActions.actionGroupsList[0].Add(name, action);
        }
        return true;
      }
      return false;
    }

    #endregion

    #region AppActions read methods
    // ******************************************************
    // read routines
    // ******************************************************

    /// <summary>
    /// ReadActionsRegistry
    /// </summary>
    /// <param name="filename"></param>

    public static bool ReadActionsRegistry()
    {
      groups = new Hashtable();     
      actionGroupsList.Clear();
      bool aok = AppActions.ReadActionsGroupFromRegistry("none", 0);
      if (aok)
      {
        AppActions.ReadActionsGroupFromRegistry("shell", 1);      	
        AppActions.ReadActionsGroupFromRegistry("bau", 2);
        AppActions.ReadActionsGroupFromRegistry("maintenance", 3);
        AppActions.ReadActionsGroupFromRegistry("custom", 4);

      }
      return aok;
    }

    /// <summary>
    /// ReadActionsFile
    /// </summary>
    /// <param name="filename"></param>

    public static bool ReadActionsFile(string filename)
    {
      groups = new Hashtable();     
      actionGroupsList.Clear();
      bool aok = AppActions.ReadActionsGroupFromFile(Path.Combine(AppSettings.workingFolder, filename), "none", 0);
      if (aok)
      {
        AppActions.ReadActionsGroupFromFile(Path.Combine(AppSettings.workingFolder, filename), "shell", 1);
        AppActions.ReadActionsGroupFromFile(Path.Combine(AppSettings.workingFolder, filename), "bau", 2);
        AppActions.ReadActionsGroupFromFile(Path.Combine(AppSettings.workingFolder, filename), "maintenance", 3);
        AppActions.ReadActionsGroupFromFile(Path.Combine(AppSettings.workingFolder, filename), "custom", 4);

      }
      return aok;
    }
      
    // ******************************************************
    // read routines
    // ******************************************************
      
    /// <summary>
    /// ReadCustomActionsGroupFromRegistry
    /// </summary>

    public static bool ReadActionsGroupFromRegistry(string group, int index)
    {
      Hashtable ht = new Hashtable();
      actionGroupsList.Add(ht);
      groups[group] = index;
      try
      {  
        RegistryKey rk = Registry.LocalMachine.OpenSubKey(c_RegistryKey);
        if (rk == null)
        {
          throw new Exception(string.Format("Registry key '{0}' does not exist", c_RegistryKey));
        }
        // itterate through all subkey names
        AppAction action;        
        foreach (var name in rk.GetSubKeyNames())
        {
          action = new AppAction(name);
          action.ReadFromRegistry(name);
          if (action.group.ToLower() == group.ToLower() || group.ToLower() == "none")
          {
            AppActions.actionGroupsList[index].Add(name, action);
          }
        }
      }
      catch (Exception ex) 
      {
        System.Windows.Forms.MessageBox.Show(ex.Message, "ReadActionsGroupFromRegistry", MessageBoxButtons.OK, MessageBoxIcon.Error);        
        return false;
      }
      return true;
    }
      
    // ******************************************************
    // read routines
    // ******************************************************
      
    /// <summary>
    /// ReadCustomActionsGroupFromFile
    /// </summary>
    /// <param name="filename"></param>

    public static bool ReadActionsGroupFromFile(string filename, string group, int index)
    {
      Hashtable ht = new Hashtable();
      actionGroupsList.Add(ht);
      groups[group] = index;
      try
      {  
        // create the XmlDocument
        XmlDocument doc = new XmlDocument();
        doc.Load(filename); 
        //
        // set xpath or group select 
        string gs = "/actions/action";
        if (!String.IsNullOrEmpty(group) && index > 0) gs = String.Format("/actions/action[@group='{0}']", group);
        //
        // read events settings
        XmlNodeList actionnodes = doc.DocumentElement.SelectNodes(gs);
        if (actionnodes != null)
        {
          AppAction action;
          string name, value;
          foreach (XmlNode node in actionnodes)
          {
            value = node.Attributes["name"].Value;
            if (value != null) 
            {
              name = value;          
              action = new AppAction(name);
              //              
              value = node.Attributes["group"].Value;
              if (!String.IsNullOrEmpty(value)) 
                action.group = value;          
              else
                action.group = "none";
              //
              //value = node.InnerText.Trim();
              value = node.Attributes["enabled"].Value;
              if (!String.IsNullOrEmpty(value) && value == "True") 
                action.enabled = true;
              else
                action.enabled = false;
              //              
              value = node.Attributes["scripttype"].Value;
              if (!String.IsNullOrEmpty(value)) 
                action.type = value;          
              else
                action.type = String.Empty;
              //
              value = GetNodeProperty(node, "description");
              if (!String.IsNullOrEmpty(value)) 
                action.description = value;
              else
                action.description = String.Empty;
              //
              value = GetNodeProperty(node, "label");
              if (!String.IsNullOrEmpty(value)) 
                action.label = value;
              else
                action.label = String.Empty;
              //
              value = GetNodeProperty(node, "script");
              action.script = value.Trim();
              //
              AppActions.actionGroupsList[index].Add(name, action);
            }
          }
        }
      }
      catch (Exception ex) 
      {
        System.Windows.Forms.MessageBox.Show(ex.Message, "ReadActionsGroupFromFile", MessageBoxButtons.OK, MessageBoxIcon.Error);        
        return false;
      }
      return true;
    }

    /// <summary>
    /// GetNodeProperty
    /// </summary>
    /// <param name="node"></param>
    /// <param name="nodeProperty"></param>    

    private static string GetNodeProperty(XmlNode node, string nodeProperty)
    {
      string value = String.Empty;
      try
      {  
        foreach(XmlNode child in node.ChildNodes)
        {
          if(child.Name == nodeProperty)
          {
            value = child.InnerText.Trim();
          }
        }       
      }
      catch (Exception ex) 
      {
        System.Windows.Forms.MessageBox.Show(ex.Message, "GetNodeProperty", MessageBoxButtons.OK, MessageBoxIcon.Error);        
      }
      return value;
    }

    #endregion

    #region AppActions write methods  
    // ******************************************************
    // write routines
    // ******************************************************

    /// <summary>
    /// WriteActionsFile
    /// </summary>
    /// <param name="name"></param>

    public static bool WriteActionsFile(string name, string filename="actions.xml")
    {
      try
      {
        string generatedFileName = Path.Combine(AppSettings.workingFolder, filename);       
        using (System.IO.StreamWriter file = new System.IO.StreamWriter(generatedFileName))
        {
          file.WriteLine("<?xml version=\"1.0\" standalone=\"yes\"?>");
          file.WriteLine(String.Format("<actions name=\"{0}\" updated=\"{1}\">", name, DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss")));          
          //  
          WriteActionsGroup(file, "shell", 1);
          WriteActionsGroup(file, "bau", 2);
          WriteActionsGroup(file, "maintenance", 3);
          WriteActionsGroup(file, "custom", 4);                                    
          //
          file.WriteLine(@"</actions>");
        }
      }
      catch (Exception ex) 
      {
        System.Windows.Forms.MessageBox.Show(ex.Message, "WriteActionsFile", MessageBoxButtons.OK, MessageBoxIcon.Error);
        return false;
      }
      return true;
    }

    // ******************************************************
    // write routines
    // ******************************************************

    /// <summary>
    /// WriteActionsFileCustom
    /// </summary>
    /// <param file="file"></param>

    private static bool WriteActionsGroup(System.IO.StreamWriter file, string group, int index)
    {
      try
      {
        string[] sep = { "\r\n" };
        string[] lines;
        //
        AppAction aa = null;
        int n = 1;
        foreach (string key in actionGroupsList[index].Keys)
        {
          aa = (AppAction)actionGroupsList[index][key];
          file.WriteLine(String.Format("  <action name=\"{0}\" group=\"{1}\" enabled=\"{2}\" scipttype=\"{3}\">", aa.name, aa.group, aa.enabled, aa.type));
          file.WriteLine(String.Format("    <description>{0}</description>", aa.description));
          file.WriteLine(String.Format("    <label>{0}</label>", aa.label));
          file.WriteLine("    <script>");
          file.WriteLine(@"      <![CDATA[");
          lines = aa.script.Split(sep,5000,0);
          foreach (string line in lines)
          {
            file.WriteLine(String.Format("{0}", line)); 
          }          
          file.WriteLine(@"      ]]>");
          file.WriteLine("     </script>");          
          file.WriteLine(@"  </action>");
          n++;
        }
      }
      catch (Exception ex) 
      {
        System.Windows.Forms.MessageBox.Show(ex.Message, "WriteActionsGroup", MessageBoxButtons.OK, MessageBoxIcon.Error);
        return false;
      }
      return true;
    }

    #endregion

    #region AppActions support methods
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
    
    // ******************************************************
    // support methods
    // ******************************************************
    /// <summary>
    /// Find action by name
    /// </summary>
    /// <param name="name"></param>
    /// <returns>AppAction</returns>

    public static AppAction FindActionByName(string name)
    {
      AppAction action = new AppAction("");
      //
      bool exists = false;      
      foreach (Hashtable ht in actionGroupsList)
      {
        exists = ht.ContainsKey(name);
        if (exists) 
        {
          action = (AppAction)ht[name];
          break;
        }
      }
      return action;
    }
    
    // ******************************************************
    // support methods
    // ******************************************************

    /// <summary>
    /// Find if an action exists
    /// </summary>
    /// <param name="name"></param>
    /// <returns>bool</returns>

    public static bool ActionExists(string name)
    {
      bool exists = false;      
      foreach (Hashtable ht in actionGroupsList)
      {
        exists = ht.ContainsKey(name);
        if (exists) break;
      }
      return exists;
    }

    #endregion

  }
  #endregion

  #region Class AppAction
  /// <summary>
  /// Summary description for AppAction class
  /// </summary>    
  class AppAction
  {
    #region Constants
    // ******************************************************
    // public constants
    // ******************************************************

    private const string c_RegistryKey = @"SOFTWARE\Crayon\FlexAdmin\Actions";

    #endregion
    
    #region AppAction data   
    // ******************************************************
    // public data
    // ******************************************************

    // status 
    public string error = String.Empty;

    // properties
    public string _name = String.Empty;
    public string _group = String.Empty;    
    public string _description = String.Empty;
    public string _script = String.Empty;
    public string _label = String.Empty;
    public string _type = "ps1";    
    //
    public bool _enabled = false;

    #endregion

    #region AppAction constructors
    // ******************************************************
    // constructors
    // ******************************************************
          
    public AppAction()    
    {
      CreateHKLMRegKeyHive(c_RegistryKey);
    }
          
    public AppAction(string name)
    {
      CreateHKLMRegKeyHive(c_RegistryKey);
      CreateHKLMRegKeySubKey(name, c_RegistryKey);   
      this.name = name;
    }

    #endregion

    #region Accessors    
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

    public string group
    {
      get
      {
        string value = this._group;
        return value;
      }
      set
      {
        this._group = value;
        this.rstrGroup = value;
      }
    }

    public string description
    {
      get
      {
        string value = this._description;
        return value;
      }
      set
      {
        this._description = value;
        this.rstrDescription = value;       
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

    public string label
    {
      get
      {
        string value = this._label;
        return value;
      }
      set
      {
        this._label = value;
        this.rstrLabel = value;       
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

    #region Registry Accessors
    // ******************************************************
    // data accessors
    // ******************************************************

    public string rstrGroup
    {
      get
      {
        string value = RegGetStringItemValue("Group", "custom");
        return value;
      }
      set
      {
        RegSetStringItemValue("Group", value); 
      }
    }

    public string rstrDescription
    {
      get
      {
        string value = RegGetStringItemValue("Description", "");
        return value;
      }
      set
      {
        RegSetStringItemValue("Description", value); 
      }
    }

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

    public string rstrLabel
    {
      get
      {
        string value = RegGetStringItemValue("Label", "");
        return value;
      }
      set
      {
        RegSetStringItemValue("Label", value); 
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

    #region AppAction main methods
    // ******************************************************
    // main routines
    // ******************************************************

    public bool ReadFromRegistry(string name)
    {   
      this._name = name;
      this._group = this.rstrGroup;
      this._description = this.rstrDescription;
      this._script = this.rstrScript;
      this._label = this.rstrLabel;
      this._type = this.rstrType;
      this._enabled = this.rbEnabled;
      //
      return true;
    }

    #endregion

    #region AppAction processing methods
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
        Logger.WriteLog(String.Format("process [{0}] action ... {1}", this.type, this.name));
        try
        {   
          string content = String.Empty;
          if (this.type.ToLower() == "sql") content += GetSqlScriptHeader(this.name);
          if (this.type.ToLower() == "ps1") content += GetPowerShellScriptHeader(this.name);          
          content += String.Format("{0}\n", this.script);
          content += "\n";
          //
          System.IO.File.WriteAllText(Path.Combine(AppSettings.workingFolder, String.Format("{0}.{1}", this.name, this.type)), content);
          WriteShellScript(!redirect);  // pause = !redirect
          //
          string commandline;
          if (redirect)
          {
            commandline = Path.Combine(AppSettings.workingFolder, "action.cmd");
            runOK = RunWithRedirection(this.name, commandline, outFileName, "action");
          }
          else
          {
            commandline = Path.Combine(AppSettings.workingFolder, "action.cmd");
            runOK = RunWithShell(this.name, commandline, "action");
          }
        }
        catch (Exception ex)
        {
          MessageBox.Show(ex.Message, String.Format("Action({0})", this.name), MessageBoxButtons.OK, MessageBoxIcon.Error);
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
    // write routines
    // ******************************************************

    public void WriteShellScript(bool bPause=false)
    {
      string scriptFileName = Path.Combine(AppSettings.workingFolder, String.Format("{0}.{1}", this.name, this.type));
      string content = String.Empty;
      content += "@ECHO OFF\n";
      content += "REM Autogenerated by FlexAdmin to run an action script\n";
      content += String.Format("REM Source event was {0}\n", this.name);
      content += String.Format("REM Created at {0}\n", DateTime.Now.ToString(@"dd/MM/yyyy HH:mm"));      
      content += "\n";
      content += "REM Change to directory containing this file\n";
      content += "CD /D %~dp0\n";
      content += "\n";
      content += "REM Run the command line as Admin\n";
      if (type.ToLower() == "sql") content += String.Format("sqlcmd.exe -S {0} -d {1} -e -i \"{2}\"\n", AppSettings.sqlServer, AppSettings.sqlDatabase, scriptFileName);
      if (type.ToLower() == "ps1") content += String.Format("PowerShell -NoProfile -ExecutionPolicy Bypass \"& {0}\"\n", scriptFileName);
      content += "\n";
      if (bPause) content += "pause\n";
      //
      string generatedFileName = Path.Combine(AppSettings.workingFolder, "action.cmd");
      Logger.WriteLog(String.Format("write generated script for action ... {0}", this.name));
      System.IO.File.WriteAllText(generatedFileName, content);
    }

    #endregion

    #region AppAction support methods
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
