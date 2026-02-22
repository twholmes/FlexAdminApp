namespace Crayon
{
    partial class AppFilerForm
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            this.buttonClose = new System.Windows.Forms.Button();
            this.buttonUnpack = new System.Windows.Forms.Button();
            this.labelMessage = new System.Windows.Forms.Label();
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabPageUnpack = new System.Windows.Forms.TabPage();
            this.pictureBoxFiler = new System.Windows.Forms.PictureBox();
            this.groupBoxUnpackOptions = new System.Windows.Forms.GroupBox();
            this.checkBoxPrompOverwrite = new System.Windows.Forms.CheckBox();
            this.checkBoxUnpackZipped = new System.Windows.Forms.CheckBox();
            this.groupBoxUnpack = new System.Windows.Forms.GroupBox();
            this.checkBoxExtractActions = new System.Windows.Forms.CheckBox();
            this.checkBoxExtractEvents = new System.Windows.Forms.CheckBox();
            this.checkBoxExtractVisualStudio = new System.Windows.Forms.CheckBox();
            this.checkBoxExtractSource = new System.Windows.Forms.CheckBox();
            this.checkBoxExtractPayload = new System.Windows.Forms.CheckBox();
            this.checkBoxExtractScripts = new System.Windows.Forms.CheckBox();
            this.tabPageWorking = new System.Windows.Forms.TabPage();
            this.buttonGoTo = new System.Windows.Forms.Button();
            this.dataGridViewFiles = new System.Windows.Forms.DataGridView();
            this.dataGridViewImageColumn1 = new System.Windows.Forms.DataGridViewImageColumn();
            this.dataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.dataGridViewTextBoxColumn2 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.dataGridViewTextBoxColumn3 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.tabPagePayload = new System.Windows.Forms.TabPage();
            this.buttonPackPayload = new System.Windows.Forms.Button();
            this.textBoxImplFilesFolder = new System.Windows.Forms.TextBox();
            this.labelImplFilesFolder = new System.Windows.Forms.Label();
            this.tabPageLogFiles = new System.Windows.Forms.TabPage();
            this.textBoxLogFilesFolder = new System.Windows.Forms.TextBox();
            this.buttonViewLogfile = new System.Windows.Forms.Button();
            this.buttonGoToLogFolder = new System.Windows.Forms.Button();
            this.dataGridViewLogFiles = new System.Windows.Forms.DataGridView();
            this.dataGridViewImageColumn2 = new System.Windows.Forms.DataGridViewImageColumn();
            this.dataGridViewTextBoxColumn5 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.dataGridViewTextBoxColumn6 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.dataGridViewTextBoxColumn7 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.menuStripFiler = new System.Windows.Forms.MenuStrip();
            this.toolStripMenuItemWrite = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemWriteDefaultScripts = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemWriteTestScripts = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemWriteEventsActions = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpack = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpackUnzip = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStripMenuItemUnpackScript = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpackPayload = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpackActions = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpackEvents = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpackSource = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpackVisualStudio = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemEvents = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemEventsEdit = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemEventsReload = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemActions = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemActionsEdit = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemActionsReload = new System.Windows.Forms.ToolStripMenuItem();
            this.checkBoxExtractImplFiles = new System.Windows.Forms.CheckBox();
            this.toolStripMenuItemUnpackImplFiles = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemUnpackHelp = new System.Windows.Forms.ToolStripMenuItem();
            this.checkBoxExtractHelp = new System.Windows.Forms.CheckBox();
            this.tabControl1.SuspendLayout();
            this.tabPageUnpack.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxFiler)).BeginInit();
            this.groupBoxUnpackOptions.SuspendLayout();
            this.groupBoxUnpack.SuspendLayout();
            this.tabPageWorking.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridViewFiles)).BeginInit();
            this.tabPagePayload.SuspendLayout();
            this.tabPageLogFiles.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridViewLogFiles)).BeginInit();
            this.menuStripFiler.SuspendLayout();
            this.SuspendLayout();
            // 
            // buttonClose
            // 
            this.buttonClose.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.buttonClose.Location = new System.Drawing.Point(12, 314);
            this.buttonClose.Name = "buttonClose";
            this.buttonClose.Size = new System.Drawing.Size(75, 23);
            this.buttonClose.TabIndex = 0;
            this.buttonClose.Text = "Close";
            this.buttonClose.UseVisualStyleBackColor = true;
            this.buttonClose.Click += new System.EventHandler(this.buttonClose_Click);
            // 
            // buttonUnpack
            // 
            this.buttonUnpack.Location = new System.Drawing.Point(455, 37);
            this.buttonUnpack.Name = "buttonUnpack";
            this.buttonUnpack.Size = new System.Drawing.Size(75, 23);
            this.buttonUnpack.TabIndex = 9;
            this.buttonUnpack.Text = "Unpack";
            this.buttonUnpack.UseVisualStyleBackColor = true;
            this.buttonUnpack.Click += new System.EventHandler(this.buttonUnpack_Click);
            // 
            // labelMessage
            // 
            this.labelMessage.AutoSize = true;
            this.labelMessage.Location = new System.Drawing.Point(17, 209);
            this.labelMessage.Name = "labelMessage";
            this.labelMessage.Size = new System.Drawing.Size(16, 13);
            this.labelMessage.TabIndex = 10;
            this.labelMessage.Text = "...";
            // 
            // tabControl1
            // 
            this.tabControl1.Controls.Add(this.tabPageUnpack);
            this.tabControl1.Controls.Add(this.tabPageWorking);
            this.tabControl1.Controls.Add(this.tabPagePayload);
            this.tabControl1.Controls.Add(this.tabPageLogFiles);
            this.tabControl1.Location = new System.Drawing.Point(2, 27);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(560, 271);
            this.tabControl1.TabIndex = 11;
            // 
            // tabPageUnpack
            // 
            this.tabPageUnpack.BackColor = System.Drawing.SystemColors.Control;
            this.tabPageUnpack.Controls.Add(this.pictureBoxFiler);
            this.tabPageUnpack.Controls.Add(this.groupBoxUnpackOptions);
            this.tabPageUnpack.Controls.Add(this.groupBoxUnpack);
            this.tabPageUnpack.Controls.Add(this.labelMessage);
            this.tabPageUnpack.Controls.Add(this.buttonUnpack);
            this.tabPageUnpack.Location = new System.Drawing.Point(4, 22);
            this.tabPageUnpack.Name = "tabPageUnpack";
            this.tabPageUnpack.Padding = new System.Windows.Forms.Padding(3);
            this.tabPageUnpack.Size = new System.Drawing.Size(552, 245);
            this.tabPageUnpack.TabIndex = 1;
            this.tabPageUnpack.Text = "Unpack";
            this.tabPageUnpack.Enter += new System.EventHandler(this.tabPageUnpack_Enter);
            // 
            // pictureBoxFiler
            // 
            this.pictureBoxFiler.Location = new System.Drawing.Point(20, 66);
            this.pictureBoxFiler.Name = "pictureBoxFiler";
            this.pictureBoxFiler.Size = new System.Drawing.Size(128, 100);
            this.pictureBoxFiler.TabIndex = 18;
            this.pictureBoxFiler.TabStop = false;
            // 
            // groupBoxUnpackOptions
            // 
            this.groupBoxUnpackOptions.Controls.Add(this.checkBoxPrompOverwrite);
            this.groupBoxUnpackOptions.Controls.Add(this.checkBoxUnpackZipped);
            this.groupBoxUnpackOptions.Location = new System.Drawing.Point(180, 20);
            this.groupBoxUnpackOptions.Name = "groupBoxUnpackOptions";
            this.groupBoxUnpackOptions.Size = new System.Drawing.Size(164, 83);
            this.groupBoxUnpackOptions.TabIndex = 17;
            this.groupBoxUnpackOptions.TabStop = false;
            this.groupBoxUnpackOptions.Text = "Options";
            // 
            // checkBoxPrompOverwrite
            // 
            this.checkBoxPrompOverwrite.AutoSize = true;
            this.checkBoxPrompOverwrite.Location = new System.Drawing.Point(17, 23);
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
            this.checkBoxUnpackZipped.Location = new System.Drawing.Point(17, 46);
            this.checkBoxUnpackZipped.Name = "checkBoxUnpackZipped";
            this.checkBoxUnpackZipped.Size = new System.Drawing.Size(119, 17);
            this.checkBoxUnpackZipped.TabIndex = 16;
            this.checkBoxUnpackZipped.Text = "Unpack zipped files";
            this.checkBoxUnpackZipped.UseVisualStyleBackColor = true;
            this.checkBoxUnpackZipped.CheckedChanged += new System.EventHandler(this.checkBoxUnpackZipped_CheckedChanged);
            // 
            // groupBoxUnpack
            // 
            this.groupBoxUnpack.Controls.Add(this.checkBoxExtractHelp);
            this.groupBoxUnpack.Controls.Add(this.checkBoxExtractImplFiles);
            this.groupBoxUnpack.Controls.Add(this.checkBoxExtractActions);
            this.groupBoxUnpack.Controls.Add(this.checkBoxExtractEvents);
            this.groupBoxUnpack.Controls.Add(this.checkBoxExtractVisualStudio);
            this.groupBoxUnpack.Controls.Add(this.checkBoxExtractSource);
            this.groupBoxUnpack.Controls.Add(this.checkBoxExtractPayload);
            this.groupBoxUnpack.Controls.Add(this.checkBoxExtractScripts);
            this.groupBoxUnpack.Location = new System.Drawing.Point(180, 122);
            this.groupBoxUnpack.Name = "groupBoxUnpack";
            this.groupBoxUnpack.Size = new System.Drawing.Size(350, 100);
            this.groupBoxUnpack.TabIndex = 14;
            this.groupBoxUnpack.TabStop = false;
            this.groupBoxUnpack.Text = "What to unpack";
            // 
            // checkBoxExtractActions
            // 
            this.checkBoxExtractActions.AutoSize = true;
            this.checkBoxExtractActions.Location = new System.Drawing.Point(128, 47);
            this.checkBoxExtractActions.Name = "checkBoxExtractActions";
            this.checkBoxExtractActions.Size = new System.Drawing.Size(61, 17);
            this.checkBoxExtractActions.TabIndex = 21;
            this.checkBoxExtractActions.Text = "Actions";
            this.checkBoxExtractActions.UseVisualStyleBackColor = true;
            this.checkBoxExtractActions.CheckedChanged += new System.EventHandler(this.checkBoxExtractActions_CheckedChanged);
            // 
            // checkBoxExtractEvents
            // 
            this.checkBoxExtractEvents.AutoSize = true;
            this.checkBoxExtractEvents.Location = new System.Drawing.Point(128, 24);
            this.checkBoxExtractEvents.Name = "checkBoxExtractEvents";
            this.checkBoxExtractEvents.Size = new System.Drawing.Size(59, 17);
            this.checkBoxExtractEvents.TabIndex = 20;
            this.checkBoxExtractEvents.Text = "Events";
            this.checkBoxExtractEvents.UseVisualStyleBackColor = true;
            this.checkBoxExtractEvents.CheckedChanged += new System.EventHandler(this.checkBoxExtractEvents_CheckedChanged);
            // 
            // checkBoxExtractVisualStudio
            // 
            this.checkBoxExtractVisualStudio.AutoSize = true;
            this.checkBoxExtractVisualStudio.Location = new System.Drawing.Point(226, 47);
            this.checkBoxExtractVisualStudio.Name = "checkBoxExtractVisualStudio";
            this.checkBoxExtractVisualStudio.Size = new System.Drawing.Size(84, 17);
            this.checkBoxExtractVisualStudio.TabIndex = 20;
            this.checkBoxExtractVisualStudio.Text = "VisualStudio";
            this.checkBoxExtractVisualStudio.UseVisualStyleBackColor = true;
            this.checkBoxExtractVisualStudio.CheckedChanged += new System.EventHandler(this.checkBoxExtractVisualStudio_CheckedChanged);
            // 
            // checkBoxExtractSource
            // 
            this.checkBoxExtractSource.AutoSize = true;
            this.checkBoxExtractSource.Location = new System.Drawing.Point(226, 24);
            this.checkBoxExtractSource.Name = "checkBoxExtractSource";
            this.checkBoxExtractSource.Size = new System.Drawing.Size(60, 17);
            this.checkBoxExtractSource.TabIndex = 19;
            this.checkBoxExtractSource.Text = "Source";
            this.checkBoxExtractSource.UseVisualStyleBackColor = true;
            this.checkBoxExtractSource.CheckedChanged += new System.EventHandler(this.checkBoxExtractSource_CheckedChanged);
            // 
            // checkBoxExtractPayload
            // 
            this.checkBoxExtractPayload.AutoSize = true;
            this.checkBoxExtractPayload.Location = new System.Drawing.Point(17, 47);
            this.checkBoxExtractPayload.Name = "checkBoxExtractPayload";
            this.checkBoxExtractPayload.Size = new System.Drawing.Size(64, 17);
            this.checkBoxExtractPayload.TabIndex = 13;
            this.checkBoxExtractPayload.Text = "Payload";
            this.checkBoxExtractPayload.UseVisualStyleBackColor = true;
            this.checkBoxExtractPayload.CheckedChanged += new System.EventHandler(this.checkBoxExtractPayload_CheckedChanged);
            // 
            // checkBoxExtractScripts
            // 
            this.checkBoxExtractScripts.AutoSize = true;
            this.checkBoxExtractScripts.Location = new System.Drawing.Point(17, 24);
            this.checkBoxExtractScripts.Name = "checkBoxExtractScripts";
            this.checkBoxExtractScripts.Size = new System.Drawing.Size(58, 17);
            this.checkBoxExtractScripts.TabIndex = 12;
            this.checkBoxExtractScripts.Text = "Scripts";
            this.checkBoxExtractScripts.UseVisualStyleBackColor = true;
            this.checkBoxExtractScripts.CheckedChanged += new System.EventHandler(this.checkBoxExtractScripts_CheckedChanged);
            // 
            // tabPageWorking
            // 
            this.tabPageWorking.BackColor = System.Drawing.SystemColors.Control;
            this.tabPageWorking.Controls.Add(this.buttonGoTo);
            this.tabPageWorking.Controls.Add(this.dataGridViewFiles);
            this.tabPageWorking.Location = new System.Drawing.Point(4, 22);
            this.tabPageWorking.Name = "tabPageWorking";
            this.tabPageWorking.Padding = new System.Windows.Forms.Padding(3);
            this.tabPageWorking.Size = new System.Drawing.Size(552, 245);
            this.tabPageWorking.TabIndex = 0;
            this.tabPageWorking.Text = "Working";
            this.tabPageWorking.Enter += new System.EventHandler(this.tabPageWorking_Enter);
            // 
            // buttonGoTo
            // 
            this.buttonGoTo.Location = new System.Drawing.Point(472, 34);
            this.buttonGoTo.Name = "buttonGoTo";
            this.buttonGoTo.Size = new System.Drawing.Size(75, 23);
            this.buttonGoTo.TabIndex = 7;
            this.buttonGoTo.Text = "GoTo";
            this.buttonGoTo.UseVisualStyleBackColor = true;
            this.buttonGoTo.Click += new System.EventHandler(this.buttonGoTo_Click);
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
            this.dataGridViewTextBoxColumn3});
            this.dataGridViewFiles.GridColor = System.Drawing.SystemColors.ControlLight;
            this.dataGridViewFiles.Location = new System.Drawing.Point(12, 12);
            this.dataGridViewFiles.Name = "dataGridViewFiles";
            this.dataGridViewFiles.ReadOnly = true;
            this.dataGridViewFiles.RowHeadersVisible = false;
            this.dataGridViewFiles.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dataGridViewFiles.Size = new System.Drawing.Size(453, 221);
            this.dataGridViewFiles.TabIndex = 6;
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
            this.dataGridViewTextBoxColumn1.Width = 230;
            // 
            // dataGridViewTextBoxColumn2
            // 
            this.dataGridViewTextBoxColumn2.DataPropertyName = "Size";
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleRight;
            dataGridViewCellStyle1.Format = "#,### bytes";
            dataGridViewCellStyle1.NullValue = null;
            this.dataGridViewTextBoxColumn2.DefaultCellStyle = dataGridViewCellStyle1;
            this.dataGridViewTextBoxColumn2.HeaderText = "Size";
            this.dataGridViewTextBoxColumn2.Name = "dataGridViewTextBoxColumn2";
            this.dataGridViewTextBoxColumn2.ReadOnly = true;
            this.dataGridViewTextBoxColumn2.Width = 80;
            // 
            // dataGridViewTextBoxColumn3
            // 
            this.dataGridViewTextBoxColumn3.DataPropertyName = "Date";
            this.dataGridViewTextBoxColumn3.HeaderText = "Date Modified";
            this.dataGridViewTextBoxColumn3.Name = "dataGridViewTextBoxColumn3";
            this.dataGridViewTextBoxColumn3.ReadOnly = true;
            this.dataGridViewTextBoxColumn3.Width = 120;
            // 
            // tabPagePayload
            // 
            this.tabPagePayload.BackColor = System.Drawing.SystemColors.Control;
            this.tabPagePayload.Controls.Add(this.buttonPackPayload);
            this.tabPagePayload.Controls.Add(this.textBoxImplFilesFolder);
            this.tabPagePayload.Controls.Add(this.labelImplFilesFolder);
            this.tabPagePayload.Location = new System.Drawing.Point(4, 22);
            this.tabPagePayload.Name = "tabPagePayload";
            this.tabPagePayload.Size = new System.Drawing.Size(552, 245);
            this.tabPagePayload.TabIndex = 3;
            this.tabPagePayload.Text = "Payload";
            this.tabPagePayload.Enter += new System.EventHandler(this.tabPagePayload_Enter);
            // 
            // buttonPackPayload
            // 
            this.buttonPackPayload.Location = new System.Drawing.Point(420, 24);
            this.buttonPackPayload.Name = "buttonPackPayload";
            this.buttonPackPayload.Size = new System.Drawing.Size(75, 23);
            this.buttonPackPayload.TabIndex = 16;
            this.buttonPackPayload.Text = "Pack";
            this.buttonPackPayload.UseVisualStyleBackColor = true;
            this.buttonPackPayload.Click += new System.EventHandler(this.buttonPackPayload_Click);
            // 
            // textBoxImplFilesFolder
            // 
            this.textBoxImplFilesFolder.Enabled = false;
            this.textBoxImplFilesFolder.Location = new System.Drawing.Point(110, 24);
            this.textBoxImplFilesFolder.Name = "textBoxImplFilesFolder";
            this.textBoxImplFilesFolder.Size = new System.Drawing.Size(265, 20);
            this.textBoxImplFilesFolder.TabIndex = 14;
            this.textBoxImplFilesFolder.TextChanged += new System.EventHandler(this.textBoxImplFilesFolder_TextChanged);
            // 
            // labelImplFilesFolder
            // 
            this.labelImplFilesFolder.AutoSize = true;
            this.labelImplFilesFolder.Location = new System.Drawing.Point(15, 27);
            this.labelImplFilesFolder.Name = "labelImplFilesFolder";
            this.labelImplFilesFolder.Size = new System.Drawing.Size(82, 13);
            this.labelImplFilesFolder.TabIndex = 13;
            this.labelImplFilesFolder.Text = "ImplFiles Folder:";
            // 
            // tabPageLogFiles
            // 
            this.tabPageLogFiles.BackColor = System.Drawing.SystemColors.Control;
            this.tabPageLogFiles.Controls.Add(this.textBoxLogFilesFolder);
            this.tabPageLogFiles.Controls.Add(this.buttonViewLogfile);
            this.tabPageLogFiles.Controls.Add(this.buttonGoToLogFolder);
            this.tabPageLogFiles.Controls.Add(this.dataGridViewLogFiles);
            this.tabPageLogFiles.Location = new System.Drawing.Point(4, 22);
            this.tabPageLogFiles.Name = "tabPageLogFiles";
            this.tabPageLogFiles.Size = new System.Drawing.Size(552, 245);
            this.tabPageLogFiles.TabIndex = 4;
            this.tabPageLogFiles.Text = "Log Files";
            this.tabPageLogFiles.Enter += new System.EventHandler(this.tabPageLogFiles_Enter);
            // 
            // textBoxLogFilesFolder
            // 
            this.textBoxLogFilesFolder.Enabled = false;
            this.textBoxLogFilesFolder.Location = new System.Drawing.Point(13, 13);
            this.textBoxLogFilesFolder.Name = "textBoxLogFilesFolder";
            this.textBoxLogFilesFolder.Size = new System.Drawing.Size(453, 20);
            this.textBoxLogFilesFolder.TabIndex = 15;
            // 
            // buttonViewLogfile
            // 
            this.buttonViewLogfile.Location = new System.Drawing.Point(472, 72);
            this.buttonViewLogfile.Name = "buttonViewLogfile";
            this.buttonViewLogfile.Size = new System.Drawing.Size(75, 23);
            this.buttonViewLogfile.TabIndex = 14;
            this.buttonViewLogfile.Text = "View...";
            this.buttonViewLogfile.UseVisualStyleBackColor = true;
            this.buttonViewLogfile.Click += new System.EventHandler(this.buttonViewLogfile_Click);
            // 
            // buttonGoToLogFolder
            // 
            this.buttonGoToLogFolder.Location = new System.Drawing.Point(472, 13);
            this.buttonGoToLogFolder.Name = "buttonGoToLogFolder";
            this.buttonGoToLogFolder.Size = new System.Drawing.Size(75, 23);
            this.buttonGoToLogFolder.TabIndex = 12;
            this.buttonGoToLogFolder.Text = "GoTo ...";
            this.buttonGoToLogFolder.UseVisualStyleBackColor = true;
            this.buttonGoToLogFolder.Click += new System.EventHandler(this.buttonGoToLogFolder_Click);
            // 
            // dataGridViewLogFiles
            // 
            this.dataGridViewLogFiles.AllowDrop = true;
            this.dataGridViewLogFiles.AllowUserToResizeRows = false;
            this.dataGridViewLogFiles.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dataGridViewLogFiles.BackgroundColor = System.Drawing.SystemColors.Window;
            this.dataGridViewLogFiles.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.dataGridViewLogFiles.CellBorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.None;
            this.dataGridViewLogFiles.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridViewLogFiles.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.dataGridViewImageColumn2,
            this.dataGridViewTextBoxColumn5,
            this.dataGridViewTextBoxColumn6,
            this.dataGridViewTextBoxColumn7});
            this.dataGridViewLogFiles.GridColor = System.Drawing.SystemColors.ControlLight;
            this.dataGridViewLogFiles.Location = new System.Drawing.Point(13, 51);
            this.dataGridViewLogFiles.Name = "dataGridViewLogFiles";
            this.dataGridViewLogFiles.ReadOnly = true;
            this.dataGridViewLogFiles.RowHeadersVisible = false;
            this.dataGridViewLogFiles.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dataGridViewLogFiles.Size = new System.Drawing.Size(453, 172);
            this.dataGridViewLogFiles.TabIndex = 11;
            // 
            // dataGridViewImageColumn2
            // 
            this.dataGridViewImageColumn2.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.None;
            this.dataGridViewImageColumn2.DataPropertyName = "Icon";
            this.dataGridViewImageColumn2.HeaderText = "";
            this.dataGridViewImageColumn2.ImageLayout = System.Windows.Forms.DataGridViewImageCellLayout.Zoom;
            this.dataGridViewImageColumn2.Name = "dataGridViewImageColumn2";
            this.dataGridViewImageColumn2.ReadOnly = true;
            this.dataGridViewImageColumn2.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.dataGridViewImageColumn2.Width = 20;
            // 
            // dataGridViewTextBoxColumn5
            // 
            this.dataGridViewTextBoxColumn5.DataPropertyName = "Name";
            this.dataGridViewTextBoxColumn5.HeaderText = "File";
            this.dataGridViewTextBoxColumn5.Name = "dataGridViewTextBoxColumn5";
            this.dataGridViewTextBoxColumn5.ReadOnly = true;
            this.dataGridViewTextBoxColumn5.Width = 230;
            // 
            // dataGridViewTextBoxColumn6
            // 
            this.dataGridViewTextBoxColumn6.DataPropertyName = "Size";
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleRight;
            dataGridViewCellStyle2.Format = "#,### bytes";
            dataGridViewCellStyle2.NullValue = null;
            this.dataGridViewTextBoxColumn6.DefaultCellStyle = dataGridViewCellStyle2;
            this.dataGridViewTextBoxColumn6.HeaderText = "Size";
            this.dataGridViewTextBoxColumn6.Name = "dataGridViewTextBoxColumn6";
            this.dataGridViewTextBoxColumn6.ReadOnly = true;
            this.dataGridViewTextBoxColumn6.Width = 80;
            // 
            // dataGridViewTextBoxColumn7
            // 
            this.dataGridViewTextBoxColumn7.DataPropertyName = "Date";
            this.dataGridViewTextBoxColumn7.HeaderText = "Date Modified";
            this.dataGridViewTextBoxColumn7.Name = "dataGridViewTextBoxColumn7";
            this.dataGridViewTextBoxColumn7.ReadOnly = true;
            this.dataGridViewTextBoxColumn7.Width = 120;
            // 
            // menuStripFiler
            // 
            this.menuStripFiler.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemWrite,
            this.toolStripMenuItemUnpack,
            this.toolStripMenuItemEvents,
            this.toolStripMenuItemActions});
            this.menuStripFiler.Location = new System.Drawing.Point(0, 0);
            this.menuStripFiler.Name = "menuStripFiler";
            this.menuStripFiler.Size = new System.Drawing.Size(574, 24);
            this.menuStripFiler.TabIndex = 12;
            this.menuStripFiler.Text = "menuStripFiler";
            // 
            // toolStripMenuItemWrite
            // 
            this.toolStripMenuItemWrite.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemWriteDefaultScripts,
            this.toolStripMenuItemWriteTestScripts,
            this.toolStripMenuItemWriteEventsActions});
            this.toolStripMenuItemWrite.Name = "toolStripMenuItemWrite";
            this.toolStripMenuItemWrite.Size = new System.Drawing.Size(47, 20);
            this.toolStripMenuItemWrite.Text = "Write";
            // 
            // toolStripMenuItemWriteDefaultScripts
            // 
            this.toolStripMenuItemWriteDefaultScripts.Name = "toolStripMenuItemWriteDefaultScripts";
            this.toolStripMenuItemWriteDefaultScripts.Size = new System.Drawing.Size(205, 22);
            this.toolStripMenuItemWriteDefaultScripts.Text = "Write Default Scripts";
            this.toolStripMenuItemWriteDefaultScripts.Click += new System.EventHandler(this.toolStripMenuItemWriteDefaultScripts_Click);
            // 
            // toolStripMenuItemWriteTestScripts
            // 
            this.toolStripMenuItemWriteTestScripts.Name = "toolStripMenuItemWriteTestScripts";
            this.toolStripMenuItemWriteTestScripts.Size = new System.Drawing.Size(205, 22);
            this.toolStripMenuItemWriteTestScripts.Text = "Write Test Scripts";
            this.toolStripMenuItemWriteTestScripts.Click += new System.EventHandler(this.toolStripMenuItemWriteTestScripts_Click);
            // 
            // toolStripMenuItemWriteEventsActions
            // 
            this.toolStripMenuItemWriteEventsActions.Name = "toolStripMenuItemWriteEventsActions";
            this.toolStripMenuItemWriteEventsActions.Size = new System.Drawing.Size(205, 22);
            this.toolStripMenuItemWriteEventsActions.Text = "Write Events and Actions";
            this.toolStripMenuItemWriteEventsActions.Click += new System.EventHandler(this.toolStripMenuItemWriteEventsActions_Click);
            // 
            // toolStripMenuItemUnpack
            // 
            this.toolStripMenuItemUnpack.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemUnpackUnzip,
            this.toolStripSeparator2,
            this.toolStripMenuItemUnpackHelp,
            this.toolStripMenuItemUnpackScript,
            this.toolStripMenuItemUnpackImplFiles,
            this.toolStripMenuItemUnpackPayload,
            this.toolStripMenuItemUnpackActions,
            this.toolStripMenuItemUnpackEvents,
            this.toolStripMenuItemUnpackSource,
            this.toolStripMenuItemUnpackVisualStudio});
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
            // toolStripSeparator2
            // 
            this.toolStripSeparator2.Name = "toolStripSeparator2";
            this.toolStripSeparator2.Size = new System.Drawing.Size(177, 6);
            // 
            // toolStripMenuItemUnpackScript
            // 
            this.toolStripMenuItemUnpackScript.Name = "toolStripMenuItemUnpackScript";
            this.toolStripMenuItemUnpackScript.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemUnpackScript.Text = "Scripts";
            this.toolStripMenuItemUnpackScript.Click += new System.EventHandler(this.toolStripMenuItemUnpackScript_Click);
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
            // toolStripMenuItemEvents
            // 
            this.toolStripMenuItemEvents.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemEventsEdit,
            this.toolStripMenuItemEventsReload});
            this.toolStripMenuItemEvents.Name = "toolStripMenuItemEvents";
            this.toolStripMenuItemEvents.Size = new System.Drawing.Size(53, 20);
            this.toolStripMenuItemEvents.Text = "Events";
            // 
            // toolStripMenuItemEventsEdit
            // 
            this.toolStripMenuItemEventsEdit.Name = "toolStripMenuItemEventsEdit";
            this.toolStripMenuItemEventsEdit.Size = new System.Drawing.Size(143, 22);
            this.toolStripMenuItemEventsEdit.Text = "Edit Events ...";
            this.toolStripMenuItemEventsEdit.Click += new System.EventHandler(this.toolStripMenuItemEventsEdit_Click);
            // 
            // toolStripMenuItemEventsReload
            // 
            this.toolStripMenuItemEventsReload.Name = "toolStripMenuItemEventsReload";
            this.toolStripMenuItemEventsReload.Size = new System.Drawing.Size(143, 22);
            this.toolStripMenuItemEventsReload.Text = "Reload";
            this.toolStripMenuItemEventsReload.Click += new System.EventHandler(this.toolStripMenuItemEventsReload_Click);
            // 
            // toolStripMenuItemActions
            // 
            this.toolStripMenuItemActions.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemActionsEdit,
            this.toolStripMenuItemActionsReload});
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
            // checkBoxExtractImplFiles
            // 
            this.checkBoxExtractImplFiles.AutoSize = true;
            this.checkBoxExtractImplFiles.Location = new System.Drawing.Point(17, 70);
            this.checkBoxExtractImplFiles.Name = "checkBoxExtractImplFiles";
            this.checkBoxExtractImplFiles.Size = new System.Drawing.Size(66, 17);
            this.checkBoxExtractImplFiles.TabIndex = 22;
            this.checkBoxExtractImplFiles.Text = "ImplFiles";
            this.checkBoxExtractImplFiles.UseVisualStyleBackColor = true;
            this.checkBoxExtractImplFiles.CheckedChanged += new System.EventHandler(this.checkBoxExtractImplFiles_CheckedChanged);
            // 
            // toolStripMenuItemUnpackImplFiles
            // 
            this.toolStripMenuItemUnpackImplFiles.Name = "toolStripMenuItemUnpackImplFiles";
            this.toolStripMenuItemUnpackImplFiles.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemUnpackImplFiles.Text = "ImplFiles";
            this.toolStripMenuItemUnpackImplFiles.Click += new System.EventHandler(this.toolStripMenuItemUnpackImplFiles_Click);
            // 
            // toolStripMenuItemUnpackHelp
            // 
            this.toolStripMenuItemUnpackHelp.Name = "toolStripMenuItemUnpackHelp";
            this.toolStripMenuItemUnpackHelp.Size = new System.Drawing.Size(180, 22);
            this.toolStripMenuItemUnpackHelp.Text = "Help";
            this.toolStripMenuItemUnpackHelp.Click += new System.EventHandler(this.toolStripMenuItemUnpackHelp_Click);
            // 
            // checkBoxExtractHelp
            // 
            this.checkBoxExtractHelp.AutoSize = true;
            this.checkBoxExtractHelp.Location = new System.Drawing.Point(128, 70);
            this.checkBoxExtractHelp.Name = "checkBoxExtractHelp";
            this.checkBoxExtractHelp.Size = new System.Drawing.Size(48, 17);
            this.checkBoxExtractHelp.TabIndex = 23;
            this.checkBoxExtractHelp.Text = "Help";
            this.checkBoxExtractHelp.UseVisualStyleBackColor = true;
            this.checkBoxExtractHelp.Click += new System.EventHandler(this.checkBoxExtractHelp_CheckedChanged);
            // 
            // AppFilerForm
            // 
            this.AcceptButton = this.buttonClose;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.buttonClose;
            this.ClientSize = new System.Drawing.Size(574, 345);
            this.Controls.Add(this.tabControl1);
            this.Controls.Add(this.buttonClose);
            this.Controls.Add(this.menuStripFiler);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MainMenuStrip = this.menuStripFiler;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "AppFilerForm";
            this.Text = "AppFiler";
            this.Load += new System.EventHandler(this.AppFilerForm_Load);
            this.tabControl1.ResumeLayout(false);
            this.tabPageUnpack.ResumeLayout(false);
            this.tabPageUnpack.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxFiler)).EndInit();
            this.groupBoxUnpackOptions.ResumeLayout(false);
            this.groupBoxUnpackOptions.PerformLayout();
            this.groupBoxUnpack.ResumeLayout(false);
            this.groupBoxUnpack.PerformLayout();
            this.tabPageWorking.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridViewFiles)).EndInit();
            this.tabPagePayload.ResumeLayout(false);
            this.tabPagePayload.PerformLayout();
            this.tabPageLogFiles.ResumeLayout(false);
            this.tabPageLogFiles.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridViewLogFiles)).EndInit();
            this.menuStripFiler.ResumeLayout(false);
            this.menuStripFiler.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button buttonClose;
        private System.Windows.Forms.Button buttonUnpack;
        private System.Windows.Forms.Label labelMessage;
        private System.Windows.Forms.TabControl tabControl1;
        private System.Windows.Forms.TabPage tabPageWorking;
        private System.Windows.Forms.TabPage tabPageUnpack;
        private System.Windows.Forms.GroupBox groupBoxUnpack;
        private System.Windows.Forms.CheckBox checkBoxExtractPayload;
        private System.Windows.Forms.CheckBox checkBoxExtractScripts;
        private System.Windows.Forms.CheckBox checkBoxUnpackZipped;
        private System.Windows.Forms.CheckBox checkBoxPrompOverwrite;
        private System.Windows.Forms.TabPage tabPagePayload;
        private System.Windows.Forms.DataGridView dataGridViewFiles;
        private System.Windows.Forms.Button buttonGoTo;
        private System.Windows.Forms.GroupBox groupBoxUnpackOptions;
        private System.Windows.Forms.PictureBox pictureBoxFiler;
        private System.Windows.Forms.TabPage tabPageLogFiles;
        private System.Windows.Forms.Button buttonViewLogfile;
        private System.Windows.Forms.Button buttonGoToLogFolder;
        private System.Windows.Forms.DataGridView dataGridViewLogFiles;
        private System.Windows.Forms.DataGridViewImageColumn dataGridViewImageColumn2;
        private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn5;
        private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn6;
        private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn7;
        private System.Windows.Forms.DataGridViewImageColumn dataGridViewImageColumn1;
        private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn1;
        private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn2;
        private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn3;
        private System.Windows.Forms.Button buttonPackPayload;
        private System.Windows.Forms.TextBox textBoxImplFilesFolder;
        private System.Windows.Forms.Label labelImplFilesFolder;
        private System.Windows.Forms.TextBox textBoxLogFilesFolder;
        private System.Windows.Forms.MenuStrip menuStripFiler;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemWrite;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemWriteDefaultScripts;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemWriteTestScripts;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemWriteEventsActions;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpack;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackUnzip;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator2;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackScript;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackPayload;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackActions;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackEvents;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackSource;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackVisualStudio;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEvents;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemActions;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemActionsEdit;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemActionsReload;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEventsEdit;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemEventsReload;
        private System.Windows.Forms.CheckBox checkBoxExtractActions;
        private System.Windows.Forms.CheckBox checkBoxExtractEvents;
        private System.Windows.Forms.CheckBox checkBoxExtractVisualStudio;
        private System.Windows.Forms.CheckBox checkBoxExtractSource;
        private System.Windows.Forms.CheckBox checkBoxExtractImplFiles;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackImplFiles;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemUnpackHelp;
        private System.Windows.Forms.CheckBox checkBoxExtractHelp;
    }
}