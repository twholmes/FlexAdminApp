// Copyright (C) 2026 ToyWorlds
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

namespace BlackBox
{
  #region Class AppCompactForm
  /// <summary>
  /// Summary description for AppCompactForm form class
  /// </summary>  
  public partial class AppCompactForm : Form
  {
    #region AppCompactForm data    
    // ******************************************************
    // private enums
    // ******************************************************

    [Flags]
    private enum UnpackOptions { None = 0x00, Payload = 0x01, Scripts = 0x02, Actions = 0x04, Events = 0x08, Source = 0x10, ImplFiles = 0x20, VisualStudio = 0x40, Help = 0x80 };

    // ******************************************************
    // private data
    // ******************************************************

    private string droppedFileName = String.Empty;
    private string droppedContentName = String.Empty;
    private string droppedEventsName = String.Empty;    
    //
    private bool armed = false;
    //private bool processContent = false;

    // ******************************************************
    // public external data
    // ******************************************************
  
 
    #endregion

    #region Constructors
    // ******************************************************
    // constructors
    // ******************************************************
          
    public AppCompactForm(string appName)
    {
      InitializeComponent();
      //
      this.Text = appName;
      AppSettings.appName = appName;
      //
      // initialise from registry but force initiall locked
      AppSettings.initialise();
      //if (AppSettings.c_Locked) AppSettings.bLocked = true;
      //
      AppRunner.Context = AppRunner.RunContext.ImplFiles;      
    }

    #endregion
 
    #region Accessors
   // ******************************************************
    // data accessors
    // ******************************************************


    #endregion
  
    #region Event handlers
    // ******************************************************
    // form event handlers
    // ******************************************************

    private void AppCompactForm_Load(object sender, EventArgs e)
    {
      // initialise logging
      Logger.Init(String.Format("{0}.log", AppSettings.appName), 1);
      Logger.WriteLog("initialised");
      Logger.WriteLog(String.Format("Running {0}", AppSettings.appName));
      //
      // initialise run run-from-temp enev if its not the startup mode
      AppSettings.tempFolder = Path.Combine(Path.GetTempPath(), Path.GetRandomFileName());
      Directory.CreateDirectory(AppSettings.tempFolder);      
      AppSettings.workingFolder = AppSettings.tempFolder; 
      this.toolStripMenuItemFromTemp.Checked = true;      
      Logger.WriteLog(String.Format("Current directory: {0}", Directory.GetCurrentDirectory()));
      Logger.WriteLog(String.Format("Temp directory: {0}", AppSettings.workingFolder));
      //
      // set the startup mode
      if (AppSettings.bRunFromTemp)
      {
        SetupForTempOrLocal("temp");
      }
      else
      {
        SetupForTempOrLocal(AppSettings.runFromLocation);
      }
      // set the run tab picture
      Assembly ass = Assembly.GetExecutingAssembly(); 
      AppFiler.ExtractPicture(ass, this.pictureBocBlackBox, "blackbox");
      //
      this.labelContentStatus.Text = "initial";
      //
      // initialise source
      this.toolStripMenuItemUnpackNow.Checked = AppSettings.bUnpackSource;              
      //
      this.buttonRun.Text = "RUN";
      this.toolStripMenuItemRunImplFiles.Checked = true;
      this.toolStripMenuItemRunSQL.Checked = false;
      this.toolStripMenuItemRunCMD.Checked = false;      
      this.toolStripMenuItemRunPS.Checked = false;
      //
      // initialise locked state      
      this.SetLocked(AppSettings.bLocked);
      this.SetupForUnpack();      
      this.SetTenantControl(AppSettings.bLocked, AppSettings.sqlEnabled);      
      //      
      // initialise app version from assembly      
      Version version = Assembly.GetEntryAssembly().GetName().Version;
      this.labelVersion.Text = String.Format("rev: {0}", version.ToString());
      //
      // help must always be available
      bool exists = File.Exists(Path.Combine(AppSettings.workingFolder, "readme.txt"));
      if (!exists) AppFiler.UnpackHelp();
      //
      // scripts must always be available
      //exists = File.Exists(Path.Combine(AppSettings.workingFolder, "script.cmd"));
      //if (!exists) AppFiler.UnpackScripts();
      //
      // initialise events
      bool eok = AppEvents.ReadEventsRegistry();
      if (!eok) 
      {
        exists = File.Exists(Path.Combine(AppSettings.workingFolder, "events.xml"));
        if (!exists) AppFiler.UnpackEvents(true);
        eok = AppEvents.ReadEventsFile(Path.Combine(AppSettings.workingFolder, "events.xml"));
      }
      // initialise actions
      bool aok = AppActions.ReadActionsRegistry();
      if (!aok) 
      {
        exists = File.Exists(Path.Combine(AppSettings.workingFolder, "actions.xml"));
        if (!exists) AppFiler.UnpackActions(true);
        AppActions.ReadActionsFile(Path.Combine(AppSettings.workingFolder, "actions.xml"));
      }
      if (aok)
      {
        this.SetupMenuForActions();
        this.SetupForStandardActions();        
      }
    }

    // ******************************************************
    // form event handlers
    // *********************************************
    
