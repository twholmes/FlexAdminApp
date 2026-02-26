using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace BlackBox
{
  #region Class AppEnterForm
  /// <summary>
  /// Summary description for AppEnterForm class
  /// </summary>    
  public partial class AppEnterForm : System.Windows.Forms.Form
  {
    #region AppEnterForm data    
    // ******************************************************
    // public data
    // ******************************************************     
 
    public string[] list;
 
    public string message = String.Empty; 
    public string value = String.Empty;    
     
    #endregion

    #region AppEnterForm constructors
    // ******************************************************
    // constructors
    // ******************************************************
     	
    public AppEnterForm()
    {
      InitializeComponent();
    }

    #endregion
  
    #region AppSettingsForm event handlers
    // ******************************************************
    // dialog event handlers
    // ******************************************************

    private void AppEnterForm_Load(object sender, EventArgs e)
    {
    	this.labelMessage.Text = this.message;
    	//this.textBoxValue.Text = this.value;
    	this.comboBoxValue.Text = this.value;    	
    	//
      comboBoxValue.Items.Clear();
      foreach (string value in list)
      {
        comboBoxValue.Items.Add(value);
      }    	
    }

    private void AppEnterForm_FormClosing(object sender, FormClosingEventArgs e)
    {
    }

    // ******************************************************
    // dialog event handlers
    // ******************************************************

    private void buttonOK_Click(object sender, EventArgs e)
    {
    	//this.value = this.textBoxValue.Text;
    	this.value = this.comboBoxValue.Text;    	
      this.DialogResult = DialogResult.OK;
      this.Close();
    }

    private void buttonCancel_Click(object sender, EventArgs e)
    {
      this.DialogResult = DialogResult.Cancel;
      this.Close();
    }

    #endregion

  #endregion
  
  }
}
