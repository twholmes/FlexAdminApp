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
  #region Logger class 
  /// <summary>
  /// The class provides static methods for writing to the log file.
  /// Its Init static method must be called before any logs are written.
  /// </summary>

  public class Logger
  {
    #region Constants

    /// <summary>
    /// Logging level definitions
    /// </summary>
    const int c_LogLevelSilent = 0; 
    const int c_LogLevelDefault = 1;
    const int c_LogLevelDebug = 2;    

    /// <summary>
    /// Default maximum log file size.
    /// </summary>
    const int c_DefaultMaxLogFileSize = 10 * 1024 * 1024; 

    /// <summary>
    /// The default name for the Crayon log file.
    /// </summary>
    const string c_DefaultLogFileName = "Crayon.log";

    #endregion

    #region Public Static Members

    /// <summary>
    /// Path to the log file.
    /// </summary>
    public static int LogLevel;

    /// <summary>
    /// Path to the log file.
    /// </summary>
    public static string LogFile;

    /// <summary>
    /// Path to which the log file will be moved when its size exceeds
    /// the value of MaxLogFileSize
    /// </summary>
    public static string LogFileOld;

    /// <summary>
    /// Set to true if the log file is to be moved to LogFileOld when its size 
    /// has surpassed the value of MaxLogFileSize.
    /// </summary>
    public static bool AutoRollLogFile = true;

    /// <summary>
    /// The maximum size (bytes) of the log file before it will be rolled.
    /// </summary>
    public static long MaxLogFileSize;

    /// <summary>
    /// Prefix for each log message.
    /// </summary>
    public static string Prefix;

    #endregion

    #region Private Static Members

    /// <summary>
    /// This mutex is used to lock access to the log file.
    /// It is necessary as multiple processes will write to 
    /// this log file.
    /// </summary>
    private static Mutex _Mutex;

    #endregion

    #region Public Static Methods

    /// <summary>
    /// This method initialises the logger allowing the caller to specify the 
    /// location of the log file.
    /// </summary>
    /// <param name="paramLogFileName"></param>
    /// <param name="paramAutoRollLogFile"></param>
    /// <param name="paramMaxLogFileSize">Ignored if paramAutoRollLogFile is false.</param>
    /// <param name="paramSourceName"></param>
    public static void Init(string paramLogFileName, bool paramAutoRollLogFile, long paramMaxLogFileSize, string paramPrefix, int paramLogLevel)
    {
      if (String.IsNullOrEmpty(paramLogFileName))
      {
        throw new Exception("No log file has been specified");
      }
      LogLevel = paramLogLevel;
      
      AutoRollLogFile = paramAutoRollLogFile;
      MaxLogFileSize = paramMaxLogFileSize;
            
      LogFile = Path.Combine(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location), paramLogFileName);

      // Create a mutex so that this log can be shared amongst multiple threads
      // and processes.
      string newMutexName = "CrayonModuleLogFile";
      _Mutex = new Mutex(false, newMutexName);

      Prefix = paramPrefix;
      LogFileOld = LogFile + ".old";

      // Check if the log file needs to be rolled
      if (AutoRollLogFile)
      {
        RollLogFile();
      }
    }

    public static void Init(string paramLogFileName, int paramLogLevel)
    { 
      Init(paramLogFileName, true, c_DefaultMaxLogFileSize, "", paramLogLevel);
    }

    public static void Init()
    {
      Init(c_DefaultLogFileName, true, c_DefaultMaxLogFileSize, "", c_LogLevelDefault);
    }
    
    /// <summary>
    /// Set the LogLevel
    /// </summary>
    public static void SetLogLevelSilent()
    {
      LogLevel = c_LogLevelSilent;
    }

    public static void SetLogLevelDefault()
    {
      LogLevel = c_LogLevelDefault;
    }
    
    public static void SetLogLevelDebug()
    {
      LogLevel = c_LogLevelDebug;
    }

    /// <summary>
    /// Write log to the log file.
    /// </summary>
    /// <param name="strMessage"></param>
    public static bool WriteDebugLog(string strMessage)
    {
      return WriteLog(strMessage, c_LogLevelDebug);
    }

    /// <summary>
    /// Write log to the log file.
    /// </summary>
    /// <param name="strMessage"></param>
    public static bool WriteLog(string strMessage)
    {
      return WriteLog(strMessage, c_LogLevelDefault);
    }

    /// <summary>
    /// Write log to the log file.
    /// </summary>
    /// <param name="strMessage"></param>
    /// <param name="LogLevel"></param>
    public static bool WriteLog(string strMessage, int level)
    {
      bool haveMutex = false;
      try
      {
        // Wait to get access to the log
        _Mutex.WaitOne();
        haveMutex = true;
        if (level <= LogLevel)
        {
          DateTime dt = DateTime.Now;
          string message = string.Format("{0} :: {1} {2}", dt.ToString("yyyy-MM-dd HH:mm:ss"), Prefix, strMessage);

          // Write the message to the log file
          FileStream logStream = File.Open(LogFile, FileMode.Append, FileAccess.Write, FileShare.ReadWrite);
          StreamWriter logWriter = new StreamWriter(logStream);
          logWriter.AutoFlush = true;
          logWriter.WriteLine(message);
          logWriter.Close();
        }
      }
      catch
      {
        return false;
      }
      finally
      {
        // Release the mutex
        if (haveMutex) { _Mutex.ReleaseMutex(); }
      }
      return true;
    }

    /// <summary>
    /// Writes a log entry that has two replaceable parameters.
    /// </summary>
    /// <param name="strMessage"></param>
    /// <param name="arg0"></param>
    /// <param name="arg1"></param>
    /// <param name="strSource"></param>
    /// <returns></returns>
    public static bool WriteLog(string strMessage, string strSource, int level)
    {
      return Logger.WriteLog(string.Format("Source [{0}]: {1}", strSource, strMessage), level);
    }

    public static bool WriteLog(string strMessage, string arg0, string strSource, int level)
    {
      return WriteLog(string.Format(strMessage, arg0), strSource, level);
    }

    public static bool WriteLog(string strMessage, string arg0, string arg1, string strSource, int level) 
    {
      return WriteLog(string.Format(strMessage, arg0, arg1), strSource, level);
    }
    
    /// <summary>
    /// Writes a log entry that has two replaceable parameters.
    /// </summary>
    /// <param name="strMessage"></param>
    /// <param name="arg0"></param>
    /// <param name="arg1"></param>
    /// <param name="strSource"></param>
    /// <returns></returns>

    public static bool WriteThreadLog(string strMessage, string strSource, int level) 
    {
      string log = string.Format("Source [{0}]: {1}", strSource, strMessage);     
      return Logger.WriteLog(log, level);
    }

    public static bool WriteThreadLog(string strMessage, string arg0, string strSource, int level) 
    {
      return WriteLog(string.Format(strMessage, arg0), strSource, level);
    }

    public static bool WriteThreadLog(string strMessage, string arg0, string arg1, string strSource, int level) 
    {
      return WriteLog(string.Format(strMessage, arg0, arg1), strSource, level);
    }

    #endregion

    #region Private static Methods

    /// <summary>
    /// This method rolls the log file if its size is larger than the value
    /// of MaxLogFileSize.
    /// </summary>
    public static void RollLogFile()
    {
      bool haveMutex = false;
      try
      {
        // Wait to get access to the log
        _Mutex.WaitOne();
        haveMutex = true;

        if (File.Exists(LogFile))
        {
          FileInfo logFileInfo = new FileInfo(LogFile);
          long logFileSize = logFileInfo.Length;
          if (logFileSize > MaxLogFileSize)
          {
            if (File.Exists(LogFileOld))
            {
              File.Delete(LogFileOld);
            }
            File.Move(LogFile, LogFileOld);
          }
        }
      }
      catch
      {
        // Do nothing.  Failure to roll the log should not prevent the application from running.
      }
      finally
      {
        // Release the mutex
        if (haveMutex) { _Mutex.ReleaseMutex(); }
      }

    }

    #endregion    
  }

  #endregion

}