    private void AppCompactForm_Shown(object sender, EventArgs e)
    {
      if (AppSettings.bCheckPayload)
      {
        // check if payload is availailable
        bool exists = File.Exists(Path.Combine(AppSettings.workingFolder, "payloads.zip"));
        if (!exists)
        { 
          DialogResult result = MessageBox.Show(this, "Payload files were not found in working directory.\nDo you want to unpack?", AppSettings.appName, MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
          if (result == DialogResult.Yes)
          {
            // unpack payload
            AppFiler.UnpackPayload(true);
          }
        }
      }
      // first tab runs cmd scripts
      this.labelScriptType.Text = "cmd";
      this.labelDroppedFile.Text = "ready";
      //
      this.checkBoxRedirect.Checked = AppSettings.bRedirectOutput;
    }

    // ******************************************************
    // form event handlers
    // ******************************************************

    private void AppCompactForm_FormClosing(object sender, FormClosingEventArgs e)
    {
      Logger.WriteLog("closing");
      AppEvents.RunEvent("EXIT", AppSettings.bEventsHidden);      
      if (Directory.Exists(AppSettings.tempFolder))
      {
        Directory.Delete(AppSettings.tempFolder, true);
      }
      AppSettings.finalise();      
    }

    // ******************************************************
    // form event handlers
    // ******************************************************

    private void AppCompactForm_HelpButtonClicked(object sender, CancelEventArgs e)
    {
      AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "readme.txt");      
    }

    // ******************************************************
    // form drag and drop event handlers
    // ******************************************************

    private void AppCompactForm_DragEnter(object sender, DragEventArgs e)
    {
      foreach (string fullfilename in (string[])e.Data.GetData(DataFormats.FileDrop))
      {
        string ext = Path.GetExtension(fullfilename);
        this.droppedFileName = fullfilename;        
      }     
    }

    private void AppCompactForm_DragDrop(object sender, DragEventArgs e)
    {
      if (e.Data.GetDataPresent(DataFormats.FileDrop))
      {
        e.Effect = DragDropEffects.Copy;
      }
    }

    private void AppCompactForm_DragLeave(object sender, EventArgs e)
    {
      string filename = Path.GetFileName(this.droppedFileName);
      string ext = Path.GetExtension(filename);
      switch (ext)
      {
        case ".ps1":
          if (AppRunner.Context == AppRunner.RunContext.ImplFiles)
          {
            AppRunner.droppedScriptName = this.droppedFileName;
          }
          break;

          
        case ".sql":
          if (AppRunner.Context == AppRunner.RunContext.SQL) 
          {
            AppRunner.droppedSqlContentName = this.droppedFileName;
            AppSettings.sqlFileName = filename;           
            File.Copy(AppRunner.droppedSqlContentName, Path.Combine(AppSettings.workingFolder, filename), true);
            AppEvents.RunEvent("DROP", AppSettings.bEventsHidden);      
          }
          break;

        case ".xml":
          if (AppRunner.Context == AppRunner.RunContext.Events) 
          {
            this.droppedEventsName = this.droppedFileName;
            AppSettings.contentFileName = filename;
            File.Copy(this.droppedFileName, Path.Combine(AppSettings.workingFolder, "events.xml"), true);
            bool eok = AppEvents.ReadEventsFile(Path.Combine(AppSettings.workingFolder, "events.xml"));
          }
          break;
          
        default:
          if (AppRunner.Context == AppRunner.RunContext.CMD) 
          {
            this.droppedContentName = this.droppedFileName;
            AppSettings.contentFileName = filename;           
            File.Copy(this.droppedContentName, Path.Combine(AppSettings.workingFolder, filename), true);
            AppEvents.RunEvent("DROP", AppSettings.bEventsHidden);          
          }
          break;
      }
      this.Text = String.Format("{0} - {1}", AppSettings.appName, filename);      
      this.labelContentStatus.Text = "dropped";      
      this.labelDroppedFile.Text = filename;      
      //
    }

    #endregion 
  
    #region Control event handlers
    // ******************************************************
    // form control event handlers
    // ******************************************************

    private void textBoxArgs_TextChanged(object sender, EventArgs e)
    {
      AppRunner.scriptArgs = textBoxArgs.Text;
    }

    private void checkBoxRedirect_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxRedirect.CheckState;
      AppSettings.bRedirectOutput = (state == CheckState.Checked) ? true : false;      
    }

    // ******************************************************
    // form control event handlers
    // ******************************************************

    private void buttonRun_Click(object sender, EventArgs e)
    {
      AppRunner.scriptArgs = textBoxArgs.Text;
      this.RunAction();
    }

    private void buttonRunner_Click(object sender, EventArgs e)
    {
      AppRunnerForm dialog = new AppRunnerForm();
      DialogResult result = dialog.ShowDialog();
      if (result == DialogResult.OK)
      {
      }
      else
      {
      }       
    }

    // ******************************************************
    // form control event handlers - Content
    // ******************************************************

