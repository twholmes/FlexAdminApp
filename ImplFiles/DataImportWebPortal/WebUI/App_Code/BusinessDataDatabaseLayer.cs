// Copyright (C) 2015-2017 Flexera Software

using System.Data;
using System.Data.SqlClient;

public class BusinessDataDatabaseLayer
{
	private const int cCommandTimeoutInSeconds = 60; // We expect all commands executed by this module to complete within 60 seconds

	/// <summary>Helper method to open a SQL connection and execute a command on it.</summary>
	///
	/// <example>For example usage, see implementation of the ExecuteStoredProcedure and ExecuteQuery methods.</example>
	private static T DoSQLCommand<T>(CommandType commandType, string commandText, System.Collections.Generic.Dictionary<string, object> parameters, System.Func<IDbCommand, T> runner)
	{
		using (ManageSoft.Database.API.IDatabaseLayer db = ManageSoft.Compliance.Database.Impl.ComplianceDatabaseLayerFactory.Create(null, "FlexNet Manager Suite Data Import Web Portal"))
		{
			db.ConnectionOpen();
			using (ManageSoft.Database.DatabaseCommand cmd = db.DatabaseConnection.CreateCommand())
			{
				cmd.CommandType = commandType;
				cmd.CommandText = commandText;
				cmd.CommandTimeout = cCommandTimeoutInSeconds;

				if (parameters != null)
				{
					foreach (var p in parameters)
						cmd.Parameters.Add(p.Key, p.Value);
				}

				return runner(cmd.DbCommand);
			}
		}
	}

	/// <summary>
	/// Execute a SQL stored procedure, returning no result.
	/// </summary>
	/// <param name="storedProcedureName"></param>
	/// <param name="parameters"></param>
	public static void ExecuteStoredProcedure(string storedProcedureName, System.Collections.Generic.Dictionary<string, object> parameters = null)
	{
		DoSQLCommand<int>(CommandType.StoredProcedure, storedProcedureName, parameters, cmd => {
			return cmd.ExecuteNonQuery();
		});
	}

	/// <summary>
	/// Execute a SQL query, returning a DataSet result.
	/// </summary>
	/// <param name="queryText"></param>
	/// <param name="parameters"></param>
	public static System.Data.DataSet ExecuteQuery(string queryText, System.Collections.Generic.Dictionary<string, object> parameters = null)
	{
		return DoSQLCommand<System.Data.DataSet>(CommandType.Text, queryText, parameters, cmd => {
			var da = new SqlDataAdapter();
			da.SelectCommand = cmd as SqlCommand; // This won't work if ever a non-SQL Server database backend is used

			var result = new System.Data.DataSet();
			da.Fill(result);

			return result;
		});
	}


	/// <summary>
	/// Execute a SQL query, returning a single-valued result.
	/// </summary>
	/// <param name="queryText"></param>
	/// <param name="parameters"></param>
	public static object ExecuteQuerySingleValue(string queryText, System.Collections.Generic.Dictionary<string, object> parameters = null)
	{
		return DoSQLCommand<object>(CommandType.Text, queryText, parameters, cmd => {
			IDataReader result = cmd.ExecuteReader();
			return result.Read() ? result[0] : null;
		});
	}
}
