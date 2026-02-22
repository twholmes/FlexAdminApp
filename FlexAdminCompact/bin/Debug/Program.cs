using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Reflection;

[assembly: AssemblyTitle("FlexAdmin")]
[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]
[assembly: AssemblyDescription("Run FlexAdmin scripting Framework")]
[assembly: AssemblyConfiguration("")]
[assembly: AssemblyCompany("Crayon Australia")]
[assembly: AssemblyProduct("FlexAdmin")]
[assembly: AssemblyCopyright("Copyright ©  2019 Crayon Auatralia")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]

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
        Application.Run(new AppForm(appname));
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
    public const bool c_Locked = false;
    public const bool c_RequirePassword = false;
    public const string c_Password = "crayon";

    // modes
    public const bool c_RunFromTemp = false;
    public const string c_RunFromLocation = "local";

    // unpack
    public const bool c_UnpackSource = true;
    public const bool c_UnpackScripts = true;
    public const bool c_UnpackPayload = true;
    public const bool c_UnpackImplFiles = true;
    public const bool c_UnpackVisualStudio = true;
    public const bool c_UnpackEvents = true;

    public const bool c_UnpackUnzip = false;

    // events
    public const bool c_EventsOnly = false;
    public const bool c_EventBUILD = false;
    public const bool c_EventUNPACK = false;
    public const bool c_EventDROP = false;
    public const bool c_EventPRE = false;
    public const bool c_EventPOST = false;
    public const bool c_EventEXIT = false;

    // logging constants
    public const string c_LogFolder = @"";
    public const string c_LogFile = @"";

    // sql constants
    public const string c_Server = "localhost";
    public const string c_Database = "FNMSCompliance";
    public const string c_ConnectionString = "";

  }
}