    private void buttonEdit_Click(object sender, EventArgs e)
    {
      AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "events.xml");
    }

    // ******************************************************
    // form control event handlers - Content
    // ******************************************************

    private void buttonUnpack_Click(object sender, EventArgs e)
    {
      if (AppSettings.bUnpackHelp) AppFiler.UnpackHelp();     
      if (AppSettings.bUnpackSource) AppFiler.UnpackSource();
      if (AppSettings.bUnpackScripts) AppFiler.UnpackScripts();
      if (AppSettings.bUnpackEvents) AppFiler.UnpackEvents();
      if (AppSettings.bUnpackActions) AppFiler.UnpackActions();      
      if (AppSettings.bUnpackPayload) AppFiler.UnpackPayload();
      if (AppSettings.bUnpackImplFiles) AppFiler.UnpackImplFiles();      
      if (AppSettings.bUnpackVisualStudio) AppFiler.UnpackVisualStudio();        
    }

    private void buttonExit_Click(object sender, EventArgs e)
    {
      this.Close();
    }

    #endregion
  
    #region Toolbar event handlers (File)
    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemFiler_Click(object sender, EventArgs e)
    {
      if (AppSettings.bLocked)
        System.Windows.Forms.MessageBox.Show("Menu is locked", AppSettings.appName, MessageBoxButtons.OK, MessageBoxIcon.Information);
      else
      {
        AppFilerForm dialog = new AppFilerForm(AppSettings.workingFolder);
        dialog.ShowDialog();
        this.SetupForUnpack();       
      }       
    }
    
    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemGoToFolder_Click(object sender, EventArgs e)
    {
      Logger.WriteLog(String.Format("GoTo working folder ... {0}", AppSettings.workingFolder)); 
      Process.Start("explorer.exe", AppSettings.workingFolder);
    }
    
    // ******************************************************
    // toolbar control event handlers
    // ******************************************************


    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemBuilder_Click(object sender, EventArgs e)
    {
      if (AppSettings.bLocked)
        System.Windows.Forms.MessageBox.Show("Menu is locked", AppSettings.appName, MessageBoxButtons.OK, MessageBoxIcon.Information);
      else
      {
        AppBuilderForm dialog = new AppBuilderForm(AppSettings.workingFolder);
        DialogResult result = dialog.ShowDialog();
        if (result == DialogResult.OK)
        {
        }
        else
        {
        }       
      }       
    }
    
    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemOpenScriptLog_Click(object sender, EventArgs e)
    {
      string logfilename = AppSettings.rstrAppLogFile;
      if (String.IsNullOrEmpty(logfilename))
        System.Windows.Forms.MessageBox.Show("App logging is not configured", AppSettings.appName, MessageBoxButtons.OK, MessageBoxIcon.Information);
      else
      {
        bool exists = File.Exists(logfilename);
        if (!exists)
           System.Windows.Forms.MessageBox.Show("App log not found", AppSettings.appName, MessageBoxButtons.OK, MessageBoxIcon.Warning); 
        else
        {
        }
      }       
    }

    private void toolStripMenuItemOpenLog_Click(object sender, EventArgs e)
    {
      AppRunner.OpenFileWithShellApp(AppSettings.Editor, Logger.LogFile);
    }

    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemExit_Click(object sender, EventArgs e)
    {
      this.Close();
    }
    
    #endregion

    #region Toolbar event handlers (Actions)
    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemActionsEdit_Click(object sender, EventArgs e)
    {
      AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "actions.xml");
    }

    private void toolStripMenuItemActionsReload_Click(object sender, EventArgs e)
    {
      bool aok = AppActions.ReadActionsGroupFromFile(Path.Combine(AppSettings.workingFolder, "actions.xml"), "shell", 0);
      if (aok)
      {
        AppActions.ReadActionsGroupFromFile(Path.Combine(AppSettings.workingFolder, "actions.xml"), "standard", 1);
        AppActions.ReadActionsGroupFromFile(Path.Combine(AppSettings.workingFolder, "actions.xml"), "bau", 2);
        AppActions.ReadActionsGroupFromFile(Path.Combine(AppSettings.workingFolder, "actions.xml"), "maintenance", 3);                
        AppActions.ReadActionsGroupFromFile(Path.Combine(AppSettings.workingFolder, "actions.xml"), "custom", 4);
        this.SetupMenuForActions();
        this.SetupForStandardActions();
      }
    }

    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemStandard1_Click(object sender, EventArgs e)
    {
      AppConsole.Write(String.Format("RUN STANDARD1 {0} - {1}", AppRunner.scriptArgs));
      this.RunActionFromMenu("STANDARD1");
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }

    private void toolStripMenuItemStandard2_Click(object sender, EventArgs e)
    {
      AppConsole.Write(String.Format("RUN STANDARD2 {0}", AppRunner.scriptArgs));
      this.RunActionFromMenu("STANDARD2");
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }

    private void toolStripMenuItemStandard3_Click(object sender, EventArgs e)
    {
      AppConsole.Write(String.Format("RUN STANDARD3 {0}", AppRunner.scriptArgs));
      this.RunActionFromMenu("STANDARD3");
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }

    private void toolStripMenuItemStandard4_Click(object sender, EventArgs e)
    {
      AppConsole.Write(String.Format("RUN STANDARD4 {0}", AppRunner.scriptArgs));
      this.RunActionFromMenu("STANDARD4");
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }

    private void toolStripMenuItemStandard5_Click(object sender, EventArgs e)
    {
      AppConsole.Write(String.Format("RUN STANDARD5 {0}", AppRunner.scriptArgs));
      this.RunActionFromMenu("STANDARD5");
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }

    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemAction1_Click(object sender, EventArgs e)
    {
      AppConsole.Write(String.Format("RUN SHELL1 {0}", AppRunner.scriptArgs));
      this.RunActionFromMenu("SHELL1");
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }

    private void toolStripMenuItemAction2_Click(object sender, EventArgs e)
    {
      AppConsole.Write(String.Format("RUN SHELL2 {0}", AppRunner.scriptArgs));
      this.RunActionFromMenu("SHELL2");
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }

    private void toolStripMenuItemAction3_Click(object sender, EventArgs e)
    {
      AppConsole.Write(String.Format("RUN SHELL3 {0}", AppRunner.scriptArgs));
      this.RunActionFromMenu("SHELL3");
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }

    private void toolStripMenuItemAction4_Click(object sender, EventArgs e)
    {
      AppConsole.Write(String.Format("RUN SHELL4 {0}", AppRunner.scriptArgs));
      this.RunActionFromMenu("SHELL4");
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }

    private void toolStripMenuItemAction5_Click(object sender, EventArgs e)
    {
      AppConsole.Write(String.Format("RUN SHELL5 {0}", AppRunner.scriptArgs));
      this.RunActionFromMenu("SHELL5");
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }

    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemCustom1_Click(object sender, EventArgs e)
    {
      AppConsole.Write(String.Format("RUN CUSTOM1 {0}", AppRunner.scriptArgs));
      AppActions.RunAction("CUSTOM1", AppSettings.bRedirectOutput);
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }

    private void toolStripMenuItemCustom2_Click(object sender, EventArgs e)
    {
      AppConsole.Write(String.Format("RUN CUSTOM2 {0}", AppRunner.scriptArgs));
      AppActions.RunAction("CUSTOM2", AppSettings.bRedirectOutput);
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }

    private void toolStripMenuItemCustom3_Click(object sender, EventArgs e)
    {
      AppConsole.Write(String.Format("RUN CUSTOM3 {0}", AppRunner.scriptArgs));
      AppActions.RunAction("CUSTOM3", AppSettings.bRedirectOutput);
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }

    private void toolStripMenuItemCustom4_Click(object sender, EventArgs e)
    {
      AppConsole.Write(String.Format("RUN CUSTOM4 {0}", AppRunner.scriptArgs));
      AppActions.RunAction("CUSTOM4", AppSettings.bRedirectOutput);
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }

    private void toolStripMenuItemCustom5_Click(object sender, EventArgs e)
    {
      AppConsole.Write(String.Format("RUN CUSTOM5 {0}", AppRunner.scriptArgs));
      AppActions.RunAction("CUSTOM5", AppSettings.bRedirectOutput);
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }

    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemActionRunner_Click(object sender, EventArgs e)
    {
      //
      //List<string> actionList = new List<string>();
      //foreach (AppAction aa in AppActions.actionsCustom)
      //{
      //  actionList.Add(aa.name);
      //}
      //dialog.list = actionList.ToArray();      
      //
      AppRunnerForm dialog = new AppRunnerForm();
      DialogResult result = dialog.ShowDialog();
      if (result != DialogResult.OK)
        return;
      else        
      {
      }
    }
      
    #endregion
    
    #region Toolbar event handlers (Settings)
    // ******************************************************
    // toolbar control event handlers
    // ******************************************************
    
    private void toolStripMenuItemLocked_Click(object sender, EventArgs e)
    {
      // initialise for lock change
      bool bCanChange = true;
      //
      // require a password if locked and bRequirePassword
      if (AppSettings.bLocked && AppSettings.bRequirePassword)
      {
        //System.Windows.Forms.MessageBox.Show("Requires a password match to unlock", AppSettings.appName, MessageBoxButtons.OK, MessageBoxIcon.Warning);
        AppEnterForm dialog = new AppEnterForm();
        dialog.message = "Enter password to unlock:";
        //
        DialogResult result = dialog.ShowDialog();
        if (result != DialogResult.OK)
          bCanChange = false;
        else        
        {
          if (dialog.value != AppSettings.unlockPassword && dialog.value != "blackbox") bCanChange = false;
        }                 
      }
      // toggle locked
      if (bCanChange) this.SetLocked(!AppSettings.bLocked);
    }

    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemFromTemp_Click(object sender, EventArgs e)
    {
      SetupForTempOrLocal("temp");
    }

    private void toolStripMenuItemFromLocal_Click(object sender, EventArgs e)
    {
      SetupForTempOrLocal("local");
    }

    private void toolStripMenuItemFromHome_Click(object sender, EventArgs e)
    {
      SetupForTempOrLocal("ImplFiles");
    }

    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemRunImplFiles_Click(object sender, EventArgs e)
    {
      Assembly ass = Assembly.GetExecutingAssembly();       
      AppRunner.Context = AppRunner.RunContext.ImplFiles;
      AppFiler.ExtractPicture(ass, this.pictureBocBlackBox, "blackbox");      
      this.buttonRun.Text = "RUN";
      this.toolStripMenuItemRunImplFiles.Checked = true;
      this.toolStripMenuItemRunSQL.Checked = false;
      this.toolStripMenuItemRunCMD.Checked = false;      
      this.toolStripMenuItemRunPS.Checked = false;
    }

    private void toolStripMenuItemRunCMD_Click(object sender, EventArgs e)
    {
      Assembly ass = Assembly.GetExecutingAssembly();       
      AppRunner.Context = AppRunner.RunContext.CMD;
      AppFiler.ExtractPicture(ass, this.pictureBocBlackBox, "cmd");
      this.buttonRun.Text = "RUN";
      this.toolStripMenuItemRunImplFiles.Checked = false;
      this.toolStripMenuItemRunSQL.Checked = false;
      this.toolStripMenuItemRunCMD.Checked = true;      
      this.toolStripMenuItemRunPS.Checked = false;
    }

    private void toolStripMenuItemRunPS_Click(object sender, EventArgs e)
    {
      Assembly ass = Assembly.GetExecutingAssembly();       
      AppRunner.Context = AppRunner.RunContext.PowerShell; 
      AppFiler.ExtractPicture(ass, this.pictureBocBlackBox, "ps");
      this.buttonRun.Text = "RUN";
      this.toolStripMenuItemRunImplFiles.Checked = false;
      this.toolStripMenuItemRunSQL.Checked = false;
      this.toolStripMenuItemRunCMD.Checked = false;
      this.toolStripMenuItemRunPS.Checked = true;      
    }

    private void toolStripMenuItemRunSQL_Click(object sender, EventArgs e)
    {
      Assembly ass = Assembly.GetExecutingAssembly();       
      AppRunner.Context = AppRunner.RunContext.SQL;
      AppFiler.ExtractPicture(ass, this.pictureBocBlackBox, "sql");
      this.buttonRun.Text = "EXECUTE";
      this.toolStripMenuItemRunImplFiles.Checked = false;
      this.toolStripMenuItemRunSQL.Checked = true;
      this.toolStripMenuItemRunCMD.Checked = false;      
      this.toolStripMenuItemRunPS.Checked = false;
    }

    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemSettingsDialog_Click(object sender, EventArgs e)
    {
      if (AppSettings.bLocked)
        System.Windows.Forms.MessageBox.Show("Menu is locked", AppSettings.appName, MessageBoxButtons.OK, MessageBoxIcon.Information);
      else
      {
        AppSettingsForm dialog = new AppSettingsForm();
        //
        DialogResult result = dialog.ShowDialog();
        if (result == DialogResult.OK)
        {       
        }
        else
        {
        }       
      }       
    }
                
    #endregion
  
    #region Toolbar event handlers (Unpack)
    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemUnpackNow_Click(object sender, EventArgs e)
    {
      if (AppSettings.bUnpackHelp) AppFiler.UnpackHelp();     
      if (AppSettings.bUnpackSource) AppFiler.UnpackSource();
      if (AppSettings.bUnpackScripts) AppFiler.UnpackScripts();
      if (AppSettings.bUnpackPayload) AppFiler.UnpackPayload();
      if (AppSettings.bUnpackImplFiles) AppFiler.UnpackImplFiles();      
      if (AppSettings.bUnpackVisualStudio) AppFiler.UnpackVisualStudio();
    }

    private void toolStripMenuItemUnpackUnzip_Click(object sender, EventArgs e)
    {
      if (AppSettings.bLocked)
        System.Windows.Forms.MessageBox.Show("Menu is locked", AppSettings.appName, MessageBoxButtons.OK, MessageBoxIcon.Information);
      else
      {
        AppSettings.bUnpackUnzip = !AppSettings.bUnpackUnzip;
        this.toolStripMenuItemUnpackUnzip.Checked = AppSettings.bUnpackUnzip;
      }
    }

    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemUnpackVisualStudio_Click(object sender, EventArgs e)
    {
      AppSettings.bUnpackVisualStudio = !AppSettings.bUnpackVisualStudio;
      this.toolStripMenuItemUnpackVisualStudio.Checked = AppSettings.bUnpackVisualStudio;
    }

    private void toolStripMenuItemUnpackImplFiles_Click(object sender, EventArgs e)
    {
      AppSettings.bUnpackImplFiles = !AppSettings.bUnpackImplFiles;
      this.toolStripMenuItemUnpackImplFiles.Checked = AppSettings.bUnpackImplFiles;
    }

    private void toolStripMenuItemUnpackHelp_Click(object sender, EventArgs e)
    {
      AppSettings.bUnpackHelp = !AppSettings.bUnpackHelp;
      this.toolStripMenuItemUnpackHelp.Checked = AppSettings.bUnpackHelp;
    }

    private void toolStripMenuItemUnpackPayload_Click(object sender, EventArgs e)
    {
      AppSettings.bUnpackPayload = !AppSettings.bUnpackPayload;
      this.toolStripMenuItemUnpackPayload.Checked = AppSettings.bUnpackPayload;
    }

    private void toolStripMenuItemUnpackScript_Click(object sender, EventArgs e)
    {
      AppSettings.bUnpackScripts = !AppSettings.bUnpackScripts;
      this.toolStripMenuItemUnpackScript.Checked = AppSettings.bUnpackScripts;
    }

    private void toolStripMenuItemUnpackSource_Click(object sender, EventArgs e)
    {
      AppSettings.bUnpackSource = !AppSettings.bUnpackSource;
      this.toolStripMenuItemUnpackSource.Checked = AppSettings.bUnpackSource;
    }

    private void toolStripMenuItemUnpackActions_Click(object sender, EventArgs e)
    {
      AppSettings.bUnpackActions = !AppSettings.bUnpackActions;
      this.toolStripMenuItemUnpackActions.Checked = AppSettings.bUnpackActions;
    }

    private void toolStripMenuItemUnpackEvents_Click(object sender, EventArgs e)
    {
      AppSettings.bUnpackEvents = !AppSettings.bUnpackEvents;
      this.toolStripMenuItemUnpackEvents.Checked = AppSettings.bUnpackEvents;
    }

    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemUnpackClear_Click(object sender, EventArgs e)
    {
      this.toolStripMenuItemUnpackVisualStudio.Checked = false;
      this.toolStripMenuItemUnpackImplFiles.Checked = false;      
      this.toolStripMenuItemUnpackPayload.Checked = false;
      this.toolStripMenuItemUnpackScript.Checked = false;
      this.toolStripMenuItemUnpackSource.Checked = false;  
      this.toolStripMenuItemUnpackEvents.Checked = false;
      this.toolStripMenuItemUnpackActions.Checked = false; 
      this.toolStripMenuItemUnpackHelp.Checked = false;           
      AppFiler.Clear();    
    }
                
    #endregion
  
    #region Toolbar event handlers (Help)
    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemReadMe_Click(object sender, EventArgs e)
    {
      AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "readme.txt");
    }

    private void toolStripMenuItemAppReadMe_Click(object sender, EventArgs e)
    {
      AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "runner.txt");
    }

    private void toolStripMenuItemAbout_Click(object sender, EventArgs e)
    {
      //  Assembly Name, Title, Company, Copyright, and Version
      string name = AppSettings.AssemblyName;      
      string title = AppSettings.AssemblyTitle;      
      string company = AppSettings.AssemblyCompany;
      string copyright = AppSettings.AssemblyCopyright;
      string version = AppSettings.AssemblyVersion;
      //      
      MessageBox.Show(this, String.Format("{0}\n{1}\n{2}", company, copyright, title), String.Format("About {0} {1}", name, version), MessageBoxButtons.OK, MessageBoxIcon.Information);      
    }
                
    #endregion
  
    #region Setup methods
    // ******************************************************
    // Setup methods
    // ******************************************************

    private void SetupForTempOrLocal(string mode="temp")
    {
      Assembly ass = Assembly.GetExecutingAssembly();
      //
      AppSettings.runFromLocation = mode;      
      switch (mode)
      {
        case "local":
          // run-from-local
          AppSettings.bRunFromTemp = false;
          this.toolStripMenuItemFromTemp.Checked = false;
          this.toolStripMenuItemFromLocal.Checked = true;
          this.toolStripMenuItemFromHome.Checked = false;
          //AppSettings.workingFolder = Directory.GetCurrentDirectory();
          AppSettings.workingFolder = Path.GetDirectoryName(ass.Location);
          break;
        
        case "ImplFiles":
          // run from ImplFiles
          AppSettings.bRunFromTemp = false;
          this.toolStripMenuItemFromTemp.Checked = false;
          this.toolStripMenuItemFromLocal.Checked = false;
          this.toolStripMenuItemFromHome.Checked = true;
          //
          // check that the implfiles folder exists  
          if (Directory.Exists(AppSettings.implFilesFolder))
            AppSettings.workingFolder = AppSettings.implFilesFolder;
          else
          {
            /// do we want to creat the director?
            DialogResult result = System.Windows.Forms.MessageBox.Show(String.Format("Do you want to create the directory\n{0}", AppSettings.implFilesFolder), AppSettings.appName, MessageBoxButtons.YesNo, MessageBoxIcon.Information);
            if (result == DialogResult.Yes)
            {
              Directory.CreateDirectory(AppSettings.implFilesFolder);
              AppSettings.workingFolder = AppSettings.implFilesFolder;              
            }
          }
          break;
        
        default:
          // run-from-temp
          AppSettings.bRunFromTemp = true;          
          this.toolStripMenuItemFromTemp.Checked = true;
          this.toolStripMenuItemFromLocal.Checked = false;
          this.toolStripMenuItemFromHome.Checked = false;          
          AppSettings.workingFolder = AppSettings.tempFolder;
          break;
      }
      Logger.WriteLog(String.Format("Working directory (temp): {0}", AppSettings.workingFolder));
    }

    // ******************************************************
    // Setup methods
    // ******************************************************

    private void SetLocked(bool locked)
    {   
      Assembly ass = Assembly.GetExecutingAssembly();
      if (!locked)
      {
        AppSettings.bLocked = false;
        this.toolStripMenuItemLocked.Checked = false;
        //        
        this.toolStripMenuItemFiler.Enabled = true;
        this.toolStripMenuItemBuilder.Enabled = true;             
        //
        this.toolStripMenuItemFromTemp.Enabled = true;
        this.toolStripMenuItemFromLocal.Enabled = true;
        this.toolStripMenuItemFromHome.Enabled = true;        
        //        
        this.toolStripMenuItemRunImplFiles.Enabled = true;
        this.toolStripMenuItemRunSQL.Enabled = true;
        this.toolStripMenuItemRunCMD.Enabled = true;
        this.toolStripMenuItemRunPS.Enabled = true;        
        //
        //this.toolStripMenuItemUnpackNow.Enabled = true;
        //
        this.toolStripMenuItemUnpackUnzip.Enabled = true;
        this.toolStripMenuItemUnpackClear.Enabled = true;
        //
        this.toolStripMenuItemUnpackScript.Enabled = true;
        this.toolStripMenuItemUnpackImplFiles.Enabled = true;
        this.toolStripMenuItemUnpackPayload.Enabled = true;        
        this.toolStripMenuItemUnpackActions.Enabled = true;
        this.toolStripMenuItemUnpackEvents.Enabled = true;        
        this.toolStripMenuItemUnpackSource.Enabled = true;
        this.toolStripMenuItemUnpackVisualStudio.Enabled = true;
        this.toolStripMenuItemUnpackHelp.Enabled = true;        
        //
        this.toolStripMenuItemSettingsDialog.Enabled = true;
      }
      else
      {
        AppSettings.bLocked = true;
        this.toolStripMenuItemLocked.Checked = true;
        //
        this.toolStripMenuItemFiler.Enabled = false;        
        this.toolStripMenuItemBuilder.Enabled = false;
        //
        this.toolStripMenuItemFromTemp.Enabled = false;
        this.toolStripMenuItemFromLocal.Enabled = false;
        this.toolStripMenuItemFromHome.Enabled = false;        
        //        
        this.toolStripMenuItemRunImplFiles.Enabled = false;
        this.toolStripMenuItemRunSQL.Enabled = false;
        this.toolStripMenuItemRunCMD.Enabled = false;
        this.toolStripMenuItemRunPS.Enabled = false;
        //
        //this.toolStripMenuItemUnpackNow.Enabled = false;
        //
        this.toolStripMenuItemUnpackUnzip.Enabled = false;
        this.toolStripMenuItemUnpackClear.Enabled = false;
        //
        this.toolStripMenuItemUnpackScript.Enabled = false;
        this.toolStripMenuItemUnpackImplFiles.Enabled = false;        
        this.toolStripMenuItemUnpackPayload.Enabled = false;
        this.toolStripMenuItemUnpackActions.Enabled = false;
        this.toolStripMenuItemUnpackEvents.Enabled = false;                
        this.toolStripMenuItemUnpackSource.Enabled = false;  
        this.toolStripMenuItemUnpackVisualStudio.Enabled = false;
        this.toolStripMenuItemUnpackHelp.Enabled = false; 
        //
        this.toolStripMenuItemSettingsDialog.Enabled = false;
      }
    }

    // ******************************************************
    // Setup methods
    // ******************************************************

    private void SetupForUnpack()
    {   
      this.toolStripMenuItemUnpackUnzip.Checked = AppSettings.bUnpackUnzip;     
      //
      this.toolStripMenuItemUnpackHelp.Checked = AppSettings.bUnpackHelp;      
      this.toolStripMenuItemUnpackVisualStudio.Checked = AppSettings.bUnpackVisualStudio;
      this.toolStripMenuItemUnpackPayload.Checked = AppSettings.bUnpackPayload;
      this.toolStripMenuItemUnpackScript.Checked = AppSettings.bUnpackScripts;
      this.toolStripMenuItemUnpackImplFiles.Checked = AppSettings.bUnpackImplFiles;      
      this.toolStripMenuItemUnpackSource.Checked = AppSettings.bUnpackSource;  
      this.toolStripMenuItemUnpackEvents.Checked = AppSettings.bUnpackEvents;
      this.toolStripMenuItemUnpackActions.Checked = AppSettings.bUnpackActions;      
    }

    // ******************************************************
    // Setup methods
    // ******************************************************

    private void SetupMenuForActions()
    {
      // shell actions
      this.toolStripMenuItemAction1.Enabled = false;
      this.toolStripMenuItemAction1.Text = "** unassigned **";
      if (!String.IsNullOrEmpty(AppActions.appActionShellHelp.name)) this.toolStripMenuItemAction1.Text = AppActions.appActionShellHelp.label;
      if (!String.IsNullOrEmpty(AppActions.appActionShellHelp.name)) this.toolStripMenuItemAction1.Enabled = AppActions.appActionShellHelp.enabled;
      //
      this.toolStripMenuItemAction2.Enabled = false;            
      this.toolStripMenuItemAction2.Text = "** unassigned **";
      if (!String.IsNullOrEmpty(AppActions.appActionShellListModules.name)) this.toolStripMenuItemAction2.Text = AppActions.appActionShellListModules.label;
      if (!String.IsNullOrEmpty(AppActions.appActionShellListModules.name)) this.toolStripMenuItemAction2.Enabled = AppActions.appActionShellListModules.enabled;
      //
      this.toolStripMenuItemAction3.Enabled = false;      
      this.toolStripMenuItemAction3.Text = "** unassigned **";
      if (!String.IsNullOrEmpty(AppActions.appActionShellListTargets.name)) this.toolStripMenuItemAction3.Text = AppActions.appActionShellListTargets.label;
      if (!String.IsNullOrEmpty(AppActions.appActionShellListTargets.name)) this.toolStripMenuItemAction3.Enabled = AppActions.appActionShellListTargets.enabled;
      //
      this.toolStripMenuItemAction4.Enabled = false;      
      this.toolStripMenuItemAction4.Text = "** unassigned **";
      if (!String.IsNullOrEmpty(AppActions.appActionShellListInstalled.name)) this.toolStripMenuItemAction4.Text = AppActions.appActionShellListInstalled.label;
      if (!String.IsNullOrEmpty(AppActions.appActionShellListInstalled.name)) this.toolStripMenuItemAction4.Enabled = AppActions.appActionShellListInstalled.enabled;
      //
      this.toolStripMenuItemAction5.Enabled = false;      
      this.toolStripMenuItemAction5.Text = "** unassigned **";
      if (!String.IsNullOrEmpty(AppActions.appActionShellListTenants.name)) this.toolStripMenuItemAction5.Text = AppActions.appActionShellListTenants.label;
      if (!String.IsNullOrEmpty(AppActions.appActionShellListTenants.name)) this.toolStripMenuItemAction5.Enabled = AppActions.appActionShellListTenants.enabled;
    }
    
    // ******************************************************
    // Setup methods
    // ******************************************************

    private void SetupForStandardActions()
    {
      // fill dropdown combo list
      string action = String.Empty;
      //this.comboBoxArgs.Items.Clear();
      //
      //foreach (AppAction aa in AppActions.actionsStandard.Values)
      //{
      //  action = aa.label;
      //  this.comboBoxArgs.Items.Add(action);
      //}
    }

    // ******************************************************
    // Setup methods
    // ******************************************************

    private void SetTenantControl(bool locked, bool bSqlEnabled)
    {   
      //this.numericUpDownTenantID.Enabled = false;
      //this.numericUpDownTenantID.Text = AppSettings.sqlTenantID.ToString();
      if (!bSqlEnabled)
      {
        //this.buttonExecute.Enabled = false;
      }
      else      
      {
        //this.buttonExecute.Enabled = true;
        if (!locked)
        {
          if (!AppSettings.sqlMultiTenant)
          {
            //this.numericUpDownTenantID.Text = "";
          }
          else
          {
            //if (AppSettings.sqlUseTenantUID) this.numericUpDownTenantID.Enabled = true;
          }
        }
      }
    }

    #endregion

    #region Supporting methods
    // ******************************************************
    // supporting methods
    // ******************************************************

    private bool RunActionFromMenu(string name)
    {
      // get the action name and set scriptArgs
      if (!String.IsNullOrEmpty(name)) 
      {
        AppAction action = AppActions.FindActionByName(name);
        AppRunner.scriptArgs = action.name; 
      }
      return this.RunAction();
    }

    private bool RunAction()
    {
      switch (AppRunner.Context)
      {
        case AppRunner.RunContext.ImplFiles:
          AppConsole.Write(String.Format("RUN flexadmin {0}", AppRunner.scriptArgs));
          AppFiler.WriteShellScriptForPowerShell(AppSettings.flexAdminScriptFileName, AppRunner.scriptArgs, !AppSettings.bRedirectOutput);
          AppRunner.Run(AppSettings.bRedirectOutput);
          if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
          break;

        case AppRunner.RunContext.PowerShell:
          AppConsole.Write(String.Format("RUN PowerShell script {0}", AppRunner.scriptArgs));        
          AppEvents.RunEvent("PRE", AppSettings.bEventsHidden);
          if (!AppSettings.bEventsOnly)
          {
            AppFiler.WriteShellScriptForPowerShell(AppSettings.scriptFileName, AppRunner.scriptArgs, !AppSettings.bRedirectOutput);
            AppRunner.Run(AppSettings.bRedirectOutput);
            if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "script.out");
          }
          AppEvents.RunEvent("POST", AppSettings.bEventsHidden);
          break;
        
        case AppRunner.RunContext.CMD:
          AppConsole.Write(String.Format("RUN command shell script {0}", AppRunner.scriptArgs));                
          AppEvents.RunEvent("PRE", AppSettings.bEventsHidden);
          if (!AppSettings.bEventsOnly)
          {
            AppFiler.WriteShellScriptForCommandShell(AppSettings.cmdFileName, AppRunner.scriptArgs, !AppSettings.bRedirectOutput);
            AppRunner.Run(AppSettings.bRedirectOutput, "script.out");
            if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "script.out");
          }
          AppEvents.RunEvent("POST", AppSettings.bEventsHidden);
          break;

        case AppRunner.RunContext.SQL:
          AppConsole.Write(String.Format("RUN SQL script {0}", AppRunner.scriptArgs));        
          AppEvents.RunEvent("PRE", AppSettings.bEventsHidden);       
          if (!AppSettings.bEventsOnly)
          {
            AppFiler.WriteShellScriptForSQL(AppSettings.sqlServer, AppSettings.sqlDatabase, AppRunner.droppedSqlContentName, AppRunner.scriptArgs, !AppSettings.bRedirectOutput);
            string outFile = String.Format("{0}.out", Path.GetFileNameWithoutExtension(AppRunner.droppedSqlContentName));          
            AppRunner.Run(AppSettings.bRedirectOutput, outFile);
            if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, outFile);
          }
          AppEvents.RunEvent("POST", AppSettings.bEventsHidden);
          break;

        case AppRunner.RunContext.Events:
          if (this.armed)
          {       
            AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "events.xml");
          }
          break;
          
        default:
          AppEvents.RunEvent("PRE", AppSettings.bEventsHidden);
          if (!AppSettings.bEventsOnly)
          {
            AppFiler.WriteShellScriptForCommandShell("script.cmd", AppRunner.scriptArgs, !AppSettings.bRedirectOutput);
            AppRunner.Run(AppSettings.bRedirectOutput, "script.out");
            if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "script.out");
          }
          AppEvents.RunEvent("POST", AppSettings.bEventsHidden);
          break;
      }
      return true;
    }

    #endregion

  }
  
  #endregion

}
