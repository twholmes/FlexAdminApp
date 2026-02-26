namespace BlackBox
{
    partial class AppBuilderForm
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            this.buttonClose = new System.Windows.Forms.Button();
            this.buttonBuild = new System.Windows.Forms.Button();
            this.groupBoxAppVersion = new System.Windows.Forms.GroupBox();
            this.numericUpDown4 = new System.Windows.Forms.NumericUpDown();
            this.labelAppVersion = new System.Windows.Forms.Label();
            this.numericUpDown3 = new System.Windows.Forms.NumericUpDown();
            this.labelAppName = new System.Windows.Forms.Label();
            this.numericUpDown2 = new System.Windows.Forms.NumericUpDown();
            this.textBoxAppName = new System.Windows.Forms.TextBox();
            this.numericUpDown1 = new System.Windows.Forms.NumericUpDown();
            this.textBoxScriptVersion = new System.Windows.Forms.TextBox();
            this.labelScriptVersion = new System.Windows.Forms.Label();
            this.groupBoxScriptVersion = new System.Windows.Forms.GroupBox();
            this.labelMessage = new System.Windows.Forms.Label();
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabPageBuild = new System.Windows.Forms.TabPage();
            this.checkBoxWorkLocal = new System.Windows.Forms.CheckBox();
            this.groupBoxSettings = new System.Windows.Forms.GroupBox();
            this.radioButtonWorkImplFiles = new System.Windows.Forms.RadioButton();
            this.radioButtonWorkLocal = new System.Windows.Forms.RadioButton();
            this.radioButtonWorkTemp = new System.Windows.Forms.RadioButton();
            this.checkBoxBuildLocked = new System.Windows.Forms.CheckBox();
            this.checkBoxSafeZip = new System.Windows.Forms.CheckBox();
            this.tabPageExtract = new System.Windows.Forms.TabPage();
            this.textBoxPassword = new System.Windows.Forms.TextBox();
            this.checkBoxRequirePassword = new System.Windows.Forms.CheckBox();
            this.groupBoxFileManagement = new System.Windows.Forms.GroupBox();
            this.checkBoxPrompOverwrite = new System.Windows.Forms.CheckBox();
            this.checkBoxUnpackZipped = new System.Windows.Forms.CheckBox();
            this.groupBoxExtract = new System.Windows.Forms.GroupBox();
            this.checkBoxExtractActions = new System.Windows.Forms.CheckBox();
            this.checkBoxExtractEvents = new System.Windows.Forms.CheckBox();
            this.checkBoxExtractSource = new System.Windows.Forms.CheckBox();
            this.checkBoxExtractPayload = new System.Windows.Forms.CheckBox();
            this.checkBoxExtractVisualStudio = new System.Windows.Forms.CheckBox();
            this.checkBoxExtractScripts = new System.Windows.Forms.CheckBox();
            this.tabPageSource = new System.Windows.Forms.TabPage();
            this.buttonSourceDelete = new System.Windows.Forms.Button();
            this.textBoxSourceName = new System.Windows.Forms.TextBox();
            this.textBoxSourceSize = new System.Windows.Forms.TextBox();
            this.textBoxSourceDate = new System.Windows.Forms.TextBox();
            this.dataGridViewFiles = new System.Windows.Forms.DataGridView();
            this.dataGridViewImageColumn1 = new System.Windows.Forms.DataGridViewImageColumn();
            this.dataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.dataGridViewTextBoxColumn2 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.dataGridViewTextBoxColumn3 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.dataGridViewTextBoxColumn4 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.textBoxSourcePath = new System.Windows.Forms.TextBox();
            this.pictureBoxSource = new System.Windows.Forms.PictureBox();
            this.tabPagePayload = new System.Windows.Forms.TabPage();
            this.buttonSelectSettings = new System.Windows.Forms.Button();
            this.textBoxImplFilesFolder = new System.Windows.Forms.TextBox();
            this.labelImplFilesFolder = new System.Windows.Forms.Label();
            this.textBoxSettingsFileName = new System.Windows.Forms.TextBox();
            this.labelSettingsFile = new System.Windows.Forms.Label();
            this.buttonUtility = new System.Windows.Forms.Button();
            this.checkBoxExtractImplFiles = new System.Windows.Forms.CheckBox();
            this.groupBoxAppVersion.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown4)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown3)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown2)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown1)).BeginInit();
            this.groupBoxScriptVersion.SuspendLayout();
            this.tabControl1.SuspendLayout();
            this.tabPageBuild.SuspendLayout();
            this.groupBoxSettings.SuspendLayout();
            this.tabPageExtract.SuspendLayout();
            this.groupBoxFileManagement.SuspendLayout();
            this.groupBoxExtract.SuspendLayout();
            this.tabPageSource.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridViewFiles)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxSource)).BeginInit();
            this.tabPagePayload.SuspendLayout();
            this.SuspendLayout();
            // 
            // buttonClose
            // 
            this.buttonClose.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.buttonClose.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.buttonClose.Location = new System.Drawing.Point(515, 320);
            this.buttonClose.Name = "buttonClose";
            this.buttonClose.Size = new System.Drawing.Size(100, 40);
            this.buttonClose.TabIndex = 0;
            this.buttonClose.Text = "Close";
            this.buttonClose.UseVisualStyleBackColor = true;
            this.buttonClose.Click += new System.EventHandler(this.buttonClose_Click);
            // 
            // buttonBuild
            // 
            this.buttonBuild.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.buttonBuild.Location = new System.Drawing.Point(24, 320);
            this.buttonBuild.Name = "buttonBuild";
            this.buttonBuild.Size = new System.Drawing.Size(100, 40);
            this.buttonBuild.TabIndex = 1;
            this.buttonBuild.Text = "Build";
            this.buttonBuild.UseVisualStyleBackColor = true;
            this.buttonBuild.Click += new System.EventHandler(this.buttonBuild_Click);
            // 
            // groupBoxAppVersion
            // 
            this.groupBoxAppVersion.Controls.Add(this.numericUpDown4);
            this.groupBoxAppVersion.Controls.Add(this.labelAppVersion);
            this.groupBoxAppVersion.Controls.Add(this.numericUpDown3);
            this.groupBoxAppVersion.Controls.Add(this.labelAppName);
            this.groupBoxAppVersion.Controls.Add(this.numericUpDown2);
            this.groupBoxAppVersion.Controls.Add(this.textBoxAppName);
            this.groupBoxAppVersion.Controls.Add(this.numericUpDown1);
            this.groupBoxAppVersion.Location = new System.Drawing.Point(15, 20);
            this.groupBoxAppVersion.Name = "groupBoxAppVersion";
            this.groupBoxAppVersion.Size = new System.Drawing.Size(285, 100);
            this.groupBoxAppVersion.TabIndex = 2;
            this.groupBoxAppVersion.TabStop = false;
            this.groupBoxAppVersion.Text = "App Version";
            // 
            // numericUpDown4
            // 
            this.numericUpDown4.Location = new System.Drawing.Point(196, 52);
            this.numericUpDown4.Maximum = new decimal(new int[] {
            99,
            0,
            0,
            0});
            this.numericUpDown4.Name = "numericUpDown4";
            this.numericUpDown4.Size = new System.Drawing.Size(35, 20);
            this.numericUpDown4.TabIndex = 14;
            this.numericUpDown4.ValueChanged += new System.EventHandler(this.numericUpDown4_ValueChanged);
            // 
            // labelAppVersion
            // 
            this.labelAppVersion.AutoSize = true;
            this.labelAppVersion.Location = new System.Drawing.Point(21, 52);
            this.labelAppVersion.Name = "labelAppVersion";
            this.labelAppVersion.Size = new System.Drawing.Size(45, 13);
            this.labelAppVersion.TabIndex = 5;
            this.labelAppVersion.Text = "Version:";
            // 
            // numericUpDown3
            // 
            this.numericUpDown3.Location = new System.Drawing.Point(155, 52);
            this.numericUpDown3.Maximum = new decimal(new int[] {
            99,
            0,
            0,
            0});
            this.numericUpDown3.Name = "numericUpDown3";
            this.numericUpDown3.Size = new System.Drawing.Size(35, 20);
            this.numericUpDown3.TabIndex = 13;
            this.numericUpDown3.ValueChanged += new System.EventHandler(this.numericUpDown3_ValueChanged);
            // 
            // labelAppName
            // 
            this.labelAppName.AutoSize = true;
            this.labelAppName.Location = new System.Drawing.Point(21, 23);
            this.labelAppName.Name = "labelAppName";
            this.labelAppName.Size = new System.Drawing.Size(38, 13);
            this.labelAppName.TabIndex = 4;
            this.labelAppName.Text = "Name:";
            // 
            // numericUpDown2
            // 
            this.numericUpDown2.Location = new System.Drawing.Point(114, 52);
            this.numericUpDown2.Maximum = new decimal(new int[] {
            99,
            0,
            0,
            0});
            this.numericUpDown2.Name = "numericUpDown2";
            this.numericUpDown2.Size = new System.Drawing.Size(35, 20);
            this.numericUpDown2.TabIndex = 12;
            this.numericUpDown2.ValueChanged += new System.EventHandler(this.numericUpDown2_ValueChanged);
            // 
            // textBoxAppName
            // 
            this.textBoxAppName.Location = new System.Drawing.Point(73, 19);
            this.textBoxAppName.Name = "textBoxAppName";
            this.textBoxAppName.Size = new System.Drawing.Size(186, 20);
            this.textBoxAppName.TabIndex = 3;
            this.textBoxAppName.TextChanged += new System.EventHandler(this.textBoxAppName_TextChanged);
            // 
            // numericUpDown1
            // 
            this.numericUpDown1.Location = new System.Drawing.Point(73, 52);
            this.numericUpDown1.Maximum = new decimal(new int[] {
            99,
            0,
            0,
            0});
            this.numericUpDown1.Name = "numericUpDown1";
            this.numericUpDown1.Size = new System.Drawing.Size(35, 20);
            this.numericUpDown1.TabIndex = 11;
            this.numericUpDown1.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.numericUpDown1.ValueChanged += new System.EventHandler(this.numericUpDown1_ValueChanged);
            // 
            // textBoxScriptVersion
            // 
            this.textBoxScriptVersion.Location = new System.Drawing.Point(76, 20);
            this.textBoxScriptVersion.Name = "textBoxScriptVersion";
            this.textBoxScriptVersion.Size = new System.Drawing.Size(72, 20);
            this.textBoxScriptVersion.TabIndex = 6;
            this.textBoxScriptVersion.TextChanged += new System.EventHandler(this.textBoxScriptVersion_TextChanged);
            // 
            // labelScriptVersion
            // 
            this.labelScriptVersion.AutoSize = true;
            this.labelScriptVersion.Location = new System.Drawing.Point(18, 23);
            this.labelScriptVersion.Name = "labelScriptVersion";
            this.labelScriptVersion.Size = new System.Drawing.Size(45, 13);
            this.labelScriptVersion.TabIndex = 7;
            this.labelScriptVersion.Text = "Version:";
            // 
            // groupBoxScriptVersion
            // 
            this.groupBoxScriptVersion.Controls.Add(this.textBoxScriptVersion);
            this.groupBoxScriptVersion.Controls.Add(this.labelScriptVersion);
            this.groupBoxScriptVersion.Location = new System.Drawing.Point(320, 20);
            this.groupBoxScriptVersion.Name = "groupBoxScriptVersion";
            this.groupBoxScriptVersion.Size = new System.Drawing.Size(190, 60);
            this.groupBoxScriptVersion.TabIndex = 8;
            this.groupBoxScriptVersion.TabStop = false;
            this.groupBoxScriptVersion.Text = "Script Version";
            // 
            // labelMessage
            // 
            this.labelMessage.AutoSize = true;
            this.labelMessage.Location = new System.Drawing.Point(46, 230);
            this.labelMessage.Name = "labelMessage";
            this.labelMessage.Size = new System.Drawing.Size(16, 13);
            this.labelMessage.TabIndex = 10;
            this.labelMessage.Text = "...";
            // 
            // tabControl1
            // 
            this.tabControl1.Controls.Add(this.tabPageBuild);
            this.tabControl1.Controls.Add(this.tabPageExtract);
            this.tabControl1.Controls.Add(this.tabPageSource);
            this.tabControl1.Controls.Add(this.tabPagePayload);
            this.tabControl1.Location = new System.Drawing.Point(5, 2);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(617, 300);
            this.tabControl1.TabIndex = 11;
            // 
            // tabPageBuild
            // 
            this.tabPageBuild.BackColor = System.Drawing.SystemColors.Control;
            this.tabPageBuild.Controls.Add(this.checkBoxWorkLocal);
            this.tabPageBuild.Controls.Add(this.groupBoxSettings);
            this.tabPageBuild.Controls.Add(this.checkBoxSafeZip);
            this.tabPageBuild.Controls.Add(this.groupBoxScriptVersion);
            this.tabPageBuild.Controls.Add(this.groupBoxAppVersion);
            this.tabPageBuild.Location = new System.Drawing.Point(4, 22);
            this.tabPageBuild.Name = "tabPageBuild";
            this.tabPageBuild.Padding = new System.Windows.Forms.Padding(3);
            this.tabPageBuild.Size = new System.Drawing.Size(609, 274);
            this.tabPageBuild.TabIndex = 0;
            this.tabPageBuild.Text = "Build";
            this.tabPageBuild.Enter += new System.EventHandler(this.tabPageBuild_Enter);
            // 
            // checkBoxWorkLocal
            // 
            this.checkBoxWorkLocal.AutoSize = true;
            this.checkBoxWorkLocal.Location = new System.Drawing.Point(341, 160);
            this.checkBoxWorkLocal.Name = "checkBoxWorkLocal";
            this.checkBoxWorkLocal.Size = new System.Drawing.Size(146, 17);
            this.checkBoxWorkLocal.TabIndex = 17;
            this.checkBoxWorkLocal.Text = "Compile in Local directory";
            this.checkBoxWorkLocal.UseVisualStyleBackColor = true;
            this.checkBoxWorkLocal.CheckedChanged += new System.EventHandler(this.checkBoxWorkLocal_CheckedChanged);
            // 
            // groupBoxSettings
            // 
            this.groupBoxSettings.Controls.Add(this.radioButtonWorkImplFiles);
            this.groupBoxSettings.Controls.Add(this.radioButtonWorkLocal);
            this.groupBoxSettings.Controls.Add(this.radioButtonWorkTemp);
            this.groupBoxSettings.Controls.Add(this.checkBoxBuildLocked);
            this.groupBoxSettings.Location = new System.Drawing.Point(15, 140);
            this.groupBoxSettings.Name = "groupBoxSettings";
            this.groupBoxSettings.Size = new System.Drawing.Size(285, 75);
            this.groupBoxSettings.TabIndex = 14;
            this.groupBoxSettings.TabStop = false;
            this.groupBoxSettings.Text = "Settings";
            // 
            // radioButtonWorkImplFiles
            // 
            this.radioButtonWorkImplFiles.AutoSize = true;
            this.radioButtonWorkImplFiles.Location = new System.Drawing.Point(155, 46);
            this.radioButtonWorkImplFiles.Name = "radioButtonWorkImplFiles";
            this.radioButtonWorkImplFiles.Size = new System.Drawing.Size(65, 17);
            this.radioButtonWorkImplFiles.TabIndex = 18;
            this.radioButtonWorkImplFiles.TabStop = true;
            this.radioButtonWorkImplFiles.Text = "ImplFiles";
            this.radioButtonWorkImplFiles.UseVisualStyleBackColor = true;
            this.radioButtonWorkImplFiles.Click += new System.EventHandler(this.radioButtonWorkImplFiles_Click);
            // 
            // radioButtonWorkLocal
            // 
            this.radioButtonWorkLocal.AutoSize = true;
            this.radioButtonWorkLocal.Location = new System.Drawing.Point(83, 46);
            this.radioButtonWorkLocal.Name = "radioButtonWorkLocal";
            this.radioButtonWorkLocal.Size = new System.Drawing.Size(51, 17);
            this.radioButtonWorkLocal.TabIndex = 17;
            this.radioButtonWorkLocal.TabStop = true;
            this.radioButtonWorkLocal.Text = "Local";
            this.radioButtonWorkLocal.UseVisualStyleBackColor = true;
            this.radioButtonWorkLocal.Click += new System.EventHandler(this.radioButtonWorkLocal_Click);
            // 
            // radioButtonWorkTemp
            // 
            this.radioButtonWorkTemp.AutoSize = true;
            this.radioButtonWorkTemp.Location = new System.Drawing.Point(10, 46);
            this.radioButtonWorkTemp.Name = "radioButtonWorkTemp";
            this.radioButtonWorkTemp.Size = new System.Drawing.Size(52, 17);
            this.radioButtonWorkTemp.TabIndex = 16;
            this.radioButtonWorkTemp.TabStop = true;
            this.radioButtonWorkTemp.Text = "Temp";
            this.radioButtonWorkTemp.UseVisualStyleBackColor = true;
            this.radioButtonWorkTemp.Click += new System.EventHandler(this.radioButtonWorkTemp_Click);
            // 
            // checkBoxBuildLocked
            // 
            this.checkBoxBuildLocked.AutoSize = true;
            this.checkBoxBuildLocked.Location = new System.Drawing.Point(10, 20);
            this.checkBoxBuildLocked.Name = "checkBoxBuildLocked";
            this.checkBoxBuildLocked.Size = new System.Drawing.Size(88, 17);
            this.checkBoxBuildLocked.TabIndex = 9;
            this.checkBoxBuildLocked.Text = "Build Locked";
            this.checkBoxBuildLocked.UseVisualStyleBackColor = true;
            this.checkBoxBuildLocked.CheckedChanged += new System.EventHandler(this.checkBoxBuildLocked_CheckedChanged);
            // 
            // checkBoxSafeZip
            // 
            this.checkBoxSafeZip.AutoSize = true;
            this.checkBoxSafeZip.Location = new System.Drawing.Point(341, 186);
            this.checkBoxSafeZip.Name = "checkBoxSafeZip";
            this.checkBoxSafeZip.Size = new System.Drawing.Size(68, 17);
            this.checkBoxSafeZip.TabIndex = 10;
            this.checkBoxSafeZip.Text = "Safe ZIP";
            this.checkBoxSafeZip.UseVisualStyleBackColor = true;
            this.checkBoxSafeZip.CheckedChanged += new System.EventHandler(this.checkBoxSafeZip_CheckedChanged);
            // 
            // tabPageExtract
            // 
            this.tabPageExtract.BackColor = System.Drawing.SystemColors.Control;
            this.tabPageExtract.Controls.Add(this.textBoxPassword);
            this.tabPageExtract.Controls.Add(this.checkBoxRequirePassword);
            this.tabPageExtract.Controls.Add(this.groupBoxFileManagement);
            this.tabPageExtract.Controls.Add(this.groupBoxExtract);
            this.tabPageExtract.Controls.Add(this.labelMessage);
            this.tabPageExtract.Location = new System.Drawing.Point(4, 22);
            this.tabPageExtract.Name = "tabPageExtract";
            this.tabPageExtract.Padding = new System.Windows.Forms.Padding(3);
            this.tabPageExtract.Size = new System.Drawing.Size(609, 274);
            this.tabPageExtract.TabIndex = 1;
            this.tabPageExtract.Text = "Extract";
            this.tabPageExtract.Enter += new System.EventHandler(this.tabPageExtract_Enter);
            // 
            // textBoxPassword
            // 
            this.textBoxPassword.Location = new System.Drawing.Point(42, 190);
            this.textBoxPassword.Name = "textBoxPassword";
            this.textBoxPassword.Size = new System.Drawing.Size(200, 20);
            this.textBoxPassword.TabIndex = 19;
            this.textBoxPassword.TextChanged += new System.EventHandler(this.textBoxPassword_TextChanged);
            // 
            // checkBoxRequirePassword
            // 
            this.checkBoxRequirePassword.AutoSize = true;
            this.checkBoxRequirePassword.Location = new System.Drawing.Point(42, 170);
            this.checkBoxRequirePassword.Name = "checkBoxRequirePassword";
            this.checkBoxRequirePassword.Size = new System.Drawing.Size(161, 17);
            this.checkBoxRequirePassword.TabIndex = 18;
            this.checkBoxRequirePassword.Text = "Require Password to Unlock";
            this.checkBoxRequirePassword.UseVisualStyleBackColor = true;
            this.checkBoxRequirePassword.CheckedChanged += new System.EventHandler(this.checkBoxRequirePassword_CheckedChanged);
            // 
            // groupBoxFileManagement
            // 
            this.groupBoxFileManagement.Controls.Add(this.checkBoxPrompOverwrite);
            this.groupBoxFileManagement.Controls.Add(this.checkBoxUnpackZipped);
            this.groupBoxFileManagement.Location = new System.Drawing.Point(379, 25);
            this.groupBoxFileManagement.Name = "groupBoxFileManagement";
            this.groupBoxFileManagement.Size = new System.Drawing.Size(200, 125);
            this.groupBoxFileManagement.TabIndex = 17;
            this.groupBoxFileManagement.TabStop = false;
            this.groupBoxFileManagement.Text = "File Management";
            // 
            // checkBoxPrompOverwrite
            // 
            this.checkBoxPrompOverwrite.AutoSize = true;
            this.checkBoxPrompOverwrite.Location = new System.Drawing.Point(20, 24);
            this.checkBoxPrompOverwrite.Name = "checkBoxPrompOverwrite";
            this.checkBoxPrompOverwrite.Size = new System.Drawing.Size(117, 17);
            this.checkBoxPrompOverwrite.TabIndex = 15;
            this.checkBoxPrompOverwrite.Text = "Prompt to overwrite";
            this.checkBoxPrompOverwrite.UseVisualStyleBackColor = true;
            this.checkBoxPrompOverwrite.CheckedChanged += new System.EventHandler(this.checkBoxPrompOverwrite_CheckedChanged);
            // 
            // checkBoxUnpackZipped
            // 
            this.checkBoxUnpackZipped.AutoSize = true;
            this.checkBoxUnpackZipped.Location = new System.Drawing.Point(20, 44);
            this.checkBoxUnpackZipped.Name = "checkBoxUnpackZipped";
            this.checkBoxUnpackZipped.Size = new System.Drawing.Size(119, 17);
            this.checkBoxUnpackZipped.TabIndex = 16;
            this.checkBoxUnpackZipped.Text = "Unpack zipped files";
            this.checkBoxUnpackZipped.UseVisualStyleBackColor = true;
            this.checkBoxUnpackZipped.CheckedChanged += new System.EventHandler(this.checkBoxUnpackZipped_CheckedChanged);
            // 
            // groupBoxExtract
            // 
            this.groupBoxExtract.Controls.Add(this.checkBoxExtractImplFiles);
            this.groupBoxExtract.Controls.Add(this.checkBoxExtractActions);
            this.groupBoxExtract.Controls.Add(this.checkBoxExtractEvents);
            this.groupBoxExtract.Controls.Add(this.checkBoxExtractSource);
            this.groupBoxExtract.Controls.Add(this.checkBoxExtractPayload);
            this.groupBoxExtract.Controls.Add(this.checkBoxExtractVisualStudio);
            this.groupBoxExtract.Controls.Add(this.checkBoxExtractScripts);
            this.groupBoxExtract.Location = new System.Drawing.Point(25, 25);
            this.groupBoxExtract.Name = "groupBoxExtract";
            this.groupBoxExtract.Size = new System.Drawing.Size(336, 125);
            this.groupBoxExtract.TabIndex = 14;
            this.groupBoxExtract.TabStop = false;
            this.groupBoxExtract.Text = "What to extract";
            // 
            // checkBoxExtractActions
            // 
            this.checkBoxExtractActions.AutoSize = true;
            this.checkBoxExtractActions.Location = new System.Drawing.Point(166, 67);
            this.checkBoxExtractActions.Name = "checkBoxExtractActions";
            this.checkBoxExtractActions.Size = new System.Drawing.Size(95, 17);
            this.checkBoxExtractActions.TabIndex = 19;
            this.checkBoxExtractActions.Text = "default actions";
            this.checkBoxExtractActions.UseVisualStyleBackColor = true;
            this.checkBoxExtractActions.CheckedChanged += new System.EventHandler(this.checkBoxExtractActions_CheckedChanged);
            // 
            // checkBoxExtractEvents
            // 
            this.checkBoxExtractEvents.AutoSize = true;
            this.checkBoxExtractEvents.Location = new System.Drawing.Point(166, 44);
            this.checkBoxExtractEvents.Name = "checkBoxExtractEvents";
            this.checkBoxExtractEvents.Size = new System.Drawing.Size(93, 17);
            this.checkBoxExtractEvents.TabIndex = 18;
            this.checkBoxExtractEvents.Text = "default events";
            this.checkBoxExtractEvents.UseVisualStyleBackColor = true;
            this.checkBoxExtractEvents.CheckedChanged += new System.EventHandler(this.checkBoxExtractEvents_CheckedChanged);
            // 
            // checkBoxExtractSource
            // 
            this.checkBoxExtractSource.AutoSize = true;
            this.checkBoxExtractSource.Location = new System.Drawing.Point(17, 24);
            this.checkBoxExtractSource.Name = "checkBoxExtractSource";
            this.checkBoxExtractSource.Size = new System.Drawing.Size(79, 17);
            this.checkBoxExtractSource.TabIndex = 17;
            this.checkBoxExtractSource.Text = "app source";
            this.checkBoxExtractSource.UseVisualStyleBackColor = true;
            this.checkBoxExtractSource.CheckedChanged += new System.EventHandler(this.checkBoxExtractSource_CheckedChanged);
            // 
            // checkBoxExtractPayload
            // 
            this.checkBoxExtractPayload.AutoSize = true;
            this.checkBoxExtractPayload.Location = new System.Drawing.Point(17, 67);
            this.checkBoxExtractPayload.Name = "checkBoxExtractPayload";
            this.checkBoxExtractPayload.Size = new System.Drawing.Size(96, 17);
            this.checkBoxExtractPayload.TabIndex = 16;
            this.checkBoxExtractPayload.Text = "zipped content";
            this.checkBoxExtractPayload.UseVisualStyleBackColor = true;
            this.checkBoxExtractPayload.CheckedChanged += new System.EventHandler(this.checkBoxExtractPayload_CheckedChanged);
            // 
            // checkBoxExtractVisualStudio
            // 
            this.checkBoxExtractVisualStudio.AutoSize = true;
            this.checkBoxExtractVisualStudio.Location = new System.Drawing.Point(17, 44);
            this.checkBoxExtractVisualStudio.Name = "checkBoxExtractVisualStudio";
            this.checkBoxExtractVisualStudio.Size = new System.Drawing.Size(118, 17);
            this.checkBoxExtractVisualStudio.TabIndex = 14;
            this.checkBoxExtractVisualStudio.Text = "zipped visual studio";
            this.checkBoxExtractVisualStudio.UseVisualStyleBackColor = true;
            this.checkBoxExtractVisualStudio.CheckedChanged += new System.EventHandler(this.checkBoxExtractVisualStudio_CheckedChanged);
            // 
            // checkBoxExtractScripts
            // 
            this.checkBoxExtractScripts.AutoSize = true;
            this.checkBoxExtractScripts.Location = new System.Drawing.Point(166, 24);
            this.checkBoxExtractScripts.Name = "checkBoxExtractScripts";
            this.checkBoxExtractScripts.Size = new System.Drawing.Size(121, 17);
            this.checkBoxExtractScripts.TabIndex = 12;
            this.checkBoxExtractScripts.Text = "default script source";
            this.checkBoxExtractScripts.UseVisualStyleBackColor = true;
            this.checkBoxExtractScripts.CheckedChanged += new System.EventHandler(this.checkBoxExtractScripts_CheckedChanged);
            // 
            // tabPageSource
            // 
            this.tabPageSource.BackColor = System.Drawing.SystemColors.Control;
            this.tabPageSource.Controls.Add(this.buttonSourceDelete);
            this.tabPageSource.Controls.Add(this.textBoxSourceName);
            this.tabPageSource.Controls.Add(this.textBoxSourceSize);
            this.tabPageSource.Controls.Add(this.textBoxSourceDate);
            this.tabPageSource.Controls.Add(this.dataGridViewFiles);
            this.tabPageSource.Controls.Add(this.textBoxSourcePath);
            this.tabPageSource.Controls.Add(this.pictureBoxSource);
            this.tabPageSource.Location = new System.Drawing.Point(4, 22);
            this.tabPageSource.Name = "tabPageSource";
            this.tabPageSource.Size = new System.Drawing.Size(609, 274);
            this.tabPageSource.TabIndex = 3;
            this.tabPageSource.Text = "Source";
            this.tabPageSource.Enter += new System.EventHandler(this.tabPageSource_Enter);
            // 
            // buttonSourceDelete
            // 
            this.buttonSourceDelete.Location = new System.Drawing.Point(365, 181);
            this.buttonSourceDelete.Name = "buttonSourceDelete";
            this.buttonSourceDelete.Size = new System.Drawing.Size(80, 25);
            this.buttonSourceDelete.TabIndex = 12;
            this.buttonSourceDelete.Text = "Delete";
            this.buttonSourceDelete.UseVisualStyleBackColor = true;
            this.buttonSourceDelete.Click += new System.EventHandler(this.buttonSourceDelete_Click);
            // 
            // textBoxSourceName
            // 
            this.textBoxSourceName.Location = new System.Drawing.Point(365, 20);
            this.textBoxSourceName.Name = "textBoxSourceName";
            this.textBoxSourceName.ReadOnly = true;
            this.textBoxSourceName.Size = new System.Drawing.Size(200, 20);
            this.textBoxSourceName.TabIndex = 17;
            this.textBoxSourceName.Text = "name";
            // 
            // textBoxSourceSize
            // 
            this.textBoxSourceSize.Location = new System.Drawing.Point(365, 115);
            this.textBoxSourceSize.Name = "textBoxSourceSize";
            this.textBoxSourceSize.ReadOnly = true;
            this.textBoxSourceSize.Size = new System.Drawing.Size(110, 20);
            this.textBoxSourceSize.TabIndex = 15;
            this.textBoxSourceSize.Text = "size";
            // 
            // textBoxSourceDate
            // 
            this.textBoxSourceDate.Location = new System.Drawing.Point(365, 145);
            this.textBoxSourceDate.Name = "textBoxSourceDate";
            this.textBoxSourceDate.ReadOnly = true;
            this.textBoxSourceDate.Size = new System.Drawing.Size(200, 20);
            this.textBoxSourceDate.TabIndex = 16;
            this.textBoxSourceDate.Text = "date";
            // 
            // dataGridViewFiles
            // 
            this.dataGridViewFiles.AllowDrop = true;
            this.dataGridViewFiles.AllowUserToResizeRows = false;
            this.dataGridViewFiles.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dataGridViewFiles.BackgroundColor = System.Drawing.SystemColors.Window;
            this.dataGridViewFiles.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.dataGridViewFiles.CellBorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.None;
            this.dataGridViewFiles.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridViewFiles.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.dataGridViewImageColumn1,
            this.dataGridViewTextBoxColumn1,
            this.dataGridViewTextBoxColumn2,
            this.dataGridViewTextBoxColumn3,
            this.dataGridViewTextBoxColumn4});
            this.dataGridViewFiles.GridColor = System.Drawing.SystemColors.ControlLight;
            this.dataGridViewFiles.Location = new System.Drawing.Point(160, 10);
            this.dataGridViewFiles.Name = "dataGridViewFiles";
            this.dataGridViewFiles.ReadOnly = true;
            this.dataGridViewFiles.RowHeadersVisible = false;
            this.dataGridViewFiles.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dataGridViewFiles.Size = new System.Drawing.Size(190, 250);
            this.dataGridViewFiles.TabIndex = 7;
            this.dataGridViewFiles.SelectionChanged += new System.EventHandler(this.dataGridViewFiles_SelectionChanged);
            // 
            // dataGridViewImageColumn1
            // 
            this.dataGridViewImageColumn1.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.None;
            this.dataGridViewImageColumn1.DataPropertyName = "Icon";
            this.dataGridViewImageColumn1.HeaderText = "";
            this.dataGridViewImageColumn1.ImageLayout = System.Windows.Forms.DataGridViewImageCellLayout.Zoom;
            this.dataGridViewImageColumn1.Name = "dataGridViewImageColumn1";
            this.dataGridViewImageColumn1.ReadOnly = true;
            this.dataGridViewImageColumn1.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.dataGridViewImageColumn1.Width = 20;
            // 
            // dataGridViewTextBoxColumn1
            // 
            this.dataGridViewTextBoxColumn1.DataPropertyName = "Name";
            this.dataGridViewTextBoxColumn1.HeaderText = "File";
            this.dataGridViewTextBoxColumn1.Name = "dataGridViewTextBoxColumn1";
            this.dataGridViewTextBoxColumn1.ReadOnly = true;
            this.dataGridViewTextBoxColumn1.Width = 150;
            // 
            // dataGridViewTextBoxColumn2
            // 
            this.dataGridViewTextBoxColumn2.DataPropertyName = "Size";
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleRight;
            dataGridViewCellStyle2.Format = "#,### bytes";
            dataGridViewCellStyle2.NullValue = null;
            this.dataGridViewTextBoxColumn2.DefaultCellStyle = dataGridViewCellStyle2;
            this.dataGridViewTextBoxColumn2.HeaderText = "Size";
            this.dataGridViewTextBoxColumn2.Name = "dataGridViewTextBoxColumn2";
            this.dataGridViewTextBoxColumn2.ReadOnly = true;
            this.dataGridViewTextBoxColumn2.Visible = false;
            this.dataGridViewTextBoxColumn2.Width = 80;
            // 
            // dataGridViewTextBoxColumn3
            // 
            this.dataGridViewTextBoxColumn3.DataPropertyName = "Date";
            this.dataGridViewTextBoxColumn3.HeaderText = "Date Modified";
            this.dataGridViewTextBoxColumn3.Name = "dataGridViewTextBoxColumn3";
            this.dataGridViewTextBoxColumn3.ReadOnly = true;
            this.dataGridViewTextBoxColumn3.Visible = false;
            this.dataGridViewTextBoxColumn3.Width = 120;
            // 
            // dataGridViewTextBoxColumn4
            // 
            this.dataGridViewTextBoxColumn4.DataPropertyName = "FullName";
            this.dataGridViewTextBoxColumn4.HeaderText = "Path";
            this.dataGridViewTextBoxColumn4.Name = "dataGridViewTextBoxColumn4";
            this.dataGridViewTextBoxColumn4.ReadOnly = true;
            this.dataGridViewTextBoxColumn4.Visible = false;
            this.dataGridViewTextBoxColumn4.Width = 260;
            // 
            // textBoxSourcePath
            // 
            this.textBoxSourcePath.Location = new System.Drawing.Point(365, 50);
            this.textBoxSourcePath.Multiline = true;
            this.textBoxSourcePath.Name = "textBoxSourcePath";
            this.textBoxSourcePath.ReadOnly = true;
            this.textBoxSourcePath.Size = new System.Drawing.Size(230, 55);
            this.textBoxSourcePath.TabIndex = 14;
            this.textBoxSourcePath.Text = "path";
            // 
            // pictureBoxSource
            // 
            this.pictureBoxSource.Location = new System.Drawing.Point(15, 25);
            this.pictureBoxSource.Name = "pictureBoxSource";
            this.pictureBoxSource.Size = new System.Drawing.Size(128, 100);
            this.pictureBoxSource.TabIndex = 13;
            this.pictureBoxSource.TabStop = false;
            // 
            // tabPagePayload
            // 
            this.tabPagePayload.BackColor = System.Drawing.SystemColors.Control;
            this.tabPagePayload.Controls.Add(this.buttonSelectSettings);
            this.tabPagePayload.Controls.Add(this.textBoxImplFilesFolder);
            this.tabPagePayload.Controls.Add(this.labelImplFilesFolder);
            this.tabPagePayload.Controls.Add(this.textBoxSettingsFileName);
            this.tabPagePayload.Controls.Add(this.labelSettingsFile);
            this.tabPagePayload.Location = new System.Drawing.Point(4, 22);
            this.tabPagePayload.Name = "tabPagePayload";
            this.tabPagePayload.Size = new System.Drawing.Size(609, 274);
            this.tabPagePayload.TabIndex = 4;
            this.tabPagePayload.Text = "Payload";
            this.tabPagePayload.Enter += new System.EventHandler(this.tabPagePayload_Enter);
            // 
            // buttonSelectSettings
            // 
            this.buttonSelectSettings.Location = new System.Drawing.Point(425, 27);
            this.buttonSelectSettings.Name = "buttonSelectSettings";
            this.buttonSelectSettings.Size = new System.Drawing.Size(75, 23);
            this.buttonSelectSettings.TabIndex = 9;
            this.buttonSelectSettings.Text = "Select ...";
            this.buttonSelectSettings.UseVisualStyleBackColor = true;
            this.buttonSelectSettings.Click += new System.EventHandler(this.buttonSelectSettings_Click);
            // 
            // textBoxImplFilesFolder
            // 
            this.textBoxImplFilesFolder.Enabled = false;
            this.textBoxImplFilesFolder.Location = new System.Drawing.Point(110, 27);
            this.textBoxImplFilesFolder.Name = "textBoxImplFilesFolder";
            this.textBoxImplFilesFolder.Size = new System.Drawing.Size(265, 20);
            this.textBoxImplFilesFolder.TabIndex = 8;
            this.textBoxImplFilesFolder.TextChanged += new System.EventHandler(this.textBoxImplFilesFolder_TextChanged);
            // 
            // labelImplFilesFolder
            // 
            this.labelImplFilesFolder.AutoSize = true;
            this.labelImplFilesFolder.Location = new System.Drawing.Point(15, 30);
            this.labelImplFilesFolder.Name = "labelImplFilesFolder";
            this.labelImplFilesFolder.Size = new System.Drawing.Size(82, 13);
            this.labelImplFilesFolder.TabIndex = 7;
            this.labelImplFilesFolder.Text = "ImplFiles Folder:";
            // 
            // textBoxSettingsFileName
            // 
            this.textBoxSettingsFileName.Enabled = false;
            this.textBoxSettingsFileName.Location = new System.Drawing.Point(110, 67);
            this.textBoxSettingsFileName.Name = "textBoxSettingsFileName";
            this.textBoxSettingsFileName.Size = new System.Drawing.Size(150, 20);
            this.textBoxSettingsFileName.TabIndex = 6;
            this.textBoxSettingsFileName.TextChanged += new System.EventHandler(this.textBoxSettingsFileName_TextChanged);
            // 
            // labelSettingsFile
            // 
            this.labelSettingsFile.AutoSize = true;
            this.labelSettingsFile.Location = new System.Drawing.Point(15, 70);
            this.labelSettingsFile.Name = "labelSettingsFile";
            this.labelSettingsFile.Size = new System.Drawing.Size(67, 13);
            this.labelSettingsFile.TabIndex = 5;
            this.labelSettingsFile.Text = "Settings File:";
            // 
            // buttonUtility
            // 
            this.buttonUtility.Location = new System.Drawing.Point(146, 320);
            this.buttonUtility.Name = "buttonUtility";
            this.buttonUtility.Size = new System.Drawing.Size(100, 40);
            this.buttonUtility.TabIndex = 8;
            this.buttonUtility.Text = "SafeZip";
            this.buttonUtility.UseVisualStyleBackColor = true;
            this.buttonUtility.Click += new System.EventHandler(this.buttonUtility_Click);
            // 
            // checkBoxExtractImplFiles
            // 
            this.checkBoxExtractImplFiles.AutoSize = true;
            this.checkBoxExtractImplFiles.Location = new System.Drawing.Point(17, 90);
            this.checkBoxExtractImplFiles.Name = "checkBoxExtractImplFiles";
            this.checkBoxExtractImplFiles.Size = new System.Drawing.Size(100, 17);
            this.checkBoxExtractImplFiles.TabIndex = 20;
            this.checkBoxExtractImplFiles.Text = "zipped ImplFiles";
            this.checkBoxExtractImplFiles.UseVisualStyleBackColor = true;
            this.checkBoxExtractImplFiles.CheckedChanged += new System.EventHandler(this.checkBoxExtractImplFiles_CheckedChanged);
            // 
            // AppBuilderForm
            // 
            this.AcceptButton = this.buttonClose;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.buttonClose;
            this.ClientSize = new System.Drawing.Size(674, 375);
            this.Controls.Add(this.tabControl1);
            this.Controls.Add(this.buttonClose);
            this.Controls.Add(this.buttonUtility);
            this.Controls.Add(this.buttonBuild);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "AppBuilderForm";
            this.Text = "AppBuilder";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.AppBuilderForm_FormClosing);
            this.Load += new System.EventHandler(this.AppBuilderForm_Load);
            this.groupBoxAppVersion.ResumeLayout(false);
            this.groupBoxAppVersion.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown4)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown3)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown2)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown1)).EndInit();
            this.groupBoxScriptVersion.ResumeLayout(false);
            this.groupBoxScriptVersion.PerformLayout();
            this.tabControl1.ResumeLayout(false);
            this.tabPageBuild.ResumeLayout(false);
            this.tabPageBuild.PerformLayout();
            this.groupBoxSettings.ResumeLayout(false);
            this.groupBoxSettings.PerformLayout();
            this.tabPageExtract.ResumeLayout(false);
            this.tabPageExtract.PerformLayout();
            this.groupBoxFileManagement.ResumeLayout(false);
            this.groupBoxFileManagement.PerformLayout();
            this.groupBoxExtract.ResumeLayout(false);
            this.groupBoxExtract.PerformLayout();
            this.tabPageSource.ResumeLayout(false);
            this.tabPageSource.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridViewFiles)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxSource)).EndInit();
            this.tabPagePayload.ResumeLayout(false);
            this.tabPagePayload.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button buttonClose;
        private System.Windows.Forms.Button buttonBuild;
        private System.Windows.Forms.GroupBox groupBoxAppVersion;
        private System.Windows.Forms.Label labelAppVersion;
        private System.Windows.Forms.Label labelAppName;
        private System.Windows.Forms.TextBox textBoxAppName;
        private System.Windows.Forms.TextBox textBoxScriptVersion;
        private System.Windows.Forms.Label labelScriptVersion;
        private System.Windows.Forms.GroupBox groupBoxScriptVersion;
        private System.Windows.Forms.Label labelMessage;
        private System.Windows.Forms.NumericUpDown numericUpDown4;
        private System.Windows.Forms.NumericUpDown numericUpDown3;
        private System.Windows.Forms.NumericUpDown numericUpDown2;
        private System.Windows.Forms.NumericUpDown numericUpDown1;
        private System.Windows.Forms.TabControl tabControl1;
        private System.Windows.Forms.TabPage tabPageBuild;
        private System.Windows.Forms.TabPage tabPageExtract;
        private System.Windows.Forms.GroupBox groupBoxExtract;
        private System.Windows.Forms.CheckBox checkBoxExtractScripts;
        private System.Windows.Forms.CheckBox checkBoxUnpackZipped;
        private System.Windows.Forms.CheckBox checkBoxPrompOverwrite;
        private System.Windows.Forms.CheckBox checkBoxExtractVisualStudio;
        private System.Windows.Forms.CheckBox checkBoxExtractPayload;
        private System.Windows.Forms.CheckBox checkBoxExtractSource;
        private System.Windows.Forms.TabPage tabPageSource;
        private System.Windows.Forms.DataGridView dataGridViewFiles;
        private System.Windows.Forms.Button buttonUtility;
        private System.Windows.Forms.CheckBox checkBoxWorkLocal;
        private System.Windows.Forms.CheckBox checkBoxBuildLocked;
        private System.Windows.Forms.CheckBox checkBoxSafeZip;
        private System.Windows.Forms.CheckBox checkBoxExtractEvents;
        private System.Windows.Forms.GroupBox groupBoxSettings;
        private System.Windows.Forms.GroupBox groupBoxFileManagement;
        private System.Windows.Forms.CheckBox checkBoxRequirePassword;
        private System.Windows.Forms.TextBox textBoxPassword;
        private System.Windows.Forms.TabPage tabPagePayload;
        private System.Windows.Forms.Button buttonSelectSettings;
        private System.Windows.Forms.TextBox textBoxImplFilesFolder;
        private System.Windows.Forms.Label labelImplFilesFolder;
        private System.Windows.Forms.TextBox textBoxSettingsFileName;
        private System.Windows.Forms.Label labelSettingsFile;
        private System.Windows.Forms.RadioButton radioButtonWorkImplFiles;
        private System.Windows.Forms.RadioButton radioButtonWorkLocal;
        private System.Windows.Forms.RadioButton radioButtonWorkTemp;
        private System.Windows.Forms.CheckBox checkBoxExtractActions;
        private System.Windows.Forms.Button buttonSourceDelete;
        private System.Windows.Forms.PictureBox pictureBoxSource;
        private System.Windows.Forms.TextBox textBoxSourcePath;
        private System.Windows.Forms.TextBox textBoxSourceSize;
        private System.Windows.Forms.TextBox textBoxSourceDate;
        private System.Windows.Forms.DataGridViewImageColumn dataGridViewImageColumn1;
        private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn1;
        private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn2;
        private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn3;
        private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn4;
        private System.Windows.Forms.TextBox textBoxSourceName;
        private System.Windows.Forms.CheckBox checkBoxExtractImplFiles;
    }
}