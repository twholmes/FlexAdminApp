using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.IO.Compression;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using Microsoft.Win32;
using Microsoft.CSharp;
using System.CodeDom.Compiler;
using System.Diagnostics;
using System.Reflection;

namespace BlackBox
{
  #region Class SqlRunner
  /// <summary>
  /// This class provides a generic interface to the ManageSoft database.
  /// </summary>
  public class DatabaseLayer
  {
    #region Constants

    private const string c_ReporterRegistryKey = "Software\\ManageSoft Corp\\ManageSoft\\Reporter\\CurrentVersion";
    private const string c_ConnectionStringRegistryName = "DatabaseConnectionString";

    #endregion

    #region

    private string _DatabaseConnectionString;

    #endregion

    #region Constructor

    /// <summary>
    /// Default constructor
    /// </summary>
    
    public DatabaseLayer()
    {
      RegistryKey rootKey = Registry.LocalMachine;
      RegistryKey connectionStringKey = rootKey.OpenSubKey(c_ReporterRegistryKey);
      SetDatabaseConnectionString((string)connectionStringKey.GetValue(c_ConnectionStringRegistryName));
      connectionStringKey.Close();
    }
    
    public DatabaseLayer(string cs)
    {
      SetDatabaseConnectionString(cs);
    }

    #endregion

    #region Public Methods

    /// <summary>
    /// Execute a SQL script
    /// </summary>
    /// <param name="script"></param>
    public void ExecuteSQLScript(string sqlFileName, string logFileName)
    {     
      string sqlcmdexe = @"C:\Program Files\Microsoft SQL Server\110\Tools\Binn\SQLCMD.EXE";
      string args = string.Format("-S FLEXAPP -d FNMP -E -w1000 -e -i {0} -o {1}", sqlFileName, logFileName);
      //
      ProcessStartInfo startInfo = new ProcessStartInfo();
      startInfo.FileName = sqlcmdexe;
      startInfo.Arguments = args;
      //startInfo.WindowStyle = ProcessWindowStyle.Hidden;
      //startInfo.ErrorDialog = false;
      //startInfo.WorkingDirectory = Path.GetDirectoryName(batchFileName);
      startInfo.UseShellExecute = false;
      startInfo.CreateNoWindow = true;
      startInfo.RedirectStandardError = true;
      startInfo.RedirectStandardOutput = true;
      int timeToWait = 50000;
      try
      {
        using (Process proc = new Process())
        {
          proc.StartInfo = startInfo;
          bool started = proc.Start();
          if (started)
          {
            bool completed = proc.WaitForExit(timeToWait);
            if (!completed)            
            {
              // Console.WriteLine("Timeout");                    
            }
            else
            {
              if (proc.ExitCode != 0) 
              {
                //Console.WriteLine("Failed");
              }
            }
          }
        }
      }
      catch (Exception ex)
      {
        throw ex;
      }
      finally
      {
      }
    }

    /// <summary>
    /// Execute a SQL command
    /// </summary>
    /// <param name="SQLCmd"></param>
    public void ExecuteSQLCmd(string SQLCmd)
    {
      SqlConnection con = new SqlConnection(_DatabaseConnectionString);
      try
      {
        SqlCommand cmd = new SqlCommand(SQLCmd, con);
        cmd.Connection.Open();
        cmd.ExecuteNonQuery();
        cmd.Connection.Close();
      }
      catch (Exception e)
      {
        throw e;
      }
      finally
      {
        if (con.State != System.Data.ConnectionState.Closed)
        {
          con.Close();
        }
      }
    }
   
    /// <summary>
    /// Execute an SQL command that returns a single value
    /// </summary>
    /// <param name="p_Query"></param>
    /// <returns></returns>
    public string ExecuteSQLQuerySingleValue(string p_Query)
    {
      string strResult = string.Empty;
      //
      SqlConnection con = new SqlConnection(_DatabaseConnectionString);
      SqlDataReader Res = null;
      try
      {
        SqlCommand cmd = new SqlCommand(p_Query, con);
        cmd.Connection.Open();
        Res = cmd.ExecuteReader();
        if (Res.Read())
        {
          strResult = Res[0].ToString();
        }
        Res = null;
        cmd.Connection.Close();
      }
      catch (Exception e)
      {
        throw e;
      }
      finally
      {
        if (con.State != System.Data.ConnectionState.Closed)
        {
          con.Close();
        }
      }
      return strResult;
    }
   
