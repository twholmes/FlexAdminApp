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
  #region Class AppSettingsForm
  /// <summary>
  /// Summary description for AppSettingsForm class
  /// </summary>    
  public partial class AppSettingsForm : System.Windows.Forms.Form
  {
    #region Data    
    // ******************************************************
    // private data
    // ******************************************************

    private BindingList<IconFileInfo> files = new BindingList<IconFileInfo>();  
    private bool redirect = false;
    private int  actionSet = 2;

    // ******************************************************
    // public data
    // ******************************************************     
 
 
    #endregion

    #region Constructors
    // ******************************************************
    // constructors
    // ******************************************************
    
    public AppSettingsForm()
    {
      InitializeComponent();
      AppSettings.sqlConnectionString = string.Format("Data Source={0};Initial Catalog={1};Integrated Security=True", AppSettings.sqlServer, AppSettings.sqlDatabase);      
    }

    public AppSettingsForm(string cs)
    {
      InitializeComponent();
      AppSettings.sqlConnectionString = cs;
    }

    #endregion
  
    #region Event handlers

    // ******************************************************
    // dialog event handlers
    // ******************************************************

    private void AppSettingsForm_Load(object sender, EventArgs e)
    {
      // on Primary tab
      this.textBoxScriptFile.Text = AppSettings.scriptFileName;
      this.textBoxCmdFile.Text = AppSettings.cmdFileName;      
      //
      this.checkBoxRequirePassword.Checked = AppSettings.bRequirePassword;
      this.textBoxPassword.Text = AppSettings.unlockPassword;
      //
      this.checkBoxCheckPayload.Checked = AppSettings.bCheckPayload;
      //
      // on implfiles tab
      this.textBoxImplFilesFolder.Text = AppSettings.rstrImplFilesFolder;
      this.textBoxSettingsFileName.Text = AppSettings.rstrSettingsFileName;
      this.textBoxLogFilesFolder.Text = AppSettings.rstrAppLogFolder;
      this.textBoxImplFilesScriptName.Text = AppSettings.flexAdminScriptFileName;
      //      
      // on SQL tab
      this.textBoxServer.Text = AppSettings.sqlServer;      
      this.textBoxDatabase.Text = AppSettings.sqlDatabase;
      this.labelConnectionString.Text = AppSettings.sqlConnectionString; 
      //
      this.checkBoxMultiTenant.Checked = AppSettings.sqlMultiTenant;
      this.checkBoxUseTenantUID.Checked = AppSettings.sqlUseTenantUID;
      this.textBoxTenantUID.Text = AppSettings.sqlTenantUID;
      //
      this.SetupSqlEnabled(AppSettings.sqlEnabled, AppSettings.sqlMultiTenant);
      //
      this.comboBoxEditor.Text = AppSettings.Editor;
      this.checkBoxRedirect.Checked = this.redirect;
      //
      // on Events tab
      this.checkBoxEventBuild.Checked = AppSettings.bEventBUILD;
      this.checkBoxEventUnpack.Checked = AppSettings.bEventUNPACK;      
      this.checkBoxEventDrop.Checked = AppSettings.bEventDROP;      
      this.checkBoxEventPre.Checked = AppSettings.bEventPRE;
      this.checkBoxEventPost.Checked = AppSettings.bEventPOST;
      this.checkBoxEventExit.Checked = AppSettings.bEventEXIT;   
      //
      this.checkBoxEventsHidden.Checked = AppSettings.bEventsHidden; 
      //
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
      this.SetupForStandardActions();
    }

    // ******************************************************
    // dialog control event handlers
    // ******************************************************

    private void buttonOK_Click(object sender, EventArgs e)
    {
    	// from Primary tab
      AppSettings.scriptFileName = this.textBoxScriptFile.Text;
      AppSettings.cmdFileName = this.textBoxCmdFile.Text;      
      //
      // from Promary tab
      AppSettings.unlockPassword = this.textBoxPassword.Text;
      AppSettings.bRequirePassword = this.checkBoxRequirePassword.Checked;
      //
      AppSettings.bCheckPayload = this.checkBoxCheckPayload.Checked;            
      //
      // from implfiles tab
      AppSettings.rstrImplFilesFolder = this.textBoxImplFilesFolder.Text;
      AppSettings.rstrSettingsFileName = this.textBoxSettingsFileName.Text;
      AppSettings.flexAdminScriptFileName = this.textBoxImplFilesScriptName.Text;      
      AppSettings.rstrFlexeraFlexAdminSettings = Path.Combine(AppSettings.rstrImplFilesFolder, AppSettings.rstrSettingsFileName);
      //
      AppSettings.rstrAppLogFolder = AppSettings.appLogFolder;      
      // 
      // from SQL settings tab
      AppSettings.sqlEnabled = this.checkBoxSqlEnabled.Checked;      
      AppSettings.sqlMultiTenant = this.checkBoxMultiTenant.Checked;
      AppSettings.sqlUseTenantUID = this.checkBoxUseTenantUID.Checked;
      AppSettings.sqlTenantUID = this.textBoxTenantUID.Text;
      AppSettings.sqlTenantID = Int32.Parse(this.numericUpDownTenantID.Text);
      //     
      // other
      AppSettings.rstrAppLogFolder = AppSettings.appLogFolder;      
      AppSettings.rstrAppLogFile = AppSettings.appLogFile;
      //
      AppSettings.rstrEditor = comboBoxEditor.Text;
      //
      this.DialogResult = DialogResult.OK;
      this.Close();
    }

    private void buttonCancel_Click(object sender, EventArgs e)
    {
      this.DialogResult = DialogResult.Cancel;
      this.Close();
    }

    // ******************************************************
    // dialog control event handlers
    // ******************************************************

     private void buttonReset_Click(object sender, EventArgs e)
     {
      // on primary tab
      this.textBoxPassword.Text = AppSettings.c_Password;
      this.textBoxScriptFile.Text = AppSettings.rstrScriptFileName;
      this.textBoxCmdFile.Text = AppSettings.rstrCmdFileName;      
      //
      // on implfiles tab
      this.textBoxImplFilesFolder.Text = AppSettings.rstrImplFilesFolder;
      this.textBoxSettingsFileName.Text = AppSettings.rstrSettingsFileName;
      this.textBoxLogFilesFolder.Text = AppSettings.rstrAppLogFolder;
      //
      this.textBoxImplFilesScriptName.Text = AppSettings.rstrFlexAdminScriptFileName;           
      //
      // on SQL settings tab
      this.checkBoxMultiTenant.Checked = AppSettings.rbSqlMultiTenant;
      this.checkBoxUseTenantUID.Checked = AppSettings.rbSqlUseTenantUID;
      this.textBoxTenantUID.Text = AppSettings.rstrSqlTenantUID;
      this.numericUpDownTenantID.Text = AppSettings.sqlTenantID.ToString();
      this.SetupSqlEnabled(AppSettings.rbSqlEnabled);
     }

    #endregion
    
    #region TabPage event handlers (Primary)
    // ******************************************************
    // tabpage event handlers - Primary
    // ******************************************************

    private void tabPagePrimary_Enter(object sender, EventArgs e)
    {
    }

    // ******************************************************
    // tabpage event handlers - Primary
    // ******************************************************

    private void textBoxScriptFile_TextChanged(object sender, EventArgs e)
    {
    }

    private void textBoxCmdFile_TextChanged(object sender, EventArgs e)
    {
    }

    private void textBoxPassword_TextChanged(object sender, EventArgs e)
    {
    }

    private void checkBoxRequirePassword_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxRequirePassword.CheckState;
      //AppSettings.bRequirePassword = (state == CheckState.Checked) ? true : false;      
    }

    private void checkBoxCheckPayload_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxCheckPayload.CheckState;
      //AppSettings.bCheckPayload = (state == CheckState.Checked) ? true : false;      
    }

    #endregion
    
    #region TabPage event handlers (ImplFiles)
    // ******************************************************
    // tabpage event handlers - ImplFiles
    // ******************************************************

    private void tabPageImplFiles_Enter(object sender, EventArgs e)
    {
    }

    // ******************************************************
    // tabpage event handlers - ImplFiles
    // ******************************************************

    private void textBoxImplFilesFolder_TextChanged(object sender, EventArgs e)
    {
    }

    private void textBoxSettingsFileName_TextChanged(object sender, EventArgs e)
    {
    }

    private void textBoxImplFilesScriptName_TextChanged(object sender, EventArgs e)
    {
      //AppSettings.flexAdminScriptFileName = this.textBoxImplFilesScriptName.Text;
    }

    // ******************************************************
    // tabpage event handlers - ImplFiles
    // ******************************************************

    private void buttonSelectSettings_Click(object sender, EventArgs e)
    {
      OpenFileDialog openFileDialog = new OpenFileDialog();
      openFileDialog.InitialDirectory = AppSettings.implFilesFolder;
      openFileDialog.Filter = "settings files (*.settings)|*.settings|All files (*.*)|*.*";
      openFileDialog.FilterIndex = 1;
      openFileDialog.RestoreDirectory = true;
      if (openFileDialog.ShowDialog() == DialogResult.OK)
      {
        string filepath = openFileDialog.FileName;
        AppSettings.implFilesFolder = Path.GetDirectoryName(filepath);
        AppSettings.settingsFileName = Path.GetFileName(filepath);
        //
        this.textBoxImplFilesFolder.Text = AppSettings.implFilesFolder;
        this.textBoxSettingsFileName.Text = AppSettings.settingsFileName;        
      }     
    }

    private void buttonSelectLogs_Click(object sender, EventArgs e)
    {
      FolderBrowserDialog fbd = new FolderBrowserDialog();
      fbd.Description = "Select the Logging folder";
      if (fbd.ShowDialog() == DialogResult.OK)
      {
        AppSettings.appLogFolder = fbd.SelectedPath;
        this.textBoxLogFilesFolder.Text = AppSettings.appLogFolder;        
      }   
    }  

    #endregion
    
    #region TabPage event handlers (SQL)
    // ******************************************************
    // tabpage event handlers - SQL
    // ******************************************************

    private void tabPageSQL_Enter(object sender, EventArgs e)
    {
    }

    // ******************************************************
    // tabpage event handlers - SQL
    // ******************************************************

    private void checkBoxSqlEnabled_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxSqlEnabled.CheckState;
      bool sqlEnabled = (state == CheckState.Checked) ? true : false;      
      this.SetupSqlEnabled(sqlEnabled);
    }

    // ******************************************************
    // tabpage event handlers - SQL
    // ******************************************************
    
    private void textBoxServer_TextChanged(object sender, EventArgs e)
    {
      AppSettings.sqlServer = textBoxServer.Text;
    }

    private void textBoxDatabase_TextChanged(object sender, EventArgs e)
    {
      AppSettings.sqlDatabase = textBoxDatabase.Text;
    }

    private void checkBoxRedirect_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxRedirect.CheckState;
      this.redirect = (state == CheckState.Checked) ? true : false;      
    }

    // ******************************************************
    // tabpage event handlers - SQL
    // ******************************************************

    private void checkBoxMultiTenant_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxMultiTenant.CheckState;
      bool multiTenant = (state == CheckState.Checked) ? true : false;      
      //AppSettings.sqlMultiTenant = multiTenant;
      if (multiTenant)
      {
        this.checkBoxUseTenantUID.Enabled = true;
        if (this.checkBoxUseTenantUID.Checked) 
        {
          this.textBoxTenantUID.Enabled = true;
          this.numericUpDownTenantID.Enabled = true;
        }
      }
      else
      {
        this.checkBoxUseTenantUID.Enabled = false;
        this.numericUpDownTenantID.Enabled = false;        
        this.textBoxTenantUID.Enabled = false;
      }
    }

    private void checkBoxUseTenantUID_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxUseTenantUID.CheckState;
      bool useTenantUID = (state == CheckState.Checked) ? true : false;      
      //AppSettings.sqlUseTenantUID = useTenantUID;
      if (useTenantUID)
      {
        this.numericUpDownTenantID.Enabled = true;        
        this.textBoxTenantUID.Enabled = true;
      }
      else
      {
        this.numericUpDownTenantID.Enabled = false;       
        this.textBoxTenantUID.Enabled = false;
      }
    }

    private void numericUpDownTenantID_ValueChanged(object sender, EventArgs e)
    {
    }

    private void textBoxTenantUID_TextChanged(object sender, EventArgs e)
    {
      //AppSettings.sqlTenantUID = this.textBoxTenantUID.Text;
    }

    // ******************************************************
    // tabpage event handlers - SQL
    // ******************************************************

    private void buttonTest_Click(object sender, EventArgs e)
    {
      String cs = AppSettings.sqlConnectionString;
      try
      {
        cs = string.Format("Data Source={0};Initial Catalog={1};Integrated Security=True", AppSettings.sqlServer, AppSettings.sqlDatabase);
        AppSettings.sqlConnectionString = cs;
        this.labelConnectionString.Text = cs;
        //
        AppFiler.WriteSqlScriptForTest("");        
        AppFiler.WriteShellScriptForSQL(AppSettings.sqlServer, AppSettings.sqlDatabase, "script.sql", "", !this.redirect);
        AppActions.RunAction("SQLTEST", redirect);
        if (this.redirect) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "sqltest.out");
      }
      catch (Exception ex)
      {
        this.labelConnectionString.Text = String.Format("*** exception *** {0}", cs);
        System.Windows.Forms.MessageBox.Show(ex.Message, "Test Connection", MessageBoxButtons.OK, MessageBoxIcon.Error);
      }            
    }

    #endregion

    #region TabPage event handlers (Events)
    // ******************************************************
    // tabpage event handlers - Events
    // ******************************************************

    private void tabPageEvents_Enter(object sender, EventArgs e)
    {
    }

    // ******************************************************
    // tabpage event handlers - Events
    // ******************************************************

    private void checkBoxEventBuild_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxEventBuild.CheckState;
      AppSettings.bEventBUILD = (state == CheckState.Checked) ? true : false;     
    }
    
    private void checkBoxEventUnpack_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxEventUnpack.CheckState;
      AppSettings.bEventUNPACK = (state == CheckState.Checked) ? true : false;     
    }
    
     private void checkBoxEventDrop_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxEventDrop.CheckState;
      AppSettings.bEventDROP = (state == CheckState.Checked) ? true : false;     
    }    
    
    private void checkBoxEventPre_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxEventPre.CheckState;
      AppSettings.bEventPRE = (state == CheckState.Checked) ? true : false;     
    }

    private void checkBoxEventPost_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxEventPost.CheckState;
      AppSettings.bEventPOST = (state == CheckState.Checked) ? true : false;     
    }

    private void checkBoxEventExit_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxEventExit.CheckState;
      AppSettings.bEventEXIT = (state == CheckState.Checked) ? true : false;     
    }

    // ******************************************************
    // tabpage event handlers - Events
    // ******************************************************

    private void checkBoxEventsHidden_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxEventsHidden.CheckState;
      AppSettings.bEventsHidden = (state == CheckState.Checked) ? true : false;     
    }

    // ******************************************************
    // tabpage event handlers - Events
    // ******************************************************

    private void buttonEventsEdit_Click(object sender, EventArgs e)
    {
      AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "events.xml");           
    }

    #endregion   

    #region TabPage event handlers (Actions)
    // ******************************************************
    // tabpage event handlers - Actions
    // ******************************************************

    private void tabPageActions_Enter(object sender, EventArgs e)
    {
    }

    // ******************************************************
    // tabpage event handlers - Actions
    // ******************************************************

    private void radioButtonShellActions_Click(object sender, EventArgs e)
    {
      this.actionSet = 1;
      SetupForShellActions();
    }

    private void radioButtonAllActions_Click(object sender, EventArgs e)
    {
      this.actionSet = 2;
      SetupForStandardActions();
    }

    private void radioButtonCustomActions_Click(object sender, EventArgs e)
    {
      this.actionSet = 3;
      SetupForCustomActions();
    }

    private void checkBoxActionEnabled_CheckedChanged(object sender, EventArgs e)
    {
      string name = textBoxActionName.Text;
      AppAction aa = AppActions.FindActionByName(name);
      aa.enabled = checkBoxActionEnabled.Checked;
    }

    // ******************************************************
    // tabpage event handlers - Actions
    // ******************************************************

    private void buttonActionsEdit_Click(object sender, EventArgs e)
    {
      AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "actions.xml");           
    }

    private void buttonActionsRun_Click(object sender, EventArgs e)
    {
      int n = listBoxActions.SelectedIndex;
      string item = listBoxActions.GetItemText(listBoxActions.SelectedItem);      
      AppAction aa = (AppAction)AppActions.actionGroupsList[4][item];
      //            
      AppActions.RunAction(aa.name, AppSettings.bRedirectOutput);
      if (AppSettings.bRedirectOutput) AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "flexadmin.out");
    }
    
    #endregion

    #region TabPage event handlers (Other)
    // ******************************************************
    // tabpage event handlers - Other
    // ******************************************************

    private void tabPageOther_Enter(object sender, EventArgs e)
    {
    }

    // ******************************************************
    // tabpage event handlers - Other
    // ******************************************************

    private void comboBoxEditor_TextChanged(object sender, EventArgs e)
    {
      AppSettings.Editor = comboBoxEditor.Text;
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

    private void toolStripMenuItemUnpackImplFiles_Click(object sender, EventArgs e)
    {
      AppSettings.bUnpackImplFiles = !AppSettings.bUnpackImplFiles;
      this.toolStripMenuItemUnpackImplFiles.Checked = AppSettings.bUnpackImplFiles;
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
      bool aok = AppActions.ReadActionsFile(Path.Combine(AppSettings.workingFolder, "actions.xml"));
      if (aok)
      {
        if (this.actionSet == 1) this.SetupForShellActions();
        if (this.actionSet == 2) this.SetupForStandardActions();                
        if (this.actionSet == 3) this.SetupForCustomActions();
      }
    }

    private void toolStripMenuItemActionsRewrite_Click(object sender, EventArgs e)
    {
      bool aok = AppActions.WriteActionsFile("actions-new", Path.Combine(AppSettings.workingFolder, "actions-new.xml"));
      if (aok)
      {
      }
    }

    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void listBoxActions_SelectedIndexChanged(object sender, EventArgs e)
    {
      int n = listBoxActions.SelectedIndex;
      string item = listBoxActions.GetItemText(listBoxActions.SelectedItem);      
      AppAction aa = new AppAction("");
      if (this.actionSet == 1) aa = (AppAction)AppActions.actionGroupsList[0][item];
      if (this.actionSet == 2) aa = (AppAction)AppActions.actionGroupsList[1][item];
      if (this.actionSet == 3) aa = (AppAction)AppActions.actionGroupsList[4][item];
      //
      this.textBoxActionName.Text = aa.name;
      this.textBoxActionLabel.Text = aa.label;      
      this.textBoxActionType.Text = aa.type;
      this.checkBoxActionEnabled.Checked = aa.enabled;
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
    // setup methods
    // ******************************************************

    private void SetupSqlEnabled(bool sqlEnabled, bool multiTenant=false)
    {
      this.numericUpDownTenantID.Text = AppSettings.sqlTenantID.ToString();     
      if (!sqlEnabled)
      {
        this.textBoxServer.Enabled = false;      
        this.textBoxDatabase.Enabled = false;
        // 
        this.buttonTest.Enabled = false;
        this.checkBoxRedirect.Enabled = false;        
        //
        this.checkBoxMultiTenant.Enabled = false;
        this.checkBoxUseTenantUID.Enabled = false;
        this.numericUpDownTenantID.Enabled = false;        
        this.textBoxTenantUID.Enabled = false;
      }
      else
      {
        this.checkBoxMultiTenant.Enabled = true;        
        this.textBoxServer.Enabled = true;      
        this.textBoxDatabase.Enabled = true;
        // 
        this.buttonTest.Enabled = true;
        this.checkBoxRedirect.Enabled = true;        
        if (!AppSettings.sqlMultiTenant)
        {
          this.numericUpDownTenantID.Enabled = false;       
          this.checkBoxUseTenantUID.Enabled = false;
          this.textBoxTenantUID.Enabled = false;
        }
        else
        {
          this.checkBoxUseTenantUID.Enabled = AppSettings.sqlUseTenantUID;          
          this.textBoxTenantUID.Enabled = AppSettings.sqlUseTenantUID;
          this.numericUpDownTenantID.Enabled = AppSettings.sqlUseTenantUID;
        }
      }
    }
  
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
        this.toolStripMenuItemUnpackImplFiles.Enabled = true;        
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
        this.toolStripMenuItemUnpackImplFiles.Enabled = false;        
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
      this.toolStripMenuItemUnpackImplFiles.Checked = AppSettings.bUnpackImplFiles;      
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

    private void SetupForStandardActions()
    {   
      listBoxActions.Items.Clear();
      foreach (AppAction aa in AppActions.actionGroupsList[1].Values)
      {
        listBoxActions.Items.Add(aa.name);
      }
    }

    private void SetupForShellActions()
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

        #endregion

        private void label2_Click(object sender, EventArgs e)
        {

        }
    }
    
  #endregion

}
