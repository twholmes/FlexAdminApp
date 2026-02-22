namespace Crayon
{
    partial class AppRunnerForm
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
            this.buttonCLOSE = new System.Windows.Forms.Button();
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
            this.radioButtonCustomActions = new System.Windows.Forms.RadioButton();
            this.radioButtonAllActions = new System.Windows.Forms.RadioButton();
            this.radioButtonShellActions = new System.Windows.Forms.RadioButton();
            this.textBoxActionLabel = new System.Windows.Forms.TextBox();
            this.buttonRUN = new System.Windows.Forms.Button();
            this.checkBoxActionEnabled = new System.Windows.Forms.CheckBox();
            this.textBoxActionType = new System.Windows.Forms.TextBox();
            this.textBoxActionName = new System.Windows.Forms.TextBox();
            this.listBoxActions = new System.Windows.Forms.ListBox();
            this.textBoxGroup = new System.Windows.Forms.TextBox();
            this.groupBoxSelectedAction = new System.Windows.Forms.GroupBox();
            this.groupBoxActionSet = new System.Windows.Forms.GroupBox();
            this.radioButtonBAUActions = new System.Windows.Forms.RadioButton();
            this.radioButtonMaintenanceActions = new System.Windows.Forms.RadioButton();
            this.menuStrip1.SuspendLayout();
            this.groupBoxSelectedAction.SuspendLayout();
            this.groupBoxActionSet.SuspendLayout();
            this.SuspendLayout();
            // 
            // buttonCLOSE
            // 
            this.buttonCLOSE.Location = new System.Drawing.Point(585, 292);
            this.buttonCLOSE.Name = "buttonCLOSE";
            this.buttonCLOSE.Size = new System.Drawing.Size(90, 40);
            this.buttonCLOSE.TabIndex = 0;
            this.buttonCLOSE.Text = "CLOSE";
            this.buttonCLOSE.UseVisualStyleBackColor = true;
            this.buttonCLOSE.Click += new System.EventHandler(this.buttonCLOSE_Click);
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
            this.menuStrip1.Size = new System.Drawing.Size(704, 24);
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
            this.toolStripMenuItemLocked.Size = new System.Drawing.Size(112, 22);
            this.toolStripMenuItemLocked.Text = "Locked";
            this.toolStripMenuItemLocked.Click += new System.EventHandler(this.toolStripMenuItemLocked_Click);
            // 
            // toolStripSeparator4
            // 
            this.toolStripSeparator4.Name = "toolStripSeparator4";
            this.toolStripSeparator4.Size = new System.Drawing.Size(109, 6);
            // 
            // toolStripMenuItemFromTemp
            // 
            this.toolStripMenuItemFromTemp.Name = "toolStripMenuItemFromTemp";
            this.toolStripMenuItemFromTemp.Size = new System.Drawing.Size(112, 22);
            this.toolStripMenuItemFromTemp.Text = "Temp";
            this.toolStripMenuItemFromTemp.Click += new System.EventHandler(this.toolStripMenuItemFromTemp_Click);
            // 
            // toolStripMenuItemFromLocal
            // 
            this.toolStripMenuItemFromLocal.Name = "toolStripMenuItemFromLocal";
            this.toolStripMenuItemFromLocal.Size = new System.Drawing.Size(112, 22);
            this.toolStripMenuItemFromLocal.Text = "Local";
            this.toolStripMenuItemFromLocal.Click += new System.EventHandler(this.toolStripMenuItemFromLocal_Click);
            // 
            // toolStripMenuItemFromHome
            // 
            this.toolStripMenuItemFromHome.Name = "toolStripMenuItemFromHome";
            this.toolStripMenuItemFromHome.Size = new System.Drawing.Size(112, 22);
            this.toolStripMenuItemFromHome.Text = "Home";
            this.toolStripMenuItemFromHome.Click += new System.EventHandler(this.toolStripMenuItemFromHome_Click);
            // 
            // toolStripMenuItemUnpack
            // 
            this.toolStripMenuItemUnpack.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemUnpackUnzip,
            this.toolStripSeparator1,
            this.toolStripMenuItemUnpackScript,
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
            this.toolStripMenuItemUnpackUnzip.Size = new System.Drawing.Size(172, 22);
            this.toolStripMenuItemUnpackUnzip.Text = "Unzip (on Unpack)";
            this.toolStripMenuItemUnpackUnzip.Click += new System.EventHandler(this.toolStripMenuItemUnpackUnzip_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(169, 6);
            // 
            // toolStripMenuItemUnpackScript
            // 
            this.toolStripMenuItemUnpackScript.Name = "toolStripMenuItemUnpackScript";
            this.toolStripMenuItemUnpackScript.Size = new System.Drawing.Size(172, 22);
            this.toolStripMenuItemUnpackScript.Text = "Scripts";
            this.toolStripMenuItemUnpackScript.Click += new System.EventHandler(this.toolStripMenuItemUnpackScript_Click);
            // 
            // toolStripMenuItemUnpackPayload
            // 
            this.toolStripMenuItemUnpackPayload.Name = "toolStripMenuItemUnpackPayload";
            this.toolStripMenuItemUnpackPayload.Size = new System.Drawing.Size(172, 22);
            this.toolStripMenuItemUnpackPayload.Text = "Payload";
            this.toolStripMenuItemUnpackPayload.Click += new System.EventHandler(this.toolStripMenuItemUnpackPayload_Click);
            // 
            // toolStripMenuItemUnpackActions
            // 
            this.toolStripMenuItemUnpackActions.Name = "toolStripMenuItemUnpackActions";
            this.toolStripMenuItemUnpackActions.Size = new System.Drawing.Size(172, 22);
            this.toolStripMenuItemUnpackActions.Text = "Actions";
            this.toolStripMenuItemUnpackActions.Click += new System.EventHandler(this.toolStripMenuItemUnpackActions_Click);
            // 
            // toolStripMenuItemUnpackEvents
            // 
            this.toolStripMenuItemUnpackEvents.Name = "toolStripMenuItemUnpackEvents";
            this.toolStripMenuItemUnpackEvents.Size = new System.Drawing.Size(172, 22);
            this.toolStripMenuItemUnpackEvents.Text = "Events";
            this.toolStripMenuItemUnpackEvents.Click += new System.EventHandler(this.toolStripMenuItemUnpackEvents_Click);
            // 
            // toolStripMenuItemUnpackSource
            // 
            this.toolStripMenuItemUnpackSource.Name = "toolStripMenuItemUnpackSource";
            this.toolStripMenuItemUnpackSource.Size = new System.Drawing.Size(172, 22);
            this.toolStripMenuItemUnpackSource.Text = "Source";
            this.toolStripMenuItemUnpackSource.Click += new System.EventHandler(this.toolStripMenuItemUnpackSource_Click);
            // 
            // toolStripMenuItemUnpackVisualStudio
            // 
            this.toolStripMenuItemUnpackVisualStudio.Name = "toolStripMenuItemUnpackVisualStudio";
            this.toolStripMenuItemUnpackVisualStudio.Size = new System.Drawing.Size(172, 22);
            this.toolStripMenuItemUnpackVisualStudio.Text = "VisualStudio";
            this.toolStripMenuItemUnpackVisualStudio.Click += new System.EventHandler(this.toolStripMenuItemUnpackVisualStudio_Click);
            // 
            // toolStripSeparator2
            // 
            this.toolStripSeparator2.Name = "toolStripSeparator2";
            this.toolStripSeparator2.Size = new System.Drawing.Size(169, 6);
            // 
            // toolStripMenuItemUnpackClear
            // 
            this.toolStripMenuItemUnpackClear.Name = "toolStripMenuItemUnpackClear";
            this.toolStripMenuItemUnpackClear.Size = new System.Drawing.Size(172, 22);
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
            // toolStripSeparator5
            // 
            this.toolStripSeparator5.Name = "toolStripSeparator5";
            this.toolStripSeparator5.Size = new System.Drawing.Size(140, 6);
            // 
            // toolStripMenuItemEventsHidden
            // 
            this.toolStripMenuItemEventsHidden.Name = "toolStripMenuItemEventsHidden";
            this.toolStripMenuItemEventsHidden.Size = new System.Drawing.Size(143, 22);
            this.toolStripMenuItemEventsHidden.Text = "Hidden";
            this.toolStripMenuItemEventsHidden.Click += new System.EventHandler(this.toolStripMenuItemEventsHidden_Click);
            // 
            // toolStripSeparator3
            // 
            this.toolStripSeparator3.Name = "toolStripSeparator3";
            this.toolStripSeparator3.Size = new System.Drawing.Size(140, 6);
            // 
            // toolStripMenuItemEventBuild
            // 
            this.toolStripMenuItemEventBuild.Name = "toolStripMenuItemEventBuild";
            this.toolStripMenuItemEventBuild.Size = new System.Drawing.Size(143, 22);
            this.toolStripMenuItemEventBuild.Text = "@ Build";
            this.toolStripMenuItemEventBuild.Click += new System.EventHandler(this.toolStripMenuItemEventBuild_Click);
            // 
            // toolStripMenuItemEventUnpack
            // 
            this.toolStripMenuItemEventUnpack.Name = "toolStripMenuItemEventUnpack";
            this.toolStripMenuItemEventUnpack.Size = new System.Drawing.Size(143, 22);
            this.toolStripMenuItemEventUnpack.Text = "@Unpack";
            this.toolStripMenuItemEventUnpack.Click += new System.EventHandler(this.toolStripMenuItemEventUnpack_Click);
            // 
            // toolStripMenuItemEventDrop
            // 
            this.toolStripMenuItemEventDrop.Name = "toolStripMenuItemEventDrop";
            this.toolStripMenuItemEventDrop.Size = new System.Drawing.Size(143, 22);
            this.toolStripMenuItemEventDrop.Text = "@ File-Drop";
            this.toolStripMenuItemEventDrop.Click += new System.EventHandler(this.toolStripMenuItemEventDrop_Click);
            // 
            // toolStripMenuItemEventPreRUN
            // 
            this.toolStripMenuItemEventPreRUN.Name = "toolStripMenuItemEventPreRUN";
            this.toolStripMenuItemEventPreRUN.Size = new System.Drawing.Size(143, 22);
            this.toolStripMenuItemEventPreRUN.Text = "@ Pre-RUN";
            this.toolStripMenuItemEventPreRUN.Click += new System.EventHandler(this.toolStripMenuItemEventPreRUN_Click);
            // 
            // toolStripMenuItemEventPostRUN
            // 
            this.toolStripMenuItemEventPostRUN.Name = "toolStripMenuItemEventPostRUN";
            this.toolStripMenuItemEventPostRUN.Size = new System.Drawing.Size(143, 22);
            this.toolStripMenuItemEventPostRUN.Text = "@ Post-RUN";
            this.toolStripMenuItemEventPostRUN.Click += new System.EventHandler(this.toolStripMenuItemEventPostRUN_Click);
            // 
            // toolStripMenuItemEventExit
            // 
            this.toolStripMenuItemEventExit.Name = "toolStripMenuItemEventExit";
            this.toolStripMenuItemEventExit.Size = new System.Drawing.Size(143, 22);
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
            // radioButtonCustomActions
            // 
            this.radioButtonCustomActions.AutoSize = true;
            this.radioButtonCustomActions.Location = new System.Drawing.Point(417, 19);
            this.radioButtonCustomActions.Name = "radioButtonCustomActions";
            this.radioButtonCustomActions.Size = new System.Drawing.Size(60, 17);
            this.radioButtonCustomActions.TabIndex = 42;
            this.radioButtonCustomActions.Text = "Custom";
            this.radioButtonCustomActions.UseVisualStyleBackColor = true;
            this.radioButtonCustomActions.Click += new System.EventHandler(this.radioButtonCustomActions_Click);
            // 
            // radioButtonAllActions
            // 
            this.radioButtonAllActions.AutoSize = true;
            this.radioButtonAllActions.Checked = true;
            this.radioButtonAllActions.Location = new System.Drawing.Point(19, 19);
            this.radioButtonAllActions.Name = "radioButtonAllActions";
            this.radioButtonAllActions.Size = new System.Drawing.Size(44, 17);
            this.radioButtonAllActions.TabIndex = 41;
            this.radioButtonAllActions.TabStop = true;
            this.radioButtonAllActions.Text = "ALL";
            this.radioButtonAllActions.UseVisualStyleBackColor = true;
            this.radioButtonAllActions.Click += new System.EventHandler(this.radioButtonAllActions_Click);
            // 
            // radioButtonShellActions
            // 
            this.radioButtonShellActions.AutoSize = true;
            this.radioButtonShellActions.Location = new System.Drawing.Point(106, 19);
            this.radioButtonShellActions.Name = "radioButtonShellActions";
            this.radioButtonShellActions.Size = new System.Drawing.Size(48, 17);
            this.radioButtonShellActions.TabIndex = 40;
            this.radioButtonShellActions.Text = "Shell";
            this.radioButtonShellActions.UseVisualStyleBackColor = true;
            this.radioButtonShellActions.Click += new System.EventHandler(this.radioButtonShellActions_Click);
            // 
            // textBoxActionLabel
            // 
            this.textBoxActionLabel.Enabled = false;
            this.textBoxActionLabel.Location = new System.Drawing.Point(15, 91);
            this.textBoxActionLabel.Name = "textBoxActionLabel";
            this.textBoxActionLabel.Size = new System.Drawing.Size(300, 20);
            this.textBoxActionLabel.TabIndex = 39;
            // 
            // buttonRUN
            // 
            this.buttonRUN.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.buttonRUN.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.buttonRUN.Location = new System.Drawing.Point(340, 25);
            this.buttonRUN.Name = "buttonRUN";
            this.buttonRUN.Size = new System.Drawing.Size(90, 130);
            this.buttonRUN.TabIndex = 38;
            this.buttonRUN.Text = "RUN";
            this.buttonRUN.UseVisualStyleBackColor = true;
            this.buttonRUN.Click += new System.EventHandler(this.buttonRUN_Click);
            // 
            // checkBoxActionEnabled
            // 
            this.checkBoxActionEnabled.AutoSize = true;
            this.checkBoxActionEnabled.Location = new System.Drawing.Point(15, 157);
            this.checkBoxActionEnabled.Name = "checkBoxActionEnabled";
            this.checkBoxActionEnabled.Size = new System.Drawing.Size(72, 17);
            this.checkBoxActionEnabled.TabIndex = 36;
            this.checkBoxActionEnabled.Text = "Enabled";
            this.checkBoxActionEnabled.UseVisualStyleBackColor = true;
            this.checkBoxActionEnabled.CheckedChanged += new System.EventHandler(this.checkBoxActionEnabled_CheckedChanged);
            // 
            // textBoxActionType
            // 
            this.textBoxActionType.Enabled = false;
            this.textBoxActionType.Location = new System.Drawing.Point(15, 124);
            this.textBoxActionType.Name = "textBoxActionType";
            this.textBoxActionType.Size = new System.Drawing.Size(60, 20);
            this.textBoxActionType.TabIndex = 35;
            // 
            // textBoxActionName
            // 
            this.textBoxActionName.Enabled = false;
            this.textBoxActionName.Location = new System.Drawing.Point(15, 58);
            this.textBoxActionName.Name = "textBoxActionName";
            this.textBoxActionName.Size = new System.Drawing.Size(280, 20);
            this.textBoxActionName.TabIndex = 33;
            // 
            // listBoxActions
            // 
            this.listBoxActions.FormattingEnabled = true;
            this.listBoxActions.Location = new System.Drawing.Point(12, 91);
            this.listBoxActions.Name = "listBoxActions";
            this.listBoxActions.ScrollAlwaysVisible = true;
            this.listBoxActions.Size = new System.Drawing.Size(220, 238);
            this.listBoxActions.TabIndex = 31;
            this.listBoxActions.SelectedIndexChanged += new System.EventHandler(this.listBoxActions_SelectedIndexChanged);
            // 
            // textBoxGroup
            // 
            this.textBoxGroup.Enabled = false;
            this.textBoxGroup.Location = new System.Drawing.Point(15, 25);
            this.textBoxGroup.Name = "textBoxGroup";
            this.textBoxGroup.Size = new System.Drawing.Size(180, 20);
            this.textBoxGroup.TabIndex = 44;
            // 
            // groupBoxSelectedAction
            // 
            this.groupBoxSelectedAction.Controls.Add(this.textBoxGroup);
            this.groupBoxSelectedAction.Controls.Add(this.buttonRUN);
            this.groupBoxSelectedAction.Controls.Add(this.textBoxActionName);
            this.groupBoxSelectedAction.Controls.Add(this.textBoxActionLabel);
            this.groupBoxSelectedAction.Controls.Add(this.checkBoxActionEnabled);
            this.groupBoxSelectedAction.Controls.Add(this.textBoxActionType);
            this.groupBoxSelectedAction.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.groupBoxSelectedAction.Location = new System.Drawing.Point(245, 93);
            this.groupBoxSelectedAction.Name = "groupBoxSelectedAction";
            this.groupBoxSelectedAction.Size = new System.Drawing.Size(445, 193);
            this.groupBoxSelectedAction.TabIndex = 45;
            this.groupBoxSelectedAction.TabStop = false;
            this.groupBoxSelectedAction.Text = "Selected Action";
            // 
            // groupBoxActionSet
            // 
            this.groupBoxActionSet.Controls.Add(this.radioButtonBAUActions);
            this.groupBoxActionSet.Controls.Add(this.radioButtonMaintenanceActions);
            this.groupBoxActionSet.Controls.Add(this.radioButtonShellActions);
            this.groupBoxActionSet.Controls.Add(this.radioButtonCustomActions);
            this.groupBoxActionSet.Controls.Add(this.radioButtonAllActions);
            this.groupBoxActionSet.Location = new System.Drawing.Point(12, 27);
            this.groupBoxActionSet.Name = "groupBoxActionSet";
            this.groupBoxActionSet.Size = new System.Drawing.Size(678, 50);
            this.groupBoxActionSet.TabIndex = 46;
            this.groupBoxActionSet.TabStop = false;
            this.groupBoxActionSet.Text = "Action Set";
            // 
            // radioButtonBAUActions
            // 
            this.radioButtonBAUActions.AutoSize = true;
            this.radioButtonBAUActions.Location = new System.Drawing.Point(197, 19);
            this.radioButtonBAUActions.Name = "radioButtonBAUActions";
            this.radioButtonBAUActions.Size = new System.Drawing.Size(47, 17);
            this.radioButtonBAUActions.TabIndex = 44;
            this.radioButtonBAUActions.Text = "BAU";
            this.radioButtonBAUActions.UseVisualStyleBackColor = false;
            this.radioButtonBAUActions.Click += new System.EventHandler(this.radioButtonBAUActions_Click);
            // 
            // radioButtonMaintenanceActions
            // 
            this.radioButtonMaintenanceActions.AutoSize = true;
            this.radioButtonMaintenanceActions.Location = new System.Drawing.Point(287, 19);
            this.radioButtonMaintenanceActions.Name = "radioButtonMaintenanceActions";
            this.radioButtonMaintenanceActions.Size = new System.Drawing.Size(87, 17);
            this.radioButtonMaintenanceActions.TabIndex = 43;
            this.radioButtonMaintenanceActions.Text = "Maintenance";
            this.radioButtonMaintenanceActions.UseVisualStyleBackColor = false;
            this.radioButtonMaintenanceActions.Click += new System.EventHandler(this.radioButtonMaintenanceActions_Click);
            // 
            // AppRunnerForm
            // 
            this.AcceptButton = this.buttonCLOSE;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(704, 361);
            this.Controls.Add(this.groupBoxActionSet);
            this.Controls.Add(this.listBoxActions);
            this.Controls.Add(this.buttonCLOSE);
            this.Controls.Add(this.menuStrip1);
            this.Controls.Add(this.groupBoxSelectedAction);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MainMenuStrip = this.menuStrip1;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "AppRunnerForm";
            this.Text = "FlexAdmin - RUN";
            this.Load += new System.EventHandler(this.AppRunnerForm_Load);
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.groupBoxSelectedAction.ResumeLayout(false);
            this.groupBoxSelectedAction.PerformLayout();
            this.groupBoxActionSet.ResumeLayout(false);
            this.groupBoxActionSet.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button buttonCLOSE;
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
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemActionsRewrite;
        private System.Windows.Forms.RadioButton radioButtonCustomActions;
        private System.Windows.Forms.RadioButton radioButtonAllActions;
        private System.Windows.Forms.RadioButton radioButtonShellActions;
        private System.Windows.Forms.TextBox textBoxActionLabel;
        private System.Windows.Forms.Button buttonRUN;
        private System.Windows.Forms.CheckBox checkBoxActionEnabled;
        private System.Windows.Forms.TextBox textBoxActionType;
        private System.Windows.Forms.TextBox textBoxActionName;
        private System.Windows.Forms.ListBox listBoxActions;
        private System.Windows.Forms.TextBox textBoxGroup;
        private System.Windows.Forms.GroupBox groupBoxSelectedAction;
        private System.Windows.Forms.GroupBox groupBoxActionSet;
        private System.Windows.Forms.RadioButton radioButtonBAUActions;
        private System.Windows.Forms.RadioButton radioButtonMaintenanceActions;
    }
}