    /// <summary>
    /// Execute an SQL command that returns a single row of data.
    /// </summary>
    /// <param name="p_Query"></param>
    /// <returns></returns>
    public Dictionary<string, string> ExecuteSQLQuerySingleRow(string p_Query)
    {
      Dictionary<string, string> Result = new Dictionary<string, string>();
      //
      SqlConnection con = new SqlConnection(_DatabaseConnectionString);
      SqlDataReader Res = null;
      try
      {
        SqlCommand cmd = new SqlCommand(p_Query, con);
        cmd.Connection.Open();
        Res = cmd.ExecuteReader();
        if (Res.Read())
        {
          for (int i = 0; i < Res.FieldCount; i++)
          {
            Result.Add(Res.GetName(i), Res.GetValue(i).ToString());
          }
        }
        Res = null;
        cmd.Connection.Close();
      }
      catch (Exception e)
      {
        throw e;
      }
      finally
      {
        if (con.State != System.Data.ConnectionState.Closed)
          con.Close();
      }
      return Result;
    }
   
    /// <summary>
    /// Execute an SQL command that returns multiple rows with one column.
    /// </summary>
    /// <param name="p_Query"></param>
    /// <returns></returns>
    public List<string> ExecuteSQLQuerySingleColumn(string p_Query)
    {
      List<string> Result = new List<string>();
      //
      SqlConnection con = new SqlConnection(_DatabaseConnectionString);
      SqlDataReader Res = null;
   
      try
      {
        SqlCommand cmd = new SqlCommand(p_Query, con);
        cmd.Connection.Open();
        Res = cmd.ExecuteReader();
        while (Res.Read())
        {
          Result.Add(Res.GetValue(0).ToString());
        }
        Res = null;
        cmd.Connection.Close();
      }
      catch (Exception e)
      {
        throw e;
      }
      finally
      {
        if (con.State != System.Data.ConnectionState.Closed)
        {
          con.Close();
        }
      }
      return Result;
    }
   
    /// <summary>
    /// Execute an SQL command that returns a data table.
    /// </summary>
    /// <param name="p_Query"></param>
    /// <returns></returns>
    public DataTable ExecuteSQLQueryDataTable(string p_Query)
    {
      DataTable Result = new DataTable();
   
      SqlConnection con = new SqlConnection(_DatabaseConnectionString);
      SqlDataReader Res = null;
   
      try
      {
        SqlCommand cmd = new SqlCommand(p_Query, con);
        cmd.Connection.Open();
        Res = cmd.ExecuteReader();
        Result.Load(Res);
        Res = null;
        cmd.Connection.Close();
      }
      catch (Exception e)
      {
        throw e;
      }
      finally
      {
        if (con.State != System.Data.ConnectionState.Closed)
        {
          con.Close();
        }
      }
      return Result;
    }
   
    /// <summary>
    /// Execute a SQL bulk copy command
    /// </summary>
    /// <param name="SQLCmd"></param>
    public void ExecuteSQLBulkCopy(string name, DataTable dt)
    {
      SqlConnection con = new SqlConnection(_DatabaseConnectionString);
      try
      {
        con.Open();
        //creating object of SqlBulkCopy  
        SqlBulkCopy objbulk = new SqlBulkCopy(con);  
        //assigning Destination table name  
        objbulk.DestinationTableName = "dbo." + name;  
        //Mapping Table column
        foreach (DataColumn dc in dt.Columns)
        {
          objbulk.ColumnMappings.Add(dc.ColumnName, dc.ColumnName);
        }          
        //inserting bulk Records into DataBase   
        objbulk.WriteToServer(dt);
      }
      catch (Exception e)
      {
        throw e;
      }
      finally
      {
        if (con.State != System.Data.ConnectionState.Closed)
        {
          con.Close();
        }
      }
    }
   
    #endregion
   
    #region Private Methods
   
    /// <summary>
    /// Set the database connection string
    /// </summary>
    /// <param name="p_DatabaseConnectionString"></param>
    private void SetDatabaseConnectionString(string p_DatabaseConnectionString)
    {
      string databaseConnectionString = p_DatabaseConnectionString;
      //
      // Strip off driver or provider part if it is in the connection string
      int DriverStart = databaseConnectionString.ToLower().IndexOf("driver");
      if (DriverStart == -1)
      {
        DriverStart = databaseConnectionString.ToLower().IndexOf("provider");
      }
      if (DriverStart > -1)
      {
        int DriverEnd = databaseConnectionString.IndexOf(";");
        if (DriverEnd > -1)
        {
          databaseConnectionString = databaseConnectionString.Remove(
            DriverStart, DriverEnd - DriverStart + 1
          );
        }
        else
        {
          databaseConnectionString = databaseConnectionString.Remove(
            DriverStart, databaseConnectionString.Length - DriverStart
          );
        }
      }
      _DatabaseConnectionString = databaseConnectionString;
    }
   
    #endregion
  }
  
  #endregion

}
