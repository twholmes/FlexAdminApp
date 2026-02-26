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
  #region Class AppBuilderForm
  /// <summary>
  /// Summary description for AppBuilderForm form class
  /// </summary>    
  public partial class AppBuilderForm : System.Windows.Forms.Form
  {
    #region Data    
    // ******************************************************
    // private data
    // ******************************************************

    private enum TabContext { Build, Extract, Source, Payload };
    private TabContext context = TabContext.Build;    

    public BindingList<IconFileInfo> files = new BindingList<IconFileInfo>();
    public ZipManifest zip;

    // ******************************************************
    // public data
    // ******************************************************

    public bool bCompileFromTemp = true;    
    public string tempFolder = String.Empty;
    public string compilerFolder = String.Empty;    
    
    public string AppShortVersion = String.Empty;    
    public string ScriptVersion = String.Empty;

    // ******************************************************
    // public data
    // ******************************************************

    public string implFilesFolder = AppSettings.implFilesFolder;
    public string settingsFileName = AppSettings.settingsFileName;

    // ******************************************************
    // public data
    // ******************************************************

    public bool bExtractSource = true;
    public bool bExtractScripts = true;
    public bool bExtractPayload = true;
    public bool bExtractImplFiles = true;    
    public bool bExtractVisualStudio = false;
    public bool bExtractEvents = true;
    public bool bExtractActions = true;    
    //
    public bool bExtractUnzip = false;
    //
    public bool bPromptOverwrite = true;

    // ******************************************************
    // public data
    // ******************************************************

    //public string scriptType = ".cmd";
    //
    //public bool bBuildLocked = true;
    //public bool bRunFromTemp = true;

    // ******************************************************
    // public data
    // ******************************************************

    public bool bSafeZip = false;    
  
    #endregion

    #region Constructors
    // ******************************************************
    // constructors
    // ******************************************************
    
    public AppBuilderForm()
    {
      InitializeComponent();
      this.zip = new ZipManifest("archive");
    }

    public AppBuilderForm(string folder)
    {
      InitializeComponent();
      this.compilerFolder = folder;
      this.zip = new ZipManifest("archive");            
    }

    #endregion
  
    #region Event handlers

    // ******************************************************
    // dialog event handlers
    // ******************************************************

    private void AppBuilderForm_Load(object sender, EventArgs e)
    {  
      // initialise to compile-from-temp
      this.bCompileFromTemp = true;
      this.tempFolder = Path.Combine(Path.GetTempPath(), Path.GetRandomFileName());
      Directory.CreateDirectory(this.tempFolder);
      this.compilerFolder = this.tempFolder;
      Logger.WriteLog(String.Format("Current directory: {0}", Directory.GetCurrentDirectory()));
      Logger.WriteLog(String.Format("Compiler directory: {0}", this.tempFolder));
      AppBuilder.Initialise(this.compilerFolder);
      //      
      Assembly ass = Assembly.GetExecutingAssembly();
      string[] res = ass.GetManifestResourceNames();
      //
      string[] nameparts = ass.GetName().Name.ToString().Split('_');      
      AppSettings.appName = nameparts[0]; 
      this.textBoxAppName.Text = AppSettings.appName;
      //
      AppSettings.appVersion = ass.GetName().Version.ToString();
      string[] ver = AppSettings.appVersion.Split('.');
      int n1 = Int32.Parse(ver[0]);
      int n2 = Int32.Parse(ver[1]);
      int n3 = Int32.Parse(ver[2]);
      int n4 = Int32.Parse(ver[3]);       
      //
      numericUpDown1.Value = n1;
      numericUpDown2.Value = n2;
      numericUpDown3.Value = n3;
      numericUpDown4.Value = n4;      
      //
      // initialise app settings for build
      AppBuilder.bBuildLocked = AppSettings.bLocked;
      this.checkBoxBuildLocked.Checked = AppBuilder.bBuildLocked;
      //
      AppBuilder.bRunFromTemp = AppSettings.bRunFromTemp;
      AppBuilder.runFromLocation = AppSettings.runFromLocation;
      if (AppSettings.runFromLocation == "temp") radioButtonWorkTemp.Checked = true;
      if (AppSettings.runFromLocation == "local") radioButtonWorkLocal.Checked = true;
      if (AppSettings.runFromLocation == "ImplFiles") radioButtonWorkImplFiles.Checked = true;            
      //
      AppBuilder.bUnpackSource = this.bExtractSource;    
      //
      this.ScriptVersion = AppSettings.appVersion.Replace(".","");
      this.textBoxScriptVersion.Text = this.ScriptVersion;
      //
      this.checkBoxExtractSource.Checked = this.bExtractSource;
      this.checkBoxExtractScripts.Checked = this.bExtractScripts;
      this.checkBoxExtractPayload.Checked = this.bExtractPayload;
      this.checkBoxExtractImplFiles.Checked = this.bExtractImplFiles;      
      this.checkBoxExtractEvents.Checked = this.bExtractEvents;
      this.checkBoxExtractActions.Checked = this.bExtractActions;      
      this.checkBoxExtractVisualStudio.Checked = this.bExtractVisualStudio;
      //
      this.checkBoxPrompOverwrite.Checked = this.bPromptOverwrite;
      this.checkBoxUnpackZipped.Checked = this.bExtractUnzip;
      //
      // set the run tab picture 
      AppFiler.ExtractPicture(ass, this.pictureBoxSource, "file");      
      //
      // grid files
      if (this.bExtractScripts) AppBuilder.UnpackScripts();
      if (this.bExtractPayload) AppBuilder.UnpackPayload();
      if (this.bExtractImplFiles) AppBuilder.UnpackImplFiles();      
      if (this.bExtractEvents)  AppBuilder.UnpackEvents();
      if (this.bExtractActions) AppBuilder.UnpackActions();      
      if (this.bExtractSource)  AppBuilder.UnpackSource(AppBuilder.bBuildLocked);
      if (this.bExtractVisualStudio) AppBuilder.UnpackVisualStudio();      
      //      
      this.RefreshFilesList();      
      this.dataGridViewFiles.AutoGenerateColumns = false;
      this.dataGridViewFiles.DataSource = this.files;
      //
      // on implfiles tab
      this.textBoxImplFilesFolder.Text = this.implFilesFolder;
      this.textBoxSettingsFileName.Text = this.settingsFileName;
    }

    private void AppBuilderForm_FormClosing(object sender, FormClosingEventArgs e)
    {
      Directory.Delete(this.tempFolder, true);      
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

    // ******************************************************
    // dialog control event handlers
    // ******************************************************
 
    private void buttonUtility_Click(object sender, EventArgs e)
    {
      switch (this.context)
      {
        case TabContext.Build:
          try
          {
            AppBuilder.SafeZipApplication(AppSettings.appName);           
            System.Windows.Forms.MessageBox.Show(AppSettings.appName + "Safe-zip packaged", "AppBuilder", MessageBoxButtons.OK, MessageBoxIcon.Information); 
          }
          catch (Exception ex)
          {
            System.Windows.Forms.MessageBox.Show(ex.Message, "Package", MessageBoxButtons.OK, MessageBoxIcon.Error);
          }         
          break;
        
        case TabContext.Extract:
          if (this.bExtractScripts)   AppBuilder.UnpackScripts();
          if (this.bExtractPayload)   AppBuilder.UnpackPayload();
          if (this.bExtractImplFiles) AppBuilder.UnpackImplFiles();          
          if (this.bExtractEvents)    AppBuilder.UnpackEvents();
          if (this.bExtractActions)   AppBuilder.UnpackActions();      
          if (this.bExtractSource)    AppBuilder.UnpackSource(AppBuilder.bBuildLocked);
          if (this.bExtractVisualStudio) AppBuilder.UnpackVisualStudio();      
          break;
        
        case TabContext.Source:      
          Logger.WriteLog(String.Format("GoTo compiler folder ... {0}", this.compilerFolder)); 
          Process.Start("explorer.exe", this.compilerFolder);
          break;
          
        case TabContext.Payload:
          string zf = Path.Combine(this.compilerFolder, "payload.zip");     
          string nzf = Path.Combine(this.compilerFolder, "new-payload.zip");
          ZipFile.CreateFromDirectory(this.implFilesFolder, nzf);
          File.Copy(nzf, zf, true);
          File.Delete(nzf);        
          break;
          
        default:
          Logger.WriteLog(String.Format("GoTo compiler folder ... {0}", this.compilerFolder)); 
          Process.Start("explorer.exe", this.compilerFolder);
          break;
      }
    }
    
    // ******************************************************
    // dialog control event handlers
    // ******************************************************
    
    private void buttonBuild_Click(object sender, EventArgs e)
    {
      try
      {
        AppBuilder.PrepareSource(AppBuilder.bBuildLocked);
        //
        bool built = AppBuilder.Build(AppSettings.appName, AppSettings.appVersion);
        if (!built)
          MessageBox.Show(this, AppBuilder.Error, "AppBuilder", MessageBoxButtons.OK, MessageBoxIcon.Error);
        else
        {
          if (!this.bSafeZip)
            System.Windows.Forms.MessageBox.Show(AppSettings.appName + ".exe built", "AppBuilder", MessageBoxButtons.OK, MessageBoxIcon.Information);
          else
          {
            AppBuilder.SafeZipApplication(AppSettings.appName);           
            System.Windows.Forms.MessageBox.Show(AppSettings.appName + ".exe built (inc. safe-zip)", "AppBuilder", MessageBoxButtons.OK, MessageBoxIcon.Information); 
          }
        }
        AppBuilder.Dispose();
      }
      catch (Exception ex)
      {
        System.Windows.Forms.MessageBox.Show(ex.Message, "Compile", MessageBoxButtons.OK, MessageBoxIcon.Error);
      }            
    }

    // ******************************************************
    // dialog control event handlers
    // ******************************************************

    private void checkBoxWorkLocal_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxWorkLocal.CheckState;
      this.bCompileFromTemp = (state == CheckState.Checked) ? false : true;
      if (bCompileFromTemp)
      {
        this.compilerFolder = this.tempFolder;
        Logger.WriteLog(String.Format("Compiler directory: {0}", this.compilerFolder));        
      }
      else
      {
        Assembly ass = Assembly.GetExecutingAssembly();
        this.compilerFolder = Path.GetDirectoryName(ass.Location);
        Logger.WriteLog(String.Format("Compiler directory: {0}", this.compilerFolder));       
      }
      this.RefreshFilesList();       
    }

    private void checkBoxSafeZip_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxSafeZip.CheckState;
      this.bSafeZip = (state == CheckState.Checked) ? true : false;      
    }

    #endregion
  
    #region TabPage event handlers (Build)
    // ******************************************************
    // tabpage event handlers - Build
    // ******************************************************
              
    private void tabPageBuild_Enter(object sender, EventArgs e)
    {
      this.context = TabContext.Build;      
      this.buttonUtility.Text = "SafeZip";
    }
    
    // ******************************************************
    // tabpage event handlers - Build
    // ******************************************************

    private void checkBoxBuildLocked_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxBuildLocked.CheckState;
      AppBuilder.bBuildLocked = (state == CheckState.Checked) ? true : false; 
    }

    // ******************************************************
    // tabpage event handlers - Build
    // ******************************************************

    private void radioButtonWorkTemp_Click(object sender, EventArgs e)
    {
      AppBuilder.bRunFromTemp = true;     
      AppBuilder.runFromLocation = "temp";
    }

    private void radioButtonWorkLocal_Click(object sender, EventArgs e)
    {
      AppBuilder.bRunFromTemp = false;      
      AppBuilder.runFromLocation = "local";      
    }

    private void radioButtonWorkImplFiles_Click(object sender, EventArgs e)
    {
      AppBuilder.bRunFromTemp = false;  
      AppBuilder.runFromLocation = "ImplFiles";      
    }

    // ******************************************************
    // tabpage event handlers - Build
    // ******************************************************

    private void textBoxAppName_TextChanged(object sender, EventArgs e)
    {
      AppSettings.appName = textBoxAppName.Text;
    }
    
    private void numericUpDown1_ValueChanged(object sender, EventArgs e)
    {
      string n1 = numericUpDown1.Value.ToString();
      string n2 = numericUpDown2.Value.ToString();
      string n3 = numericUpDown3.Value.ToString();
      string n4 = numericUpDown4.Value.ToString();
      AppSettings.appVersion = String.Format("{0}.{1}.{2}.{3}", n1, n2, n3, n4);
    }

    private void numericUpDown2_ValueChanged(object sender, EventArgs e)
    {
      string n1 = numericUpDown1.Value.ToString();
      string n2 = numericUpDown2.Value.ToString();
      string n3 = numericUpDown3.Value.ToString();
      string n4 = numericUpDown4.Value.ToString();
      AppSettings.appVersion = String.Format("{0}.{1}.{2}.{3}", n1, n2, n3, n4);
    }

    private void numericUpDown3_ValueChanged(object sender, EventArgs e)
    {
      string n1 = numericUpDown1.Value.ToString();
      string n2 = numericUpDown2.Value.ToString();
      string n3 = numericUpDown3.Value.ToString();
      string n4 = numericUpDown4.Value.ToString();
      AppSettings.appVersion = String.Format("{0}.{1}.{2}.{3}", n1, n2, n3, n4);
    }

    private void numericUpDown4_ValueChanged(object sender, EventArgs e)
    {
      string n1 = numericUpDown1.Value.ToString();
      string n2 = numericUpDown2.Value.ToString();
      string n3 = numericUpDown3.Value.ToString();
      string n4 = numericUpDown4.Value.ToString();
      AppSettings.appVersion = String.Format("{0}.{1}.{2}.{3}", n1, n2, n3, n4);
    }

    // ******************************************************
    // tabpage event handlers - Build
    // ******************************************************

    private void textBoxScriptVersion_TextChanged(object sender, EventArgs e)
    {
      this.ScriptVersion = textBoxScriptVersion.Text;
    }

    // ******************************************************
    // tabpage event handlers - Build
    // ******************************************************

    private void checkBoxPrompOverwrite_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxPrompOverwrite.CheckState;
      this.bPromptOverwrite = (state == CheckState.Checked) ? true : false;
    }

    private void checkBoxUnpackZipped_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxUnpackZipped.CheckState;
      this.bExtractUnzip = (state == CheckState.Checked) ? true : false;      
    }

    #endregion

    #region TabPage event handlers (Extract)
    // ******************************************************
    // tabpage event handlers - Extract 
    // ******************************************************
              
    private void tabPageExtract_Enter(object sender, EventArgs e)
    {
      this.context = TabContext.Extract; 
      this.buttonUtility.Text = "Extract";
    }    

    // ******************************************************
    // tabpage event handlers - Extract
    // ******************************************************

    private void checkBoxExtractSource_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxExtractSource.CheckState;
      this.bExtractSource = (state == CheckState.Checked) ? true : false;      
    }

    private void checkBoxExtractScripts_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxExtractScripts.CheckState;
      this.bExtractScripts = (state == CheckState.Checked) ? true : false;      
    }

    private void checkBoxExtractPayload_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxExtractPayload.CheckState;
      this.bExtractPayload = (state == CheckState.Checked) ? true : false;      
    }

    private void checkBoxExtractImplFiles_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxExtractImplFiles.CheckState;
      this.bExtractImplFiles = (state == CheckState.Checked) ? true : false;      
    }

    private void checkBoxExtractEvents_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxExtractEvents.CheckState;
      this.bExtractEvents = (state == CheckState.Checked) ? true : false;      
    }

    private void checkBoxExtractActions_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxExtractActions.CheckState;
      this.bExtractActions = (state == CheckState.Checked) ? true : false;      
    }

    private void checkBoxExtractVisualStudio_CheckedChanged(object sender, EventArgs e)
    {
      CheckState state = this.checkBoxExtractVisualStudio.CheckState;
      this.bExtractVisualStudio = (state == CheckState.Checked) ? true : false;      
    }

    // ******************************************************
    // tabpage event handlers - Extract
    // ******************************************************
  
    private void checkBoxRequirePassword_CheckedChanged(object sender, EventArgs e)
    {
    }

    private void textBoxPassword_TextChanged(object sender, EventArgs e)
    {
    }

    #endregion

    #region TabPage event handlers (Source)
    // ******************************************************
    // tabpage event handlers - Source
    // ******************************************************

    private void tabPageSource_Enter(object sender, EventArgs e)
    {   
      this.context = TabContext.Source; 
      this.buttonUtility.Text = "GoTo";
      //         
      RefreshFilesList();
    }

    // ******************************************************
    // tabpage event handlers - Source
    // ******************************************************

    private void dataGridViewFiles_DragEnter(object sender, DragEventArgs e)
    {
      if (e.Data.GetDataPresent(DataFormats.FileDrop))
      {
        e.Effect = DragDropEffects.Copy;
      }
    }

    private void dataGridViewFiles_DragDrop(object sender, DragEventArgs e)
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
            zip.Add(fullfilename);
          else
            zip.AddFilesFromFolder(fullfilename);
        }  
      }
    }
    
    // ******************************************************
    // tabpage event handlers - Source
    // ******************************************************
    
    private void dataGridViewFiles_SelectionChanged(object sender, EventArgs e)
    {
      Int32 selectedRowCount = dataGridViewFiles.Rows.GetRowCount(DataGridViewElementStates.Selected);
      if (selectedRowCount == 1)
      {
        //this.textBoxSourcePath.Text = dataGridViewFiles.SelectedRows[0].Cells[4].Value.ToString();
        //this.textBoxSourceSize.Text = dataGridViewFiles.SelectedRows[0].Cells[2].Value.ToString();
        //this.textBoxSourceDate.Text = dataGridViewFiles.SelectedRows[0].Cells[3].Value.ToString();        
        
        int n = dataGridViewFiles.SelectedRows[0].Index;
        this.textBoxSourceName.Text = this.files[n].Name;        
        this.textBoxSourcePath.Text = this.files[n].DirectoryName;
        this.textBoxSourceSize.Text = this.files[n].Size.ToString();
        this.textBoxSourceDate.Text = this.files[n].Date.ToString();        
      }
    }
 
    // ******************************************************
    // tabpage event handlers - Source
    // ******************************************************
    
    private void buttonSourceDelete_Click(object sender, EventArgs e)
    {
      Int32 selectedRowCount = dataGridViewFiles.Rows.GetRowCount(DataGridViewElementStates.Selected);
      if (selectedRowCount == 1)
      {        
        int n = dataGridViewFiles.SelectedRows[0].Index;
        string filename = this.files[n].FullName;
        File.Delete(filename);         
      }      
      RefreshFilesList();           
    }

    #endregion

    #region TabPage event handlers (Payload)
    // ******************************************************
    // tabpage event handlers - Payload
    // ******************************************************

    private void tabPagePayload_Enter(object sender, EventArgs e)
    {
      this.context = TabContext.Payload; 
      this.buttonUtility.Text = "Pack";
    }

    // ******************************************************
    // tabpage event handlers - Payload
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
        this.implFilesFolder = Path.GetDirectoryName(filepath);
        this.settingsFileName = Path.GetFileName(filepath);
      }     
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

    #endregion
  
    #region Support methods
    // ******************************************************
    // Setup methods
    // ******************************************************
    
    private void RefreshFilesList()
    {     
      string [] fileEntries = Directory.GetFiles(this.compilerFolder);
      this.dataGridViewFiles.Rows.Clear();      
      if (fileEntries.Length > 0) 
      {
        this.files = new BindingList<IconFileInfo>();      	
        foreach (string f in fileEntries)
        {
          this.files.Add(new IconFileInfo(f));
        }
        this.dataGridViewFiles.DataSource = this.files;          
      }
    }

    #endregion
        
  }

  #endregion

}
