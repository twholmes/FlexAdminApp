using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Reflection;

namespace Crayon 
{
  static class Program
  {
    [STAThread]
    static void Main()
    {
      try
      {
        Assembly ass = Assembly.GetExecutingAssembly();     
        string[] nameparts = ass.GetName().Name.ToString().Split('_');      
        string appname = nameparts[0]; 
        //      
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        Application.Run(new AppCompactForm(appname));
      }
      catch (Exception ex)
      {
        MessageBox.Show(ex.Message, "FlexAdmin(main)", MessageBoxButtons.OK, MessageBoxIcon.Error);
      }
    }
  }
  
  static partial class AppSettings
  { 
    // locking
    public const bool c_Locked = true;
    public const bool c_RequirePassword = false;
    public const string c_Password = "crayon";
    //
    // general
    public const bool c_CheckPayload = false;    
    //
    // modes    
    public const bool c_DragAndDrop = false;
    public const bool c_RunFromTemp = true;
    public const string c_RunFromLocation = "temp";    
    //
    // unpack
    public const bool c_UnpackHelp = true;    
    public const bool c_UnpackScripts = true;
    public const bool c_UnpackImplFiles = true;
    public const bool c_UnpackPayload = true;    
    public const bool c_UnpackEvents = true;
    public const bool c_UnpackSource = false;    
    public const bool c_UnpackVisualStudio = false;
    //           
    public const bool c_UnpackUnzip = false;
    //
    // events
    public const bool c_EventsOnly = false;
    //
    public const bool c_EventBUILD = false;    
    public const bool c_EventUNPACK = false;
    public const bool c_EventDROP = false;        
    public const bool c_EventPRE = false;
    public const bool c_EventPOST = false;
    public const bool c_EventEXIT = false;          
    //      
    // logging settings
    public const string c_LogFolder = "C:\\LogFiles";
    public const string c_LogFile = "";    
    //
    // sql constants 
    public const string c_Server = "localhost";   
    public const string c_Database = "FNMSCompliance";        
    public const string c_ConnectionString = "Data Source=localhost;Initial Catalog=FNMSCompliance;Integrated Security=true";
 
  }  
  
}
