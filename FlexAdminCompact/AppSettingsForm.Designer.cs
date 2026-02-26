namespace BlackBox
{
    partial class AppSettingsForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.buttonOK = new System.Windows.Forms.Button();
            this.textBoxDatabase = new System.Windows.Forms.TextBox();
            this.labelDatabase = new System.Windows.Forms.Label();
            this.buttonCancel = new System.Windows.Forms.Button();
            this.labelConnectionString = new System.Windows.Forms.Label();
            this.textBoxServer = new System.Windows.Forms.TextBox();
            this.labelServer = new System.Windows.Forms.Label();
            this.buttonTest = new System.Windows.Forms.Button();
            this.groupBoxAppVersion = new System.Windows.Forms.GroupBox();
            this.checkBoxRedirect = new System.Windows.Forms.CheckBox();
            this.tabControlSettings = new System.Windows.Forms.TabControl();
            this.tabPagePrimary = new System.Windows.Forms.TabPage();
            this.checkBoxCheckPayload = new System.Windows.Forms.CheckBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.labelCommandFile = new System.Windows.Forms.Label();
            this.textBoxCmdFile = new System.Windows.Forms.TextBox();
            this.labelScriptFile = new System.Windows.Forms.Label();
            this.textBoxScriptFile = new System.Windows.Forms.TextBox();
            this.groupBoxAccessControl = new System.Windows.Forms.GroupBox();
            this.checkBoxRequirePassword = new System.Windows.Forms.CheckBox();
            this.labelPassword = new System.Windows.Forms.Label();
            this.textBoxPassword = new System.Windows.Forms.TextBox();
            this.tabPageImplFiles = new System.Windows.Forms.TabPage();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.buttonSelectLogs = new System.Windows.Forms.Button();
            this.textBoxLogFilesFolder = new System.Windows.Forms.TextBox();
            this.labelLogFilesFolder = new System.Windows.Forms.Label();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.textBoxImplFilesScriptName = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.labelSettingsFile = new System.Windows.Forms.Label();
            this.buttonSelectSettings = new System.Windows.Forms.Button();
            this.labelImplFilesFolder = new System.Windows.Forms.Label();
            this.textBoxSettingsFileName = new System.Windows.Forms.TextBox();
            this.textBoxImplFilesFolder = new System.Windows.Forms.TextBox();
            this.tabPageSQL = new System.Windows.Forms.TabPage();
            this.checkBoxSqlEnabled = new System.Windows.Forms.CheckBox();
            this.groupBoxTenant = new System.Windows.Forms.GroupBox();
            this.numericUpDownTenantID = new System.Windows.Forms.NumericUpDown();
            this.textBoxTenantUID = new System.Windows.Forms.TextBox();
            this.checkBoxUseTenantUID = new System.Windows.Forms.CheckBox();
            this.checkBoxMultiTenant = new System.Windows.Forms.CheckBox();
            this.tabPageEvents = new System.Windows.Forms.TabPage();
            this.buttonEventsEdit = new System.Windows.Forms.Button();
            this.checkBoxEventsHidden = new System.Windows.Forms.CheckBox();
            this.groupBoxEvents = new System.Windows.Forms.GroupBox();
            this.checkBoxEventPost = new System.Windows.Forms.CheckBox();
            this.checkBoxEventPre = new System.Windows.Forms.CheckBox();
            this.checkBoxEventDrop = new System.Windows.Forms.CheckBox();
            this.checkBoxEventUnpack = new System.Windows.Forms.CheckBox();
            this.checkBoxEventBuild = new System.Windows.Forms.CheckBox();
            this.checkBoxEventExit = new System.Windows.Forms.CheckBox();
            this.tabPageActions = new System.Windows.Forms.TabPage();
            this.radioButtonCustomActions = new System.Windows.Forms.RadioButton();
            this.radioButtonAllActions = new System.Windows.Forms.RadioButton();
            this.radioButtonShellActions = new System.Windows.Forms.RadioButton();
            this.textBoxActionLabel = new System.Windows.Forms.TextBox();
            this.button1 = new System.Windows.Forms.Button();
            this.labelActionsList = new System.Windows.Forms.Label();
            this.checkBoxActionEnabled = new System.Windows.Forms.CheckBox();
            this.textBoxActionType = new System.Windows.Forms.TextBox();
            this.textBoxActionMenu = new System.Windows.Forms.TextBox();
            this.textBoxActionName = new System.Windows.Forms.TextBox();
            this.buttonActionsRun = new System.Windows.Forms.Button();
            this.listBoxActions = new System.Windows.Forms.ListBox();
            this.tabPageOther = new System.Windows.Forms.TabPage();
            this.groupBoxEditor = new System.Windows.Forms.GroupBox();
            this.comboBoxEditor = new System.Windows.Forms.ComboBox();
            this.labelOtherMessage = new System.Windows.Forms.Label();
            this.buttonReset = new System.Windows.Forms.Button();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.toolStripMenuItemSettimgs = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemLocked = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator4 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStripMenuItemFromTemp = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemFromLocal = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemFromHome = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpack = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpackUnzip = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStripMenuItemUnpackScript = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpackImplFiles = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpackPayload = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpackActions = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpackEvents = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpackSource = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpackVisualStudio = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStripMenuItemUnpackClear = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemEvents = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemEventsEdit = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemEventsReload = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator5 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStripMenuItemEventsHidden = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator3 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStripMenuItemEventBuild = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemEventUnpack = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemEventDrop = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemEventPreRUN = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemEventPostRUN = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemEventExit = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemActions = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemActionsEdit = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemActionsReload = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemActionsRewrite = new System.Windows.Forms.ToolStripMenuItem();
            this.groupBoxAppVersion.SuspendLayout();
            this.tabControlSettings.SuspendLayout();
            this.tabPagePrimary.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.groupBoxAccessControl.SuspendLayout();
            this.tabPageImplFiles.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.tabPageSQL.SuspendLayout();
            this.groupBoxTenant.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownTenantID)).BeginInit();
            this.tabPageEvents.SuspendLayout();
            this.groupBoxEvents.SuspendLayout();
            this.tabPageActions.SuspendLayout();
            this.tabPageOther.SuspendLayout();
            this.groupBoxEditor.SuspendLayout();
            this.menuStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // buttonOK
            // 
            this.buttonOK.Location = new System.Drawing.Point(12, 355);
            this.buttonOK.Name = "buttonOK";
            this.buttonOK.Size = new System.Drawing.Size(75, 23);
            this.buttonOK.TabIndex = 0;
            this.buttonOK.Text = "OK";
            this.buttonOK.UseVisualStyleBackColor = true;
            this.buttonOK.Click += new System.EventHandler(this.buttonOK_Click);
            // 
            // textBoxDatabase
            // 
            this.textBoxDatabase.Location = new System.Drawing.Point(76, 59);
            this.textBoxDatabase.Name = "textBoxDatabase";
            this.textBoxDatabase.Size = new System.Drawing.Size(186, 20);
            this.textBoxDatabase.TabIndex = 6;
            this.textBoxDatabase.TextChanged += new System.EventHandler(this.textBoxDatabase_TextChanged);
            // 
            // labelDatabase
            // 
            this.labelDatabase.AutoSize = true;
            this.labelDatabase.Location = new System.Drawing.Point(21, 62);
            this.labelDatabase.Name = "labelDatabase";
            this.labelDatabase.Size = new System.Drawing.Size(56, 13);
            this.labelDatabase.TabIndex = 7;
            this.labelDatabase.Text = "Database:";
            // 
            // buttonCancel
            // 
            this.buttonCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.buttonCancel.Location = new System.Drawing.Point(98, 355);
            this.buttonCancel.Name = "buttonCancel";
            this.buttonCancel.Size = new System.Drawing.Size(75, 23);
            this.buttonCancel.TabIndex = 9;
            this.buttonCancel.Text = "Cancel";
            this.buttonCancel.UseVisualStyleBackColor = true;
            this.buttonCancel.Click += new System.EventHandler(this.buttonCancel_Click);
            // 
            // labelConnectionString
            // 
            this.labelConnectionString.AutoSize = true;
            this.labelConnectionString.Location = new System.Drawing.Point(20, 160);
            this.labelConnectionString.Name = "labelConnectionString";
            this.labelConnectionString.Size = new System.Drawing.Size(16, 13);
            this.labelConnectionString.TabIndex = 10;
            this.labelConnectionString.Text = "...";
            // 
            // textBoxServer
            // 
            this.textBoxServer.Location = new System.Drawing.Point(76, 25);
            this.textBoxServer.Name = "textBoxServer";
            this.textBoxServer.Size = new System.Drawing.Size(186, 20);
            this.textBoxServer.TabIndex = 3;
            this.textBoxServer.TextChanged += new System.EventHandler(this.textBoxServer_TextChanged);
            // 
            // labelServer
            // 
            this.labelServer.AutoSize = true;
            this.labelServer.Location = new System.Drawing.Point(21, 29);
            this.labelServer.Name = "labelServer";
            this.labelServer.Size = new System.Drawing.Size(38, 13);
            this.labelServer.TabIndex = 4;
            this.labelServer.Text = "Name:";
            // 
            // buttonTest
            // 
            this.buttonTest.Location = new System.Drawing.Point(291, 25);
            this.buttonTest.Name = "buttonTest";
            this.buttonTest.Size = new System.Drawing.Size(100, 50);
            this.buttonTest.TabIndex = 1;
            this.buttonTest.Text = "Test";
            this.buttonTest.UseVisualStyleBackColor = true;
            this.buttonTest.Click += new System.EventHandler(this.buttonTest_Click);
            // 
            // groupBoxAppVersion
            // 
            this.groupBoxAppVersion.Controls.Add(this.checkBoxRedirect);
            this.groupBoxAppVersion.Controls.Add(this.textBoxDatabase);
            this.groupBoxAppVersion.Controls.Add(this.buttonTest);
            this.groupBoxAppVersion.Controls.Add(this.labelDatabase);
            this.groupBoxAppVersion.Controls.Add(this.labelServer);
            this.groupBoxAppVersion.Controls.Add(this.textBoxServer);
            this.groupBoxAppVersion.Location = new System.Drawing.Point(20, 50);
            this.groupBoxAppVersion.Name = "groupBoxAppVersion";
            this.groupBoxAppVersion.Size = new System.Drawing.Size(530, 101);
            this.groupBoxAppVersion.TabIndex = 2;
            this.groupBoxAppVersion.TabStop = false;
            this.groupBoxAppVersion.Text = "SQL Server Connection String";
            // 
            // checkBoxRedirect
            // 
            this.checkBoxRedirect.AutoSize = true;
            this.checkBoxRedirect.Location = new System.Drawing.Point(413, 43);
            this.checkBoxRedirect.Name = "checkBoxRedirect";
            this.checkBoxRedirect.Size = new System.Drawing.Size(94, 17);
            this.checkBoxRedirect.TabIndex = 11;
            this.checkBoxRedirect.Text = "redirect output";
            this.checkBoxRedirect.UseVisualStyleBackColor = true;
            this.checkBoxRedirect.CheckedChanged += new System.EventHandler(this.checkBoxRedirect_CheckedChanged);
            // 
            // tabControlSettings
            // 
            this.tabControlSettings.Controls.Add(this.tabPagePrimary);
            this.tabControlSettings.Controls.Add(this.tabPageImplFiles);
            this.tabControlSettings.Controls.Add(this.tabPageSQL);
            this.tabControlSettings.Controls.Add(this.tabPageEvents);
            this.tabControlSettings.Controls.Add(this.tabPageActions);
            this.tabControlSettings.Controls.Add(this.tabPageOther);
            this.tabControlSettings.Location = new System.Drawing.Point(0, 27);
            this.tabControlSettings.Name = "tabControlSettings";
            this.tabControlSettings.SelectedIndex = 0;
            this.tabControlSettings.Size = new System.Drawing.Size(580, 310);
            this.tabControlSettings.TabIndex = 10;
            // 
            // tabPagePrimary
            // 
            this.tabPagePrimary.BackColor = System.Drawing.SystemColors.Control;
            this.tabPagePrimary.Controls.Add(this.checkBoxCheckPayload);
            this.tabPagePrimary.Controls.Add(this.groupBox1);
            this.tabPagePrimary.Controls.Add(this.groupBoxAccessControl);
            this.tabPagePrimary.Location = new System.Drawing.Point(4, 22);
            this.tabPagePrimary.Name = "tabPagePrimary";
            this.tabPagePrimary.Padding = new System.Windows.Forms.Padding(3);
            this.tabPagePrimary.Size = new System.Drawing.Size(572, 261);
            this.tabPagePrimary.TabIndex = 1;
            this.tabPagePrimary.Text = "Primary";
            this.tabPagePrimary.Enter += new System.EventHandler(this.tabPagePrimary_Enter);
            // 
            // checkBoxCheckPayload
            // 
            this.checkBoxCheckPayload.AutoSize = true;
            this.checkBoxCheckPayload.Location = new System.Drawing.Point(20, 145);
            this.checkBoxCheckPayload.Name = "checkBoxCheckPayload";
            this.checkBoxCheckPayload.Size = new System.Drawing.Size(169, 17);
            this.checkBoxCheckPayload.TabIndex = 12;
            this.checkBoxCheckPayload.Text = "Check that payload is installed";
            this.checkBoxCheckPayload.UseVisualStyleBackColor = true;
            this.checkBoxCheckPayload.CheckedChanged += new System.EventHandler(this.checkBoxCheckPayload_CheckedChanged);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.labelCommandFile);
            this.groupBox1.Controls.Add(this.textBoxCmdFile);
            this.groupBox1.Controls.Add(this.labelScriptFile);
            this.groupBox1.Controls.Add(this.textBoxScriptFile);
            this.groupBox1.Location = new System.Drawing.Point(295, 20);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(250, 100);
            this.groupBox1.TabIndex = 11;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Shell Script Defaults";
            // 
            // labelCommandFile
            // 
            this.labelCommandFile.AutoSize = true;
            this.labelCommandFile.Location = new System.Drawing.Point(21, 64);
            this.labelCommandFile.Name = "labelCommandFile";
            this.labelCommandFile.Size = new System.Drawing.Size(53, 13);
            this.labelCommandFile.TabIndex = 14;
            this.labelCommandFile.Text = "CMD File:";
            this.labelCommandFile.Click += new System.EventHandler(this.label2_Click);
            // 
            // textBoxCmdFile
            // 
            this.textBoxCmdFile.Location = new System.Drawing.Point(83, 60);
            this.textBoxCmdFile.Name = "textBoxCmdFile";
            this.textBoxCmdFile.Size = new System.Drawing.Size(150, 20);
            this.textBoxCmdFile.TabIndex = 13;
            this.textBoxCmdFile.TextChanged += new System.EventHandler(this.textBoxCmdFile_TextChanged);
            // 
            // labelScriptFile
            // 
            this.labelScriptFile.AutoSize = true;
            this.labelScriptFile.Location = new System.Drawing.Point(21, 33);
            this.labelScriptFile.Name = "labelScriptFile";
            this.labelScriptFile.Size = new System.Drawing.Size(56, 13);
            this.labelScriptFile.TabIndex = 6;
            this.labelScriptFile.Text = "Script File:";
            // 
            // textBoxScriptFile
            // 
            this.textBoxScriptFile.Location = new System.Drawing.Point(83, 29);
            this.textBoxScriptFile.Name = "textBoxScriptFile";
            this.textBoxScriptFile.Size = new System.Drawing.Size(150, 20);
            this.textBoxScriptFile.TabIndex = 5;
            this.textBoxScriptFile.TextChanged += new System.EventHandler(this.textBoxScriptFile_TextChanged);
            // 
            // groupBoxAccessControl
            // 
            this.groupBoxAccessControl.Controls.Add(this.checkBoxRequirePassword);
            this.groupBoxAccessControl.Controls.Add(this.labelPassword);
            this.groupBoxAccessControl.Controls.Add(this.textBoxPassword);
            this.groupBoxAccessControl.Location = new System.Drawing.Point(20, 20);
            this.groupBoxAccessControl.Name = "groupBoxAccessControl";
            this.groupBoxAccessControl.Size = new System.Drawing.Size(255, 100);
            this.groupBoxAccessControl.TabIndex = 3;
            this.groupBoxAccessControl.TabStop = false;
            this.groupBoxAccessControl.Text = "Access Control";
            // 
            // checkBoxRequirePassword
            // 
            this.checkBoxRequirePassword.AutoSize = true;
            this.checkBoxRequirePassword.Location = new System.Drawing.Point(24, 63);
            this.checkBoxRequirePassword.Name = "checkBoxRequirePassword";
            this.checkBoxRequirePassword.Size = new System.Drawing.Size(161, 17);
            this.checkBoxRequirePassword.TabIndex = 11;
            this.checkBoxRequirePassword.Text = "Require Password to Unlock";
            this.checkBoxRequirePassword.UseVisualStyleBackColor = true;
            this.checkBoxRequirePassword.CheckedChanged += new System.EventHandler(this.checkBoxRequirePassword_CheckedChanged);
            // 
            // labelPassword
            // 
            this.labelPassword.AutoSize = true;
            this.labelPassword.Location = new System.Drawing.Point(21, 29);
            this.labelPassword.Name = "labelPassword";
            this.labelPassword.Size = new System.Drawing.Size(56, 13);
            this.labelPassword.TabIndex = 4;
            this.labelPassword.Text = "Password:";
            // 
            // textBoxPassword
            // 
            this.textBoxPassword.Location = new System.Drawing.Point(83, 25);
            this.textBoxPassword.Name = "textBoxPassword";
            this.textBoxPassword.Size = new System.Drawing.Size(150, 20);
            this.textBoxPassword.TabIndex = 3;
            this.textBoxPassword.TextChanged += new System.EventHandler(this.textBoxPassword_TextChanged);
            // 
            // tabPageImplFiles
            // 
            this.tabPageImplFiles.BackColor = System.Drawing.SystemColors.Control;
            this.tabPageImplFiles.Controls.Add(this.groupBox3);
            this.tabPageImplFiles.Controls.Add(this.groupBox2);
            this.tabPageImplFiles.Location = new System.Drawing.Point(4, 22);
            this.tabPageImplFiles.Name = "tabPageImplFiles";
            this.tabPageImplFiles.Size = new System.Drawing.Size(572, 261);
            this.tabPageImplFiles.TabIndex = 3;
            this.tabPageImplFiles.Text = "ImplFiles";
            this.tabPageImplFiles.Enter += new System.EventHandler(this.tabPageImplFiles_Enter);
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.buttonSelectLogs);
            this.groupBox3.Controls.Add(this.textBoxLogFilesFolder);
            this.groupBox3.Controls.Add(this.labelLogFilesFolder);
            this.groupBox3.Location = new System.Drawing.Point(20, 145);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(535, 70);
            this.groupBox3.TabIndex = 6;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "LogFiles";
            // 
            // buttonSelectLogs
            // 
            this.buttonSelectLogs.Location = new System.Drawing.Point(445, 25);
            this.buttonSelectLogs.Name = "buttonSelectLogs";
            this.buttonSelectLogs.Size = new System.Drawing.Size(75, 23);
            this.buttonSelectLogs.TabIndex = 5;
            this.buttonSelectLogs.Text = "Select ...";
            this.buttonSelectLogs.UseVisualStyleBackColor = true;
            this.buttonSelectLogs.Click += new System.EventHandler(this.buttonSelectLogs_Click);
            // 
            // textBoxLogFilesFolder
            // 
            this.textBoxLogFilesFolder.Enabled = false;
            this.textBoxLogFilesFolder.Location = new System.Drawing.Point(76, 27);
            this.textBoxLogFilesFolder.Name = "textBoxLogFilesFolder";
            this.textBoxLogFilesFolder.Size = new System.Drawing.Size(265, 20);
            this.textBoxLogFilesFolder.TabIndex = 4;
            // 
            // labelLogFilesFolder
            // 
            this.labelLogFilesFolder.AutoSize = true;
            this.labelLogFilesFolder.Location = new System.Drawing.Point(17, 30);
            this.labelLogFilesFolder.Name = "labelLogFilesFolder";
            this.labelLogFilesFolder.Size = new System.Drawing.Size(39, 13);
            this.labelLogFilesFolder.TabIndex = 3;
            this.labelLogFilesFolder.Text = "Folder:";
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.textBoxImplFilesScriptName);
            this.groupBox2.Controls.Add(this.label1);
            this.groupBox2.Controls.Add(this.labelSettingsFile);
            this.groupBox2.Controls.Add(this.buttonSelectSettings);
            this.groupBox2.Controls.Add(this.labelImplFilesFolder);
            this.groupBox2.Controls.Add(this.textBoxSettingsFileName);
            this.groupBox2.Controls.Add(this.textBoxImplFilesFolder);
            this.groupBox2.Location = new System.Drawing.Point(20, 20);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(535, 110);
            this.groupBox2.TabIndex = 5;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "ImplFiles";
            // 
            // textBoxImplFilesScriptName
            // 
            this.textBoxImplFilesScriptName.Location = new System.Drawing.Point(76, 79);
            this.textBoxImplFilesScriptName.Name = "textBoxImplFilesScriptName";
            this.textBoxImplFilesScriptName.Size = new System.Drawing.Size(150, 20);
            this.textBoxImplFilesScriptName.TabIndex = 6;
            this.textBoxImplFilesScriptName.TextChanged += new System.EventHandler(this.textBoxImplFilesScriptName_TextChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(17, 82);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(37, 13);
            this.label1.TabIndex = 5;
            this.label1.Text = "Script:";
            // 
            // labelSettingsFile
            // 
            this.labelSettingsFile.AutoSize = true;
            this.labelSettingsFile.Location = new System.Drawing.Point(17, 50);
            this.labelSettingsFile.Name = "labelSettingsFile";
            this.labelSettingsFile.Size = new System.Drawing.Size(48, 13);
            this.labelSettingsFile.TabIndex = 0;
            this.labelSettingsFile.Text = "Settings:";
            // 
            // buttonSelectSettings
            // 
            this.buttonSelectSettings.Location = new System.Drawing.Point(445, 15);
            this.buttonSelectSettings.Name = "buttonSelectSettings";
            this.buttonSelectSettings.Size = new System.Drawing.Size(75, 23);
            this.buttonSelectSettings.TabIndex = 4;
            this.buttonSelectSettings.Text = "Select ...";
            this.buttonSelectSettings.UseVisualStyleBackColor = true;
            this.buttonSelectSettings.Click += new System.EventHandler(this.buttonSelectSettings_Click);
            // 
            // labelImplFilesFolder
            // 
            this.labelImplFilesFolder.AutoSize = true;
            this.labelImplFilesFolder.Location = new System.Drawing.Point(17, 20);
            this.labelImplFilesFolder.Name = "labelImplFilesFolder";
            this.labelImplFilesFolder.Size = new System.Drawing.Size(39, 13);
            this.labelImplFilesFolder.TabIndex = 2;
            this.labelImplFilesFolder.Text = "Folder:";
            // 
            // textBoxSettingsFileName
            // 
            this.textBoxSettingsFileName.Location = new System.Drawing.Point(76, 47);
            this.textBoxSettingsFileName.Name = "textBoxSettingsFileName";
            this.textBoxSettingsFileName.Size = new System.Drawing.Size(150, 20);
            this.textBoxSettingsFileName.TabIndex = 1;
            this.textBoxSettingsFileName.TextChanged += new System.EventHandler(this.textBoxSettingsFileName_TextChanged);
            // 
            // textBoxImplFilesFolder
            // 
            this.textBoxImplFilesFolder.Enabled = false;
            this.textBoxImplFilesFolder.Location = new System.Drawing.Point(76, 17);
            this.textBoxImplFilesFolder.Name = "textBoxImplFilesFolder";
            this.textBoxImplFilesFolder.Size = new System.Drawing.Size(265, 20);
            this.textBoxImplFilesFolder.TabIndex = 3;
            this.textBoxImplFilesFolder.TextChanged += new System.EventHandler(this.textBoxImplFilesFolder_TextChanged);
            // 
            // tabPageSQL
            // 
            this.tabPageSQL.BackColor = System.Drawing.SystemColors.Control;
            this.tabPageSQL.Controls.Add(this.checkBoxSqlEnabled);
            this.tabPageSQL.Controls.Add(this.labelConnectionString);
            this.tabPageSQL.Controls.Add(this.groupBoxTenant);
            this.tabPageSQL.Controls.Add(this.groupBoxAppVersion);
            this.tabPageSQL.Location = new System.Drawing.Point(4, 22);
            this.tabPageSQL.Name = "tabPageSQL";
            this.tabPageSQL.Padding = new System.Windows.Forms.Padding(3);
            this.tabPageSQL.Size = new System.Drawing.Size(572, 284);
            this.tabPageSQL.TabIndex = 0;
            this.tabPageSQL.Text = "SQL Settings";
            this.tabPageSQL.Enter += new System.EventHandler(this.tabPageSQL_Enter);
            // 
            // checkBoxSqlEnabled
            // 
            this.checkBoxSqlEnabled.AutoSize = true;
            this.checkBoxSqlEnabled.Location = new System.Drawing.Point(20, 20);
            this.checkBoxSqlEnabled.Name = "checkBoxSqlEnabled";
            this.checkBoxSqlEnabled.Size = new System.Drawing.Size(89, 17);
            this.checkBoxSqlEnabled.TabIndex = 12;
            this.checkBoxSqlEnabled.Text = "SQL Enabled";
            this.checkBoxSqlEnabled.UseVisualStyleBackColor = true;
            this.checkBoxSqlEnabled.CheckedChanged += new System.EventHandler(this.checkBoxSqlEnabled_CheckedChanged);
            // 
            // groupBoxTenant
            // 
            this.groupBoxTenant.Controls.Add(this.numericUpDownTenantID);
            this.groupBoxTenant.Controls.Add(this.textBoxTenantUID);
            this.groupBoxTenant.Controls.Add(this.checkBoxUseTenantUID);
            this.groupBoxTenant.Controls.Add(this.checkBoxMultiTenant);
            this.groupBoxTenant.Location = new System.Drawing.Point(20, 203);
            this.groupBoxTenant.Name = "groupBoxTenant";
            this.groupBoxTenant.Size = new System.Drawing.Size(530, 60);
            this.groupBoxTenant.TabIndex = 3;
            this.groupBoxTenant.TabStop = false;
            this.groupBoxTenant.Text = "Tenant";
            // 
            // numericUpDownTenantID
            // 
            this.numericUpDownTenantID.Location = new System.Drawing.Point(255, 26);
            this.numericUpDownTenantID.Maximum = new decimal(new int[] {
            10,
            0,
            0,
            0});
            this.numericUpDownTenantID.Name = "numericUpDownTenantID";
            this.numericUpDownTenantID.Size = new System.Drawing.Size(44, 20);
            this.numericUpDownTenantID.TabIndex = 25;
            this.numericUpDownTenantID.ValueChanged += new System.EventHandler(this.numericUpDownTenantID_ValueChanged);
            // 
            // textBoxTenantUID
            // 
            this.textBoxTenantUID.Location = new System.Drawing.Point(310, 26);
            this.textBoxTenantUID.Name = "textBoxTenantUID";
            this.textBoxTenantUID.Size = new System.Drawing.Size(170, 20);
            this.textBoxTenantUID.TabIndex = 2;
            this.textBoxTenantUID.TextChanged += new System.EventHandler(this.textBoxTenantUID_TextChanged);
            // 
            // checkBoxUseTenantUID
            // 
            this.checkBoxUseTenantUID.AutoSize = true;
            this.checkBoxUseTenantUID.Location = new System.Drawing.Point(154, 28);
            this.checkBoxUseTenantUID.Name = "checkBoxUseTenantUID";
            this.checkBoxUseTenantUID.Size = new System.Drawing.Size(99, 17);
            this.checkBoxUseTenantUID.TabIndex = 1;
            this.checkBoxUseTenantUID.Text = "Use Tenant ID:";
            this.checkBoxUseTenantUID.UseVisualStyleBackColor = true;
            this.checkBoxUseTenantUID.CheckedChanged += new System.EventHandler(this.checkBoxUseTenantUID_CheckedChanged);
            // 
            // checkBoxMultiTenant
            // 
            this.checkBoxMultiTenant.AutoSize = true;
            this.checkBoxMultiTenant.Location = new System.Drawing.Point(24, 28);
            this.checkBoxMultiTenant.Name = "checkBoxMultiTenant";
            this.checkBoxMultiTenant.Size = new System.Drawing.Size(81, 17);
            this.checkBoxMultiTenant.TabIndex = 0;
            this.checkBoxMultiTenant.Text = "Multi-tenant";
            this.checkBoxMultiTenant.UseVisualStyleBackColor = true;
            this.checkBoxMultiTenant.CheckedChanged += new System.EventHandler(this.checkBoxMultiTenant_CheckedChanged);
            // 
            // tabPageEvents
            // 
            this.tabPageEvents.BackColor = System.Drawing.SystemColors.Control;
            this.tabPageEvents.Controls.Add(this.buttonEventsEdit);
            this.tabPageEvents.Controls.Add(this.checkBoxEventsHidden);
            this.tabPageEvents.Controls.Add(this.groupBoxEvents);
            this.tabPageEvents.Location = new System.Drawing.Point(4, 22);
            this.tabPageEvents.Name = "tabPageEvents";
            this.tabPageEvents.Size = new System.Drawing.Size(572, 261);
            this.tabPageEvents.TabIndex = 4;
            this.tabPageEvents.Text = "Events";
            this.tabPageEvents.Enter += new System.EventHandler(this.tabPageEvents_Enter);
            // 
            // buttonEventsEdit
            // 
            this.buttonEventsEdit.Location = new System.Drawing.Point(440, 40);
            this.buttonEventsEdit.Name = "buttonEventsEdit";
            this.buttonEventsEdit.Size = new System.Drawing.Size(100, 50);
            this.buttonEventsEdit.TabIndex = 19;
            this.buttonEventsEdit.Text = "Edit";
            this.buttonEventsEdit.UseVisualStyleBackColor = true;
            this.buttonEventsEdit.Click += new System.EventHandler(this.buttonEventsEdit_Click);
            // 
            // checkBoxEventsHidden
            // 
            this.checkBoxEventsHidden.AutoSize = true;
            this.checkBoxEventsHidden.Location = new System.Drawing.Point(300, 52);
            this.checkBoxEventsHidden.Name = "checkBoxEventsHidden";
            this.checkBoxEventsHidden.Size = new System.Drawing.Size(60, 17);
            this.checkBoxEventsHidden.TabIndex = 18;
            this.checkBoxEventsHidden.Text = "Hidden";
            this.checkBoxEventsHidden.UseVisualStyleBackColor = true;
            this.checkBoxEventsHidden.CheckedChanged += new System.EventHandler(this.checkBoxEventsHidden_CheckedChanged);
            // 
            // groupBoxEvents
            // 
            this.groupBoxEvents.Controls.Add(this.checkBoxEventPost);
            this.groupBoxEvents.Controls.Add(this.checkBoxEventPre);
            this.groupBoxEvents.Controls.Add(this.checkBoxEventDrop);
            this.groupBoxEvents.Controls.Add(this.checkBoxEventUnpack);
            this.groupBoxEvents.Controls.Add(this.checkBoxEventBuild);
            this.groupBoxEvents.Controls.Add(this.checkBoxEventExit);
            this.groupBoxEvents.Location = new System.Drawing.Point(23, 21);
            this.groupBoxEvents.Name = "groupBoxEvents";
            this.groupBoxEvents.Size = new System.Drawing.Size(252, 145);
            this.groupBoxEvents.TabIndex = 13;
            this.groupBoxEvents.TabStop = false;
            this.groupBoxEvents.Text = "Enabled";
            // 
            // checkBoxEventPost
            // 
            this.checkBoxEventPost.AutoSize = true;
            this.checkBoxEventPost.Location = new System.Drawing.Point(142, 55);
            this.checkBoxEventPost.Name = "checkBoxEventPost";
            this.checkBoxEventPost.Size = new System.Drawing.Size(66, 17);
            this.checkBoxEventPost.TabIndex = 17;
            this.checkBoxEventPost.Text = "@POST";
            this.checkBoxEventPost.UseVisualStyleBackColor = true;
            this.checkBoxEventPost.CheckedChanged += new System.EventHandler(this.checkBoxEventPost_CheckedChanged);
            // 
            // checkBoxEventPre
            // 
            this.checkBoxEventPre.AutoSize = true;
            this.checkBoxEventPre.Location = new System.Drawing.Point(142, 32);
            this.checkBoxEventPre.Name = "checkBoxEventPre";
            this.checkBoxEventPre.Size = new System.Drawing.Size(59, 17);
            this.checkBoxEventPre.TabIndex = 16;
            this.checkBoxEventPre.Text = "@PRE";
            this.checkBoxEventPre.UseVisualStyleBackColor = true;
            this.checkBoxEventPre.CheckedChanged += new System.EventHandler(this.checkBoxEventPre_CheckedChanged);
            // 
            // checkBoxEventDrop
            // 
            this.checkBoxEventDrop.AutoSize = true;
            this.checkBoxEventDrop.Location = new System.Drawing.Point(21, 78);
            this.checkBoxEventDrop.Name = "checkBoxEventDrop";
            this.checkBoxEventDrop.Size = new System.Drawing.Size(68, 17);
            this.checkBoxEventDrop.TabIndex = 15;
            this.checkBoxEventDrop.Text = "@DROP";
            this.checkBoxEventDrop.UseVisualStyleBackColor = true;
            this.checkBoxEventDrop.CheckedChanged += new System.EventHandler(this.checkBoxEventDrop_CheckedChanged);
            // 
            // checkBoxEventUnpack
            // 
            this.checkBoxEventUnpack.AutoSize = true;
            this.checkBoxEventUnpack.Location = new System.Drawing.Point(21, 55);
            this.checkBoxEventUnpack.Name = "checkBoxEventUnpack";
            this.checkBoxEventUnpack.Size = new System.Drawing.Size(81, 17);
            this.checkBoxEventUnpack.TabIndex = 14;
            this.checkBoxEventUnpack.Text = "@UNPACK";
            this.checkBoxEventUnpack.UseVisualStyleBackColor = true;
            this.checkBoxEventUnpack.CheckedChanged += new System.EventHandler(this.checkBoxEventUnpack_CheckedChanged);
            // 
            // checkBoxEventBuild
            // 
            this.checkBoxEventBuild.AutoSize = true;
            this.checkBoxEventBuild.Location = new System.Drawing.Point(21, 32);
            this.checkBoxEventBuild.Name = "checkBoxEventBuild";
            this.checkBoxEventBuild.Size = new System.Drawing.Size(69, 17);
            this.checkBoxEventBuild.TabIndex = 13;
            this.checkBoxEventBuild.Text = "@BUILD";
            this.checkBoxEventBuild.UseVisualStyleBackColor = true;
            this.checkBoxEventBuild.CheckedChanged += new System.EventHandler(this.checkBoxEventBuild_CheckedChanged);
            // 
            // checkBoxEventExit
            // 
            this.checkBoxEventExit.AutoSize = true;
            this.checkBoxEventExit.Location = new System.Drawing.Point(21, 101);
            this.checkBoxEventExit.Name = "checkBoxEventExit";
            this.checkBoxEventExit.Size = new System.Drawing.Size(61, 17);
            this.checkBoxEventExit.TabIndex = 12;
            this.checkBoxEventExit.Text = "@EXIT";
            this.checkBoxEventExit.UseVisualStyleBackColor = true;
            this.checkBoxEventExit.CheckedChanged += new System.EventHandler(this.checkBoxEventExit_CheckedChanged);
            // 
            // tabPageActions
            // 
            this.tabPageActions.BackColor = System.Drawing.SystemColors.Control;
            this.tabPageActions.Controls.Add(this.radioButtonCustomActions);
            this.tabPageActions.Controls.Add(this.radioButtonAllActions);
            this.tabPageActions.Controls.Add(this.radioButtonShellActions);
            this.tabPageActions.Controls.Add(this.textBoxActionLabel);
            this.tabPageActions.Controls.Add(this.button1);
            this.tabPageActions.Controls.Add(this.labelActionsList);
            this.tabPageActions.Controls.Add(this.checkBoxActionEnabled);
            this.tabPageActions.Controls.Add(this.textBoxActionType);
            this.tabPageActions.Controls.Add(this.textBoxActionMenu);
            this.tabPageActions.Controls.Add(this.textBoxActionName);
            this.tabPageActions.Controls.Add(this.buttonActionsRun);
            this.tabPageActions.Controls.Add(this.listBoxActions);
            this.tabPageActions.Location = new System.Drawing.Point(4, 22);
            this.tabPageActions.Name = "tabPageActions";
            this.tabPageActions.Size = new System.Drawing.Size(572, 261);
            this.tabPageActions.TabIndex = 5;
            this.tabPageActions.Text = "Actions";
            this.tabPageActions.Enter += new System.EventHandler(this.tabPageActions_Enter);
            // 
            // radioButtonCustomActions
            // 
            this.radioButtonCustomActions.AutoSize = true;
            this.radioButtonCustomActions.Location = new System.Drawing.Point(170, 17);
            this.radioButtonCustomActions.Name = "radioButtonCustomActions";
            this.radioButtonCustomActions.Size = new System.Drawing.Size(60, 17);
            this.radioButtonCustomActions.TabIndex = 30;
            this.radioButtonCustomActions.TabStop = true;
            this.radioButtonCustomActions.Text = "Custom";
            this.radioButtonCustomActions.UseVisualStyleBackColor = true;
            this.radioButtonCustomActions.Click += new System.EventHandler(this.radioButtonCustomActions_Click);
            // 
            // radioButtonAllActions
            // 
            this.radioButtonAllActions.AutoSize = true;
            this.radioButtonAllActions.Location = new System.Drawing.Point(80, 17);
            this.radioButtonAllActions.Name = "radioButtonAllActions";
            this.radioButtonAllActions.Size = new System.Drawing.Size(68, 17);
            this.radioButtonAllActions.TabIndex = 29;
            this.radioButtonAllActions.TabStop = true;
            this.radioButtonAllActions.Text = "Standard";
            this.radioButtonAllActions.UseVisualStyleBackColor = true;
            this.radioButtonAllActions.Click += new System.EventHandler(this.radioButtonAllActions_Click);
            // 
            // radioButtonShellActions
            // 
            this.radioButtonShellActions.AutoSize = true;
            this.radioButtonShellActions.Location = new System.Drawing.Point(15, 17);
            this.radioButtonShellActions.Name = "radioButtonShellActions";
            this.radioButtonShellActions.Size = new System.Drawing.Size(48, 17);
            this.radioButtonShellActions.TabIndex = 28;
            this.radioButtonShellActions.TabStop = true;
            this.radioButtonShellActions.Text = "Shell";
            this.radioButtonShellActions.UseVisualStyleBackColor = true;
            this.radioButtonShellActions.Click += new System.EventHandler(this.radioButtonShellActions_Click);
            // 
            // textBoxActionLabel
            // 
            this.textBoxActionLabel.Enabled = false;
            this.textBoxActionLabel.Location = new System.Drawing.Point(240, 130);
            this.textBoxActionLabel.Name = "textBoxActionLabel";
            this.textBoxActionLabel.Size = new System.Drawing.Size(300, 20);
            this.textBoxActionLabel.TabIndex = 27;
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(482, 11);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(70, 28);
            this.button1.TabIndex = 26;
            this.button1.Text = "Run";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.buttonActionsRun_Click);
            // 
            // labelActionsList
            // 
            this.labelActionsList.AutoSize = true;
            this.labelActionsList.Location = new System.Drawing.Point(13, 50);
            this.labelActionsList.Name = "labelActionsList";
            this.labelActionsList.Size = new System.Drawing.Size(60, 13);
            this.labelActionsList.TabIndex = 25;
            this.labelActionsList.Text = "Actions list:";
            // 
            // checkBoxActionEnabled
            // 
            this.checkBoxActionEnabled.AutoSize = true;
            this.checkBoxActionEnabled.Location = new System.Drawing.Point(240, 200);
            this.checkBoxActionEnabled.Name = "checkBoxActionEnabled";
            this.checkBoxActionEnabled.Size = new System.Drawing.Size(65, 17);
            this.checkBoxActionEnabled.TabIndex = 24;
            this.checkBoxActionEnabled.Text = "Enabled";
            this.checkBoxActionEnabled.UseVisualStyleBackColor = true;
            this.checkBoxActionEnabled.CheckedChanged += new System.EventHandler(this.checkBoxActionEnabled_CheckedChanged);
            // 
            // textBoxActionType
            // 
            this.textBoxActionType.Enabled = false;
            this.textBoxActionType.Location = new System.Drawing.Point(240, 160);
            this.textBoxActionType.Name = "textBoxActionType";
            this.textBoxActionType.Size = new System.Drawing.Size(60, 20);
            this.textBoxActionType.TabIndex = 23;
            // 
            // textBoxActionMenu
            // 
            this.textBoxActionMenu.Enabled = false;
            this.textBoxActionMenu.Location = new System.Drawing.Point(240, 100);
            this.textBoxActionMenu.Name = "textBoxActionMenu";
            this.textBoxActionMenu.Size = new System.Drawing.Size(260, 20);
            this.textBoxActionMenu.TabIndex = 22;
            // 
            // textBoxActionName
            // 
            this.textBoxActionName.Enabled = false;
            this.textBoxActionName.Location = new System.Drawing.Point(240, 70);
            this.textBoxActionName.Name = "textBoxActionName";
            this.textBoxActionName.Size = new System.Drawing.Size(220, 20);
            this.textBoxActionName.TabIndex = 21;
            // 
            // buttonActionsRun
            // 
            this.buttonActionsRun.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.buttonActionsRun.Location = new System.Drawing.Point(391, 11);
            this.buttonActionsRun.Name = "buttonActionsRun";
            this.buttonActionsRun.Size = new System.Drawing.Size(70, 28);
            this.buttonActionsRun.TabIndex = 20;
            this.buttonActionsRun.Text = "Edit";
            this.buttonActionsRun.UseVisualStyleBackColor = true;
            this.buttonActionsRun.Click += new System.EventHandler(this.buttonActionsEdit_Click);
            // 
            // listBoxActions
            // 
            this.listBoxActions.FormattingEnabled = true;
            this.listBoxActions.Location = new System.Drawing.Point(15, 70);
            this.listBoxActions.Name = "listBoxActions";
            this.listBoxActions.Size = new System.Drawing.Size(200, 147);
            this.listBoxActions.TabIndex = 0;
            this.listBoxActions.SelectedIndexChanged += new System.EventHandler(this.listBoxActions_SelectedIndexChanged);
            // 
            // tabPageOther
            // 
            this.tabPageOther.BackColor = System.Drawing.SystemColors.Control;
            this.tabPageOther.Controls.Add(this.groupBoxEditor);
            this.tabPageOther.Controls.Add(this.labelOtherMessage);
            this.tabPageOther.Location = new System.Drawing.Point(4, 22);
            this.tabPageOther.Name = "tabPageOther";
            this.tabPageOther.Padding = new System.Windows.Forms.Padding(3);
            this.tabPageOther.Size = new System.Drawing.Size(572, 261);
            this.tabPageOther.TabIndex = 2;
            this.tabPageOther.Text = "Other";
            this.tabPageOther.Enter += new System.EventHandler(this.tabPageOther_Enter);
            // 
            // groupBoxEditor
            // 
            this.groupBoxEditor.Controls.Add(this.comboBoxEditor);
            this.groupBoxEditor.Location = new System.Drawing.Point(20, 30);
            this.groupBoxEditor.Name = "groupBoxEditor";
            this.groupBoxEditor.Size = new System.Drawing.Size(224, 88);
            this.groupBoxEditor.TabIndex = 11;
            this.groupBoxEditor.TabStop = false;
            this.groupBoxEditor.Text = "Text File Editor";
            // 
            // comboBoxEditor
            // 
            this.comboBoxEditor.FormattingEnabled = true;
            this.comboBoxEditor.Items.AddRange(new object[] {
            "notepad.exe",
            "notepad++.exe",
            "code.exe"});
            this.comboBoxEditor.Location = new System.Drawing.Point(25, 28);
            this.comboBoxEditor.Name = "comboBoxEditor";
            this.comboBoxEditor.Size = new System.Drawing.Size(179, 21);
            this.comboBoxEditor.TabIndex = 12;
            this.comboBoxEditor.Text = "notepad.exe";
            this.comboBoxEditor.TextChanged += new System.EventHandler(this.comboBoxEditor_TextChanged);
            // 
            // labelOtherMessage
            // 
            this.labelOtherMessage.AutoSize = true;
            this.labelOtherMessage.Location = new System.Drawing.Point(28, 203);
            this.labelOtherMessage.Name = "labelOtherMessage";
            this.labelOtherMessage.Size = new System.Drawing.Size(16, 13);
            this.labelOtherMessage.TabIndex = 10;
            this.labelOtherMessage.Text = "...";
            // 
            // buttonReset
            // 
            this.buttonReset.Location = new System.Drawing.Point(501, 355);
            this.buttonReset.Name = "buttonReset";
            this.buttonReset.Size = new System.Drawing.Size(75, 23);
            this.buttonReset.TabIndex = 1;
            this.buttonReset.Text = "Reset";
            this.buttonReset.UseVisualStyleBackColor = true;
            this.buttonReset.Click += new System.EventHandler(this.buttonReset_Click);
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemSettimgs,
            this.toolStripMenuItemUnpack,
            this.toolStripMenuItemEvents,
            this.toolStripMenuItemActions});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(584, 24);
            this.menuStrip1.TabIndex = 11;
            this.menuStrip1.Text = "menuStripSettings";
            // 
            // toolStripMenuItemSettimgs
            // 
            this.toolStripMenuItemSettimgs.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemLocked,
            this.toolStripSeparator4,
            this.toolStripMenuItemFromTemp,
            this.toolStripMenuItemFromLocal,
            this.toolStripMenuItemFromHome});
            this.toolStripMenuItemSettimgs.Name = "toolStripMenuItemSettimgs";
            this.toolStripMenuItemSettimgs.Size = new System.Drawing.Size(61, 20);
            this.toolStripMenuItemSettimgs.Text = "Settings";
            // 
            // toolStripMenuItemLocked
            // 
            this.toolStripMenuItemLocked.Name = "toolStripMenuItemLocked";
            this.toolStripMenuItemLocked.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemLocked.Text = "Locked";
            this.toolStripMenuItemLocked.Click += new System.EventHandler(this.toolStripMenuItemLocked_Click);
            // 
            // toolStripSeparator4
            // 
            this.toolStripSeparator4.Name = "toolStripSeparator4";
            this.toolStripSeparator4.Size = new System.Drawing.Size(177, 6);
            // 
            // toolStripMenuItemFromTemp
            // 
            this.toolStripMenuItemFromTemp.Name = "toolStripMenuItemFromTemp";
            this.toolStripMenuItemFromTemp.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemFromTemp.Text = "Temp";
            this.toolStripMenuItemFromTemp.Click += new System.EventHandler(this.toolStripMenuItemFromTemp_Click);
            // 
            // toolStripMenuItemFromLocal
            // 
            this.toolStripMenuItemFromLocal.Name = "toolStripMenuItemFromLocal";
            this.toolStripMenuItemFromLocal.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemFromLocal.Text = "Local";
            this.toolStripMenuItemFromLocal.Click += new System.EventHandler(this.toolStripMenuItemFromLocal_Click);
            // 
            // toolStripMenuItemFromHome
            // 
            this.toolStripMenuItemFromHome.Name = "toolStripMenuItemFromHome";
            this.toolStripMenuItemFromHome.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemFromHome.Text = "Home";
            this.toolStripMenuItemFromHome.Click += new System.EventHandler(this.toolStripMenuItemFromHome_Click);
            // 
            // toolStripMenuItemUnpack
            // 
            this.toolStripMenuItemUnpack.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemUnpackUnzip,
            this.toolStripSeparator1,
            this.toolStripMenuItemUnpackScript,
            this.toolStripMenuItemUnpackImplFiles,
            this.toolStripMenuItemUnpackPayload,
            this.toolStripMenuItemUnpackActions,
            this.toolStripMenuItemUnpackEvents,
            this.toolStripMenuItemUnpackSource,
            this.toolStripMenuItemUnpackVisualStudio,
            this.toolStripSeparator2,
            this.toolStripMenuItemUnpackClear});
            this.toolStripMenuItemUnpack.Name = "toolStripMenuItemUnpack";
            this.toolStripMenuItemUnpack.Size = new System.Drawing.Size(59, 20);
            this.toolStripMenuItemUnpack.Text = "Unpack";
            // 
            // toolStripMenuItemUnpackUnzip
            // 
            this.toolStripMenuItemUnpackUnzip.Name = "toolStripMenuItemUnpackUnzip";
            this.toolStripMenuItemUnpackUnzip.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemUnpackUnzip.Text = "Unzip (on Unpack)";
            this.toolStripMenuItemUnpackUnzip.Click += new System.EventHandler(this.toolStripMenuItemUnpackUnzip_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(177, 6);
            // 
            // toolStripMenuItemUnpackScript
            // 
            this.toolStripMenuItemUnpackScript.Name = "toolStripMenuItemUnpackScript";
            this.toolStripMenuItemUnpackScript.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemUnpackScript.Text = "Scripts";
            this.toolStripMenuItemUnpackScript.Click += new System.EventHandler(this.toolStripMenuItemUnpackScript_Click);
            // 
            // toolStripMenuItemUnpackImplFiles
            // 
            this.toolStripMenuItemUnpackImplFiles.Name = "toolStripMenuItemUnpackImplFiles";
            this.toolStripMenuItemUnpackImplFiles.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemUnpackImplFiles.Text = "ImplFiles";
            this.toolStripMenuItemUnpackImplFiles.Click += new System.EventHandler(this.toolStripMenuItemUnpackImplFiles_Click);
            // 
            // toolStripMenuItemUnpackPayload
            // 
            this.toolStripMenuItemUnpackPayload.Name = "toolStripMenuItemUnpackPayload";
            this.toolStripMenuItemUnpackPayload.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemUnpackPayload.Text = "Payload";
            this.toolStripMenuItemUnpackPayload.Click += new System.EventHandler(this.toolStripMenuItemUnpackPayload_Click);
            // 
            // toolStripMenuItemUnpackActions
            // 
            this.toolStripMenuItemUnpackActions.Name = "toolStripMenuItemUnpackActions";
            this.toolStripMenuItemUnpackActions.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemUnpackActions.Text = "Actions";
            this.toolStripMenuItemUnpackActions.Click += new System.EventHandler(this.toolStripMenuItemUnpackActions_Click);
            // 
            // toolStripMenuItemUnpackEvents
            // 
            this.toolStripMenuItemUnpackEvents.Name = "toolStripMenuItemUnpackEvents";
            this.toolStripMenuItemUnpackEvents.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemUnpackEvents.Text = "Events";
            this.toolStripMenuItemUnpackEvents.Click += new System.EventHandler(this.toolStripMenuItemUnpackEvents_Click);
            // 
            // toolStripMenuItemUnpackSource
            // 
            this.toolStripMenuItemUnpackSource.Name = "toolStripMenuItemUnpackSource";
            this.toolStripMenuItemUnpackSource.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemUnpackSource.Text = "Source";
            this.toolStripMenuItemUnpackSource.Click += new System.EventHandler(this.toolStripMenuItemUnpackSource_Click);
            // 
            // toolStripMenuItemUnpackVisualStudio
            // 
            this.toolStripMenuItemUnpackVisualStudio.Name = "toolStripMenuItemUnpackVisualStudio";
            this.toolStripMenuItemUnpackVisualStudio.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemUnpackVisualStudio.Text = "VisualStudio";
            this.toolStripMenuItemUnpackVisualStudio.Click += new System.EventHandler(this.toolStripMenuItemUnpackVisualStudio_Click);
            // 
            // toolStripSeparator2
            // 
            this.toolStripSeparator2.Name = "toolStripSeparator2";
            this.toolStripSeparator2.Size = new System.Drawing.Size(177, 6);
            // 
            // toolStripMenuItemUnpackClear
            // 
            this.toolStripMenuItemUnpackClear.Name = "toolStripMenuItemUnpackClear";
            this.toolStripMenuItemUnpackClear.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemUnpackClear.Text = "Clear";
            // 
            // toolStripMenuItemEvents
            // 
            this.toolStripMenuItemEvents.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemEventsEdit,
            this.toolStripMenuItemEventsReload,
            this.toolStripSeparator5,
            this.toolStripMenuItemEventsHidden,
            this.toolStripSeparator3,
            this.toolStripMenuItemEventBuild,
            this.toolStripMenuItemEventUnpack,
            this.toolStripMenuItemEventDrop,
            this.toolStripMenuItemEventPreRUN,
            this.toolStripMenuItemEventPostRUN,
            this.toolStripMenuItemEventExit});
            this.toolStripMenuItemEvents.Name = "toolStripMenuItemEvents";
            this.toolStripMenuItemEvents.Size = new System.Drawing.Size(53, 20);
            this.toolStripMenuItemEvents.Text = "Events";
            // 
            // toolStripMenuItemEventsEdit
            // 
            this.toolStripMenuItemEventsEdit.Name = "toolStripMenuItemEventsEdit";
            this.toolStripMenuItemEventsEdit.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemEventsEdit.Text = "Edit Events ...";
            this.toolStripMenuItemEventsEdit.Click += new System.EventHandler(this.toolStripMenuItemEventsEdit_Click);
            // 
            // toolStripMenuItemEventsReload
            // 
            this.toolStripMenuItemEventsReload.Name = "toolStripMenuItemEventsReload";
            this.toolStripMenuItemEventsReload.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemEventsReload.Text = "Reload";
            this.toolStripMenuItemEventsReload.Click += new System.EventHandler(this.toolStripMenuItemEventsReload_Click);
            // 
            // toolStripSeparator5
            // 
            this.toolStripSeparator5.Name = "toolStripSeparator5";
            this.toolStripSeparator5.Size = new System.Drawing.Size(177, 6);
            // 
            // toolStripMenuItemEventsHidden
            // 
            this.toolStripMenuItemEventsHidden.Name = "toolStripMenuItemEventsHidden";
            this.toolStripMenuItemEventsHidden.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemEventsHidden.Text = "Hidden";
            this.toolStripMenuItemEventsHidden.Click += new System.EventHandler(this.toolStripMenuItemEventsHidden_Click);
            // 
            // toolStripSeparator3
            // 
            this.toolStripSeparator3.Name = "toolStripSeparator3";
            this.toolStripSeparator3.Size = new System.Drawing.Size(177, 6);
            // 
            // toolStripMenuItemEventBuild
            // 
            this.toolStripMenuItemEventBuild.Name = "toolStripMenuItemEventBuild";
            this.toolStripMenuItemEventBuild.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemEventBuild.Text = "@ Build";
            this.toolStripMenuItemEventBuild.Click += new System.EventHandler(this.toolStripMenuItemEventBuild_Click);
            // 
            // toolStripMenuItemEventUnpack
            // 
            this.toolStripMenuItemEventUnpack.Name = "toolStripMenuItemEventUnpack";
            this.toolStripMenuItemEventUnpack.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemEventUnpack.Text = "@Unpack";
            this.toolStripMenuItemEventUnpack.Click += new System.EventHandler(this.toolStripMenuItemEventUnpack_Click);
            // 
            // toolStripMenuItemEventDrop
            // 
            this.toolStripMenuItemEventDrop.Name = "toolStripMenuItemEventDrop";
            this.toolStripMenuItemEventDrop.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemEventDrop.Text = "@ File-Drop";
            this.toolStripMenuItemEventDrop.Click += new System.EventHandler(this.toolStripMenuItemEventDrop_Click);
            // 
            // toolStripMenuItemEventPreRUN
            // 
            this.toolStripMenuItemEventPreRUN.Name = "toolStripMenuItemEventPreRUN";
            this.toolStripMenuItemEventPreRUN.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemEventPreRUN.Text = "@ Pre-RUN";
            this.toolStripMenuItemEventPreRUN.Click += new System.EventHandler(this.toolStripMenuItemEventPreRUN_Click);
            // 
            // toolStripMenuItemEventPostRUN
            // 
            this.toolStripMenuItemEventPostRUN.Name = "toolStripMenuItemEventPostRUN";
            this.toolStripMenuItemEventPostRUN.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemEventPostRUN.Text = "@ Post-RUN";
            this.toolStripMenuItemEventPostRUN.Click += new System.EventHandler(this.toolStripMenuItemEventPostRUN_Click);
            // 
            // toolStripMenuItemEventExit
            // 
            this.toolStripMenuItemEventExit.Name = "toolStripMenuItemEventExit";
            this.toolStripMenuItemEventExit.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemEventExit.Text = "@ Exit";
            this.toolStripMenuItemEventExit.Click += new System.EventHandler(this.toolStripMenuItemEventExit_Click);
            // 
            // toolStripMenuItemActions
            // 
            this.toolStripMenuItemActions.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemActionsEdit,
            this.toolStripMenuItemActionsReload,
            this.toolStripMenuItemActionsRewrite});
            this.toolStripMenuItemActions.Name = "toolStripMenuItemActions";
            this.toolStripMenuItemActions.Size = new System.Drawing.Size(59, 20);
            this.toolStripMenuItemActions.Text = "Actions";
            // 
            // toolStripMenuItemActionsEdit
            // 
            this.toolStripMenuItemActionsEdit.Name = "toolStripMenuItemActionsEdit";
            this.toolStripMenuItemActionsEdit.Size = new System.Drawing.Size(149, 22);
            this.toolStripMenuItemActionsEdit.Text = "Edit Actions ...";
            this.toolStripMenuItemActionsEdit.Click += new System.EventHandler(this.toolStripMenuItemActionsEdit_Click);
            // 
            // toolStripMenuItemActionsReload
            // 
            this.toolStripMenuItemActionsReload.Name = "toolStripMenuItemActionsReload";
            this.toolStripMenuItemActionsReload.Size = new System.Drawing.Size(149, 22);
            this.toolStripMenuItemActionsReload.Text = "Reload";
            this.toolStripMenuItemActionsReload.Click += new System.EventHandler(this.toolStripMenuItemActionsReload_Click);
            // 
            // toolStripMenuItemActionsRewrite
            // 
            this.toolStripMenuItemActionsRewrite.Name = "toolStripMenuItemActionsRewrite";
            this.toolStripMenuItemActionsRewrite.Size = new System.Drawing.Size(149, 22);
            this.toolStripMenuItemActionsRewrite.Text = "Rewrite";
            this.toolStripMenuItemActionsRewrite.Click += new System.EventHandler(this.toolStripMenuItemActionsRewrite_Click);
            // 
            // AppSettingsForm
            // 
            this.AcceptButton = this.buttonOK;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.buttonCancel;
            this.ClientSize = new System.Drawing.Size(584, 391);
            this.Controls.Add(this.tabControlSettings);
            this.Controls.Add(this.buttonCancel);
            this.Controls.Add(this.buttonReset);
            this.Controls.Add(this.buttonOK);
            this.Controls.Add(this.menuStrip1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MainMenuStrip = this.menuStrip1;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "AppSettingsForm";
            this.Text = "FlexAdmin - Settings";
            this.Load += new System.EventHandler(this.AppSettingsForm_Load);
            this.groupBoxAppVersion.ResumeLayout(false);
            this.groupBoxAppVersion.PerformLayout();
            this.tabControlSettings.ResumeLayout(false);
            this.tabPagePrimary.ResumeLayout(false);
            this.tabPagePrimary.PerformLayout();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBoxAccessControl.ResumeLayout(false);
            this.groupBoxAccessControl.PerformLayout();
            this.tabPageImplFiles.ResumeLayout(false);
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.tabPageSQL.ResumeLayout(false);
            this.tabPageSQL.PerformLayout();
            this.groupBoxTenant.ResumeLayout(false);
            this.groupBoxTenant.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownTenantID)).EndInit();
            this.tabPageEvents.ResumeLayout(false);
            this.tabPageEvents.PerformLayout();
            this.groupBoxEvents.ResumeLayout(false);
            this.groupBoxEvents.PerformLayout();
            this.tabPageActions.ResumeLayout(false);
            this.tabPageActions.PerformLayout();
            this.tabPageOther.ResumeLayout(false);
            this.tabPageOther.PerformLayout();
            this.groupBoxEditor.ResumeLayout(false);
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button buttonOK;
        private System.Windows.Forms.TextBox textBoxDatabase;
        private System.Windows.Forms.Label labelDatabase;
        private System.Windows.Forms.Button buttonCancel;
        private System.Windows.Forms.Label labelConnectionString;
        private System.Windows.Forms.TextBox textBoxServer;
        private System.Windows.Forms.Label labelServer;
        private System.Windows.Forms.Button buttonTest;
        private System.Windows.Forms.GroupBox groupBoxAppVersion;
        private System.Windows.Forms.TabControl tabControlSettings;
        private System.Windows.Forms.TabPage tabPageSQL;
        private System.Windows.Forms.TabPage tabPagePrimary;
        private System.Windows.Forms.GroupBox groupBoxAccessControl;
        private System.Windows.Forms.Label labelOtherMessage;
        private System.Windows.Forms.Button buttonReset;
        private System.Windows.Forms.Label labelPassword;
        private System.Windows.Forms.TextBox textBoxPassword;
        private System.Windows.Forms.CheckBox checkBoxRequirePassword;
        private System.Windows.Forms.TabPage tabPageOther;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label labelScriptFile;
        private System.Windows.Forms.TextBox textBoxScriptFile;
        private System.Windows.Forms.TabPage tabPageImplFiles;
        private System.Windows.Forms.TextBox textBoxSettingsFileName;
        private System.Windows.Forms.Label labelSettingsFile;
        private System.Windows.Forms.Label labelImplFilesFolder;
        private System.Windows.Forms.TextBox textBoxImplFilesFolder;
        private System.Windows.Forms.Button buttonSelectSettings;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.Button buttonSelectLogs;
        private System.Windows.Forms.TextBox textBoxLogFilesFolder;
        private System.Windows.Forms.Label labelLogFilesFolder;
        private System.Windows.Forms.TextBox textBoxImplFilesScriptName;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.GroupBox groupBoxTenant;
        private System.Windows.Forms.CheckBox checkBoxMultiTenant;
        private System.Windows.Forms.TextBox textBoxTenantUID;
        private System.Windows.Forms.CheckBox checkBoxUseTenantUID;
        private System.Windows.Forms.CheckBox checkBoxRedirect;
        private System.Windows.Forms.GroupBox groupBoxEditor;
        private System.Windows.Forms.ComboBox comboBoxEditor;
        private System.Windows.Forms.NumericUpDown numericUpDownTenantID;
        private System.Windows.Forms.CheckBox checkBoxSqlEnabled;
        private System.Windows.Forms.TabPage tabPageEvents;
        private System.Windows.Forms.GroupBox groupBoxEvents;
        private System.Windows.Forms.CheckBox checkBoxEventExit;
        private System.Windows.Forms.CheckBox checkBoxEventPost;
        private System.Windows.Forms.CheckBox checkBoxEventPre;
        private System.Windows.Forms.CheckBox checkBoxEventDrop;
        private System.Windows.Forms.CheckBox checkBoxEventUnpack;
        private System.Windows.Forms.CheckBox checkBoxEventBuild;
        private System.Windows.Forms.Button buttonEventsEdit;
        private System.Windows.Forms.CheckBox checkBoxEventsHidden;
        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpack;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackUnzip;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackScript;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackPayload;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackActions;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackEvents;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackSource;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackVisualStudio;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator2;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackClear;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEvents;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEventsEdit;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEventsHidden;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator3;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEventBuild;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEventUnpack;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEventDrop;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEventPreRUN;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEventPostRUN;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEventExit;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemActions;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemActionsEdit;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemActionsReload;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemSettimgs;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemLocked;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator4;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemFromTemp;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemFromLocal;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemFromHome;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEventsReload;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator5;
        private System.Windows.Forms.TabPage tabPageActions;
        private System.Windows.Forms.ListBox listBoxActions;
        private System.Windows.Forms.Button buttonActionsRun;
        private System.Windows.Forms.TextBox textBoxActionMenu;
        private System.Windows.Forms.TextBox textBoxActionName;
        private System.Windows.Forms.TextBox textBoxActionType;
        private System.Windows.Forms.CheckBox checkBoxActionEnabled;
        private System.Windows.Forms.Label labelActionsList;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.TextBox textBoxActionLabel;
        private System.Windows.Forms.RadioButton radioButtonCustomActions;
        private System.Windows.Forms.RadioButton radioButtonAllActions;
        private System.Windows.Forms.RadioButton radioButtonShellActions;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemActionsRewrite;
        private System.Windows.Forms.CheckBox checkBoxCheckPayload;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackImplFiles;
        private System.Windows.Forms.Label labelCommandFile;
        private System.Windows.Forms.TextBox textBoxCmdFile;
    }
}