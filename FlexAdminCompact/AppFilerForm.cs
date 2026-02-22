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
  #region Class AppFilerForm
  /// <summary>
  /// Summary description for AppFilerForm form class
  /// </summary>    
  public partial class AppFilerForm : System.Windows.Forms.Form
  {
    #region Data    
    // ******************************************************
    // private data
    // ******************************************************

    private BindingList<IconFileInfo> files = new BindingList<IconFileInfo>();
    private BindingList<IconFileInfo> logfiles = new BindingList<IconFileInfo>();  
    
    private ZipManifest zip;

    // ******************************************************
    // public data
    // ******************************************************

    public string AppShortVersion = String.Empty;    
    public string ScriptVersion = String.Empty;

    // ******************************************************
    // public external data
    // ******************************************************

  
    #endregion

    #region Constructors
    // ******************************************************
    // constructors
    // ******************************************************
    
    public AppFilerForm()
    {
      InitializeComponent();
      this.zip = new ZipManifest("archive");
      //
      // on payload tab
      this.textBoxImplFilesFolder.Text = AppSettings.implFilesFolder;
    }

    public AppFilerForm(string folder)
    {
      InitializeComponent();
      AppSettings.workingFolder = folder;
      this.zip = new ZipManifest("archive");            
      //
      // on payload tab
      this.textBoxImplFilesFolder.Text = AppSettings.implFilesFolder;
    }

    #endregion
  
    #region Event handlers
    // ******************************************************
    // dialog event handlers
    // ******************************************************

    private void AppFilerForm_Load(object sender, EventArgs e)
    {  
      Assembly ass = Assembly.GetExecutingAssembly();
      string[] res = ass.GetManifestResourceNames();
      //
      string[] nameparts = ass.GetName().Name.ToString().Split('_');      
      AppSettings.appName = nameparts[0]; 
      //
      AppFiler.ExtractPicture(ass, this.pictureBoxFiler, "crayon");
      //
      this.ScriptVersion = AppSettings.appVersion.Replace(".","");
      //
      this.checkBoxExtractHelp.Checked = AppSettings.bUnpackHelp;      
      this.checkBoxExtractScripts.Checked = AppSettings.bUnpackScripts;
      this.checkBoxExtractPayload.Checked = AppSettings.bUnpackPayload;
      this.checkBoxExtractImplFiles.Checked = AppSettings.bUnpackImplFiles;      
      this.checkBoxExtractEvents.Checked = AppSettings.bUnpackEvents;
      this.checkBoxExtractActions.Checked = AppSettings.bUnpackActions;      
      this.checkBoxExtractSource.Checked = AppSettings.bUnpackSource;
      this.checkBoxExtractVisualStudio.Checked = AppSettings.bUnpackVisualStudio;      

      //
      this.checkBoxPrompOverwrite.Checked = AppSettings.bPromptOverwrite;
      this.checkBoxUnpackZipped.Checked = AppSettings.bUnpackUnzip;
      //
      // grid files
      this.RefreshFilesList();      
      this.dataGridViewFiles.AutoGenerateColumns = false;
      this.dataGridViewFiles.DataSource = this.files;
      //
      // grid files
      //AppSettings.appLogFolder = AppSettings.rstrAppLogFolder;
      this.textBoxLogFilesFolder.Text = AppSettings.appLogFolder;
      this.RefreshLogFilesList();      
      this.dataGridViewLogFiles.AutoGenerateColumns = false;
      this.dataGridViewLogFiles.DataSource = this.logfiles;
    }

    #endregion
  
    #region Control event handlers
    // ******************************************************
    // dialog control event handlers
    // ******************************************************

    private void buttonClose_Click(object sender, EventArgs e)
    {
      this.DialogResult = DialogResult.OK;
      this.Close();
    }

    #endregion

    #region TabPage event handlers (Working)
    // ******************************************************
    // tabpage event handlers - Working
    // ******************************************************

    private void tabPageWorking_Enter(object sender, EventArgs e)
    {     
      RefreshFilesList();
    }

    // ******************************************************
    // tabpage event handlers - Working
    // ******************************************************

    private void buttonGoTo_Click(object sender, EventArgs e)
    {
      Logger.WriteLog(String.Format("GoTo working folder ... {0}", AppSettings.workingFolder)); 
      Process.Start("explorer.exe", AppSettings.workingFolder);
    }

    #endregion

    #region TabPage event handlers (Unpack)
    // ******************************************************
    // tabpage event handlers - Extract
    // ******************************************************

    private void tabPageUnpack_Enter(object sender, EventArgs e)
    {
    }

    // ******************************************************
    // tabpage event handlers - Unpack
    // ******************************************************

    private void buttonUnpack_Click(object sender, EventArgs e)
    {
      if (AppSettings.bUnpackHelp) AppFiler.UnpackHelp();    	
      if (AppSettings.bUnpackScripts) AppFiler.UnpackScripts();
      if (AppSettings.bUnpackPayload) AppFiler.UnpackPayload(AppSettings.bUnpackUnzip);
    }

    // ******************************************************
    // tabpage event handlers - Unpack
    // ******************************************************

    private void checkBoxExtractHelp_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxExtractHelp.CheckState;
      AppSettings.bUnpackHelp = (state == CheckState.Checked) ? true : false;      
    }

    private void checkBoxExtractScripts_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxExtractScripts.CheckState;
      AppSettings.bUnpackScripts = (state == CheckState.Checked) ? true : false;      
    }

    private void checkBoxExtractImplFiles_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxExtractImplFiles.CheckState;
      AppSettings.bUnpackImplFiles = (state == CheckState.Checked) ? true : false;      
    }

    private void checkBoxExtractPayload_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxExtractPayload.CheckState;
      AppSettings.bUnpackPayload = (state == CheckState.Checked) ? true : false;      
    }

    private void checkBoxExtractEvents_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxExtractEvents.CheckState;
      AppSettings.bUnpackEvents = (state == CheckState.Checked) ? true : false;      
    }

    private void checkBoxExtractActions_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxExtractActions.CheckState;
      AppSettings.bUnpackActions = (state == CheckState.Checked) ? true : false;      
    }

    private void checkBoxExtractSource_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxExtractSource.CheckState;
      AppSettings.bUnpackSource = (state == CheckState.Checked) ? true : false;      
    }

    private void checkBoxExtractVisualStudio_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxExtractVisualStudio.CheckState;
      AppSettings.bUnpackVisualStudio = (state == CheckState.Checked) ? true : false;      
    }

    // ******************************************************
    // tabpage event handlers - Unpack
    // ******************************************************

    private void checkBoxPrompOverwrite_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxPrompOverwrite.CheckState;
      AppSettings.bPromptOverwrite = (state == CheckState.Checked) ? true : false;
    }

    private void checkBoxUnpackZipped_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxUnpackZipped.CheckState;
      AppSettings.bUnpackUnzip = (state == CheckState.Checked) ? true : false;      
    }

    #endregion

    #region TabPage event handlers (LogFiles)
    // ******************************************************
    // tabpage event handlers - LogFiles
    // ******************************************************

    private void tabPageLogFiles_Enter(object sender, EventArgs e)
    {
      RefreshLogFilesList();
    }

    // ******************************************************
    // tabpage event handlers - LogFiles
    // ******************************************************

    private void buttonGoToLogFolder_Click(object sender, EventArgs e)
    {
      Logger.WriteLog(String.Format("GoTo LogFiles folder ... {0}", AppSettings.appLogFolder)); 
      Process.Start("explorer.exe", AppSettings.appLogFolder);
    }

    private void buttonViewLogfile_Click(object sender, EventArgs e)
    {
      DataGridViewRow vr = dataGridViewLogFiles.CurrentRow;
      string value = vr.Cells[1].Value.ToString();
      this.OpenFileWithShellApp("notepad", Path.Combine(AppSettings.appLogFolder,value));
    }

    #endregion

    #region TabPage event handlers (Payload)
    // ******************************************************
    // tabpage event handlers - Payload
    // ******************************************************

    private void tabPagePayload_Enter(object sender, EventArgs e)
    {
    }
    
    // ******************************************************
    // tabpage event handlers - Payload
    // ******************************************************

    private void buttonPackPayload_Click(object sender, EventArgs e)
    {
      string zf = Path.Combine(AppSettings.workingFolder, "payload.zip");     
      string nzf = Path.Combine(AppSettings.workingFolder, "new-payload.zip");
      ZipFile.CreateFromDirectory(AppSettings.implFilesFolder, zf);
      File.Copy(nzf, zf, true);
      File.Delete(nzf);      
    }

    // ******************************************************
    // tabpage event handlers - Payload
    // ******************************************************

    private void textBoxImplFilesFolder_TextChanged(object sender, EventArgs e)
    {
    }

    private void textBoxSettingsFileName_TextChanged(object sender, EventArgs e)
    {
    }
    

    // ******************************************************
    // tabpage event handlers - Payload
    // ******************************************************

    private void dataGridViewPayload_DragEnter(object sender, DragEventArgs e)
    {
      if (e.Data.GetDataPresent(DataFormats.FileDrop))
      {
        e.Effect = DragDropEffects.Copy;
      }
    }

    private void dataGridViewPayload_DragDrop(object sender, DragEventArgs e)
    {
      string filename = String.Empty;
      foreach (string fullfilename in (string[])e.Data.GetData(DataFormats.FileDrop))
      {
        filename = Path.GetFileName(fullfilename);
        if (filename.ToLower() == "manifest.xml")
        {
          zip.ReadManifest(fullfilename);
        }
        else
        {
          if (!Directory.Exists(fullfilename))
          {
            // its not a directory so it must be a file
            zip.Add(fullfilename);
          }
          else
          {
            // itterate through folder
            zip.AddFilesFromFolder(fullfilename);
          }
        }  
      }
    }

    #endregion
 
    #region Toolbar event handlers (Write)    
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

    private void toolStripMenuItemWriteDefaultScripts_Click(object sender, EventArgs e)
    {
      AppFiler.WriteDefaultShellScript(AppSettings.flexAdminScriptFileName, AppRunner.scriptArgs);
      AppFiler.WriteDefaultPowerShellScript(AppSettings.flexAdminScriptFileName, AppRunner.scriptArgs);
      AppFiler.WriteDefaultSqlScript(AppRunner.scriptArgs);      
    }

    private void toolStripMenuItemWriteTestScripts_Click(object sender, EventArgs e)
    {
      AppFiler.WriteShellScriptForTest(AppSettings.flexAdminScriptFileName, AppRunner.scriptArgs);
      AppFiler.WritePowerShellScriptForTest(AppSettings.flexAdminScriptFileName, AppRunner.scriptArgs);
      AppFiler.WriteSqlScriptForTest(AppRunner.scriptArgs);
    }

    private void toolStripMenuItemWriteEventsActions_Click(object sender, EventArgs e)
    {
      AppEvents.WriteEventsFile("FlexAdmin");
      AppActions.WriteActionsFile("FlexAdmin");
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
    
    #endregion
   
    #region Toolbar event handlers (Unpack)
    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

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
      AppFiler.UnpackVisualStudio();      
    }

    private void toolStripMenuItemUnpackPayload_Click(object sender, EventArgs e)
    {
      AppFiler.UnpackPayload();
    }

    private void toolStripMenuItemUnpackImplFiles_Click(object sender, EventArgs e)
    {
      AppFiler.UnpackImplFiles();
    }

    private void toolStripMenuItemUnpackHelp_Click(object sender, EventArgs e)
    {
      AppFiler.UnpackHelp();
    }

    private void toolStripMenuItemUnpackScript_Click(object sender, EventArgs e)
    {
      AppFiler.UnpackScripts();
    }

    private void toolStripMenuItemUnpackSource_Click(object sender, EventArgs e)
    {
      AppFiler.UnpackSource();
    }

    private void toolStripMenuItemUnpackActions_Click(object sender, EventArgs e)
    {
      AppFiler.UnpackActions();     
    }

    private void toolStripMenuItemUnpackEvents_Click(object sender, EventArgs e)
    {
      AppFiler.UnpackEvents();      
    }
                
    #endregion
  
    #region Toolbar event handlers (Events)
    // ******************************************************
    // toolbar control event handlers
    // ******************************************************

    private void toolStripMenuItemEventsEdit_Click(object sender, EventArgs e)
    {
      AppRunner.OpenWorkingFileWithShellApp(AppSettings.Editor, "events.xml");
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
    }
      
    #endregion

    #region Support methods
    // ******************************************************
    // support methods
    // ******************************************************
    
    private void RefreshFilesList()
    {     
      string [] fileEntries = Directory.GetFiles(AppSettings.workingFolder);
      this.dataGridViewFiles.Rows.Clear();      
      if (fileEntries.Length > 0) 
      {
        foreach (string f in fileEntries)
        {
          this.files.Add(new IconFileInfo(f));
        }
      }
    }
    // ******************************************************
    // support methods
    // ******************************************************
    
    private void RefreshLogFilesList()
    {     
      if (!String.IsNullOrEmpty(AppSettings.appLogFolder) && Directory.Exists(AppSettings.appLogFolder))
      {
        string [] fileEntries = Directory.GetFiles(AppSettings.appLogFolder, "*.log");
        this.dataGridViewLogFiles.Rows.Clear();      
        if (fileEntries.Length > 0) 
        {
          foreach (string f in fileEntries)
          {
            this.logfiles.Add(new IconFileInfo(f));
          }
        }
      }
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

  }
    
  #endregion

}
