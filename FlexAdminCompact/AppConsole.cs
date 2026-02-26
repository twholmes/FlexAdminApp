using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.IO.Compression;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using System.Xml;
using System.Xml.Serialization;

using Microsoft.CSharp;
using System.Threading;
using System.Threading.Tasks;
using System.CodeDom.Compiler;
using System.Diagnostics;
using System.Reflection;

namespace BlackBox
{
  #region Class AppConsole

  /// <summary>
  /// Summary description for AppConsole class
  /// </summary>    
  public static class AppConsole
  {
    #region Data    
    // ******************************************************
    // public static data
    // ******************************************************
        
    public static System.Windows.Forms.ListBox listBoxConsole = null;
 
    #endregion
 
    #region Accessors   
    // ******************************************************
    // public accessors
    // ******************************************************
    

    #endregion

    #region Console initialisation methods
    // ******************************************************
    // console initialisation methods
    // ******************************************************

    public static bool Register(ListBox lbConsole)
    {
      listBoxConsole = lbConsole;
      return true;
    }

    #endregion

    #region Console methods
    // ******************************************************
    // console methods
    // ******************************************************

    public static bool Clear()
    {
      if (listBoxConsole != null)
      {
        listBoxConsole.Items.Clear();
      }
      return true;
    }

    public static bool Write(string message)
    {
      Logger.WriteLog(String.Format("Console: {0}", message));
      if (listBoxConsole != null)
      {
        listBoxConsole.Items.Add(message);
        listBoxConsole.TopIndex = listBoxConsole.Items.Count - 1;
      }
      return true;
    }

    public static bool ScrollToBottom()
    {
      if (listBoxConsole != null)
      {
        listBoxConsole.TopIndex = listBoxConsole.Items.Count - 1;
      }
      return true;
    }

    #endregion
    
  }

  #endregion

}
