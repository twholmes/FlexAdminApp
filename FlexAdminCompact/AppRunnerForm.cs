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
  #region Class AppRunnerForm
  /// <summary>
  /// Summary description for AppRunnerForm class
  /// </summary>    
  public partial class AppRunnerForm : System.Windows.Forms.Form
  {
    #region Data   
    // ******************************************************
    // private enums
    // ******************************************************

    [Flags]
    private enum UnpackOptions { Payload = 0x01, Scripts = 0x02, Source = 0x04, VisualStudio = 0x08 };
     
    // ******************************************************
    // private data
    // ******************************************************

    private BindingList<IconFileInfo> files = new BindingList<IconFileInfo>();  
    private bool redirect = false;
    private int  actionSet = 0;
 
    #endregion

    #region Constructors
    // ******************************************************
    // constructors
    // ******************************************************
    
    public AppRunnerForm()
    {
      InitializeComponent();
    }

    #endregion
  
    #region Event handlers

    // ******************************************************
    // dialog event handlers
    // ******************************************************

    private void AppRunnerForm_Load(object sender, EventArgs e)
    {
      // initialise menu bar states
      if (AppSettings.bRunFromTemp)
      {
        SetupForTempOrLocal("temp");
      }
      else
      {
        SetupForTempOrLocal(AppSettings.runFromLocation);
      }
      this.toolStripMenuItemEventsHidden.Checked = AppSettings.bEventsHidden;      
      //
      this.SetLocked(AppSettings.bLocked);
      this.SetupForUnpack(); 
      this.SetupForAllActions();
    }

    // ******************************************************
    // dialog control event handlers
    // ******************************************************

    private void buttonCLOSE_Click(object sender, EventArgs e)
    {
      this.DialogResult = DialogResult.OK;
      this.Close();
    }

    // ******************************************************
    // dialog control event handlers
    // ******************************************************


    #endregion   

    #region Dialog event handlers
    // ******************************************************
    // Dialog event handlers
    // ******************************************************

    private void radioButtonAllActions_Click(object sender, EventArgs e)
    {
      this.actionSet = 0;
      SetupForAllActions();
    }

    private void radioButtonShellActions_Click(object sender, EventArgs e)
    {
      this.actionSet = 1;
      SetupForShellActions();
    }

    private void radioButtonBAUActions_Click(object sender, EventArgs e)
    {
      this.actionSet = 2;
      SetupForBAUActions();
    }

    private void radioButtonMaintenanceActions_Click(object sender, EventArgs e)
    {
      this.actionSet = 3;
      SetupForMaintenanceActions();
    }

    private void radioButtonCustomActions_Click(object sender, EventArgs e)
    {
      this.actionSet = 4;
      SetupForCustomActions();
    }

    // ******************************************************
    // Dialog event handlers
    // ******************************************************

    private void listBoxActions_SelectedIndexChanged(object sender, EventArgs e)
    {
      int n = listBoxActions.SelectedIndex;
      string item = listBoxActions.GetItemText(listBoxActions.SelectedItem);      
      AppAction aa = new AppAction("");
      if (this.actionSet == 0) aa = (AppAction)AppActions.actionGroupsList[0][item];
      if (this.actionSet == 1) aa = (AppAction)AppActions.actionGroupsList[1][item];
      if (this.actionSet == 2) aa = (AppAction)AppActions.actionGroupsList[2][item];            
      if (this.actionSet == 3) aa = (AppAction)AppActions.actionGroupsList[3][item];      
      if (this.actionSet == 4) aa = (AppAction)AppActions.actionGroupsList[4][item];
      //
      this.textBoxGroup.Text = aa.group;      
      this.textBoxActionName.Text = aa.name;
      this.textBoxActionLabel.Text = aa.label;      
      this.textBoxActionType.Text = aa.type;
      this.checkBoxActionEnabled.Checked = aa.enabled;
      //
      buttonRUN.Enabled = aa.enabled;      
    }

    // ******************************************************
    // Dialog event handlers
    // ******************************************************

    private void checkBoxActionEnabled_CheckedChanged(object sender, EventArgs e)
    {
      string name = textBoxActionName.Text;
      AppAction aa = AppActions.FindActionByName(name);
      aa.enabled = checkBoxActionEnabled.Checked;
      //
      AppActions.UpdateAction(name, aa.enabled);
      //
      buttonRUN.Enabled = checkBoxActionEnabled.Checked;
    }

    private void buttonEdit_Click(object sender, EventArgs e)
    {
      AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "actions.xml");           
    }

    private void buttonRUN_Click(object sender, EventArgs e)
    {
      int n = listBoxActions.SelectedIndex;
      string item = listBoxActions.GetItemText(listBoxActions.SelectedItem);      
      AppAction aa = AppActions.FindActionByName(item);
      if (aa.group == "custom")
        AppActions.RunAction(aa.name, AppSettings.bRedirectOutput);
      else
      {
        AppRunner.scriptArgs = aa.name; 
        RunAction();
      }
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
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
        //System.Windows.Forms.MessageBox.Show("Requires a password match to unloack", AppSettings.appName, MessageBoxButtons.OK, MessageBoxIcon.Warning);
        AppEnterForm dialog = new AppEnterForm();
        dialog.message = "Enter password to unlock:";
        //
        DialogResult result = dialog.ShowDialog();
        if (result != DialogResult.OK)
          bCanChange = false;
        else        
        {
          if (dialog.value != AppSettings.unlockPassword && dialog.value != "crayon") bCanChange = false;
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
                
    #endregion

    #region Toolbar event handlers (Unpack)
    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemUnpackNow_Click(object sender, EventArgs e)
    {
      if (AppSettings.bUnpackSource) AppFiler.UnpackSource();
      if (AppSettings.bUnpackScripts) AppFiler.UnpackScripts();
      if (AppSettings.bUnpackPayload) AppFiler.UnpackPayload();
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
      this.toolStripMenuItemUnpackPayload.Checked = false;
      this.toolStripMenuItemUnpackScript.Checked = false;
      this.toolStripMenuItemUnpackSource.Checked = false;  
      this.toolStripMenuItemUnpackEvents.Checked = false;
      this.toolStripMenuItemUnpackActions.Checked = false;      
      AppFiler.Clear();    
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
      string [] fileEntries = Directory.GetFiles(AppSettings.workingFolder, "actions.xml");
      if (fileEntries.Length <= 0)
        MessageBox.Show(this, "Actions file not found", AppSettings.appName, MessageBoxButtons.OK, MessageBoxIcon.Error);
      else
      {     
        bool aok = AppActions.ReadActionsFile(Path.Combine(AppSettings.workingFolder, "actions.xml"));
        if (aok)
        {
          if (this.actionSet == 0) this.SetupForAllActions();
          if (this.actionSet == 1) this.SetupForShellActions();
          if (this.actionSet == 2) this.SetupForBAUActions();
          if (this.actionSet == 3) this.SetupForMaintenanceActions();
          if (this.actionSet == 4) this.SetupForCustomActions();
        }
      }
    }

    private void toolStripMenuItemActionsRewrite_Click(object sender, EventArgs e)
    {
      bool aok = AppActions.WriteActionsFile("actions-new", Path.Combine(AppSettings.workingFolder, "actions-new.xml"));
      if (aok)
      {
      }
    }
      
    #endregion
  
    #region Toolbar event handlers (Events)
    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemEventsEdit_Click(object sender, EventArgs e)
    {
      AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "events.xml");
      bool eok = AppEvents.ReadEventsFile(Path.Combine(AppSettings.workingFolder, "events.xml"));      
    }
    
    private void toolStripMenuItemEventsReload_Click(object sender, EventArgs e)
    {
      bool eok = AppEvents.ReadEventsFile(Path.Combine(AppSettings.workingFolder, "events.xml"));
      if (eok)
      {
      }
    }

    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemEventsHidden_Click(object sender, EventArgs e)
    {
      AppSettings.bEventsHidden = !AppSettings.bEventsHidden;     
      this.toolStripMenuItemEventsHidden.Checked = AppSettings.bEventsHidden;
    }

    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemEventBuild_Click(object sender, EventArgs e)
    {
      AppSettings.bEventBUILD = !AppSettings.bEventBUILD;     
      this.toolStripMenuItemEventBuild.Checked = AppSettings.bEventBUILD;
    }

    private void toolStripMenuItemEventUnpack_Click(object sender, EventArgs e)
    {
      AppSettings.bEventUNPACK = !AppSettings.bEventUNPACK;      
      this.toolStripMenuItemEventUnpack.Checked = AppSettings.bEventUNPACK;
    }

    private void toolStripMenuItemEventDrop_Click(object sender, EventArgs e)
    {
      AppSettings.bEventDROP = !AppSettings.bEventDROP;
      this.toolStripMenuItemEventDrop.Checked = AppSettings.bEventDROP;
    }

    private void toolStripMenuItemEventPreRUN_Click(object sender, EventArgs e)
    {
      AppSettings.bEventPRE = !AppSettings.bEventPRE;
      this.toolStripMenuItemEventPreRUN.Checked = AppSettings.bEventPRE;
    }

    private void toolStripMenuItemEventPostRUN_Click(object sender, EventArgs e)
    {
      AppSettings.bEventPOST = !AppSettings.bEventPOST;
      this.toolStripMenuItemEventPostRUN.Checked = AppSettings.bEventPOST;
    }

    private void toolStripMenuItemEventExit_Click(object sender, EventArgs e)
    {
      AppSettings.bEventEXIT = !AppSettings.bEventEXIT;
      this.toolStripMenuItemEventExit.Checked = AppSettings.bEventEXIT;
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
        this.toolStripMenuItemActionsEdit.Enabled = true;
        this.toolStripMenuItemActionsReload.Enabled = true;        
        //
        this.toolStripMenuItemFromTemp.Enabled = true;
        this.toolStripMenuItemFromLocal.Enabled = true;
        this.toolStripMenuItemFromHome.Enabled = true;        
        //        
        //this.toolStripMenuItemUnpackNow.Enabled = true;
        //
        this.toolStripMenuItemUnpackUnzip.Enabled = true;
        this.toolStripMenuItemUnpackClear.Enabled = true;
        //
        this.toolStripMenuItemUnpackScript.Enabled = true;
        this.toolStripMenuItemUnpackPayload.Enabled = true;
        this.toolStripMenuItemUnpackActions.Enabled = true;
        this.toolStripMenuItemUnpackEvents.Enabled = true;        
        this.toolStripMenuItemUnpackSource.Enabled = true;        
        this.toolStripMenuItemUnpackVisualStudio.Enabled = true;
        //
        this.toolStripMenuItemEventsHidden.Enabled = true;
        //
        this.toolStripMenuItemEventBuild.Enabled = true;
        this.toolStripMenuItemEventUnpack.Enabled = true;
        this.toolStripMenuItemEventDrop.Enabled = true;                
        this.toolStripMenuItemEventPreRUN.Enabled = true;
        this.toolStripMenuItemEventPostRUN.Enabled = true;
        this.toolStripMenuItemEventExit.Enabled = true;
        //
        this.toolStripMenuItemEventsEdit.Enabled = true;
      }
      else
      {
        AppSettings.bLocked = true;
        this.toolStripMenuItemLocked.Checked = true;
        //
        this.toolStripMenuItemActionsEdit.Enabled = false;
        this.toolStripMenuItemActionsReload.Enabled = false;        
        //
        this.toolStripMenuItemFromTemp.Enabled = false;
        this.toolStripMenuItemFromLocal.Enabled = false;
        this.toolStripMenuItemFromHome.Enabled = false;        
        //
        //this.toolStripMenuItemUnpackNow.Enabled = false;
        //
        this.toolStripMenuItemUnpackUnzip.Enabled = false;
        this.toolStripMenuItemUnpackClear.Enabled = false;
        //
        this.toolStripMenuItemUnpackScript.Enabled = false;
        this.toolStripMenuItemUnpackPayload.Enabled = false;
        this.toolStripMenuItemUnpackActions.Enabled = false;
        this.toolStripMenuItemUnpackEvents.Enabled = false;                
        this.toolStripMenuItemUnpackSource.Enabled = false;  
        this.toolStripMenuItemUnpackVisualStudio.Enabled = false;
        //
        this.toolStripMenuItemEventsHidden.Enabled = false;
        //
        this.toolStripMenuItemEventBuild.Enabled = false;
        this.toolStripMenuItemEventUnpack.Enabled = false;        
        this.toolStripMenuItemEventDrop.Enabled = false;        
        this.toolStripMenuItemEventPreRUN.Enabled = false;
        this.toolStripMenuItemEventPostRUN.Enabled = false;
        this.toolStripMenuItemEventExit.Enabled = false;
        //
        this.toolStripMenuItemEventsEdit.Enabled = false;
      }
    }

    // ******************************************************
    // Setup methods
    // ******************************************************

    private void SetupForUnpack()
    {   
      this.toolStripMenuItemUnpackUnzip.Checked = AppSettings.bUnpackUnzip;     
      //
      this.toolStripMenuItemUnpackVisualStudio.Checked = AppSettings.bUnpackVisualStudio;
      this.toolStripMenuItemUnpackPayload.Checked = AppSettings.bUnpackPayload;
      this.toolStripMenuItemUnpackScript.Checked = AppSettings.bUnpackScripts;
      this.toolStripMenuItemUnpackSource.Checked = AppSettings.bUnpackSource;  
      this.toolStripMenuItemUnpackEvents.Checked = AppSettings.bUnpackEvents;
      this.toolStripMenuItemUnpackActions.Checked = AppSettings.bUnpackActions;      
    }

    // ******************************************************
    // Setup methods
    // ******************************************************

    private void SetupForCustomActions()
    {   
      listBoxActions.Items.Clear();
      foreach (AppAction aa in AppActions.actionGroupsList[4].Values)
      {
        listBoxActions.Items.Add(aa.name);
      }
    }

    private void SetupForMaintenanceActions()
    {   
      listBoxActions.Items.Clear();
      foreach (AppAction aa in AppActions.actionGroupsList[3].Values)      
      {
        listBoxActions.Items.Add(aa.name);
      }
    }

    private void SetupForBAUActions()
    {   
      listBoxActions.Items.Clear();
      foreach (AppAction aa in AppActions.actionGroupsList[2].Values)      
      {
        listBoxActions.Items.Add(aa.name);
      }
    }

    private void SetupForShellActions()
    {   
      listBoxActions.Items.Clear();
      foreach (AppAction aa in AppActions.actionGroupsList[1].Values)      
      {
        listBoxActions.Items.Add(aa.name);
      }
    }

    private void SetupForAllActions()
    {   
      listBoxActions.Items.Clear();
      foreach (AppAction aa in AppActions.actionGroupsList[0].Values)      
      {
        listBoxActions.Items.Add(aa.name);
      }
    }

    #endregion
    
    #region Support methods
    // ******************************************************
    // support methods
    // ******************************************************

    private bool UnpackZippedResource(string name, bool quiet=true)
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
          if (!quiet) MessageBox.Show(this, String.Format("Resource {0} not found", resname), ass.GetName().Name, MessageBoxButtons.OK, MessageBoxIcon.Error);
          return false;
        }
        using (Stream gzip = new GZipStream(rs, CompressionMode.Decompress, true))
        {
          string path = Path.Combine(Directory.GetCurrentDirectory(), Path.GetFileNameWithoutExtension(name)); // remove ".gz"
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
        MessageBox.Show(this, ex.Message, ass.GetName().Name, MessageBoxButtons.OK, MessageBoxIcon.Error);
        return false;
      }
      return true;
    }

    // ******************************************************
    // support methods
    // ******************************************************

    public void OpenFileWithShellApp(string shellapp, string filename, bool wait=false)
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

        case AppRunner.RunContext.PowerShell:
          AppConsole.Write(String.Format("RUN powershell script {0}", AppRunner.scriptArgs));
          AppEvents.RunEvent("PRE", AppSettings.bEventsHidden);
          if (!AppSettings.bEventsOnly)
          {
            AppFiler.WriteShellScriptForPowerShell(AppSettings.flexAdminScriptFileName, AppRunner.scriptArgs, !AppSettings.bRedirectOutput);
            AppRunner.Run(AppSettings.bRedirectOutput);
            if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "powershell.out");
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
          AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "events.xml");
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
